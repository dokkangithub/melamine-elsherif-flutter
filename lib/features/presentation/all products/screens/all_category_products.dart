import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_empty_widgets.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';
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
      //categoryProvider.getSubCategories(mainCategoryId: id.toString());
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios, size: 20, color: AppTheme.accentColor),
                      ),
                      const Spacer(),
                      Text(
                        'discover_products'.tr(context),
                        style: context.headlineSmall,
                      ),
                      const Spacer(),
                      const Icon(Icons.filter_list_rounded, color: AppTheme.accentColor),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),

                // Search bar
                InkWell(
                  onTap: (){
                    AppRoutes.navigateTo(context, AppRoutes.searchScreen);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 1,color: AppTheme.primaryColor)
                    ),
                    child: Row(
                      spacing: 10,
                      children: [
                        CustomImage(
                          assetPath: AppSvgs.category_search_icon,
                        ),
                        Text(
                          'search_skin_care_products'.tr(context),
                          style: context.bodySmall?.copyWith(color: AppTheme.primaryColor),
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: categoryProvider.filterPageCategoriesResponse?.data
                          .map((category) {
                        bool isSelected = _selectedCategoryId == category.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () {
                              if (category.id != null && category.name != null) {
                                _selectCategory(category.name!, category.id!);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.amber[100] : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.amber : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                category.name ?? '',
                                style: TextStyle(
                                  color: isSelected ? Colors.amber[800] : Colors.grey,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList() ?? [],
                    ),
                  ),

                /// Subcategories horizontal list
                // if (categoryProvider.subCategoriesState == LoadingState.loading)
                //   const Padding(
                //     padding: EdgeInsets.symmetric(vertical: 8.0),
                //     child: CustomLoadingWidget(),
                //   )
                // else if (categoryProvider.subCategoriesState == LoadingState.error)
                //   Padding(
                //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                //     child: Text(categoryProvider.errorMessage!),
                //   )
                // else if (categoryProvider.subCategoriesResponse?.data.isNotEmpty ?? false)
                //     SingleChildScrollView(
                //       scrollDirection: Axis.horizontal,
                //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                //       child: Row(
                //         children: [
                //           // "All" option for subcategories
                //           Padding(
                //             padding: const EdgeInsets.only(right: 8.0),
                //             child: InkWell(
                //               onTap: () {
                //                 setState(() {
                //                   _selectedSubCategoryId = null;
                //                   _selectedSubCategoryName = null;
                //                   final provider = Provider.of<HomeProvider>(context, listen: false);
                //                   provider.fetchCategoryProducts(_selectedCategoryId, refresh: true, name: _searchQuery);
                //                 });
                //               },
                //               child: Container(
                //                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                //                 decoration: BoxDecoration(
                //                   color: _selectedSubCategoryId == null ? Colors.amber[100] : Colors.white,
                //                   borderRadius: BorderRadius.circular(20),
                //                   border: Border.all(
                //                     color: _selectedSubCategoryId == null ? Colors.amber : Colors.grey.shade300,
                //                   ),
                //                 ),
                //                 child: Text(
                //                   'all'.tr(context),
                //                   style: TextStyle(
                //                     color: _selectedSubCategoryId == null ? Colors.amber[800] : Colors.grey,
                //                     fontWeight: _selectedSubCategoryId == null ? FontWeight.w600 : FontWeight.normal,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //
                //           // Individual subcategories
                //           ...categoryProvider.subCategoriesResponse?.data.map((subcategory) {
                //             bool isSelected = _selectedSubCategoryId == subcategory.id;
                //             return Padding(
                //               padding: const EdgeInsets.only(right: 8.0),
                //               child: InkWell(
                //                 onTap: () {
                //                   if (subcategory.id != null && subcategory.name != null) {
                //                     _selectSubCategory(subcategory.name!, subcategory.id!);
                //                   }
                //                 },
                //                 child: Container(
                //                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                //                   decoration: BoxDecoration(
                //                     color: isSelected ? Colors.amber[100] : Colors.white,
                //                     borderRadius: BorderRadius.circular(20),
                //                     border: Border.all(
                //                       color: isSelected ? Colors.amber : Colors.grey.shade300,
                //                     ),
                //                   ),
                //                   child: Text(
                //                     subcategory.name ?? '',
                //                     style: TextStyle(
                //                       color: isSelected ? Colors.amber[800] : Colors.grey,
                //                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             );
                //           }) ?? [],
                //         ],
                //       ),
                //     ),

                // Products grid
                Expanded(
                  child: _buildProductsGrid(products, state, error, homeProvider, error),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsGrid(
      List<product_import.Product> products, LoadingState state, String errorMessage, HomeProvider homeProvider, String error) {

    if (state == LoadingState.loading && products.isEmpty) {
      return const Center(child: ProductsGridShimmer());
    }

    if (state == LoadingState.error && products.isEmpty) {
      return Center(
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
      );
    }

    if (products.isEmpty) {
      return const Center(child: CustomEmptyWidget());
    }

    final  filteredProducts = products.where((product) => product.published == 1).toList();

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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'loading_more_products'.tr(context),
              style: context.titleSmall?.copyWith(color: AppTheme.accentColor),
            ),
          ),
      ],
    );
  }


}