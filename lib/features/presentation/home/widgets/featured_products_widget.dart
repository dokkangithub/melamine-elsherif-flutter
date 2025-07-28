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

class FeaturedProductsWidget extends StatefulWidget {
  const FeaturedProductsWidget({super.key});

  @override
  State<FeaturedProductsWidget> createState() => _FeaturedProductsWidgetState();
}

class _FeaturedProductsWidgetState extends State<FeaturedProductsWidget>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Auto-scroll to center the first few cards initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          20.0, // Small offset to trigger initial animation
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });

    // Start fade animation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

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

        final filteredProducts = products
            .where((product) => product.published.toString() == '1')
            .toList();

        // Show products list with scroll-based animation
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SeeAllWidget(
                    title: 'featured_collection'.tr(context),
                    onTap: () {
                      AppRoutes.navigateTo(
                        context,
                        AppRoutes.allProductsByTypeScreen,
                        arguments: {
                          'productType': ProductType.featured,
                          'title': 'featured_collection'.tr(context),
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Scroll-animated products list
                SizedBox(
                  height: 330,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) => FeaturedProductCard(
                      product: filteredProducts[index],
                      scrollController: _scrollController,
                      index: index,
                      width: 250,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox.shrink();
  }
}