import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';

class CategoryCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0), // Square corners
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            CustomImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
            ),
            
            // Dark overlay
            Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
            
            // Category name
            Align(
              alignment: Alignment.center,
              child: Text(
                name.toUpperCase(),
                style: context.headlineMedium!.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w700
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}