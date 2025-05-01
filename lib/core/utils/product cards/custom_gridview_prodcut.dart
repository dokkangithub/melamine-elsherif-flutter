import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/responsive_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:provider/provider.dart';
import '../../../../features/domain/product/entities/product.dart';
import '../../../../features/presentation/wishlist/controller/wishlist_provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../helpers.dart';
import '../widgets/custom_cached_image.dart';

class ProductGridCard extends StatelessWidget {
  final Product product;
  final bool availableAddToCart;

  const ProductGridCard({
    super.key,
    required this.product,
    this.availableAddToCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.productDetailScreen,
          arguments: {'slug': product.slug},
        );
      },
      child: Container(
        width: context.responsive(160),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomImage(
                        width: double.infinity,
                        imageUrl: product.thumbnailImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Product details
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name
                        Text(
                          product.name,
                          style: context.titleSmall!.copyWith(fontWeight: FontWeight.w600,color: AppTheme.black),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 6),
                        // Price
                        Text('${product.mainPrice}', style: context.titleSmall!.copyWith(fontWeight: FontWeight.w600,color: AppTheme.primaryColor)),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 4,
                right: Directionality.of(context) == TextDirection.ltr ? 4 : null,
                left: Directionality.of(context) == TextDirection.rtl ? 4 : null,
                child: Consumer<WishlistProvider>(
                  builder: (context, provider, _) {
                    final isInWishlist = provider.isProductInWishlist(
                      product.slug,
                    );

                    return InkWell(
                      onTap: () {
                        AppFunctions.toggleWishlistStatus(context, product.slug);
                      },
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : Colors.black54,
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: availableAddToCart ? 0 : 4,
                right:
                    Directionality.of(context) == TextDirection.ltr
                        ? (availableAddToCart ? 0 : 4)
                        : null,
                left:
                    Directionality.of(context) == TextDirection.rtl
                        ? (availableAddToCart ? 0 : 4)
                        : null,
                child: InkWell(
                  onTap: () {
                    availableAddToCart
                        ? product.currentStock < 1
                            ? null
                            : AppFunctions.addProductToCart(
                              context: context,
                              productId: product.id,
                              productName: product.name,
                              productSlug: product.slug,
                              hasVariation: product.hasVariation,
                            )
                        : null;
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          !availableAddToCart
                              ? AppTheme.accentColor.withValues(alpha: 0.1)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child:
                        !availableAddToCart
                            ? Text(
                              'new'.tr(context),
                              style: context.bodySmall?.copyWith(
                                color:
                                    !availableAddToCart
                                        ? AppTheme.accentColor
                                        : AppTheme.primaryColor,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                            : CustomImage(assetPath: AppSvgs.active_cart_icon),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
