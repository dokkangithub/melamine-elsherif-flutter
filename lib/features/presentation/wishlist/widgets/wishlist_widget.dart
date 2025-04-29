import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/helpers.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/widgets/shimmer/wishlist_screen_shimmer.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../controller/wishlist_provider.dart';
import 'empty_wishlist_widget.dart';

class WishlistWidget extends StatelessWidget {
  final WishlistProvider provider;

  const WishlistWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Wishlist',
          style: context.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              AppRoutes.navigateTo(context, AppRoutes.searchScreen);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter categories - removed as per request
          
          // Remove All button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                for (var item in provider.wishlistItems) {
                  provider.removeFromWishlist(item.slug);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('wishlist_cleared'.tr(context)),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline, color: AppTheme.accentColor),
                  const SizedBox(width: 4),
                  Text(
                    'remove_all'.tr(context),
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Wishlist items grid
          provider.wishlistState != LoadingState.loading
              ? provider.wishlistItems.isEmpty
                  ? Expanded(child: EmptyWishlistWidget())
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: provider.wishlistItems.length,
                          itemBuilder: (context, index) {
                            final item = provider.wishlistItems[index];
                            return _buildWishlistItem(context, item, provider);
                          },
                        ),
                      ),
                    )
              : Expanded(child: WishlistScreenShimmer()),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(BuildContext context, wishlistItem, WishlistProvider provider) {
    return InkWell(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.productDetailScreen,
          arguments: {'slug': wishlistItem.slug},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: CustomImage(
                      imageUrl:  wishlistItem.thumbnailImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),

                // Product details
                Padding(
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Text(
                            '${wishlistItem.price}',
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
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomImage(assetPath: AppSvgs.cart_white)
                            ),
                          ),
                        ],
                      ),


                    ],
                  ),
                ),
              ],
            ),

            // Wishlist heart icon
            Positioned(
              top: 8,
              right: 8,
              child: InkWell(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
