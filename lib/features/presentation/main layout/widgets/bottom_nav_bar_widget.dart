import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import '../controller/layout_provider.dart';
import '../../cart/controller/cart_provider.dart';
import 'package:flutter/services.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LayoutProvider, CartProvider>(
      builder: (context, layoutProvider, cartProvider, _) {
        return Container(
          height: 80,
          decoration: const BoxDecoration(
            color: AppTheme.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                currentIndex: layoutProvider.currentIndex,
                icon: AppSvgs.home_icon,
                activeIcon: AppSvgs.active_home_icon,
                label: 'home'.tr(context).toUpperCase(),
                onTap: () => _handleNavigation(context, layoutProvider, 0),
              ),
              _buildNavItem(
                context: context,
                index: 1,
                currentIndex: layoutProvider.currentIndex,
                icon: AppSvgs.un_products_icon,
                activeIcon: AppSvgs.active_products_icon,
                label: 'choose_your_set'.tr(context).toUpperCase(),
                onTap: () => _handleNavigation(context, layoutProvider, 1),
              ),
              _buildNavItem(
                context: context,
                index: 2,
                currentIndex: layoutProvider.currentIndex,
                icon: AppSvgs.category_icon,
                activeIcon: AppSvgs.active_category_icon,
                label: 'category'.tr(context).toUpperCase(),
                onTap: () => _handleNavigation(context, layoutProvider, 2),
              ),
              _buildNavItemWithBadge(
                context: context,
                index: 3,
                currentIndex: layoutProvider.currentIndex,
                icon: AppSvgs.cart_icon,
                activeIcon: AppSvgs.active_cart_icon,
                label: 'cart'.tr(context).toUpperCase(),
                count: cartProvider.cartCount,
                onTap: () => _handleNavigation(context, layoutProvider, 3),
              ),
              _buildNavItem(
                context: context,
                index: 4,
                currentIndex: layoutProvider.currentIndex,
                icon: AppSvgs.profile_icon,
                activeIcon: AppSvgs.active_profile_icon,
                label: 'profile'.tr(context).toUpperCase(),
                onTap: () => _handleNavigation(context, layoutProvider, 4),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleNavigation(
    BuildContext context,
    LayoutProvider layoutProvider,
    int index,
  ) {
    HapticFeedback.lightImpact();
    layoutProvider.setCurrentIndex(index);
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required String icon,
    required String activeIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomImage(
                assetPath: isSelected ? activeIcon : icon,
                color: isSelected ? AppTheme.primaryColor : const Color(0xFFBDBDBD),
                width: 24,
                height: 24,
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    label,
                    style: context.titleSmall!.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required String icon,
    required String activeIcon,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomImage(
                    assetPath: isSelected ? activeIcon : icon,
                    color: isSelected ? AppTheme.primaryColor : const Color(0xFFBDBDBD),
                    width: 24,
                    height: 24,
                  ),
                  if (count > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.white, width: 1),
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    label,
                    style: context.titleSmall!.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
