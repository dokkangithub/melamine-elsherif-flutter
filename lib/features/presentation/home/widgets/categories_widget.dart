import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/core/utils/extension/responsive_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/see_all_widget.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/features/presentation/category/controller/provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/category_card.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/categories_shimmer.dart';
import 'package:melamine_elsherif/features/presentation/main layout/controller/layout_provider.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        // Show shimmer while loading
        if (categoryProvider.categoriesState == LoadingState.loading) {
          return const CategoriesShimmer();
        }

        // Show error state
        if (categoryProvider.featuredCategoriesState == LoadingState.error) {
          return _buildEmptyState();
        }

        // Get categories data
        final categories = categoryProvider.categoriesResponse?.data ?? [];

        // Show empty state if no categories
        if (categories.isEmpty) {
          return _buildEmptyState();
        }

        // Only display first 4 categories
        final displayCategories = categories.take(4).toList();


        // Show categories grid
        return Container(
          padding: const EdgeInsets.only(top: 0.0, bottom: 16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: displayCategories.length,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => CategoryCard(
              imageUrl: displayCategories[index].coverImage ?? '',
              // Use predefined display names for better UI match
              name: displayCategories[index].name??'',
              onTap: () {
                AppRoutes.navigateTo(
                  context,
                  AppRoutes.allCategoryProductsScreen,
                  arguments: {
                    'category': displayCategories[index],
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox.shrink();
  }
}