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
  String currentQuery = '';
  String errorMessage = '';
  Timer? _debounce;

  // Filtered products state
  List<Product> filteredProducts = [];
  LoadingState filteredProductsState = LoadingState.initial;
  bool hasMoreFilteredProducts = false;
  int currentPage = 1;

  SearchProvider({
    required this.getSearchSuggestionsUseCase,
    required this.getFilteredProductsUseCase,
  });

  void onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    currentQuery = query;

    if (query.isEmpty) {
      suggestions = [];
      suggestionState = LoadingState.initial;
      clearFilteredProducts(); // Clear results when search is empty
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
    suggestionState = LoadingState.loading;
    notifyListeners();

    try {
      suggestions = await getSearchSuggestionsUseCase(query);
      suggestionState = LoadingState.loaded;
    } catch (e) {
      suggestionState = LoadingState.error;
      errorMessage = e.toString();
    }

    notifyListeners();
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

  // Method to clear search results
  void clearFilteredProducts() {
    filteredProducts = [];
    filteredProductsState = LoadingState.initial;
    currentPage = 1;
    hasMoreFilteredProducts = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}