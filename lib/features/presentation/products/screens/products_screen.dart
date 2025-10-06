import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_empty_widgets.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
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
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Fetch initial data
    Future.microtask(
      () => Provider.of<SetProductsProvider>(
        context,
        listen: false,
      ).getSetProducts(),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.7) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    final provider = Provider.of<SetProductsProvider>(context, listen: false);
    if (_isLoading || !provider.hasMorePages) {
      return;
    }
    setState(() => _isLoading = true);
    await provider.loadMoreProducts();
    if (mounted) setState(() => _isLoading = false);
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
        await provider.getSetProducts();
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
        itemCount: provider.setProducts.length + (_isLoading ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.setProducts.length) {
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
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const CustomLoadingWidget(),
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
            onPressed: () => provider.getSetProducts(),
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
