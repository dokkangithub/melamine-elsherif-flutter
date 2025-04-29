import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:melamine_elsherif/core/utils/widgets/see_all_widget.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/enums/products_type.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/new_products_shimmer.dart';

import '../../../../core/utils/product cards/custom_product_card.dart';
import '../../../../core/utils/product cards/custom_product_row.dart';

class TodayDealsProductsWidget extends StatelessWidget {
  const TodayDealsProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Show shimmer while loading
        if (homeProvider.todaysDealProductsState == LoadingState.loading) {
          return const NewProductsShimmer();
        }

        // Show error state
        if (homeProvider.todaysDealProductsState == LoadingState.error) {
          return _buildEmptyState(context, "no_products_available".tr(context));
        }

        // Get products data
        final products = homeProvider.todaysDealProducts;

        // Show empty state if no products
        if (products.isEmpty) {
          return _buildEmptyState(
            context,
            "no_new_products_available".tr(context),
          );
        }
        final filteredProducts = products.where((product) => product.published == 1).toList();

        // Show products carousel
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SeeAllWidget(
              title: 'today_deals'.tr(context),
              onTap: () {
                AppRoutes.navigateTo(
                  context,
                  AppRoutes.allProductsByTypeScreen,
                  arguments: {
                    'productType': ProductType.todaysDeal,
                    'title': 'today_deal_products'.tr(context),
                  },
                );
              },
            ),

            SizedBox(
              height: 340,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredProducts.length,
                itemBuilder:
                    (context, index) => ProductCard(product: filteredProducts[index],isOutlinedAddToCart: true),
              ),
            ),
            ///carousal slider
            // CarouselSlider.builder(
            //   itemCount: filteredProducts.length,
            //   options: CarouselOptions(
            //     height: 175,
            //     viewportFraction: 0.98,
            //     enableInfiniteScroll: filteredProducts.length > 3,
            //     autoPlay: filteredProducts.length > 1,
            //     autoPlayInterval: const Duration(seconds: 5),
            //     enlargeCenterPage: true,
            //     padEnds: true,
            //   ),
            //   itemBuilder: (context, index, realIndex) {
            //     final product = filteredProducts[index];
            //     return Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //       child: ProductItemInRow1(product: product),
            //     );
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
