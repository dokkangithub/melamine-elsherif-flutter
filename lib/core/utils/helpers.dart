import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_dilog.dart';
import 'package:melamine_elsherif/core/utils/widgets/cutsom_toast.dart';
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
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            message:
            cartMessage ?? 'added_to_cart_successfully'.tr(context),
            backgroundColor: AppTheme.primaryColor,
          ),
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
      CustomToast.showToast(message: 'please_login'.tr(context), type: ToastType.warning);
    } else {
      final provider = Provider.of<WishlistProvider>(context, listen: false);

      await provider.toggleWishlistStatus(context, slug);

      if (context.mounted && provider.lastActionMessage != null) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            message: provider.lastActionMessage!,
            backgroundColor: AppTheme.primaryColor,
          ),
        );

      }
    }
  }

}
