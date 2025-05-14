import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/responsive_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
// import 'package:provider/provider.dart'; // Not needed if wishlist icon is removed for now
import '../../../../features/domain/product/entities/product.dart';
// import '../../../../features/presentation/wishlist/controller/wishlist_provider.dart'; // Not needed
import '../../../../core/config/routes.dart/routes.dart';
// import '../../utils/helpers.dart'; // Not needed if wishlist icon is removed
import '../widgets/custom_cached_image.dart';

class CustomProductCardForAllProducts extends StatelessWidget {
  final Product product;

  const CustomProductCardForAllProducts({
    super.key,
    required this.product,
    // availableAddToCart is removed as it's not used for UI in this version
  });

  Widget _buildRatingStars(BuildContext context, double ratingValue) {
    List<Widget> stars = [];
    int fullStars = ratingValue.floor();
    double remainder = ratingValue - fullStars;
    const starColor = Color(0xFFD9534F);
    const starSize = 14.0; // Reduced star size

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, color: starColor, size: starSize));
      } else if (i == fullStars && remainder >= 0.25) {
        stars.add(const Icon(Icons.star_half, color: starColor, size: starSize));
      } else {
        stars.add(const Icon(Icons.star_border, color: starColor, size: starSize));
      }
      if (i < 4) stars.add(const SizedBox(width: 1.0)); // Reduced spacing between stars
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    final double averageRating = (product.rating ?? 0).toDouble();
    final currentTextDirection = Directionality.of(context);

    return InkWell(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.productDetailScreen,
          arguments: {'slug': product.slug},
        );
      },
      child: Container(
        width: context.responsive(170), 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // Image has slightly less rounding
          border: Border.all(color: Colors.grey.shade300, width: 0.8), // Thinner border
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              spreadRadius: 0.5,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
            children: [
              // Product image
              AspectRatio(
                aspectRatio: 1.05, // Image seems slightly taller than wide, or square
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6), // Less rounding for image corners
                  child: CustomImage(
                    width: double.infinity,
                    imageUrl: product.thumbnailImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 4), 

              // Product details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Important for Column within Column
                  children: [
                    Align(
                      alignment: currentTextDirection == TextDirection.rtl ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        product.name,
                        style: context.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.black,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: currentTextDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                        textDirection: currentTextDirection,
                      ),
                    ),
                    const SizedBox(height: 2),
                    
                    _buildRatingStars(context, averageRating),
                    
                    const SizedBox(height: 2),
                    
                    Align(
                      alignment: currentTextDirection == TextDirection.rtl ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        product.discountedPrice,
                        style: context.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                        textAlign: currentTextDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                        textDirection: currentTextDirection,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 