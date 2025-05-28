import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/enums/products_type.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/helpers.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_empty_widgets.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:melamine_elsherif/features/domain/product/entities/product.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/widgets/custom_back_button.dart';
import '../../home/controller/home_provider.dart';
import '../../wishlist/controller/wishlist_provider.dart';
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
  _AllProductsByTypeScreenState createState() => _AllProductsByTypeScreenState();
}

class _AllProductsByTypeScreenState extends State<AllProductsByTypeScreen> {
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
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading && 
        _scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    
    if (_isLoading || !_hasMoreProducts(provider)) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      await _fetchProducts(provider);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        return false; // No pagination for flash deal
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
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              // Category tabs
              _buildCategoryTabs(homeProvider),
              
              // Products grid
              Expanded(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: _buildProductsGrid(
                    products,
                    state,
                    error,
                    homeProvider,
                  ),
                ),
              ),
            ],
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
        "MELAMEN",
        style: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      leading: const CustomBackButton(),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {
            AppRoutes.navigateTo(context, AppRoutes.searchScreen);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryTabs(HomeProvider homeProvider) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      child: FadeInDown(
        duration: const Duration(milliseconds: 500),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildCategoryTab('ALL', ProductType.all),
            _buildCategoryTab('BEST SELLERS', ProductType.bestSelling),
            _buildCategoryTab('NEW ARRIVALS', ProductType.newArrival),
            _buildCategoryTab('FEATURED', ProductType.featured),
            _buildCategoryTab('DEALS', ProductType.flashDeal),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryTab(String title, ProductType type) {
    final bool isSelected = _selectedProductType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProductType = type;
          _fetchProducts(Provider.of<HomeProvider>(context, listen: false), refresh: true);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: context.titleSmall!.copyWith(
            color: isSelected ? AppTheme.primaryColor : AppTheme.darkDividerColor,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,

          )
        ),
      ),
    );
  }

  Widget _buildProductsGrid(
    List<Product> products,
    LoadingState state,
    String error,
    HomeProvider homeProvider,
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
              Text(error),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: () => _fetchProducts(
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
      filteredProducts = products.where((product) => product.published == 1).toList();
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
              // Alternate item heights for visual variety
              final bool isEven = index % 2 == 0;
              
              return _buildProductCard(context, product, isEven);
            },
          ),
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildProductCard(BuildContext context, Product product, bool isEven) {
    return GestureDetector(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.productDetailScreen,
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
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with favorite button
            Stack(
              children: [
                CustomImage(
                  imageUrl: product.thumbnailImage,
                  height: isEven ? 180 : 200, // Alternate heights
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlistProvider, _) {
                      final isInWishlist = wishlistProvider.isProductInWishlist(product.slug);
                      return GestureDetector(
                        onTap: () {
                          AppFunctions.toggleWishlistStatus(context, product.slug);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            isInWishlist ? Icons.favorite : Icons.favorite_border,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Product details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: context.titleMedium!.copyWith(color: AppTheme.darkDividerColor,fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        product.discountedPrice,
                        style: context.titleLarge!.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 6),
                      product.hasDiscount? Text(
                        product.mainPrice,
                        style: context.titleMedium!.copyWith(color: AppTheme.darkDividerColor, fontWeight: FontWeight.w400,decoration: TextDecoration.lineThrough),
                      ):const SizedBox.shrink(),
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
