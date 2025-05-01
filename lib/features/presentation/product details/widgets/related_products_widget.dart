import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/product details/widgets/product_theme.dart';
import 'package:melamine_elsherif/features/presentation/product details/widgets/shimmers/shimmer_widget.dart';

import '../../../../core/utils/product cards/custom_gridview_prodcut.dart';

class RelatedProductsWidget extends StatelessWidget {
  final HomeProvider provider;

  const RelatedProductsWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('related_products'.tr(context),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (provider.relatedProductsState == LoadingState.loading)
            const ShimmerWidget(height: 200)
          else if (provider.relatedProductsState == LoadingState.error)
            Center(
                child: Text('Error: ${provider.relatedProductsError}',
                    style: const TextStyle(color: ProductTheme.errorColor)))
          else if (provider.relatedProducts.isEmpty)
               Center(child: Text('no_related_products_available'.tr(context)))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: provider.relatedProducts.length,
                itemBuilder: (context, index) {
                  final product = provider.relatedProducts[index];
                  return ProductGridCard(
                      product: product
                  );
                },
              ),
        ],
      ),
    );
  }
}