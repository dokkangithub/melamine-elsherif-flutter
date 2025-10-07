// lib/features/presentation/set products/controller/set_product_provider.dart

import 'package:flutter/material.dart';
import '../../../domain/set products/entities/set_products.dart';
import '../../../domain/set products/entities/set_products_response.dart';
import '../../../domain/set products/entities/set_product_details.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../domain/set products/usecases/get_set_products_use_case.dart';
import '../../../domain/set products/usecases/get_set_product_details_use_case.dart';
import '../../../domain/set products/usecases/get_related_set_products_use_case.dart';
import '../../../domain/set products/usecases/calculate_price_use_case.dart';
import '../../../domain/set products/usecases/add_full_set_to_cart_use_case.dart';
import '../../../domain/set products/usecases/add_custom_set_to_cart_use_case.dart';

class SetProductsProvider extends ChangeNotifier {
  final GetSetProductsUseCase getSetProductsUseCase;
  final GetSetProductDetailsUseCase getSetProductDetailsUseCase;
  final GetRelatedSetProductsUseCase getRelatedSetProductsUseCase;
  final CalculatePriceUseCase calculatePriceUseCase;
  final AddFullSetToCartUseCase addFullSetToCartUseCase;
  final AddCustomSetToCartUseCase addCustomSetToCartUseCase;

  SetProductsProvider({
    required this.getSetProductsUseCase,
    required this.getSetProductDetailsUseCase,
    required this.getRelatedSetProductsUseCase,
    required this.calculatePriceUseCase,
    required this.addFullSetToCartUseCase,
    required this.addCustomSetToCartUseCase,
  });

  // Set Products List State
  LoadingState setProductsState = LoadingState.loading;
  List<SetProduct> setProducts = [];
  String setProductsError = '';

  // Pagination properties
  int currentPage = 1;
  int? lastPage;
  int? total;
  bool hasMorePages = true;
  bool isLoadingMore = false;

  // Set Product Details State
  LoadingState setProductDetailsState = LoadingState.initial;
  SetProductDetailsData? setProductDetails;
  String setProductDetailsError = '';

  // Related Products State
  LoadingState relatedProductsState = LoadingState.initial;
  List<SetProduct> relatedProducts = [];
  String relatedProductsError = '';
  int? currentRelatedProductId;

  // Calculate Price State
  LoadingState calculatePriceState = LoadingState.initial;
  CalculatedPriceData? calculatedPrice;
  String calculatePriceError = '';

  // Add to Cart State
  LoadingState addToCartState = LoadingState.initial;
  String addToCartError = '';
  Map<String, dynamic>? addToCartResponse;

