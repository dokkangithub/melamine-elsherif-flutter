import 'package:flutter/material.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/set_product_card.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/core/utils/widgets/see_all_widget.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/features/presentation/set products/controller/set_product_provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/featured_products_shimmer.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/featured_product_card.dart';

class SetProductsWidget extends StatelessWidget {
  const SetProductsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SetProductsProvider>(
      builder: (context, setProductsProvider, child) {
        // TODO: Replace with actual set products state and data
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
        final filteredProducts = products.where((product) => product.published.toString() == '1').toList();

        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SeeAllWidget(
                title: 'customize_yours'.tr(context),
                onTap: () {
                  AppRoutes.navigateTo(context, AppRoutes.setProductsScreen);
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 330,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 16.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) => 
                    SetProductCard(
                      setProduct: filteredProducts[index],
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
