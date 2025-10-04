import 'package:flutter/material.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/set_product_card.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/core/utils/widgets/see_all_widget.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/all_products_shimmer.dart';

class AllProductsWidget extends StatelessWidget {
  const AllProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Show shimmer while loading
        if (homeProvider.allSetProductsState == LoadingState.loading) {
          return const AllProductsShimmer();
        }

        // Show error state
        if (homeProvider.allSetProductsState == LoadingState.error) {
          return _buildEmptyState(
            context,
            "Couldn't load products: ${homeProvider.allSetProductsError}".tr(
              context,
            ),
          );
        }

        // Get set products data
        final allSetProducts = homeProvider.allSetProducts;

        // Show empty state if no products
        if (allSetProducts.isEmpty) {
          return _buildEmptyState(context, "no_products_available".tr(context));
        }

        // Filter only published products
        final filteredProducts = allSetProducts
            .where((product) => product.published == true)
            .toList();

        // Show empty state if no published products
        if (filteredProducts.isEmpty) {
          return _buildEmptyState(context, "no_products_available".tr(context));
        }

        // Show products grid
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SeeAllWidget(
              title: 'all_products'.tr(context),
              onTap: () {
                AppRoutes.navigateTo(
                  context,
                  AppRoutes.setProductsScreen,
                );
              },
            ),
            GridView.builder(
              padding:const EdgeInsets.symmetric(vertical: 15),

              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing:0,
                mainAxisSpacing: 5,
              ),
              itemCount: filteredProducts.length > 8
                  ? 8
                  : filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return SetProductCard(setProduct: product, width: 200);
              },
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
