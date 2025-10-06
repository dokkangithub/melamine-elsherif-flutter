import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../data/search/models/search_suggestion_model.dart';
import '../../../domain/product/entities/product.dart';
import '../../../domain/search/usecases/get_filtered_products_use_case.dart';
import '../../../domain/search/usecases/get_search_suggestions_use_case.dart';

class SearchProvider extends ChangeNotifier {
  final GetSearchSuggestionsUseCase getSearchSuggestionsUseCase;
  final GetFilteredProductsUseCase getFilteredProductsUseCase;

  // Search suggestions state
  LoadingState suggestionState = LoadingState.initial;
  List<SearchSuggestion> suggestions = [];
  List<SearchSuggestion> cachedEmptySuggestions =
      []; // Cache for empty query suggestions
  String currentQuery = '';
  String errorMessage = '';
  Timer? _debounce;

  // Filtered products state
  List<Product> filteredProducts = [];
  List<Product> cachedInitialProducts = []; // Cache for initial products
  LoadingState filteredProductsState = LoadingState.initial;
  bool hasMoreFilteredProducts = false;
  int currentPage = 1;

  // Cache state
  bool _hasInitialSuggestionsCache = false;
  bool _hasInitialProductsCache = false;

  SearchProvider({
    required this.getSearchSuggestionsUseCase,
    required this.getFilteredProductsUseCase,
  });

  void onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    currentQuery = query;

    if (query.isEmpty) {
      // Use cached suggestions if available
      if (_hasInitialSuggestionsCache) {
        suggestions = cachedEmptySuggestions;
        suggestionState = LoadingState.loaded;
        notifyListeners();
      } else {
        suggestions = [];
        suggestionState = LoadingState.initial;
      }

      // Use cached initial products if available
      if (_hasInitialProductsCache) {
        restoreInitialProducts();
      } else {
        clearFilteredProducts(); // Clear results when search is empty
      }

      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchSearchSuggestions(query);
      // Also fetch filtered products when query changes (after debounce)
      fetchFilteredProducts(refresh: true, name: query);
    });
  }

  Future<void> fetchSearchSuggestions(String query) async {
    // If we're requesting empty query suggestions and already have them cached, use the cache
    if (query.isEmpty && _hasInitialSuggestionsCache) {
      suggestions = cachedEmptySuggestions;
      suggestionState = LoadingState.loaded;
      notifyListeners();
      return;
    }

    suggestionState = LoadingState.loading;
    notifyListeners();

    try {
      final rawSuggestions = await getSearchSuggestionsUseCase(query);
      // Filter out partial words and keep only complete words
      suggestions = _filterCompleteWords(rawSuggestions);
      suggestionState = LoadingState.loaded;

      // Cache empty query suggestions
      if (query.isEmpty) {
        cachedEmptySuggestions = List.from(suggestions);
        _hasInitialSuggestionsCache = true;
      }
    } catch (e) {
      suggestionState = LoadingState.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  List<SearchSuggestion> _filterCompleteWords(List<SearchSuggestion> rawSuggestions) {
    return rawSuggestions.where((suggestion) {
      final query = suggestion.query.toLowerCase().trim();
      
      // Skip empty queries
      if (query.isEmpty) return false;
      
      // Skip queries that are too short (less than 4 characters for better filtering)
      if (query.length < 4) return false;
      
      // Skip single Arabic letters (common partial words)
      if (query.length == 1 && RegExp(r'[أ-ي]').hasMatch(query)) {
        return false;
      }
      
      final arabicPartialWords = [
        'م', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'ن', 'ه', 'و', 'ي',
        'مي', 'ميل', 'ميلا', 'ميلام', 'بيت', 'بيتر', 'طقم', 'طق', 'طب', 'طا', 'طب', 'طق'
      ];
      
      if (arabicPartialWords.contains(query)) {
        return false;
      }
      
      final partialIndicators = ['...', '..', '.', '-', '_', '...', '…'];
      if (partialIndicators.any((indicator) => query.endsWith(indicator))) {
        return false;
      }
      
      // Skip queries that start with common partial word indicators
      if (partialIndicators.any((indicator) => query.startsWith(indicator))) {
        return false;
      }
      
      // Skip queries that contain only numbers and special characters
      if (RegExp(r'^[0-9\s\-_\.]+$').hasMatch(query)) {
        return false;
      }
      
      // Skip words that appear to be prefixes of longer words (common in Arabic)
      if (query.length < 5 && RegExp(r'^[أ-ي]+$').hasMatch(query)) {
        // Check if this might be a prefix of a longer word
        final possiblePrefixes = ['ميل', 'ميلا', 'ميلام', 'بيت', 'بيتر', 'طقم'];
        if (possiblePrefixes.any((prefix) => prefix.startsWith(query) && prefix != query)) {
          return false;
        }
      }
      
      // Keep complete words that contain letters and have meaningful length
      return RegExp(r'[a-zA-Zأ-ي]').hasMatch(query) && query.length >= 4;
    }).toList();
  }

  Future<void> fetchFilteredProducts({
    bool refresh = false,
    String? name,
    String? sortKey,
    String? brands,
    String? categories,
    double? min,
    double? max,
  }) async {
    // If requesting initial products and we have a cache, use it
    if (refresh && (name == null || name.isEmpty) && _hasInitialProductsCache) {
      restoreInitialProducts();
      return;
    }

    // Reset page if refreshing
    if (refresh) {
      currentPage = 1;
      filteredProducts = [];
    }

    // Set loading state
    filteredProductsState = LoadingState.loading;
    notifyListeners();

    try {
      final result = await getFilteredProductsUseCase(
        currentPage,
        name: name ?? currentQuery,
        sortKey: sortKey,
        brands: brands,
        categories: categories,
        min: min,
        max: max,
      );

      // Add new products to the list
      if (refresh) {
        filteredProducts = result.data;

        // Cache initial results (when no search query)
        if (name == null || name.isEmpty) {
          cachedInitialProducts = List.from(result.data);
          _hasInitialProductsCache = true;
        }
      } else {
        filteredProducts.addAll(result.data);
      }

      // Check if there are more pages
      hasMoreFilteredProducts = currentPage < result.meta.lastPage;
      if (hasMoreFilteredProducts) {
        currentPage++;
      }

      // Update state
      filteredProductsState = LoadingState.loaded;
    } catch (e) {
      filteredProductsState = LoadingState.error;
      errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Method to restore initial products from cache
  void restoreInitialProducts() {
    filteredProducts = List.from(cachedInitialProducts);
    filteredProductsState = LoadingState.loaded;
    currentPage = 2; // Set to 2 since we've loaded the first page
    hasMoreFilteredProducts = true; // Assume there might be more
    notifyListeners();
  }

  // Method to clear search results
  void clearFilteredProducts() {
    filteredProducts = [];
    filteredProductsState = LoadingState.initial;
    currentPage = 1;
    hasMoreFilteredProducts = false;
    notifyListeners();
  }

  // Method to reset cache if needed (e.g., for refreshing stale data)
  void resetCache() {
    _hasInitialSuggestionsCache = false;
    _hasInitialProductsCache = false;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
