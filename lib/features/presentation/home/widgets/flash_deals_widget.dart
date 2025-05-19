import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/product%20cards/custom_product_card.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/core/utils/widgets/see_all_widget.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/enums/products_type.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/shimmer/new_products_shimmer.dart';
import 'package:melamine_elsherif/core/utils/product cards/custom_product_row.dart';
import 'package:melamine_elsherif/features/domain/product/entities/flash_deal.dart';

class FlashDealsWidget extends StatelessWidget {
  const FlashDealsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Show shimmer while loading
        if (homeProvider.flashDealProductsState == LoadingState.loading) {
          return const NewProductsShimmer();
        }

        // Show error state
        if (homeProvider.flashDealProductsState == LoadingState.error) {
          return const SizedBox.shrink();
        }

        // Get flash deals data
        final deals = homeProvider.flashDeals;

        // Show empty state if no deals
        if (deals.isEmpty) {
          return const SizedBox.shrink();
        }

        // Create a list of sections, one for each flash deal
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: deals.map((deal) => _buildFlashDealSection(context, deal)).toList(),
        );
      },
    );
  }

  Widget _buildFlashDealSection(BuildContext context, FlashDeal deal) {
    // Filter published products
    final products = deal.products;
    
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and see all option
        SeeAllWidget(
          title: deal.title,
          onTap: () {
            AppRoutes.navigateTo(
              context,
              AppRoutes.allProductsByTypeScreen,
              arguments: {
                'productType': ProductType.flashDeal,
                'title': deal.title,
                'deal_id': deal.id,
              },
            );
          },
        ),
        
        // Banner image if available
        if (deal.banner.isNotEmpty && !deal.banner.toString().contains('placeholder'))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImage(
                imageUrl:  deal.banner,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        
        // Products list
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) => 
                ProductCard(product: products[index],isOutlinedAddToCart: true),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
} 