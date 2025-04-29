import 'package:flutter/material.dart';
import 'order_details_card_shimmer.dart';
import 'order_items_list_shimmer.dart';

class OrderScreenShimmer extends StatelessWidget {
  const OrderScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order details card shimmer
          const OrderDetailsCardShimmer(),
          const SizedBox(height: 20),
          // Order items title shimmer
          Container(
            width: 120,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),
          // Order items list shimmer
          const OrderItemsListShimmer(itemCount: 3),
        ],
      ),
    );
  }
}
