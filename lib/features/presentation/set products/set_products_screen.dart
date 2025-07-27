import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_empty_widgets.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/widgets/custom_back_button.dart';
import '../all products/widgets/shimmer/products_grid_shimmer.dart';
import '../set products/controller/set_product_provider.dart';
import '../../../../features/domain/set products/entities/set_products.dart';

class SetProductsScreen extends StatefulWidget {
  const SetProductsScreen({super.key});

  @override
  _SetProductsScreenState createState() => _SetProductsScreenState();
}

class _SetProductsScreenState extends State<SetProductsScreen> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Fetch initial data
    Future.microtask(() => Provider.of<SetProductsProvider>(context, listen: false).getSetProducts());
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
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'set_products'.tr(context),
        style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
      leading: CustomBackButton(
        respectDirection: isRTL,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            AppRoutes.navigateTo(context, AppRoutes.searchScreen);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProductsGrid(SetProductsProvider provider) {
    if (provider.setProductsState == LoadingState.loading && provider.setProducts.isEmpty) {
      return const Center(child: ProductsGridShimmer());
    }
    if (provider.setProductsState == LoadingState.error && provider.setProducts.isEmpty) {
      return Center(
        child: FadeIn(
          duration: const Duration(milliseconds: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(provider.setProductsError),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: () {
                  provider.refreshSetProducts();
                },
                child: Text('retry'.tr(context)),
              ),
            ],
          ),
        ),
      );
    }
    // Filter out unpublished products
    final filteredProducts = provider.setProducts.where((product) => product.published == true).toList();
    if (filteredProducts.isEmpty) {
      return const Center(child: CustomEmptyWidget());
    }
    return Column(
      children: [
        Expanded(
          child: MasonryGridView.count(
            controller: _scrollController,
            crossAxisCount: 2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            padding: const EdgeInsets.all(8),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              final bool isEven = index % 2 == 0;
              return _buildProductCard(context, product, isEven);
            },
          ),
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Column(
                children: [
                  const CustomLoadingWidget(),
                  const SizedBox(height: 8),
                  Text(
                    'loading_more_products'.tr(context),
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: AppTheme.darkDividerColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, SetProduct product, bool isEven) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;
    return InkWell(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.productDetailScreen, // TODO: Replace with set product detail route if needed
          arguments: {'slug': product.slug},
        );
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            CustomImage(
              imageUrl: product.thumbnailImage ?? '',
              height: isEven ? 180 : 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            // Product details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppTheme.darkDividerColor, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Text(
                        product.discountedPrice ?? '',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 6),
                      (product.hasDiscount ?? false) && (product.mainPrice != null)
                        ? Text(
                            product.mainPrice!,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppTheme.darkDividerColor, fontWeight: FontWeight.w400, decoration: TextDecoration.lineThrough),
                          )
                        : const SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}