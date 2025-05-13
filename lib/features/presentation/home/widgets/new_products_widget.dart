import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:melamine_elsherif/core/utils/widgets/see_all_widget.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/enums/products_type.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/new_products_shimmer.dart';

import '../../../../core/utils/product cards/custom_gridview_prodcut.dart';
import '../../../../core/utils/product cards/custom_product_card.dart';
import '../../../../core/utils/product cards/custom_product_row.dart';

class NewProductsWidget extends StatelessWidget {
  const NewProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Show shimmer while loading
        if (homeProvider.newProductsState == LoadingState.loading) {
          return const NewProductsShimmer();
        }

        // Show error state
        if (homeProvider.newProductsState == LoadingState.error) {
          return _buildEmptyState(context, "no_products_available".tr(context));
        }

        // Get products data
        final products = homeProvider.newProducts;

        // Show empty state if no products
        if (products.isEmpty) {
          return _buildEmptyState(
            context,
            "no_new_products_available".tr(context),
          );
        }

        // Show products carousel
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SeeAllWidget(
              title: 'new_arrival'.tr(context),
              onTap: () {
                AppRoutes.navigateTo(
                  context,
                  AppRoutes.allProductsByTypeScreen,
                  arguments: {
                    'productType': ProductType.newArrival,
                    'title': 'new_arrival_products'.tr(context),
                  },
                );
              },
            ),
            SizedBox(
              height: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder:
                    (context, index) => ProductCard(product: products[index],isOutlinedAddToCart: true),
              ),
            ),
            ///gridView
            // GridView.builder(
            //   physics: const NeverScrollableScrollPhysics(),
            //   shrinkWrap: true,
            //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: 2,
            //     childAspectRatio: 0.75,
            //     crossAxisSpacing: 16,
            //     mainAxisSpacing: 16,
            //   ),
            //   itemCount: products.length > 8 ? 8 : products.length,
            //   itemBuilder: (context, index) {
            //     final product = products[index];
            //     return ProductGridCard(product: product);
            //   },
            // ),
          ],
        );
      },
    );
  }


  Widget _buildEmptyState(BuildContext context, String message) {
    return const SizedBox.shrink();
  }
}
