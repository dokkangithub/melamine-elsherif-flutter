import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_empty_widgets.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:melamine_elsherif/features/domain/product/entities/product.dart' as product_import;
import 'package:provider/provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../../../domain/category/entities/category.dart';
import '../../category/controller/provider.dart';
import '../../home/controller/home_provider.dart';
import '../widgets/products_grid.dart';
import '../widgets/shimmer/products_grid_shimmer.dart';

class AllCategoryProductsScreen extends StatefulWidget {
  final Category category;

  const AllCategoryProductsScreen({
    super.key,
    required this.category,
  });

  @override
  _AllCategoryProductsScreenState createState() =>
      _AllCategoryProductsScreenState();
}

class _AllCategoryProductsScreenState extends State<AllCategoryProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = '';
  late String _selectedCategoryName;
  late int _selectedCategoryId;
  int? _selectedSubCategoryId;
  String? _selectedSubCategoryName;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _selectedCategoryName = widget.category.name!;
    _selectedCategoryId = widget.category.id!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

      homeProvider.fetchCategoryProducts(
        _selectedCategoryId,
        name: _searchQuery,
        refresh: true,
      );
      categoryProvider.getFilterPageCategories();
      categoryProvider.getSubCategories(mainCategoryId: _selectedCategoryId.toString());
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

    if (_selectedSubCategoryId != null) {
      if (!provider.hasMoreSubCategoryProducts) return;
      setState(() => _isLoading = true);

      try {
        await provider.fetchSubCategoryProducts(
          _selectedSubCategoryId!,
          name: _searchQuery,
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      if (!provider.hasMoreCategoryProducts) return;
      setState(() => _isLoading = true);

      try {
        await provider.fetchCategoryProducts(
          _selectedCategoryId,
          name: _searchQuery,
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _selectCategory(String name, int id) {
    setState(() {
      _selectedCategoryName = name;
      _selectedCategoryId = id;
      _selectedSubCategoryId = null;
      _selectedSubCategoryName = null;
      final provider = Provider.of<HomeProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      provider.fetchCategoryProducts(id, refresh: true, name: _searchQuery);
      categoryProvider.getSubCategories(mainCategoryId: id.toString());
    });
  }

  void _selectSubCategory(String name, int id) {
    setState(() {
      _selectedSubCategoryName = name;
      _selectedSubCategoryId = id;
      final provider = Provider.of<HomeProvider>(context, listen: false);
      provider.fetchSubCategoryProducts(id, refresh: true, name: _searchQuery);
    });
  }

  void _retryLoading() {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    if (_selectedSubCategoryId != null) {
      provider.fetchSubCategoryProducts(
        _selectedSubCategoryId!,
        refresh: true,
        name: _searchQuery,
      );
    } else {
      provider.fetchCategoryProducts(
        _selectedCategoryId,
        refresh: true,
        name: _searchQuery,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, CategoryProvider>(
      builder: (context, homeProvider, categoryProvider, child) {
        final products = _selectedSubCategoryId != null
            ? homeProvider.subCategoryProducts
            : homeProvider.categoryProducts;
        final state = _selectedSubCategoryId != null
            ? homeProvider.subCategoryProductsState
            : homeProvider.categoryProductsState;
        final error = _selectedSubCategoryId != null
            ? homeProvider.subCategoryProductsError
            : homeProvider.categoryProductsError;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // App Bar similar to AllProductsByTypeScreen
                FadeIn(
                  duration: const Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios, size: 20, color: AppTheme.accentColor),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              AppRoutes.navigateTo(context, AppRoutes.searchScreen);
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
                                      style: context.titleSmall?.copyWith(color: AppTheme.lightSecondaryTextColor),
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

                // Categories horizontal list
                if (categoryProvider.filterPageCategoriesState == LoadingState.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: ProductsGridShimmer(),
                  )
                else if (categoryProvider.filterPageCategoriesState == LoadingState.error)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(categoryProvider.errorMessage!),
                  )
                else
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: categoryProvider.filterPageCategoriesResponse?.data
                            .map((category) {
                          onCategorySelect() {
                            if (category.id != null && category.name != null) {
                              _selectCategory(category.name!, category.id!);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              onTap: onCategorySelect,
                              borderRadius: BorderRadius.circular(12.0),
                              child: SizedBox(
                                width: 280,
                                height: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Background Image
                                      CustomImage(
                                        imageUrl: category.bannerMobile,
                                        fit: BoxFit.fill,
                                      ),
                                      // Gradient Overlay for text readability
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.black.withValues(alpha: 0.7),
                                              Colors.black.withValues(alpha: 0.1),
                                              Colors.transparent
                                            ],
                                            stops: const [0.0, 0.5, 1.0],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                      // Content: Name, Product Count, Shop Now button
                                      Positioned(
                                        bottom: 5,
                                        left: 0,
                                        right: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      category.name ?? '',
                                                      style: context.headlineSmall?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      'product_count'.tr(context).replaceAll('{count}', '${category.productCount ?? 0}'),
                                                      style: context.titleLarge?.copyWith(
                                                        color: AppTheme.lightDividerColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              CustomButton(
                                                onPressed: onCategorySelect,
                                                padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 15),
                                                child: Text(
                                                  'shop_now'.tr(context),
                                                  style: context.bodyLarge?.copyWith(color: Colors.white)
                                                  ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList() ??
                            [], // Provide an empty list if data is null
                      ),
                    ),
                  ),

                const SizedBox(height: 10),
                /// Subcategories horizontal list
                if (categoryProvider.subCategoriesState == LoadingState.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: CustomLoadingWidget(),
                  )
                else if (categoryProvider.subCategoriesState == LoadingState.error)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(categoryProvider.errorMessage!),
                  )
                else if (categoryProvider.subCategoriesResponse?.data.isNotEmpty ?? false)
                    FadeIn(
                      duration: const Duration(milliseconds: 500),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            // "All" option for subcategories
                            _buildSubCategoryChip(
                              text: 'all'.tr(context),
                              isSelected: _selectedSubCategoryId == null,
                              onTap: () {
                                setState(() {
                                  _selectedSubCategoryId = null;
                                  _selectedSubCategoryName = null;
                                  final provider = Provider.of<HomeProvider>(context, listen: false);
                                  provider.fetchCategoryProducts(_selectedCategoryId, refresh: true, name: _searchQuery);
                                });
                              },
                            ),
                            // Individual subcategories
                            ...categoryProvider.subCategoriesResponse!.data.map((subcategory) {
                              bool isSelected = _selectedSubCategoryId == subcategory.id;
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0), // Add spacing between items
                                child: _buildSubCategoryChip(
                                  text: subcategory.name ?? '',
                                  isSelected: isSelected,
                                  onTap: () {
                                    if (subcategory.id != null && subcategory.name != null) {
                                      _selectSubCategory(subcategory.name!, subcategory.id!);
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),

                //Products grid
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: _buildProductsGrid(products, state, error, homeProvider, error),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubCategoryChip({required String text, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.0), // Optional: for ink splash shape
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0), // Padding for tap area and visual spacing
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: context.titleMedium?.copyWith(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.lightSecondaryTextColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4), // Space between text and underline
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
      List<product_import.Product> products, LoadingState state, String errorMessage, HomeProvider homeProvider, String error) {

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
              ElevatedButton(
                onPressed: _retryLoading,
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

    final filteredProducts = products.where((product) => product.published == 1).toList();

    return Column(
      children: [
        Expanded(
          child: ProductsGrid(
            products: filteredProducts,
            state: state,
            error: error,
            isLoading: _isLoading,
            scrollController: _scrollController,
            onRetry: _retryLoading,
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