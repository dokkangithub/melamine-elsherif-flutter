import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import '../../../domain/category/entities/category.dart';
import '../controller/provider.dart';
import '../widgets/category_shimmer.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';

class CategoryScreen extends StatefulWidget {
  final bool needRefresh;
  final bool isActive;

  const CategoryScreen({super.key, this.needRefresh = false, this.isActive = true});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().getCategories(needRefresh: widget.needRefresh);
    });
  }

  Future<void> _refreshCategories() async {
    await context.read<CategoryProvider>().getCategories(needRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'category'.tr(context),
          style: context.displaySmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCategories,
        child: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            if (categoryProvider.categoriesState == LoadingState.loading) {
              return const CategoryShimmer();
            }

            if (categoryProvider.categoriesState == LoadingState.error) {
              return ErrorStateWidget(
                message: 'couldnt_load_categories'.tr(context),
                onRetry: () => categoryProvider.getCategories(needRefresh: true),
              );
            }

            if (categoryProvider.categoriesState == LoadingState.loaded &&
                categoryProvider.categoriesResponse?.data != null) {
              final categories = categoryProvider.categoriesResponse!.data;

              if (categories.isEmpty) {
                return EmptyStateWidget(
                  message: 'no_categories_available'.tr(context),
                );
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Porcelain Collection Banner
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: const CustomImage(
                            assetPath:  AppSvgs.porcelain_collection,
                            width: double.infinity,
                            height: 274,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'porcelain_collection_title'.tr(context),
                                maxLines: 2,
                                style: context.displayMedium!.copyWith(color: AppTheme.white,fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'porcelain_collection_subtitle'.tr(context),
                                style: context.headlineSmall!.copyWith(color: AppTheme.white,fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // Shop by Category Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'shop_by_category'.tr(context),
                            style: context.displayMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'luxurious_dining_table'.tr(context),
                            style: context.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    
                    // Category Grid
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: categories.length >= 6 ? 6 : categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          

                          return _buildCategoryCard(
                            context, 
                            category,
                            (category.productCount ?? 0),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return EmptyStateWidget(
              message: 'no_categories_available'.tr(context),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category, int productCount) {
    return InkWell(
      onTap: () {
        AppRoutes.navigateTo(
          context,
          AppRoutes.allCategoryProductsScreen,
          arguments: {
            'category': category,
          },
        );
      },
      child: Card(
        color: AppTheme.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: Column(
          children: [
            // Category Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(category.icon ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    category.name ?? '',
                    textAlign: TextAlign.center,
                    style: context.headlineMedium!.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'products_count'.tr(context).replaceAll('{count}', productCount.toString()),
                    textAlign: TextAlign.center,
                    style: context.titleMedium!.copyWith(color: AppTheme.darkDividerColor),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// Helper method to determine text direction based on content
  TextDirection _getTextDirection(String text) {
    if (text.isEmpty) return TextDirection.ltr;

    // Check if text contains Arabic characters
    final arabicRegex = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');

    if (arabicRegex.hasMatch(text)) {
      return TextDirection.rtl;
    }

    return TextDirection.ltr;
  }}