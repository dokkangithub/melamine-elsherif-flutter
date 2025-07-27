import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import '../controller/layout_provider.dart';
import '../../cart/controller/cart_provider.dart';
import '../../wishlist/controller/wishlist_provider.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<LayoutProvider, CartProvider, WishlistProvider>(
      builder: (context, layoutProvider, cartProvider, wishlistProvider, _) {
        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.lightSecondaryTextColor,
            currentIndex: layoutProvider.currentIndex,
            onTap: (int index) {
              if (index == 2 && AppStrings.token == null) {
                AppRoutes.navigateTo(context, AppRoutes.login);
                layoutProvider.setCurrentIndex(0);
                return;
              }
              layoutProvider.setCurrentIndex(index);
            },
            useLegacyColorScheme: false,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            enableFeedback: false,
            selectedFontSize: 12.0,
            unselectedFontSize: 10.0,
            selectedLabelStyle: context.titleSmall!.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
            unselectedLabelStyle: context.bodySmall,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const CustomImage(assetPath: AppSvgs.home_icon),
                activeIcon: const CustomImage(assetPath: AppSvgs.active_home_icon),
                label: 'home'.tr(context).toUpperCase(),
              ),
              BottomNavigationBarItem(
                icon: const CustomImage(assetPath: AppSvgs.category_icon),
                activeIcon: const CustomImage(
                  assetPath: AppSvgs.active_category_icon,
                ),
                label: 'category'.tr(context).toUpperCase(),
              ),
              BottomNavigationBarItem(
                icon: _buildIconWithBadge(
                  icon: const CustomImage(assetPath: AppSvgs.wishlist_icon),
                  count: wishlistProvider.wishlistItems.length,
                  isActive: false,
                ),
                activeIcon: _buildIconWithBadge(
                  icon: const CustomImage(assetPath: AppSvgs.active_wishlist_icon),
                  count: wishlistProvider.wishlistItems.length,
                  isActive: true,
                ),
                label: 'wishlist'.tr(context).toUpperCase(),
              ),
              BottomNavigationBarItem(
                icon: _buildIconWithBadge(
                  icon: const CustomImage(assetPath: AppSvgs.cart_icon),
                  count: cartProvider.cartCount,
                  isActive: false,
                ),
                activeIcon: _buildIconWithBadge(
                  icon: const CustomImage(assetPath: AppSvgs.active_cart_icon),
                  count: cartProvider.cartCount,
                  isActive: true,
                ),
                label: 'cart'.tr(context).toUpperCase(),
              ),
              BottomNavigationBarItem(
                icon: const CustomImage(assetPath: AppSvgs.profile_icon),
                activeIcon: const CustomImage(assetPath: AppSvgs.active_profile_icon),
                label: 'profile'.tr(context).toUpperCase(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconWithBadge({
    required Widget icon,
    required int count,
    required bool isActive,
  }) {
    if (count == 0) {
      // Return the icon without badge if count is 0
      return icon;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          right: -10,
          top: -10,
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: AppTheme.white,
                width: 1,
              ),
            ),
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}