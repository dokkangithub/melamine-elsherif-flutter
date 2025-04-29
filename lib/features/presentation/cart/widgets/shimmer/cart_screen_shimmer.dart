import 'package:flutter/material.dart';
import 'cart_items_list_shimmer.dart';
import 'cart_cost_summary_shimmer.dart';
import 'checkout_button_shimmer.dart';

class CartScreenShimmer extends StatelessWidget {
  const CartScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [

          // Cart items list shimmer
          CartItemsListShimmer(),
          // Cost summary shimmer
          CartCostSummaryShimmer(),
          // Checkout button shimmer
          CheckoutButtonShimmer(),
        ],
      ),
    );
  }
}
