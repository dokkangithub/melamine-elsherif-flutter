import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/core/utils/widgets/see_all_widget.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/enums/products_type.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/featured_products_shimmer.dart';

import '../../../../core/utils/product cards/custom_product_card.dart';

class FeaturedProductsWidget extends StatelessWidget {
  const FeaturedProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Show shimmer while loading
        if (homeProvider.featuredProductsState == LoadingState.loading) {
          return const FeaturedProductsShimmer();
        }

        // Show error state
        if (homeProvider.featuredProductsState == LoadingState.error) {
          return _buildEmptyState(context, "no_products_available".tr(context));
        }

        // Get products data
        final products = homeProvider.featuredProducts;

        // Show empty state if no products
        if (products.isEmpty) {
          return _buildEmptyState(
            context,
            "no_featured_products_available".tr(context),
          );
        }
        final filteredProducts = products.where((product) => product.published == 1).toList();

        // Show products list
        return Column(
          children: [
            SeeAllWidget(
              title: 'feature_products'.tr(context),
              onTap: () {
                AppRoutes.navigateTo(
                  context,
                  AppRoutes.allProductsByTypeScreen,
                  arguments: {
                    'productType': ProductType.featured,
                    'title': 'feature_products'.tr(context),
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredProducts.length,
                itemBuilder:
                    (context, index) => ProductCard(product: filteredProducts[index]),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildEmptyState(BuildContext context, String message) {
    return const SizedBox.shrink();
  }
}
