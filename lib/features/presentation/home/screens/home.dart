import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:melamine_elsherif/features/presentation/wishlist/controller/wishlist_provider.dart';
import 'package:melamine_elsherif/features/presentation/category/controller/provider.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/top_home.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/categories_widget.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/best_selling_products_widget.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/featured_products_widget.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/new_products_widget.dart';
import 'package:melamine_elsherif/features/presentation/home/widgets/all_products_widget.dart';
import '../../cart/controller/cart_provider.dart';
import '../../slider/controller/provider.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/banners_widget.dart';
import '../widgets/plates_widget.dart';
import '../widgets/second_home_image_widget.dart';
import '../widgets/summers_deals_widget.dart';
import '../widgets/flash_deals.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );
    final cartProvider = Provider.of<CartProvider>(
      context,
      listen: false,
    );
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    categoryProvider.getCategories();
    homeProvider.initHomeData();
    wishlistProvider.fetchWishlist();
  }

  void _scrollToShopNow() {
    _scrollController.animateTo(
      250.0, // The position to scroll to
      duration: const Duration(milliseconds: 500), // Duration of the scroll animation
      curve: Curves.easeInOut, // Animation curve
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final homeProvider = Provider.of<HomeProvider>(context, listen: false);
        final categoryProvider = Provider.of<CategoryProvider>(
          context,
          listen: false,
        );
        final sliderProvider = Provider.of<SliderProvider>(context, listen: false);

        await Future.wait([
        sliderProvider.getSliders(refresh: true),
          homeProvider.refreshHomeData(),
          categoryProvider.getCategories(needRefresh: true),
        ]);
      },
      child: Scaffold(
        appBar: const AppBarWidget(),
        body: SingleChildScrollView(
          controller: _scrollController, // Assign the controller here
          child: Column(
            spacing: 8,
            children: [
              TopHomeWidget(onShopNowTapped: _scrollToShopNow), // Pass the callback
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoriesWidget(),
                    PlatesWidgets(),
                    NewProductsWidget(),
                    SimpleBannerCarousel(),
                    BestSellingProductsWidget(),
                    SecondHomeImageWidget(),
                    FeaturedProductsWidget(),
                    FlashProductsWidget(),
                    SummerDealsWidgets(),
                    AllProductsWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
