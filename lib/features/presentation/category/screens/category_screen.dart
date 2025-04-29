import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:provider/provider.dart';
import '../controller/provider.dart';
import '../widgets/category_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/shimmer/category_grid_shimmer.dart';

class CategoryScreen extends StatefulWidget {
  final bool needRefresh;

  const CategoryScreen({super.key, this.needRefresh = false});

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
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshCategories,
        child: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            // Show shimmer while loading
            if (categoryProvider.categoriesState == LoadingState.loading) {
              return const CategoryGridShimmer();
            }

            // Show error if fetching failed
            if (categoryProvider.categoriesState == LoadingState.error) {
              return ErrorStateWidget(
                message: 'couldnt_load_categories'.tr(context),
                onRetry: () => categoryProvider.getCategories(needRefresh: true),
              );
            }

            // Show categories if data is loaded
            if (categoryProvider.categoriesState == LoadingState.loaded &&
                categoryProvider.categoriesResponse?.data != null) {
              final categories = categoryProvider.categoriesResponse!.data;

              if (categories.isEmpty) {
                return EmptyStateWidget(
                  message: 'no_categories_available'.tr(context),
                );
              }

              return CategoryWidget(categories: categories);
            }

            return EmptyStateWidget(
              message: 'no_categories_available'.tr(context),
            );
          },
        ),
      ),
    );
  }
}