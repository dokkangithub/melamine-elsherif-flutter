import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/features/domain/set%20products/entities/set_products.dart';

class SetProductCard extends StatelessWidget {
  final SetProduct setProduct;
  final double width;

  const SetProductCard({
    super.key,
    required this.setProduct,
    this.width = 250,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.productDetailScreen,
          arguments: {'slug': setProduct.slug},
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
                  imageUrl: setProduct.thumbnailImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Collection Text
            Text(
              setProduct.name!,
              maxLines: 2,
              style: context.titleLarge!.copyWith(fontWeight: FontWeight.w600),
            ),

            // Price
            Text(
              setProduct.discountedPrice!,
              style: context.titleLarge!.copyWith(fontWeight: FontWeight.w600,color: AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}