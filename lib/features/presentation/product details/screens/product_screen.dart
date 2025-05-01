import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/enums/loading_state.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/helpers.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_back_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:melamine_elsherif/features/presentation/product%20details/controller/product_provider.dart';
import 'package:melamine_elsherif/features/presentation/product%20details/widgets/choice_options_widget.dart';
import 'package:melamine_elsherif/features/presentation/product%20details/widgets/reviews_section.dart';
import 'package:melamine_elsherif/features/presentation/home/controller/home_provider.dart';
import 'package:melamine_elsherif/features/presentation/review/controller/reviews_provider.dart';
import 'package:provider/provider.dart';
import '../../wishlist/controller/wishlist_provider.dart';
import '../widgets/color_variants_widget.dart';
import '../widgets/description_widget.dart';
import '../widgets/product_image_widget.dart';
import '../widgets/product_theme.dart';
import '../widgets/quantity_selector_widget.dart';
import '../widgets/related_products_widget.dart';
import '../widgets/shimmers/shimmer_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;

  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool isFavorite = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductDetailsProvider>(
        context,
        listen: false,
      );
      productProvider.fetchProductDetails(widget.slug).then((_) {
        if (productProvider.selectedProduct != null) {
          final homeProvider = Provider.of<HomeProvider>(
            context,
            listen: false,
          );
          homeProvider.fetchRelatedProducts(
            productProvider.selectedProduct!.id,
          );

          final reviewProvider = Provider.of<ReviewProvider>(
            context,
            listen: false,
          );
          reviewProvider.fetchReviews(productProvider.selectedProduct!.id);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Consumer2<ProductDetailsProvider, HomeProvider>(
      builder: (context, productProvider, homeProvider, child) {
        if (productProvider.productDetailsState == LoadingState.loading) {
          return const ShimmerProductScreen();
        }

        if (productProvider.productDetailsState == LoadingState.error) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${productProvider.productDetailsError}',
                    style: const TextStyle(color: ProductTheme.errorColor),
                  ),
                  ElevatedButton(
                    onPressed:
                        () => productProvider.fetchProductDetails(widget.slug),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (productProvider.selectedProduct == null) {
          return Scaffold(
            body: Center(child: Text('no_product_details_data_available'.tr(context))),
          );
        }

        final product = productProvider.selectedProduct!;

        return Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    Stack(
                      children: [
                        ProductImageWidget(
                          product: product,
                          height: screenHeight * 0.4,
                        ),
                        const Positioned(
                          top: 16,
                          left: 16,
                          child: CustomBackButton(),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Consumer<WishlistProvider>(
                            builder: (context, wishlistProvider, child) {
                              return IconButton(
                                icon: Icon(
                                  wishlistProvider.isProductInWishlist(
                                    widget.slug,
                                  )
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: ProductTheme.favoriteColor,
                                ),
                                onPressed: () async {
                                  await AppFunctions.toggleWishlistStatus(
                                    context,
                                    widget.slug,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: ProductTheme.titleLarge(context),
                          ),
                          const SizedBox(height: 16),

                          // Display variations
                          if (product.hasVariation) ...[
                            // Color variants
                            if (product.colors.isNotEmpty) ...[
                              ColorVariantsWidget(product: product),
                              const SizedBox(height: 16),
                            ],

                            // Choice options
                            if (product.choiceOptions.isNotEmpty) ...[
                              ChoiceOptionsWidget(product: product),
                              const SizedBox(height: 16),
                            ],
                          ],

                          DescriptionWidget(product: product),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    ReviewsSectionWidget(productId: product.id),
                    RelatedProductsWidget(provider: homeProvider),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: productProvider.isAddingToCart
                    ? const CustomLoadingWidget()
                    : Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: ProductTheme.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QuantitySelectorWidget(product: product),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: CustomButton(
                          onPressed:
                          productProvider.isAddingToCart ||
                              !productProvider.canAddToCart
                              ? null
                              : () {
                            // For products with variations
                            if (product.hasVariation) {
                              final colorVariant =
                                  productProvider.selectedColor ?? '';
                              final choiceVariants =
                                  productProvider
                                      .variantPrice
                                      ?.data
                                      .variant ??
                                      '';

                              AppFunctions.addProductToCart(
                                context: context,
                                productSlug: product.slug,
                                productId: product.id,
                                productName: product.name,
                                variant: choiceVariants,
                                quantity: productProvider.quantity,
                                color: colorVariant,
                                hasVariation: false,
                              );
                            } else {
                              AppFunctions.addProductToCart(
                                context: context,
                                productSlug: product.slug,
                                productId: product.id,
                                productName: product.name,
                                variant: "",
                                // No variant for non-variation products
                                quantity: productProvider.quantity,
                                color: "",
                                // No color for non-variation products
                                hasVariation: false,
                              );
                            }
                          },
                          child: Center(
                            child: Text(
                              productProvider.canAddToCart
                                  ? 'Add to Cart'
                                  : 'Out of Stock',
                              style: context.titleMedium.copyWith(color: AppTheme.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}