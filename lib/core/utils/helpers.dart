import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_dilog.dart';
import 'package:melamine_elsherif/core/utils/widgets/cutsom_toast.dart';
import 'package:provider/provider.dart';

import '../../features/presentation/cart/controller/cart_provider.dart';
import '../../features/presentation/product details/controller/product_provider.dart';
import '../../features/presentation/wishlist/controller/wishlist_provider.dart';

abstract class AppFunctions {
  static Future<void> addProductToCart({
    required BuildContext context,
    required int productId,
    required String productName,
    required String productSlug,
    required bool hasVariation,
    String variant = "",
    String color = "",
    int quantity = 1,
  }) async {
    // If we're not on the product detail screen and the product has variations,
    // navigate to the product detail screen first
    if (hasVariation) {
      AppRoutes.navigateTo(
        context,
        AppRoutes.productDetailScreen,
        arguments: {'slug': productSlug},
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // If we're on a product detail screen, get the provider
    final productProvider = Provider.of<ProductDetailsProvider>(
      context,
      listen: false,
    );

    // Set loading state
    if (productProvider.selectedProduct?.slug == productSlug) {
      productProvider.setAddingToCartState(true);
    }

    try {
      final cartMessage = await cartProvider.addToCart(
        productId,
        variant,
        quantity,
        color,
      );

      // Manually refresh cart data
      await cartProvider.fetchCartItems();
      await cartProvider.fetchCartCount();
      await cartProvider.fetchCartSummary();

      if (context.mounted) {
        CustomToast.showToast(
          message: cartMessage ?? 'Added to cart successfully',
          type: ToastType.success,
        );
      }
    } finally {
      // Reset loading state if still on same product
      if (context.mounted &&
          productProvider.selectedProduct?.slug == productSlug) {
        productProvider.setAddingToCartState(false);
      }
    }
  }

  static Future<void> toggleWishlistStatus(
    BuildContext context,
    String slug,
  ) async {
    if (AppStrings.token == null) {
      CustomToast.showToast(message: 'please login', type: ToastType.warning);
    } else {
      final provider = Provider.of<WishlistProvider>(context, listen: false);

      await provider.toggleWishlistStatus(context, slug);

      if (context.mounted && provider.lastActionMessage != null) {
        CustomToast.showToast(
          message: provider.lastActionMessage!,
          type: ToastType.success,
        );
      }
    }
  }

  static Future<void> showCustomDialog({
    required BuildContext context,
    required String title,
    required String description,
    String confirmButtonText = 'OK',
    String cancelButtonText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return showDialog(
      context: context,
      builder:
          (context) => CustomDialog(
            title: title,
            description: description,
            confirmButtonText: confirmButtonText,
            cancelButtonText: cancelButtonText,
            onConfirm: onConfirm,
            onCancel: onCancel,
          ),
    );
  }
}
