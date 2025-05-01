import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/responsive_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/helpers.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../domain/wishlist/entities/wishlist_details.dart';
import '../controller/wishlist_provider.dart';
import '../../../../core/config/routes.dart/routes.dart';

class ProductItemInWishList extends StatelessWidget {
  final WishlistItem wishlistItem;

  const ProductItemInWishList({
    super.key,
    required this.wishlistItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () {
                    AppRoutes.navigateTo(
                      context,
                      AppRoutes.productDetailScreen,
                      arguments: {'slug': wishlistItem.slug},
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: CustomImage(
                      imageUrl: wishlistItem.thumbnailImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              
              // Product details
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Product name
                      Text(
                        wishlistItem.name,
                        style: context.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Price
                      Text('${wishlistItem.price}',
                        style: context.titleSmall,
                      ),

                      // Add to cart button
                      InkWell(
                        onTap: () {
                          AppFunctions.addProductToCart(
                            context: context,
                            productId: wishlistItem.productId,
                            productName: wishlistItem.name,
                            productSlug: wishlistItem.slug,
                            hasVariation: wishlistItem.hasVariation,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: CustomImage(assetPath: AppSvgs.cart_icon)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Wishlist heart icon
          Positioned(
            top: 8,
            right: 8,
            child: Consumer<WishlistProvider>(
              builder: (context, provider, _) {
                return InkWell(
                  onTap: () {
                    provider.removeFromWishlist(wishlistItem.slug);
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: AppTheme.accentColor,
                      size: 18,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}