import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/features/presentation/search/widgets/shimmer/popular_searches_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../set products/controller/set_product_provider.dart';
import '../../home/widgets/set_product_card.dart';

class PopularSearches extends StatelessWidget {
  const PopularSearches({
    super.key,
    this.isLoading = false,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Consumer<SetProductsProvider>(
      builder: (context, setProductsProvider, _) {
        final loadingState = setProductsProvider.setProductsState;
        final setProducts = setProductsProvider.setProducts;

        // Show loading shimmer while loading
        if (loadingState == LoadingState.loading && setProducts.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'most_searched'.tr(context),
                  style: context.headlineSmall!.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              const PopularSearchesShimmer(),
            ],
          );
        }

        // Filter published set products
        final filteredSetProducts = setProducts
            .where((product) => product.published == true)
            .toList();

        // Get first 10 set products for most searched
        final mostSearchedSetProducts = filteredSetProducts.take(10).toList();

        if (mostSearchedSetProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'most_searched'.tr(context),
                style: context.headlineSmall!.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(
              height: 300, // Increased height to accommodate set product cards
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: mostSearchedSetProducts.length,
                itemBuilder: (context, index) {
                  final setProduct = mostSearchedSetProducts[index];
                  return FadeInUp( // تغيير الانيميشن من Down إلى Up
                    delay: Duration(milliseconds: 100 + (index * 100)),
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SetProductCard(
                        setProduct: setProduct,
                        width: 190,
                        index: index,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
