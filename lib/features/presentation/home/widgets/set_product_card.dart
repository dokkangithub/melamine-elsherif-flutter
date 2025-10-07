import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:melamine_elsherif/features/presentation/main%20layout/controller/layout_provider.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/features/domain/set%20products/entities/set_products.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/controller/wishlist_provider.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';
import 'package:melamine_elsherif/core/utils/helpers.dart';
import 'package:melamine_elsherif/core/utils/widgets/like_button.dart';
import 'package:lottie/lottie.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/features/presentation/cart/controller/cart_provider.dart';

class SetProductCard extends StatefulWidget {
  final SetProduct setProduct;
  final double width;
  final bool? isOutlinedAddToCart;
  final bool? isBuyNow;
  final int index;

  const SetProductCard({
    super.key, 
    required this.setProduct, 
    this.width = 250,
    this.isOutlinedAddToCart = false,
    this.isBuyNow = false,
    this.index = 0,
  });

  @override
  State<SetProductCard> createState() => _SetProductCardState();
}

class _SetProductCardState extends State<SetProductCard> {
  bool isAddingToCart = false;
  bool _showWishlistAnimation = false;

  void _triggerWishlistAnimation() {
    if (mounted) {
      setState(() {
        _showWishlistAnimation = true;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _showWishlistAnimation = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current price (which is after discount)
    final currentPrice = double.tryParse(widget.setProduct.discountedPrice?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0;
    // Calculate original price by adding 10% to current price
    final originalPrice = currentPrice * 1.1;
    final discountAmount = originalPrice - currentPrice;
    
    return FadeInUp(
      delay: Duration(milliseconds: 100 + (widget.index * 50)),
      duration: const Duration(milliseconds: 400),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          AppRoutes.navigateTo(
            context,
            AppRoutes.setProductDetailsScreen,
            arguments: {
              'slug': widget.setProduct.slug,
              'fromProductsTab': false,
            },
          );
        },
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: widget.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image with discount badge
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: Stack(
                          children: [
                            CustomImage(
                              imageUrl: widget.setProduct.thumbnailImage,
                              fit: BoxFit.contain,
                            ),
                            // Discount badge
                            Positioned(
                              top: 0,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor, // Primary color
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.accentColor,
                                      AppTheme.accentColor.withOpacity(0.8),
                                      AppTheme.accentColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '- ${discountAmount.toInt()} L.E',
                                  style: context.titleSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Product details
                    Column(
                      spacing: 2,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        // Rating stars
                        !widget.isBuyNow!
                            ? const SizedBox.shrink()
                            : Row(
                                children: List.generate(
                                  5,
                                  (index) => const Icon(
                                    Icons.star_outline_sharp,
                                    color: AppTheme.accentColor,
                                    size: 16,
                                  ),
                                ),
                              ),
                        // Product name
                        InkWell(
                           onTap: ()=> debugPrint('${widget.setProduct.name}'),
                          child: Text(
                            widget.setProduct.name!,
                            style: context.titleLarge.copyWith(
                              color: AppTheme.black,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            textAlign:
                                Directionality.of(context) == TextDirection.rtl
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                        ),

                        // Price and fav icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                spacing: 4,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Show current price (after discount) - use the original API price format
                                  Text(
                                    widget.setProduct.discountedPrice!,
                                    style: context.titleLarge.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign:
                                        Directionality.of(context) ==
                                            TextDirection.rtl
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  ),
                                  // Show original price (current price + 10%) with strikethrough
                                  Text(
                                    '${originalPrice.toInt()} L.E',
                                    style: context.titleMedium.copyWith(
                                      color: AppTheme
                                          .lightSecondaryTextColor,
                                      fontWeight: FontWeight.w400,
                                      decoration:
                                          TextDecoration.lineThrough,
                                    ),
                                    textAlign:
                                        Directionality.of(context) ==
                                            TextDirection.rtl
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                            Consumer<WishlistProvider>(
                              builder: (context, provider, _) {
                                final isInWishlist = provider
                                    .isProductInWishlist(widget.setProduct.slug!);

                                return LikeButton(
                                  isFavorite: isInWishlist,
                                  iconColor: AppTheme.primaryColor,
                                  onPressed: () async {
                                    (AppStrings.token == null || isInWishlist)
                                        ? null
                                        : _triggerWishlistAnimation();
                                    await AppFunctions.toggleWishlistStatus(
                                      context,
                                      widget.setProduct.slug!,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),

                        isAddingToCart
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [CustomLoadingWidget()],
                              )
                            : CustomButton(
                                height: 40,
                                text: widget.isBuyNow!
                                    ? 'buy_now'.tr(context)
                                    : 'add_to_cart'.tr(context),
                                textStyle: context.titleLarge.copyWith(
                                  color: widget.isOutlinedAddToCart!
                                      ? AppTheme.primaryColor
                                      : AppTheme.white,
                                  fontWeight: FontWeight.w900,
                                ),
                                fullWidth: true,
                                isOutlined: widget.isOutlinedAddToCart!,
                                padding: const EdgeInsets.all(8),
                                onPressed: () async {
                                  setState(() {
                                    isAddingToCart = true;
                                  });

                                  // Store the current cart count
                                  final cartProvider =
                                      Provider.of<CartProvider>(
                                        context,
                                        listen: false,
                                      );

                                  await AppFunctions.addProductToCart(
                                    context: context,
                                    productId: widget.setProduct.id!,
                                    productName: widget.setProduct.name!,
                                    productSlug: widget.setProduct.slug!,
                                    hasVariation: false, // Set products might have variations
                                  );

                                  setState(() {
                                    isAddingToCart = false;
                                  });

                                  // Only navigate if it's buy now and the product was added successfully
                                  if (widget.isBuyNow! &&
                                      cartProvider.lastAddToCartSuccess) {
                                    if (context.mounted) {
                                      // Use the optimized navigation that sets a flag to avoid unnecessary API calls
                                      Provider.of<LayoutProvider>(
                                        context,
                                        listen: false,
                                      ).navigateToCartFromBuyNow();
                                    }
                                  }
                                },
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_showWishlistAnimation)
              Opacity(
                opacity: 0.05,
                child: Lottie.asset(
                  AppAnimations.wishlistAnimation,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
