import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_empty_widgets.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_back_button.dart';
import 'package:melamine_elsherif/features/domain/product/entities/product.dart' as product_import;
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../../../domain/category/entities/category.dart';
import '../../category/controller/provider.dart';
import '../../home/controller/home_provider.dart';
import '../../wishlist/controller/wishlist_provider.dart';
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
  int _currentCategoryIndex = 0;

  // New variables for scroll to top functionality
  bool _showScrollToTop = false;
  final double _carouselHeight = 260.0;

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
    // Check if carousel is visible to show/hide scroll to top button
    final bool shouldShowScrollToTop = _scrollController.offset > _carouselHeight;
    if (shouldShowScrollToTop != _showScrollToTop) {
      setState(() {
        _showScrollToTop = shouldShowScrollToTop;
      });
    }

    // Load more products when near bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  // Method to scroll to top
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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
          body: Stack(
            children: [
              // Main scrollable content
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 1. App Bar as SliverAppBar
                  SliverAppBar(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    pinned: true,
                    floating: false,
                    snap: false,
                    expandedHeight: 0,
                    leading: const CustomBackButton(respectDirection: true),
                    title: Text(
                      _selectedCategoryName.toUpperCase(),
                      style: context.displaySmall,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.black),
                        onPressed: () {
                          AppRoutes.navigateTo(context, AppRoutes.searchScreen);
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),

                  // 2. Categories carousel as SliverToBoxAdapter
                  SliverToBoxAdapter(
                    child: _buildCategoriesCarousel(categoryProvider),
                  ),

                  // 3. Subcategories section as SliverToBoxAdapter (changed from SliverPersistentHeader)
                  SliverToBoxAdapter(
                    child: _buildSubcategoriesSection(categoryProvider),
                  ),

                  // 4. Products grid as SliverList
                  SliverList(
                    delegate: SliverChildListDelegate([
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: _buildProductsGrid(products, state, error, homeProvider),
                      ),
                    ]),
                  ),
                ],
              ),

              // Scroll to top button
              if (_showScrollToTop)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: FloatingActionButton(
                      onPressed: _scrollToTop,
                      backgroundColor: AppTheme.primaryColor,
                      mini: true,
                      child: const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesCarousel(CategoryProvider categoryProvider) {
    if (categoryProvider.categoriesResponse == LoadingState.loading) {
      return Container(
        height: _carouselHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (categoryProvider.categoriesResponse == LoadingState.error) {
      return Container(
        height: _carouselHeight,
        child: Center(
          child: Text(categoryProvider.errorMessage ?? 'Error loading categories'),
        ),
      );
    } else if (categoryProvider.categoriesResponse?.data.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    final categories = categoryProvider.categoriesResponse!.data;

    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        height: _carouselHeight,
        child: Stack(
          children: [
            // Carousel
            CarouselSlider(
              options: CarouselOptions(
                height: _carouselHeight,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                onPageChanged: (index, reason) {
                  // Update the current category index for both auto-scroll and manual selection
                  setState(() {
                    _currentCategoryIndex = index;
                  });
                },
              ),
              items: categories.map((category) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image
                          CustomImage(
                            imageUrl: category.banner,
                            fit: BoxFit.cover,
                          ),
                          // Gradient Overlay
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black87,
                                  Colors.black54,
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          // Content - Centered
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  category.name?.toUpperCase() ?? '',
                                  style: context.displaySmall!.copyWith(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                CustomButton(
                                  onPressed: () {
                                    if (category.id != null && category.name != null) {
                                      _selectCategory(category.name!, category.id!);
                                      // Note: _currentCategoryIndex is already updated by onPageChanged
                                      // when user manually selects, so no need to update it here again
                                    }
                                  },
                                  child: Text(
                                    'discover_collection'.tr(context),
                                    textAlign: TextAlign.center,
                                    style: context.titleLarge!.copyWith(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            // Dynamic Carousel Indicator at bottom
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: categories.asMap().entries.map((entry) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentCategoryIndex == entry.key ? 12.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: _currentCategoryIndex == entry.key
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoriesSection(CategoryProvider categoryProvider) {
    if (categoryProvider.subCategoriesState == LoadingState.loading) {
      return Container(
        height: 54,
        color: Colors.white,
        child: const Center(child: CustomLoadingWidget()),
      );
    } else if (categoryProvider.subCategoriesState == LoadingState.error) {
      return Container(
        height: 54,
        color: Colors.white,
        child: Center(
          child: Text(categoryProvider.errorMessage ?? 'Error loading subcategories'),
        ),
      );
    } else if (categoryProvider.subCategoriesResponse?.data.isEmpty ?? true) {
      return Container(
        height: 0,
        color: Colors.white,
        child: const SizedBox.shrink(),
      );
    }

    // Check if the current locale is RTL
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    // Create a list with "All" as the first tab, then all subcategories
    final List<Map<String, dynamic>> tabs = [
      {'id': null, 'name': 'all'.tr(context)}
    ];

    // Add all subcategories to the tabs list
    if (categoryProvider.subCategoriesResponse?.data != null) {
      categoryProvider.subCategoriesResponse!.data.forEach((subCategory) {
        tabs.add({
          'id': subCategory.id,
          'name': subCategory.name ?? ''
        });
      });
    }

    // Limit to maximum 4 tabs for better display
    final displayedTabs = tabs.length > 4 ? tabs.sublist(0, 4) : tabs;

    if (displayedTabs.isEmpty) {
      return Container(
        height: 54,
        color: Colors.white,
        child: const SizedBox.shrink(),
      );
    }

    return Container(
      height: 54,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        color: Colors.white,
      ),
      child: DefaultTabController(
        length: displayedTabs.length,
        initialIndex: displayedTabs.indexWhere((tab) => tab['id'] == _selectedSubCategoryId).clamp(0, displayedTabs.length - 1),
        child: TabBar(
          isScrollable: false,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: context.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
          unselectedLabelStyle: context.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          padding: EdgeInsets.zero,
          labelPadding: EdgeInsets.zero,
          dividerColor: Colors.transparent,
          tabAlignment: TabAlignment.fill,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          onTap: (index) {
            final selectedTab = displayedTabs[index];
            if (selectedTab['id'] == null) {
              // "All" tab
              setState(() {
                _selectedSubCategoryId = null;
                _selectedSubCategoryName = null;
                final provider = Provider.of<HomeProvider>(context, listen: false);
                provider.fetchCategoryProducts(_selectedCategoryId, refresh: true);
              });
            } else {
              // Subcategory tab
              _selectSubCategory(
                  selectedTab['name'] as String,
                  selectedTab['id'] as int
              );
            }
          },
          tabs: displayedTabs.map((tab) {
            return Tab(
              height: 44,
              child: Center(
                child: Text(
                  tab['name'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductsGrid(
      List<product_import.Product> products,
      LoadingState state,
      String errorMessage,
      HomeProvider homeProvider,
      ) {
    if (state == LoadingState.loading && products.isEmpty) {
      return Container(
        height: 400,
        child: const Center(child: ProductsGridShimmer()),
      );
    }

    if (state == LoadingState.error && products.isEmpty) {
      return Container(
        height: 400,
        child: Center(
          child: FadeIn(
            duration: const Duration(milliseconds: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(errorMessage),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: _retryLoading,
                  child: Text('retry'.tr(context), style: context.titleLarge?.copyWith(color: AppTheme.white) ?? const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return Container(
        height: 400,
        child: const Center(child: CustomEmptyWidget()),
      );
    }

    final filteredProducts = products.where((product) => product.published == 1).toList();

    return Column(
      children: [
        MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
        if (_isLoading)
          FadeIn(
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'loading_more_products'.tr(context),
                style: context.titleSmall?.copyWith(color: AppTheme.primaryColor),
              ),
            ),
          ),
        // Add some bottom padding
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, product_import.Product product, bool isEven) {
    // Check if the current locale is RTL
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
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
          crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Product image with favorite button
            Stack(
              children: [
                CustomImage(
                  imageUrl: product.thumbnailImage,
                  height: isEven ? 180 : 200, // Alternate heights
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: 8,
                  // Adjust position based on text direction
                  right: isRTL ? null : 8,
                  left: isRTL ? 8 : null,
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
                crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: context.titleMedium?.copyWith(color: AppTheme.darkDividerColor, fontWeight: FontWeight.w600) ?? const TextStyle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    // Adjust row direction based on language
                    mainAxisAlignment: isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Text(
                        product.discountedPrice,
                        style: context.titleLarge?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w900) ?? const TextStyle(),
                      ),
                      const SizedBox(width: 6),
                      product.hasDiscount? Text(
                        product.mainPrice,
                        style: context.titleMedium?.copyWith(color: AppTheme.darkDividerColor, fontWeight: FontWeight.w400, decoration: TextDecoration.lineThrough) ?? const TextStyle(),
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