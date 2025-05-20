import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/cart_animation_overlay.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_dilog.dart';
import 'package:melamine_elsherif/core/utils/widgets/cutsom_toast.dart';
import 'package:melamine_elsherif/features/presentation/profile/controller/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
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
      // Add product to cart and get the result
      final result = await cartProvider.addToCart(
        productId,
        variant,
        quantity,
        color,
      );

      // Reset loading state immediately after getting the API response
      if (context.mounted &&
          productProvider.selectedProduct?.slug == productSlug) {
        productProvider.setAddingToCartState(false);
      }

      if (context.mounted) {
        // Check if the operation was successful
        final bool isSuccess = cartProvider.lastAddToCartSuccess;

        // Show appropriate toast message
        isSuccess
            ? CustomToast.showToast(
          message: result ?? 'added_to_cart_successfully'.tr(context),
          type: ToastType.success
        )
            : CustomToast.showToast(
          message: result ?? 'failed_to_add_to_cart'.tr(context),
            type: ToastType.error
        );
        
        // Show animation only if cart addition was successful
        if (isSuccess) {
          showCartAddedAnimation(context);
          
          // Refresh cart data asynchronously without waiting
          _refreshCartDataAsync(cartProvider,context);
        }
      }
    } catch (e) {
      // Reset loading state in case of error
      if (context.mounted &&
          productProvider.selectedProduct?.slug == productSlug) {
        productProvider.setAddingToCartState(false);
      }
      
      if (context.mounted) {
        CustomToast.showToast(
          message: e.toString(),
          type: ToastType.error
        );
      }
    }
  }
  
  // Helper method to refresh cart data asynchronously
  static Future<void> _refreshCartDataAsync(CartProvider cartProvider,context) async {
    await cartProvider.fetchCartItems();
    await cartProvider.fetchCartCount();
    await cartProvider.fetchCartSummary();
    await Provider.of<ProfileProvider>(context,listen: false).getProfileCounters();
  }

  static Future<void> toggleWishlistStatus(
    BuildContext context,
    String slug,
  ) async {
    if (AppStrings.token == null) {
      CustomToast.showToast(message: 'please_login'.tr(context), type: ToastType.warning);
    } else {
      final provider = Provider.of<WishlistProvider>(context, listen: false);

      await provider.toggleWishlistStatus(context, slug);
      await Provider.of<ProfileProvider>(context,listen: false).getProfileCounters();
    }
  }
}
