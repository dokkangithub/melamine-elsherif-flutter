import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:melamine_elsherif/features/presentation/main%20layout/controller/layout_provider.dart';
import 'package:provider/provider.dart';
import '../../../../features/domain/product/entities/product.dart';
import '../../../features/presentation/wishlist/controller/wishlist_provider.dart';
import '../../config/routes.dart/routes.dart';
import '../helpers.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final bool? isOutlinedAddToCart;
  final bool? isBuyNow;

  const ProductCard({
    super.key,
    required this.product,
    this.isOutlinedAddToCart = false,
    this.isBuyNow = false,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    print(widget.product.discountedPrice);
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.productDetailScreen,
          arguments: {'slug': widget.product.slug},
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
                          imageUrl: widget.product.thumbnailImage,
                          fit: BoxFit.cover,
                        ),
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
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                          ),
                      // Product name
                      Text(
                        widget.product.name,
                        style: context.titleMedium.copyWith(
                          color: AppTheme.black,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        textAlign: Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                      ),

                      // Price
                      Text(
                        widget.product.discountedPrice,
                        style: context.titleMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                      ),

                      isAddingToCart
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [CustomLoadingWidget()],
                          )
                          : CustomButton(
                            text:
                                widget.isBuyNow!
                                    ? 'buy_now'.tr(context)
                                    : 'add_to_cart'.tr(context),
                            textStyle: context.titleSmall.copyWith(
                              color:
                                  widget.isOutlinedAddToCart!
                                      ? AppTheme.primaryColor
                                      : AppTheme.white,
                            ),
                            fullWidth: true,
                            isOutlined: widget.isOutlinedAddToCart!,
                            padding: const EdgeInsets.all(8),
                            onPressed: () async {
                              setState(() {
                                isAddingToCart = true;
                              });
                              await AppFunctions.addProductToCart(
                                context: context,
                                productId: widget.product.id,
                                productName: widget.product.name,
                                productSlug: widget.product.slug,
                                hasVariation: widget.product.hasVariation,
                              );
                              widget.isBuyNow!
                                  ? AppRoutes.navigateTo(
                                    context,
                                    AppRoutes.mainLayoutScreen,
                                  )
                                  : null;
                              widget.isBuyNow!
                                  ? Provider.of<LayoutProvider>(
                                        context,
                                        listen: false,
                                      ).currentIndex =
                                      3
                                  : null;
                              setState(() {
                                isAddingToCart = false;
                              });
                            },
                          ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 4,
                right:
                    Directionality.of(context) == TextDirection.ltr ? 4 : null,
                left:
                    Directionality.of(context) == TextDirection.rtl ? 4 : null,
                child: Consumer<WishlistProvider>(
                  builder: (context, provider, _) {
                    final isInWishlist = provider.isProductInWishlist(
                      widget.product.slug,
                    );

                    return InkWell(
                      onTap: () {
                        AppFunctions.toggleWishlistStatus(
                          context,
                          widget.product.slug,
                        );
                      },
                      child: Card(
                        elevation: 2,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            isInWishlist ? Icons.favorite : Icons.favorite_border,
                            color: AppTheme.primaryColor,
                            size: 22,
                          ),
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
