import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/helpers.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/cutsom_toast.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/widgets/shimmer/wishlist_screen_shimmer.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/widgets/snappable_wishlist_item.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../../../../core/widgets/custom_confirmation_dialog.dart';
import '../../../domain/wishlist/entities/wishlist_details.dart';
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
    // If wishlist is empty, return the full-screen empty widget
    if (widget.provider.wishlistState != LoadingState.loading && 
        widget.provider.wishlistItems.isEmpty) {
      return const EmptyWishlistWidget();
    }
    
    // If wishlist has items, show the regular layout with AppBar
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'my_wishlist'.tr(context),
          style: context.displaySmall.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: widget.provider.wishlistState == LoadingState.loading
          ? const WishlistScreenShimmer()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Remove All button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _showClearWishlistDialog(context),
                      icon: const Icon(Icons.delete_outline, color: AppTheme.accentColor),
                      label: Text(
                        'remove_all'.tr(context),
                        style: context.titleSmall.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                    ),
                  ),
                  
                  // Products grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 1,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: widget.provider.wishlistItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.provider.wishlistItems[index];
                        if (item.name == "Loading...") {
                          return const SizedBox.shrink();
                        }
                        
                        return _buildProductCard(context, item);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProductCard(BuildContext context, WishlistItem wishlistItem) {
    final GlobalKey<SnappableWishlistItemState> snappableKey =
        GlobalKey<SnappableWishlistItemState>();

    return SnappableWishlistItem(
      key: snappableKey,
      slug: wishlistItem.slug,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Product image with favorite icon
            Expanded(
              child: Stack(
                children: [
                  // Product image
                  GestureDetector(
                    onTap: () => _navigateToProductDetails(context, wishlistItem.slug),
                    child: ClipRRect(
                      child: CustomImage(
                        imageUrl: wishlistItem.thumbnailImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  // Remove button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () {
                        snappableKey.currentState?.startSnap();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_outlined,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Product details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product title
                  GestureDetector(
                    onTap: () => _navigateToProductDetails(context, wishlistItem.slug),
                    child: Text(
                      wishlistItem.name,
                      style: context.headlineMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Rating bar instead of category
                  Row(
                    children: [
                      // Star icons based on rating
                      ...List.generate(5, (index) {
                        return Icon(
                          index < wishlistItem.rating.floor()
                              ? Icons.star
                              : index < wishlistItem.rating
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: const Color(0xFFFFB800),
                          size: 16,
                        );
                      }),
                      const SizedBox(width: 4),
                      // Rating count in parentheses
                      if (wishlistItem.ratingCount > 0)
                        Text(
                          "(${wishlistItem.ratingCount})",
                          style: context.titleSmall.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Price and Add to Cart button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        wishlistItem.price,
                        style: context.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      
                      // Add to Cart button
                      SizedBox(
                        height: 42,
                        child: CustomButton(
                          onPressed: () => _addToCart(context, wishlistItem),
                          child: Text(
                            'add_to_cart'.tr(context),
                            style: context.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }

  void _navigateToProductDetails(BuildContext context, String slug) {
    AppRoutes.navigateTo(
      context,
      AppRoutes.productDetailScreen,
      arguments: {'slug': slug},
    );
  }
  
  void _addToCart(BuildContext context, wishlistItem) {
    AppFunctions.addProductToCart(
      context: context,
      productId: wishlistItem.productId,
      productName: wishlistItem.name,
      productSlug: wishlistItem.slug,
      hasVariation: wishlistItem.hasVariation,
    );
  }
  
  void _showClearWishlistDialog(BuildContext context) {
    showCustomConfirmationDialog(
      context: context,
      title: 'clear_wishlist'.tr(context),
      message: 'clear_wishlist_confirmation'.tr(context),
      confirmText: 'clear'.tr(context),
      cancelText: 'cancel'.tr(context),
      icon: Icons.delete_outline,
      confirmButtonColor: AppTheme.accentColor,
      onConfirm: () {
        widget.provider.clearWishlist();
        CustomToast.showToast(message: 'wishlist_cleared'.tr(context), type: ToastType.success);
      },
    );
  }
}
