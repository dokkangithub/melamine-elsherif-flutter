import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/product details/widgets/product_theme.dart';
import 'package:melamine_elsherif/features/presentation/product details/widgets/shimmers/shimmer_widget.dart';

import '../../../../core/utils/product cards/custom_product_card_for_all_products.dart';

class RelatedProductsWidget extends StatelessWidget {
  final HomeProvider provider;
  final bool useCategoryProducts;

  const RelatedProductsWidget({super.key, required this.provider, this.useCategoryProducts = false});

  @override
  Widget build(BuildContext context) {
    final loadingState = useCategoryProducts
        ? provider.categoryProductsState
        : provider.relatedProductsState;
    final errorText = useCategoryProducts
        ? provider.categoryProductsError
        : provider.relatedProductsError;
    final products = useCategoryProducts
        ? provider.categoryProducts
        : provider.relatedProducts;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('related_products'.tr(context), style: context.headlineSmall),
          const SizedBox(height: 8),
          if (loadingState == LoadingState.loading)
            const ShimmerWidget(height: 200)
          else if (loadingState == LoadingState.error)
            Center(
              child: Text(
                'Error: $errorText',
                style: const TextStyle(color: ProductTheme.errorColor),
              ),
            )
          else if (products.isEmpty)
            Center(child: Text('no_related_products_available'.tr(context)))
          else
            Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return CustomProductCardForAllProducts(product: product);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