  Future<void> getSetProducts({bool isRefresh = false}) async {
    // If we already have data and it's not a refresh, don't reload
    if (!isRefresh && setProducts.isNotEmpty && setProductsState == LoadingState.loaded) {
      return;
    }
    
    try {
      if (isRefresh) {
        currentPage = 1;
        hasMorePages = true;
        setProducts.clear();
        setProductsError = '';
      }

      setProductsState = LoadingState.loading;
      notifyListeners();

      final SetProductsResponse response = await getSetProductsUseCase(
        page: currentPage,
        needUpdate: isRefresh,
      );


      if (isRefresh) {
        setProducts = response.products;
      } else {
        // This should not happen in normal flow, but if it does, add to existing products
        setProducts.addAll(response.products);
      }
      
      // Update currentPage from response
      if (response.currentPage != null) {
        currentPage = response.currentPage!;
      } else if (isRefresh) {
        currentPage = 1; // Fallback for refresh
      }

      // Update pagination info from response
      lastPage = response.lastPage;
      total = response.total;
      hasMorePages = currentPage < (lastPage ?? 1);
      

      setProductsState = LoadingState.loaded;
    } catch (e) {
      setProductsState = LoadingState.error;
      setProductsError = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts() async {
    if (!hasMorePages || isLoadingMore) {
      return;
    }

    try {
      isLoadingMore = true;
      notifyListeners();

      final nextPage = currentPage + 1;
      
      final SetProductsResponse response = await getSetProductsUseCase(
        page: nextPage,
        needUpdate: true, // Force update for pagination
      );

      
      setProducts.addAll(response.products);
      
      // Update currentPage from response
      if (response.currentPage != null) {
        currentPage = response.currentPage!;
      } else {
        currentPage = nextPage; // Fallback to nextPage if response doesn't have currentPage
      }
      
      // Update pagination info from response
      lastPage = response.lastPage;
      total = response.total;
      hasMorePages = currentPage < (lastPage ?? 1);
      

      isLoadingMore = false;
    } catch (e) {
      // Don't revert currentPage since we didn't increment it before the API call
      setProductsError = e.toString();
      isLoadingMore = false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshSetProducts() async {
    await getSetProducts(isRefresh: true);
  }

  Future<void> getSetProductDetails({required String slug}) async {
    try {
      setProductDetailsState = LoadingState.loading;
      setProductDetailsError = '';
      notifyListeners();

      final SetProductDetailsEntity response =
          await getSetProductDetailsUseCase(slug: slug);

      setProductDetails = response.data;
      setProductDetailsState = LoadingState.loaded;
    } catch (e) {
      setProductDetailsState = LoadingState.error;
      setProductDetailsError = e.toString();
      setProductDetails = null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> getRelatedSetProducts({required int productId}) async {
    // Avoid loading the same product multiple times
    if (currentRelatedProductId == productId && 
        (relatedProductsState == LoadingState.loading || 
         relatedProductsState == LoadingState.loaded)) {
      return;
    }

    try {
      currentRelatedProductId = productId;
      relatedProductsState = LoadingState.loading;
      relatedProductsError = '';
      notifyListeners();

      final SetProductsResponse response =
          await getRelatedSetProductsUseCase(productId: productId);

      relatedProducts = response.products;
      relatedProductsState = LoadingState.loaded;
    } catch (e) {
      relatedProductsState = LoadingState.error;
      relatedProductsError = e.toString();
      relatedProducts = [];
      // Reset current product ID on error so it can be retried
      currentRelatedProductId = null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshRelatedProducts({required int productId}) async {
    // Clear current related products and reload
    relatedProducts.clear();
    relatedProductsState = LoadingState.initial;
    relatedProductsError = '';
    currentRelatedProductId = null;
    notifyListeners();
    
    // Add delay to avoid rate limiting
    await Future.delayed(const Duration(seconds: 1));
    
    // Load new related products
    await getRelatedSetProducts(productId: productId);
  }

  Future<void> retryRelatedProducts({required int productId}) async {
    // Reset state and retry with delay
    relatedProductsState = LoadingState.initial;
    relatedProductsError = '';
    currentRelatedProductId = null;
    notifyListeners();
    
    // Add delay to avoid rate limiting
    await Future.delayed(const Duration(seconds: 2));
    
    // Retry loading related products
    await getRelatedSetProducts(productId: productId);
  }

  Future<void> loadFallbackProducts() async {
    try {
      relatedProductsState = LoadingState.loading;
      relatedProductsError = '';
      notifyListeners();

      final SetProductsResponse response = await getSetProductsUseCase(page: 1);
      
      // Take only first 6 products as fallback
      relatedProducts = response.products.take(6).toList();
      relatedProductsState = LoadingState.loaded;
    } catch (e) {
      relatedProductsState = LoadingState.error;
      relatedProductsError = e.toString();
      relatedProducts = [];
    } finally {
      notifyListeners();
    }
  }

  Future<void> calculatePrice({required CalculatePriceRequest request}) async {
    try {
      calculatePriceState = LoadingState.loading;
      calculatePriceError = '';
      notifyListeners();

      final CalculatePriceResponseEntity response = await calculatePriceUseCase(
        request: request,
      );

      calculatedPrice = response.data;
      calculatePriceState = LoadingState.loaded;
    } catch (e) {
      calculatePriceState = LoadingState.error;
      calculatePriceError = e.toString();
      calculatedPrice = null;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addFullSetToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      addToCartState = LoadingState.loading;
      addToCartError = '';
      notifyListeners();

      final response = await addFullSetToCartUseCase(
        productId: productId,
        quantity: quantity,
      );

      addToCartResponse = response;
      addToCartState = LoadingState.loaded;
      return true;
    } catch (e) {
      addToCartState = LoadingState.error;
      addToCartError = e.toString();
      addToCartResponse = null;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addCustomSetToCart({
    required int productId,
    required int quantity,
    required List<ComponentRequest> components,
  }) async {
    try {
      addToCartState = LoadingState.loading;
      addToCartError = '';
      notifyListeners();

      final response = await addCustomSetToCartUseCase(
        productId: productId,
        quantity: quantity,
        components: components,
      );

      addToCartResponse = response;
      addToCartState = LoadingState.loaded;
      return true;
    } catch (e) {
      addToCartState = LoadingState.error;
      addToCartError = e.toString();
      addToCartResponse = null;
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Clear details when navigating away
  void clearSetProductDetails() {
    setProductDetails = null;
    setProductDetailsState = LoadingState.initial;
    setProductDetailsError = '';
    notifyListeners();
  }

  // Clear related products
  void clearRelatedProducts() {
    relatedProducts = [];
    relatedProductsState = LoadingState.initial;
    relatedProductsError = '';
    currentRelatedProductId = null;
    notifyListeners();
  }

  // Clear calculated price
  void clearCalculatedPrice() {
    calculatedPrice = null;
    calculatePriceState = LoadingState.initial;
    calculatePriceError = '';
    notifyListeners();
  }

  // Clear add to cart state
  void clearAddToCartState() {
    addToCartState = LoadingState.initial;
    addToCartError = '';
    addToCartResponse = null;
    notifyListeners();
  }

  // Check if data is already loaded
  bool get isDataLoaded => setProducts.isNotEmpty && setProductsState == LoadingState.loaded;

  // Special method for language change - refresh all set products data
  Future<void> refreshAfterLanguageChange() async {
    debugPrint('Refreshing set products data after language change');

    // Reset all states to loading
    setProductsState = LoadingState.loading;
    setProductDetailsState = LoadingState.loading;
    relatedProductsState = LoadingState.loading;
    
    // Clear all data
    setProducts.clear();
    setProductDetails = null;
    relatedProducts.clear();
    calculatedPrice = null;
    
    // Reset pagination
    currentPage = 1;
    hasMorePages = true;
    isLoadingMore = false;
    currentRelatedProductId = null;
    
    // Clear error messages
    setProductsError = '';
    setProductDetailsError = '';
    relatedProductsError = '';
    calculatePriceError = '';
    addToCartError = '';
    
    notifyListeners();

    // Force refresh set products data
    try {
      await getSetProducts(isRefresh: true);
    } catch (e) {
      debugPrint('Error refreshing set products after language change: $e');
    }

    notifyListeners();
  }
}
