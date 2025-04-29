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
          return _buildEmptyState(context, "no_categories_available".tr(context));
        }

        // Get categories data
        final categories = categoryProvider.categoriesResponse?.data ?? [];

        // Show empty state if no categories
        if (categories.isEmpty) {
          return _buildEmptyState(
            context,
            "no_categories_available".tr(context),
          );
        }


        // Show categories grid
        return SizedBox(
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SeeAllWidget(
              //   title: 'categories'.tr(context),
              //   onTap: () {
              //     Provider.of<LayoutProvider>(context, listen: false)
              //         .currentIndex = 1;
              //   },
              // ),
              // const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => CategoryCard(
                    imageUrl: categories[index].banner ?? '',
                    name: categories[index].name ?? 'Category',
                    onTap: () {
                      AppRoutes.navigateTo(
                        context,
                        AppRoutes.allCategoryProductsScreen,
                        arguments: {
                          'category': categories[index],
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return const SizedBox.shrink();
  }
}