import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/themes.dart/theme.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../../core/utils/enums/loading_state.dart';
import '../../../../core/utils/widgets/custom_cached_image.dart';
import '../controller/cart_provider.dart';
import '../widgets/cart_cost_summary.dart';
import '../widgets/cart_items_list.dart';
import '../widgets/checkout_button.dart';
import '../widgets/empty_cart_widget.dart';
import '../widgets/shimmer/cart_screen_shimmer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final cartProvider = context.read<CartProvider>();
      cartProvider.fetchCartItems();
      cartProvider.fetchCartCount();
      cartProvider.fetchCartSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withValues(alpha: 0.95),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 6,
                    children: [
                      Text(
                        'my_cart'.tr(context),
                        style: context.displaySmall.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 50,
                child: Opacity(
                  opacity: 0.2,
                  child: CustomImage(assetPath: AppSvgs.category_1),
                ),
              ),
              Positioned(
                top: 40,
                right: 50,
                child: Opacity(
                  opacity: 0.2,
                  child: CustomImage(assetPath: AppSvgs.category_1),
                ),
              ),
              Positioned(
                top: 30,
                left: 30,
                child: Opacity(
                  opacity: 0.2,
                  child: CustomImage(assetPath: AppSvgs.category_2),
                ),
              ),
              Positioned(
                top: 20,
                right: 100,
                child: Opacity(
                  opacity: 0.2,
                  child: CustomImage(assetPath: AppSvgs.category_3),
                ),
              ),
              Positioned(
                top: 10,
                left: 20,
                child: Opacity(
                  opacity: 0.2,
                  child: CustomImage(assetPath: AppSvgs.category_4),
                ),
              ),
            ],
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              if (cartProvider.cartState == LoadingState.loading) {
                return Expanded(child: const CartScreenShimmer());
              }
              // Cart content
              return cartProvider.cartItems.isEmpty
                  ? Column(
                    children: [
                      const SizedBox(height: 100),
                      const EmptyCartWidget(),
                    ],
                  )
                  : Expanded(
                    child: Column(
                      children: [
                        // Cart items list
                        CartItemsList(
                          items: cartProvider.cartItems,
                          onDeleteItem: (itemId) {
                            cartProvider.deleteCartItem(itemId);
                          },
                          onQuantityChanged: (itemId, newQuantity) {
                            // Create a list of all cart IDs
                            final cartIds = cartProvider.cartItems
                                .map((i) => i.id.toString())
                                .join(',');

                            // Create updated quantities list
                            final quantities =
                                cartProvider.cartItems
                                    .map(
                                      (i) =>
                                          i.id == itemId
                                              ? newQuantity
                                              : i.quantity,
                                    )
                                    .toList();

                            final quantitiesStr = quantities.join(',');

                            // Update cart quantities
                            cartProvider.updateCartQuantities(
                              cartIds,
                              quantitiesStr,
                            );
                          },
                        ),

                        // Cost summary
                        if (cartProvider.cartSummary != null)
                          CartCostSummary(summary: cartProvider.cartSummary!),

                        // Checkout button
                        const CheckoutButton(),
                      ],
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }
}
