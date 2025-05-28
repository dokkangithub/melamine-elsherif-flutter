import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/core/utils/widgets/see_all_widget.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/enums/products_type.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/featured_products_shimmer.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/featured_product_card.dart';

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
          return _buildEmptyState();
        }

        // Get products data
        final products = homeProvider.featuredProducts;

        // Show empty state if no products
        if (products.isEmpty) {
          return _buildEmptyState();
        }
        final filteredProducts = products.where((product) => product.published.toString() == '1').toList();

        // Show products list
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                child: Text(
                  'featured_collection'.tr(context),
                  style: context.headlineMedium,
                ),
              ),
              SizedBox(
                height: 290,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 16.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) => 
                    FeaturedProductCard(
                      product: filteredProducts[index],
                      width: 220,
                    ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox.shrink();
  }
}
