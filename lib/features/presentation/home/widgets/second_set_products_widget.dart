import 'package:flutter/material.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/set_product_card.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/core/utils/widgets/see_all_widget.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/features/presentation/set products/controller/set_product_provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/featured_products_shimmer.dart';

class SecondSetProductsWidget extends StatelessWidget {
  const SecondSetProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SetProductsProvider>(
      builder: (context, setProductsProvider, child) {
        final loadingState = setProductsProvider.setProductsState;
        final products = setProductsProvider.setProducts;

        if (loadingState == LoadingState.loading) {
          return const FeaturedProductsShimmer();
        }
        if (loadingState == LoadingState.error) {
          return _buildEmptyState();
        }
        if (products.isEmpty) {
          return _buildEmptyState();
        }

        final filteredProducts = products.where((product) => product.published == true).toList();

        // Get next 10 products (from index 10 to 19) for the center section
        final nextTenProducts = filteredProducts.skip(10).take(10).toList();

        if (nextTenProducts.isEmpty) {
          return _buildEmptyState();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SeeAllWidget(
                title: 'build_premium_sets'.tr(context), // Different title
                onTap: () {
                  AppRoutes.navigateTo(context, AppRoutes.setProductsScreen);
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 16.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: nextTenProducts.length,
                  itemBuilder: (context, index) =>
                      SetProductCard(
                        setProduct: nextTenProducts[index],
                        width: 250,
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