import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/responsive_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import '../../../../features/domain/product/entities/product.dart';
import '../../../features/presentation/wishlist/controller/wishlist_provider.dart';
import '../../config/routes.dart/routes.dart';
import '../helpers.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool? isOutlinedAddToCart;

  const ProductCard({super.key, required this.product, this.isOutlinedAddToCart=false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.productDetailScreen,
          arguments: {'slug': product.slug},
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 200,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  // Product image
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CustomImage(
                          imageUrl: product.thumbnailImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Product details
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating stars
                        Row(
                          children: List.generate(
                            5,
                                (index) =>
                                Icon(Icons.star_outline_sharp, color: Colors.amber, size: 14),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Product name
                        Text(
                          product.name,
                          style: context.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Price
                        Text(
                          '${product.discountedPrice}',
                          style: context.titleMedium.copyWith(color: AppTheme.primaryColor),
                        ),

                        const SizedBox(height: 4),

                        CustomButton(
                          text: 'add_to_cart'.tr(context),
                          textStyle: context.bodyMedium.copyWith(color: isOutlinedAddToCart! ?AppTheme.primaryColor:AppTheme.white),
                          fullWidth: true,
                          isOutlined: isOutlinedAddToCart!,
                          onPressed: (){
                            AppFunctions.addProductToCart(
                                context: context,
                                productId: product.id,
                                productName: product.name,
                                productSlug: product.slug,
                                hasVariation: product.hasVariation
                            );
                          },
                        )

                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 12,
                right:
                    Directionality.of(context) == TextDirection.ltr ? 8 : null,
                left: Directionality.of(context) == TextDirection.rtl ? 8 : null,
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
                          shape: BoxShape.circle,
                          color: AppTheme.white.withValues(alpha: 0.6)
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
            ],
          ),
        ),
      ),
    );
  }
}
