import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/helpers.dart';
import 'package:melamine_elsherif/core/utils/widgets/cutsom_toast.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/widgets/shimmer/wishlist_screen_shimmer.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/widgets/snappable_wishlist_item.dart';
import 'package:quickalert/quickalert.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../controller/wishlist_provider.dart';
import 'empty_wishlist_widget.dart';

class WishlistWidget extends StatefulWidget {
  final WishlistProvider provider;
  final bool triggerAnimation;

  const WishlistWidget({
    super.key, 
    required this.provider, 
    this.triggerAnimation = true
  });

  @override
  State<WishlistWidget> createState() => _WishlistWidgetState();
}

class _WishlistWidgetState extends State<WishlistWidget> {
  bool _shouldAnimate = true;

  @override
  void initState() {
    super.initState();
    _shouldAnimate = widget.triggerAnimation;
  }
  
  @override
  void didUpdateWidget(WishlistWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.triggerAnimation != oldWidget.triggerAnimation) {
      setState(() {
        _shouldAnimate = widget.triggerAnimation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _shouldAnimate 
          ? FadeIn(
              duration: const Duration(milliseconds: 400),
              child: Text(
                'my_wishlist'.tr(context),
                style: context.headlineSmall.copyWith(fontWeight: FontWeight.w800),
              ),
            )
          : Text(
              'my_wishlist'.tr(context),
              style: context.headlineSmall.copyWith(fontWeight: FontWeight.w800),
            ),
        actions: [
          _shouldAnimate 
            ? FadeInRight(
                duration: const Duration(milliseconds: 500),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    AppRoutes.navigateTo(context, AppRoutes.searchScreen);
                  },
                ),
              )
            : IconButton(
                icon: const Icon(Icons.search, color: Colors.black),
                onPressed: () {
                  AppRoutes.navigateTo(context, AppRoutes.searchScreen);
                },
              ),
        ],
      ),
      body: Column(
        children: [
          // Remove All button
          widget.provider.wishlistItems.isEmpty
              ? const SizedBox.shrink()
              : _shouldAnimate 
                ? FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 400),
                    child: _buildRemoveAllButton(context),
                  )
                : _buildRemoveAllButton(context),

          // Wishlist items grid
          widget.provider.wishlistState != LoadingState.loading
              ? widget.provider.wishlistItems.isEmpty
                  ? Expanded(
                    child: _shouldAnimate
                      ? FadeIn(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 600),
                          child: const EmptyWishlistWidget(),
                        )
                      : const EmptyWishlistWidget(),
                  )
                  : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: widget.provider.wishlistItems.length,
                        itemBuilder: (context, index) {
                          final item = widget.provider.wishlistItems[index];
                          // Skip rendering placeholder items that are in loading state
                          if (item.name == "Loading...") {
                            return const SizedBox.shrink();
                          }
                          return _shouldAnimate
                            ? FadeInUp(
                                delay: Duration(milliseconds: 100 * index % 8),
                                duration: const Duration(milliseconds: 500),
                                child: _buildWishlistItem(context, item, widget.provider),
                              )
                            : _buildWishlistItem(context, item, widget.provider);
                        },
                      ),
                    ),
                  )
              : const Expanded(child: WishlistScreenShimmer()),
        ],
      ),
    );
  }

  Widget _buildRemoveAllButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () {
          // Get all item keys and trigger snap animation
          final wishlistItemKeys = List.generate(
            widget.provider.wishlistItems.length,
            (index) => GlobalKey<SnappableWishlistItemState>(),
          );

          // Show confirmation with QuickAlert instead of standard AlertDialog
          QuickAlert.show(
            context: context,
            type: QuickAlertType.confirm,
            title: 'clear_wishlist'.tr(context),
            text: 'clear_wishlist_confirmation'.tr(context),
            confirmBtnText: 'clear'.tr(context),
            cancelBtnText: 'cancel'.tr(context),
            confirmBtnColor: AppTheme.accentColor,
            cancelBtnTextStyle: context.titleMedium.copyWith(fontWeight: FontWeight.w600,color: AppTheme.lightSecondaryTextColor),
            confirmBtnTextStyle: context.titleMedium.copyWith(fontWeight: FontWeight.w600,color: AppTheme.white),
            onConfirmBtnTap: () {
              Navigator.pop(context);
              
              // Use clearWishlist instead of iterating and removing
              widget.provider.clearWishlist();

              CustomToast.showToast(message: 'wishlist_cleared'.tr(context),type: ToastType.success);
            },
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_outline,
              color: AppTheme.accentColor,
            ),
            const SizedBox(width: 4),
            Text(
              'remove_all'.tr(context),
              style: context.titleSmall.copyWith(fontWeight: FontWeight.w700,color: AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistItem(
    BuildContext context,
    wishlistItem,
    WishlistProvider provider,
  ) {
    final GlobalKey<SnappableWishlistItemState> snappableKey =
        GlobalKey<SnappableWishlistItemState>();

    return SnappableWishlistItem(
      key: snappableKey,
      slug: wishlistItem.slug,
      child: InkWell(
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
                      borderRadius: const BorderRadius.only(
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
                          maxLines: 2,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price
                            Text(
                              '${wishlistItem.price}',
                              style: context.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const CustomImage(
                                  assetPath: AppSvgs.cart_white,
                                ),
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
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: () {
                    // Trigger the snap effect before removing item
                    snappableKey.currentState?.startSnap();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
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
                    child: const Icon(
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
      ),
    );
  }
}
