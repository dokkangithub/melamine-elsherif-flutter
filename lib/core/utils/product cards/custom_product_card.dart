import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/responsive_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/features/presentation/main%20layout/controller/layout_provider.dart';
import 'package:provider/provider.dart';
import '../../../../features/domain/product/entities/product.dart';
import '../../../features/presentation/wishlist/controller/wishlist_provider.dart';
import '../../config/routes.dart/routes.dart';
import '../helpers.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool? isOutlinedAddToCart;
  final bool? isBuyNow;

  const ProductCard({super.key, required this.product, this.isOutlinedAddToCart=false, this.isBuyNow=false});

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
          width: 160,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: AspectRatio(
                        aspectRatio: 1.3,
                        child: CustomImage(
                          imageUrl: product.thumbnailImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Product details
                  Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating stars
                      !isBuyNow! ?SizedBox.shrink():Row(
                        children: List.generate(
                          5,
                              (index) =>
                              Icon(Icons.star_outline_sharp, color: Colors.amber, size: 14),
                        ),
                      ),
                      // Product name
                      Text(
                        product.name,
                        style: context.bodyMedium.copyWith(color: AppTheme.black,fontWeight: FontWeight.w700),
                        maxLines: 1,
                      ),

                      // Price
                      Text(
                        '${product.discountedPrice}',
                        style: context.titleMedium.copyWith(color: AppTheme.primaryColor),
                      ),

                      CustomButton(
                        text: isBuyNow! ? 'buy_now'.tr(context): 'add_to_cart'.tr(context),
                        textStyle: context.bodyMedium.copyWith(color: isOutlinedAddToCart! ?AppTheme.primaryColor:AppTheme.white),
                        fullWidth: true,
                        isOutlined: isOutlinedAddToCart!,
                        padding: EdgeInsets.all(8),
                        onPressed: () async {
                          await AppFunctions.addProductToCart(
                              context: context,
                              productId: product.id,
                              productName: product.name,
                              productSlug: product.slug,
                              hasVariation: product.hasVariation
                          );
                          isBuyNow! ? AppRoutes.navigateTo(context, AppRoutes.mainLayoutScreen):null;
                          isBuyNow! ? Provider.of<LayoutProvider>(context,listen: false).currentIndex=3:null;
                        },
                      )
                    ],
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
