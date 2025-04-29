import 'package:flutter/material.dart';
import 'order_card_shimmer.dart';

class OrdersListShimmer extends StatelessWidget {
  final int itemCount;

  const OrdersListShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const OrderCardShimmer();
        },
      ),
    );
  }
}
