// lib/features/presentation/set products/controller/set_product_provider.dart

import 'package:flutter/material.dart';
import '../../../domain/set products/entities/set_products.dart';
import '../../../domain/set products/entities/set_products_response.dart';
import '../../../domain/set products/entities/set_product_details.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../domain/set products/usecases/get_set_products_use_case.dart';
import '../../../domain/set products/usecases/get_set_product_details_use_case.dart';
import '../../../domain/set products/usecases/calculate_price_use_case.dart';
import '../../../domain/set products/usecases/add_full_set_to_cart_use_case.dart';
import '../../../domain/set products/usecases/add_custom_set_to_cart_use_case.dart';

class SetProductsProvider extends ChangeNotifier {
  final GetSetProductsUseCase getSetProductsUseCase;
  final GetSetProductDetailsUseCase getSetProductDetailsUseCase;
  final CalculatePriceUseCase calculatePriceUseCase;
  final AddFullSetToCartUseCase addFullSetToCartUseCase;
  final AddCustomSetToCartUseCase addCustomSetToCartUseCase;

  SetProductsProvider({
    required this.getSetProductsUseCase,
    required this.getSetProductDetailsUseCase,
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

  // Calculate Price State
  LoadingState calculatePriceState = LoadingState.initial;
  CalculatedPriceData? calculatedPrice;
  String calculatePriceError = '';

  // Add to Cart State
  LoadingState addToCartState = LoadingState.initial;
  String addToCartError = '';
  Map<String, dynamic>? addToCartResponse;

  Future<void> getSetProducts({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage = 1;
        hasMorePages = true;
        setProducts.clear();
      }

      setProductsState = LoadingState.loading;
      notifyListeners();

      final SetProductsResponse response = await getSetProductsUseCase(page: currentPage);

      if (isRefresh) {
        setProducts = response.products;
      } else {
        setProducts.addAll(response.products);
      }

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
    if (!hasMorePages || isLoadingMore) return;

    try {
      isLoadingMore = true;
      notifyListeners();

      currentPage++;
      final SetProductsResponse response = await getSetProductsUseCase(page: currentPage);

      setProducts.addAll(response.products);
      hasMorePages = currentPage < (lastPage ?? 1);

      isLoadingMore = false;
    } catch (e) {
      currentPage--; // Revert page increment on error
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

      final SetProductDetailsEntity response = await getSetProductDetailsUseCase(slug: slug);

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

  Future<void> calculatePrice({required CalculatePriceRequest request}) async {
    try {
      calculatePriceState = LoadingState.loading;
      calculatePriceError = '';
      notifyListeners();

      final CalculatePriceResponseEntity response = await calculatePriceUseCase(request: request);

      calculatedPrice = response.data;
      print('dddddd${calculatedPrice!.totalPrice}');
      calculatePriceState = LoadingState.loaded;
    } catch (e) {
      calculatePriceState = LoadingState.error;
      calculatePriceError = e.toString();
      calculatedPrice = null;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addFullSetToCart({required int productId, required int quantity}) async {
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
    required List<ComponentRequest> components
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
}