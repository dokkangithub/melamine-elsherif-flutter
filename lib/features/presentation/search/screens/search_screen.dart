import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_empty_widgets.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../controller/search_provider.dart';
import '../widgets/search_input_field.dart';
import '../widgets/popular_searches.dart';
import '../widgets/search_results_grid.dart';
import '../widgets/shimmer/popular_searches_shimmer.dart';
import '../widgets/shimmer/search_results_shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SearchProvider>(context, listen: false);
      provider.clearFilteredProducts();
      // Fetch popular products (empty search)
      provider.fetchFilteredProducts(refresh: true, name: '');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _isSearchActive = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      Provider.of<SearchProvider>(
        context,
        listen: false,
      ).fetchFilteredProducts(refresh: true, name: query);
    } else {
      Provider.of<SearchProvider>(
        context,
        listen: false,
      ).clearFilteredProducts();
      // Re-fetch popular products when search is cleared
      Provider.of<SearchProvider>(
        context,
        listen: false,
      ).fetchFilteredProducts(refresh: true, name: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('search'.tr(context)),
        elevation: 0,
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, _) {
          return Column(
            children: [
              // Search input field (always visible)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SearchInputField(
                  controller: _searchController,
                  onChanged: (value) {
                    // Update search state immediately
                    setState(() {
                      _isSearchActive = value.isNotEmpty;
                    });
                    searchProvider.onSearchQueryChanged(value);
                    if (value.isEmpty) {
                      searchProvider.clearFilteredProducts();
                      // Re-fetch popular products
                      searchProvider.fetchFilteredProducts(refresh: true, name: '');
                    }
                  },
                  onSubmitted: _performSearch,
                ),
              ),

              // Content area (expanded to fill remaining space)
              Expanded(
                child: _isSearchActive
                    ? _buildSearchResults(searchProvider)
                    : _buildInitialView(searchProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget for search results (when search is active)
  Widget _buildSearchResults(SearchProvider searchProvider) {
    final bool isLoading =
        searchProvider.filteredProductsState == LoadingState.loading;

    if (isLoading) {
      return const SearchResultsShimmer();
    }

    return SearchResultsGrid(
      searchQuery: _searchController.text,
    );
  }

  // Widget for initial view (when search is not active)
  Widget _buildInitialView(SearchProvider searchProvider) {
    final bool isLoading =
        searchProvider.filteredProductsState == LoadingState.loading;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Popular products section
          isLoading
              ? const PopularSearchesShimmer()
              : PopularSearches(popularProducts: searchProvider.filteredProducts),

          // Empty widget (when not searching)
          const SizedBox(height: 32),
          const CustomEmptyWidget(),
        ],
      ),
    );
  }
}