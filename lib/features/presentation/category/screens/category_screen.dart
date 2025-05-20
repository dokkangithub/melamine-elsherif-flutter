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
  final bool isActive;

  const CategoryScreen({super.key, this.needRefresh = false, this.isActive = true});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final GlobalKey _animationKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().getCategories(needRefresh: widget.needRefresh);
    });
  }

  @override
  void didUpdateWidget(CategoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      setState(() {
        // This will force the CategoryWidget to rebuild with a new key
      });
    }
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
            if (categoryProvider.categoriesState == LoadingState.loading) {
              return const CategoryGridShimmer();
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

              return CategoryWidget(
                key: _animationKey,
                categories: categories,
                triggerAnimation: widget.isActive,
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
}