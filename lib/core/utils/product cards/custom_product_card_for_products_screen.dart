import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/responsive_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import '../../../../features/domain/set products/entities/set_products.dart';
import '../widgets/custom_cached_image.dart';
import '../../../core/config/routes.dart/routes.dart';

class CustomProductCardForProductsScreen extends StatelessWidget {
  final SetProduct product;

  const CustomProductCardForProductsScreen({
    super.key,
    required this.product,
  });


  @override
  Widget build(BuildContext context) {
    final currentTextDirection = Directionality.of(context);
    
    // Get the current price (which is after discount)
    final currentPrice = product.fullSetPrice ?? 0;
    // Calculate original price by adding 10% to current price
    final originalPrice = currentPrice * 1.1;
    final discountAmount = originalPrice - currentPrice;

    return InkWell(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.setProductDetailsScreen,
          arguments: {
            'slug': product.slug ?? '',
            'fromProductsTab': true,
          },
        );
      },
      child: Container(
        width: context.responsive(170),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with discount badge
            AspectRatio(
              aspectRatio: 1.05,
              child: Stack(
                children: [
                  CustomImage(
                    width: double.infinity,
                    imageUrl: product.thumbnailImage,
                    fit: BoxFit.contain,
                  ),
                  // Discount badge
                  Positioned(
                    top: 2,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor, // Primary color
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentColor,
                            AppTheme.accentColor.withOpacity(0.8),
                            AppTheme.accentColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '- ${discountAmount.toInt()} L.E',
                        style: context.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Product details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // Important for Column within Column
                children: [
                  Align(
                    alignment: currentTextDirection == TextDirection.rtl
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      product.name ?? '',
                      style: context.titleLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.black,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: currentTextDirection == TextDirection.rtl
                          ? TextAlign.right
                          : TextAlign.left,
                      textDirection: currentTextDirection,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Align(
                    alignment: currentTextDirection == TextDirection.rtl
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: currentTextDirection == TextDirection.rtl
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        // Show current price (after discount)
                        Text(
                          '${currentPrice.toInt()} L.E',
                          style: context.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryColor,
                          ),
                          textAlign: currentTextDirection == TextDirection.rtl
                              ? TextAlign.right
                              : TextAlign.left,
                          textDirection: currentTextDirection,
                        ),
                        // Show original price (current price + 10%) with strikethrough
                        Text(
                          '${originalPrice.toInt()} L.E',
                          style: context.titleMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: AppTheme.lightSecondaryTextColor,
                            decoration: TextDecoration.lineThrough,
                          ),
                          textAlign: currentTextDirection == TextDirection.rtl
                              ? TextAlign.right
                              : TextAlign.left,
                          textDirection: currentTextDirection,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
