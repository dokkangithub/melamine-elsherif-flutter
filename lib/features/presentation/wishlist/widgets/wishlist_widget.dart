import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/widgets/shimmer/wishlist_screen_shimmer.dart';
import '../../../../core/config/app_config.dart/app_config.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/product cards/custom_gridview_prodcut.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../controller/wishlist_provider.dart';
import 'custom_product_in_wishlist.dart';
import 'empty_wishlist_widget.dart';

class WishlistWidget extends StatelessWidget {
  final WishlistProvider provider;

  const WishlistWidget({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.95),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  spacing: 6,
                  children: [
                    const SizedBox(height: 10),
                    CustomImage(assetPath: AppSvgs.category_star),
                    Text(
                      'my_wishlist'.tr(context),
                      style: context.displayMedium.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                    Text(
                      provider.wishlistItems.length.toString() +
                          ' ' +
                          'items_saved'.tr(context),
                      style: context.titleMedium.copyWith(
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 50,
              child: Opacity(
                opacity: 0.2,
                child: CustomImage(assetPath: AppSvgs.category_1),
              ),
            ),
            Positioned(
              top: 50,
              right: 50,
              child: Opacity(
                opacity: 0.2,
                child: CustomImage(assetPath: AppSvgs.category_1),
              ),
            ),
            Positioned(
              top: 30,
              left: 30,
              child: Opacity(
                opacity: 0.2,
                child: CustomImage(assetPath: AppSvgs.category_2),
              ),
            ),
            Positioned(
              top: 50,
              right: 100,
              child: Opacity(
                opacity: 0.2,
                child: CustomImage(assetPath: AppSvgs.category_3),
              ),
            ),
            Positioned(
              top: 110,
              left: 20,
              child: Opacity(
                opacity: 0.2,
                child: CustomImage(assetPath: AppSvgs.category_4),
              ),
            ),
          ],
        ),
        Container(
          height: 40,
          width: double.infinity,
          color: AppTheme.accentColor.withValues(alpha: 0.1),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  for (var item
                  in provider.wishlistItems) {
                    provider.removeFromWishlist(
                      item.slug,
                    );
                  }
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        'wishlist_cleared'.tr(context),
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.delete_forever_outlined, color: AppTheme.accentColor),
                    const SizedBox(width: 4),
                    Text(
                      'remove_all'.tr(context),
                      style: context.titleSmall.copyWith(color: AppTheme.accentColor),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ],
          ),
        ),

        provider.wishlistState != LoadingState.loading
            ? provider.wishlistItems.isEmpty? EmptyWishlistWidget(): Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount:
                      provider.wishlistItems.length > 8
                          ? 8
                          : provider.wishlistItems.length,
                  itemBuilder: (context, index) {
                    final wishlistItem = provider.wishlistItems[index];
                    return ProductItemInWishList(wishlistItem: wishlistItem);
                  },
                ),
              ),
            )
            : Expanded(child: WishlistScreenShimmer()),
      ],
    );
  }
}
