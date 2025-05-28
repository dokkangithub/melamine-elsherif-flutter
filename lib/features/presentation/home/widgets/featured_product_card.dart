import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/features/domain/product/entities/product.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';

class FeaturedProductCard extends StatelessWidget {
  final Product product;
  final double width;
  
  const FeaturedProductCard({
    Key? key,
    required this.product,
    this.width = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.productDetailScreen,
          arguments: {'slug': product.slug},
        );
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomImage(
                  imageUrl: product.thumbnailImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Collection Text
            Text(
              product.name,
              style: context.titleLarge!.copyWith(fontWeight: FontWeight.w600),
            ),
            
            // Price
            Text(
              product.discountedPrice,
              style: context.titleLarge!.copyWith(fontWeight: FontWeight.w600,color: AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
} 