import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_empty_widgets.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:provider/provider.dart';
import '../../../../../core/utils/enums/loading_state.dart';
import '../../../../../core/utils/product cards/custom_product_card_for_products_screen.dart';
import '../../set products/controller/set_product_provider.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Fetch initial data only if not already loaded
    Future.microtask(() async {
      final provider = Provider.of<SetProductsProvider>(context, listen: false);
      if (!provider.isDataLoaded) {
        await provider.getSetProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final provider = Provider.of<SetProductsProvider>(context, listen: false);
    
    if (!_scrollController.hasClients) return;
    
    final scrollPosition = _scrollController.position.pixels;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final threshold = maxScrollExtent * 0.7;
    
    if (!provider.isLoadingMore &&
        provider.hasMorePages &&
        scrollPosition >= threshold) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    final provider = Provider.of<SetProductsProvider>(context, listen: false);
    if (provider.isLoadingMore || !provider.hasMorePages) {
      return;
    }
    await provider.loadMoreProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SetProductsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context),
          body: FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: _buildProductsGrid(provider),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'choose_your_set'.tr(context),
        style: Theme.of(
          context,
        ).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProductsGrid(SetProductsProvider provider) {
    if (provider.setProductsState == LoadingState.loading && 
        provider.setProducts.isEmpty) {
      return _buildLoadingGrid();
    }

    if (provider.setProductsState == LoadingState.error) {
      return _buildErrorState(provider);
    }

    if (provider.setProducts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.getSetProducts(isRefresh: true);
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: provider.setProducts.length + 
            (provider.isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          // Show loading cards when loading more
          if (index >= provider.setProducts.length && provider.isLoadingMore) {
            return _buildLoadingCard();
          }
          
          final product = provider.setProducts[index];
          return CustomProductCardForProductsScreen(product: product);
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: 170,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder - matching AspectRatio 1.05
          AspectRatio(
            aspectRatio: 1.05,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
              ),
              child: CustomImage(
                assetPath: AppImages.placeHolder,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 4),
          
          // Product details placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name - first line
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 2),
                // Product name - second line (partial)
                Container(
                  width: 120,
                  height: 16,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 2),
                // Price placeholder
                Container(
                  width: 80,
                  height: 14,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SetProductsProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomEmptyWidget(
            title: 'error_loading_products'.tr(context),
            subtitle: provider.setProductsError,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => provider.getSetProducts(isRefresh: true),
            child: Text('retry'.tr(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: CustomEmptyWidget(
        title: 'no_products_found'.tr(context),
        subtitle: 'try_again_later'.tr(context),
      ),
    );
  }

}
