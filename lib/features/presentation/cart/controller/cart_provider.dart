import 'package:flutter/material.dart';
import '../../../domain/cart/entities/cart.dart';
import '../../../domain/cart/entities/shipping_update_response.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../domain/cart/usecases/add_to_cart_usecases.dart';
import '../../../domain/cart/usecases/clear_cart_usecases.dart';
import '../../../domain/cart/usecases/delete_cart_item_usecases.dart';
import '../../../domain/cart/usecases/get_cart_count_usecases.dart';
import '../../../domain/cart/usecases/get_cart_items_usecases.dart';
import '../../../domain/cart/usecases/get_cart_summary_usecases.dart';
import '../../../domain/cart/usecases/update_cart_quantities_usecases.dart';

class CartProvider extends ChangeNotifier {
  final GetCartItemsUseCase getCartItemsUseCase;
  final GetCartCountUseCase getCartCountUseCase;
  final DeleteCartItemUseCase deleteCartItemUseCase;
  final ClearCartUseCase clearCartUseCase;
  final UpdateCartQuantitiesUseCase updateCartQuantitiesUseCase;
  final AddToCartUseCase addToCartUseCase;
  final GetCartSummaryUseCase getCartSummaryUseCase;

  CartProvider({
    required this.getCartItemsUseCase,
    required this.getCartCountUseCase,
    required this.deleteCartItemUseCase,
    required this.clearCartUseCase,
    required this.updateCartQuantitiesUseCase,
    required this.addToCartUseCase,
    required this.getCartSummaryUseCase,
  });

  LoadingState cartState = LoadingState.loading;
  List<CartItem> cartItems = [];
  int cartCount = 0;
  CartSummary? cartSummary;
  String cartError = '';
  ShippingUpdateResponse? shippingUpdateResponse;
  bool isUpdatingShipping = false;

  Future<void> fetchCartItems() async {
    try {
      cartState = LoadingState.loading;
      notifyListeners();

      cartItems = await getCartItemsUseCase();
      cartState = LoadingState.loaded;
    } catch (e) {
      cartState = LoadingState.error;
      cartError = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchCartSummary() async {
    try {
      cartSummary = await getCartSummaryUseCase();
      notifyListeners();
    } catch (e) {
      cartError = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchCartCount() async {
    try {
      cartCount = await getCartCountUseCase();
      notifyListeners();
    } catch (e) {
      cartError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCartItem(int cartId) async {
    try {
      await deleteCartItemUseCase(cartId);
      await fetchCartItems();
      await fetchCartCount();
      await fetchCartSummary();
      notifyListeners();
    } catch (e) {
      cartError = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await clearCartUseCase();
      await fetchCartItems();
      await fetchCartCount();
      notifyListeners();
    } catch (e) {
      cartError = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCartQuantities(String cartIds, String quantities) async {
    try {
      await updateCartQuantitiesUseCase(cartIds, quantities);
      await fetchCartItems();
      await fetchCartCount();
      await fetchCartSummary();
      notifyListeners();
    } catch (e) {
      cartError = e.toString();
      notifyListeners();
    }
  }

  Future<String?> addToCart(int productId, String variant, int quantity, String color) async {
    try {
      await addToCartUseCase(productId, variant, quantity, color);
      await fetchCartItems();
      await fetchCartCount();
      await fetchCartSummary();
      notifyListeners();
      return null;
    } catch (e) {
      cartError = e.toString();
      String errorMessage = cartError;
      if (cartError.contains('Exception: ')) {
        errorMessage = cartError.replaceFirst('Exception: ', '');
      }
      notifyListeners();
      return errorMessage;
    }
  }

}