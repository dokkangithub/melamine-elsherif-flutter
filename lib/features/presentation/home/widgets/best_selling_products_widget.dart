import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/core/utils/widgets/see_all_widget.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/enums/products_type.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/best_selling_products_shimmer.dart';

import '../../../../core/utils/product cards/custom_product_card.dart';

class BestSellingProductsWidget extends StatelessWidget {
  const BestSellingProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Show shimmer while loading
        if (homeProvider.bestSellingProductsState == LoadingState.loading) {
          return const BestSellingProductsShimmer();
        }

        // Show error state
        if (homeProvider.bestSellingProductsState == LoadingState.error) {
          return _buildEmptyState(
            context,
            "couldnt_load_best_selling_products".tr(context),
          );
        }

        // Get products data
        final products = homeProvider.bestSellingProducts;

        // Show empty state if no products
        if (products.isEmpty) {
          return _buildEmptyState(
            context,
            "no_best_selling_products_available".tr(context),
          );
        }

        final filteredProducts = products.where((product) => product.published == 1).toList();
        // Show products list
        return Column(
          children: [
            SeeAllWidget(
              title: 'best_seller'.tr(context),
              onTap: () {
                AppRoutes.navigateTo(
                  context,
                  AppRoutes.allProductsByTypeScreen,
                  arguments: {
                    'productType': ProductType.bestSelling,
                    'title': 'best_selling_products'.tr(context),
                  },
                );
              },
            ),
            SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredProducts.length,
                itemBuilder:
                    (context, index) => ProductCard(product: filteredProducts[index],isBuyNow: true,),
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
