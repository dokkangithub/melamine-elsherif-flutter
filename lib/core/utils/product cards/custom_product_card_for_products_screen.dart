import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/responsive_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import '../../../../features/domain/set products/entities/set_products.dart';
import '../widgets/custom_cached_image.dart';
import '../../../features/presentation/set products/screens/set_product_details_screen.dart';

class CustomProductCardForProductsScreen extends StatelessWidget {
  final SetProduct product;

  const CustomProductCardForProductsScreen({
    super.key,
    required this.product,
  });


  @override
  Widget build(BuildContext context) {
    final double averageRating = 0.0;
    final currentTextDirection = Directionality.of(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetProductDetailsScreen(
              slug: product.slug ?? '',
              fromProductsTab: true,
            ),
          ),
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
            // Product image
            AspectRatio(
              aspectRatio: 1.05,
              child: CustomImage(
                width: double.infinity,
                imageUrl: product.thumbnailImage,
                fit: BoxFit.contain,
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
                    child: Row(
                      spacing: 4,
                      children: [
                        Text(
                          '${product.fullSetPrice ?? 0} L.E',
                          style: context.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryColor,
                          ),
                          textAlign: currentTextDirection == TextDirection.rtl
                              ? TextAlign.right
                              : TextAlign.left,
                          textDirection: currentTextDirection,
                        ),
                        // Note: Set products don't have discount price for now
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
