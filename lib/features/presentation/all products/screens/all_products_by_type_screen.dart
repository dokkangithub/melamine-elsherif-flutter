import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/enums/products_type.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_empty_widgets.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:melamine_elsherif/features/domain/product/entities/product.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/widgets/custom_appBar.dart';
import '../../home/controller/home_provider.dart';
import '../widgets/products_grid.dart';
import '../widgets/shimmer/products_grid_shimmer.dart';

class AllProductsByTypeScreen extends StatefulWidget {
  final ProductType productType;
  final String title;
  final int? dealId;

  const AllProductsByTypeScreen({
    super.key,
    required this.productType,
    required this.title,
    this.dealId,
  });

  @override
  _AllProductsByTypeScreenState createState() =>
      _AllProductsByTypeScreenState();
}

class _AllProductsByTypeScreenState extends State<AllProductsByTypeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  ProductType _selectedProductType = ProductType.all;

  final Map<ProductType, String> _productTypeNames = {
    ProductType.all: 'all_products',
    ProductType.bestSelling: 'best_selling_products',
    ProductType.featured: 'feature_products',
    ProductType.newArrival: 'new_arrival_products',
    ProductType.flashDeal: 'today_deals',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _selectedProductType = widget.productType;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      _fetchProducts(homeProvider, refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Add a small threshold so it triggers slightly before hitting the very bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading) return;
    final provider = Provider.of<HomeProvider>(context, listen: false);

    if (!_hasMoreProducts(provider)) return;

    setState(() => _isLoading = true);

    // Add a print statement to confirm the state change
    print("Loading more products, _isLoading: $_isLoading");

    try {
      await _fetchProducts(provider);
    } finally {
      // Make sure this runs even if there's an error
      if (mounted) {
        setState(() => _isLoading = false);
        // Add another print statement to see when it's set back to false
        print("Finished loading, _isLoading: $_isLoading");
      }
    }
  }

  Future<void> _fetchProducts(
    HomeProvider provider, {
    bool refresh = false,
  }) async {
    switch (_selectedProductType) {
      case ProductType.all:
        await provider.fetchAllProducts(refresh: refresh);
        break;
      case ProductType.bestSelling:
        await provider.fetchBestSellingProducts(refresh: refresh);
        break;
      case ProductType.featured:
        await provider.fetchFeaturedProducts(refresh: refresh);
        break;
      case ProductType.newArrival:
        await provider.fetchNewProducts(refresh: refresh);
        break;
      case ProductType.flashDeal:
        await provider.fetchFlashDealProducts(refresh: refresh);
        break;
    }
  }

  bool _hasMoreProducts(HomeProvider provider) {
    switch (_selectedProductType) {
      case ProductType.all:
        return provider.hasMoreAllProducts;
      case ProductType.bestSelling:
        return provider.hasMoreBestSellingProducts;
      case ProductType.featured:
        return provider.hasMoreFeaturedProducts;
      case ProductType.newArrival:
        return provider.hasMoreNewProducts;
      case ProductType.flashDeal:
        return false; // No pagination for today's deal
    }
  }

  List<Product> _getProducts(HomeProvider provider) {
    switch (_selectedProductType) {
      case ProductType.all:
        return provider.allProducts;
      case ProductType.bestSelling:
        return provider.bestSellingProducts;
      case ProductType.featured:
        return provider.featuredProducts;
      case ProductType.newArrival:
        return provider.newProducts;
      case ProductType.flashDeal:
        // Return all flash deal products
        return provider.flashDealProducts;
    }
  }

  LoadingState _getLoadingState(HomeProvider provider) {
    switch (_selectedProductType) {
      case ProductType.all:
        return provider.allProductsState;
      case ProductType.bestSelling:
        return provider.bestSellingProductsState;
      case ProductType.featured:
        return provider.featuredProductsState;
      case ProductType.newArrival:
        return provider.newProductsState;
      case ProductType.flashDeal:
        return provider.flashDealProductsState;
    }
  }

  String _getErrorMessage(HomeProvider provider) {
    switch (_selectedProductType) {
      case ProductType.all:
        return provider.allProductsError;
      case ProductType.bestSelling:
        return provider.bestSellingProductsError;
      case ProductType.featured:
        return provider.featuredProductsError;
      case ProductType.newArrival:
        return provider.newProductsError;
      case ProductType.flashDeal:
        return provider.flashDealProductsError;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final products = _getProducts(homeProvider);
        final state = _getLoadingState(homeProvider);
        final error = _getErrorMessage(homeProvider);
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // App bar with back button and search field
                FadeIn(
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 20.0,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              AppRoutes.navigateTo(
                                context,
                                AppRoutes.searchScreen,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              height: 45,
                              decoration: BoxDecoration(
                                color: AppTheme.lightBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const CustomImage(
                                    assetPath: AppSvgs.category_search_icon,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'search_for_yours'.tr(context),
                                      style: context.titleSmall?.copyWith(
                                        color: AppTheme.lightSecondaryTextColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Product type tabs - New Style
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children:
                          ProductType.values.map((type) {
                            bool isSelected = _selectedProductType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: _buildProductTypeChip(
                                text: _productTypeNames[type]!.tr(context),
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedProductType = type;
                                    _fetchProducts(homeProvider, refresh: true);
                                  });
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),

                // Products grid
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: _buildProductsGrid(
                      products,
                      state,
                      error,
                      homeProvider,
                      error,
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

  Widget _buildProductTypeChip({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: context.titleMedium?.copyWith(
                  color:
                      isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.lightSecondaryTextColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2.5,
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid(
    List<Product> products,
    LoadingState state,
    String errorMessage,
    HomeProvider homeProvider,
    String error,
  ) {
    if (state == LoadingState.loading && products.isEmpty) {
      return const Center(child: ProductsGridShimmer());
    }

    if (state == LoadingState.error && products.isEmpty) {
      return Center(
        child: FadeIn(
          duration: const Duration(milliseconds: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage),
              const SizedBox(height: 16),
              CustomButton(
                onPressed:
                    () => _fetchProducts(
                      Provider.of<HomeProvider>(context, listen: false),
                      refresh: true,
                    ),
                child: Text('retry'.tr(context)),
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return const Center(child: CustomEmptyWidget());
    }
    List<Product> filteredProducts = products;
    if (_selectedProductType != ProductType.newArrival) {
      filteredProducts =
          products.where((product) => product.published == 1).toList();
    }
    return Column(
      children: [
        Expanded(
          child: ProductsGrid(
            products: _selectedProductType !=ProductType.flashDeal ? filteredProducts : products,
            state: state,
            error: error,
            isLoading: _isLoading,
            scrollController: _scrollController,
            onRetry: () => _fetchProducts(homeProvider, refresh: true),
          ),
        ),
        if (_isLoading)
          FadeIn(
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'loading_more_products'.tr(context),
                style: context.titleSmall?.copyWith(color: AppTheme.accentColor),
              ),
            ),
          ),
      ],
    );
  }
}
