import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/responsive_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/widgets/shimmer/wishlist_screen_shimmer.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../domain/wishlist/entities/wishlist_details.dart';
import '../controller/wishlist_provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/helpers.dart';

class ProductItemInWishList extends StatelessWidget {
  final WishlistItem wishlistItem;

  const ProductItemInWishList({
    super.key,
    required this.wishlistItem,
  });

  @override
  Widget build(BuildContext context) {


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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.secondaryColor, width: 1),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Expanded(
                  child: Stack(
                    children: [
                      CustomImage(
                        imageUrl: wishlistItem.thumbnailImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10)
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppTheme.white,
                                AppTheme.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                // Product details
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        wishlistItem.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Price
                      Text(
                        '${wishlistItem.price}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Consumer<WishlistProvider>(
                builder: (context, provider, _) {
                  return InkWell(
                    onTap: () {
                      AppFunctions.toggleWishlistStatus(context, wishlistItem.slug);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1,color: AppTheme.primaryColor)
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppTheme.primaryColor,
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
    );
  }
}