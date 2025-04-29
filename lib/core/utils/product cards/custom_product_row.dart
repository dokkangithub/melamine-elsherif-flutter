import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import '../../../../features/domain/product/entities/product.dart';
import '../../../../features/presentation/wishlist/controller/wishlist_provider.dart';
import '../../config/routes.dart/routes.dart';
import '../helpers.dart';

class ProductItemInRow1 extends StatelessWidget {
  final Product product;

  const ProductItemInRow1({super.key, required this.product});

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
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Row(
              children: [
                // Left section with product details
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Product name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Price display
                      Text(
                        '\$${product.discountedPrice}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),

                      // Original price (strikethrough) if present
                      if (product.hasDiscount)
                        Text(
                          '\$${product.mainPrice}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const Spacer(),
                      // Add to cart button
                      GestureDetector(
                        onTap:
                            () =>
                                product.currentStock < 1
                                    ? null
                                    : AppFunctions.addProductToCart(
                                      context: context,
                                      productId: product.id,
                                      productName: product.name,
                                      productSlug: product.slug,
                                      hasVariation: product.hasVariation,
                                    ),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color:
                                product.currentStock < 1
                                    ? Colors.grey
                                    : Colors.blue,
                            borderRadius:
                                Directionality.of(context) == TextDirection.ltr
                                    ? BorderRadius.only(
                                      topRight: Radius.circular(15),
                                      bottomLeft: Radius.circular(15),
                                    )
                                    : BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      bottomRight: Radius.circular(15),
                                    ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right section with product image
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius:
                        Directionality.of(context) == TextDirection.ltr
                            ? const BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            )
                            : const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                    child: CustomImage(imageUrl: product.thumbnailImage),
                  ),
                ),
              ],
            ),

            // Favorite icon overlay with Consumer
            Positioned(
              top: 0,
              right: Directionality.of(context) == TextDirection.ltr ? 0 : null,
              left: Directionality.of(context) == TextDirection.rtl ? 0 : null,
              child: Consumer<WishlistProvider>(
                builder: (context, provider, _) {
                  // Use direct in-memory check
                  final isFavorite = provider.isProductInWishlist(product.slug);

                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius:
                          Directionality.of(context) == TextDirection.ltr
                              ? const BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              )
                              : const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                    ),
                    child: InkWell(
                      onTap:
                          () => AppFunctions.toggleWishlistStatus(
                            context,
                            product.slug,
                          ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black54,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
