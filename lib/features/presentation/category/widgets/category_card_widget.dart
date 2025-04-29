import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../../../data/category/models/category_model.dart';
import '../../../domain/category/entities/category.dart';
import '../../all products/screens/all_category_products.dart';

class CategoryCardInCategoryScreen extends StatelessWidget {
  final Category category;

  CategoryCardInCategoryScreen({
    super.key,
    required this.category,
  });

  final List<String> categoryCardIcons = [
    AppSvgs.category_card_1,
    AppSvgs.category_card_2,
    AppSvgs.category_card_3,
    AppSvgs.category_card_4,
    AppSvgs.category_card_5,
    AppSvgs.category_card_6,
    AppSvgs.category_card_7,
    AppSvgs.category_card_8,
  ];

  @override
  Widget build(BuildContext context) {
    final randomIcon = categoryCardIcons[Random().nextInt(categoryCardIcons.length)];

    return InkWell(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.allCategoryProductsScreen,
          arguments: {
            'category': category,
          },
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Stack(
              children: [
                CustomImage(
                  imageUrl: category.banner,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 150,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.6),
                            AppTheme.primaryColor.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                          stops: [0.05,0.6,0.9]
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentColor,
                ),
                child: CustomImage(
                  assetPath: randomIcon,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 6,
              child: Text(
                category.name!,
                maxLines: 1,
                style: context.titleMedium.copyWith(color: AppTheme.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}