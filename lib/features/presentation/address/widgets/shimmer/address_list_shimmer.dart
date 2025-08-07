import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'address_item_shimmer.dart';
import 'shimmer_widget.dart';

class AddressListShimmer extends StatelessWidget {
  final int itemCount;

  const AddressListShimmer({
    super.key,
    this.itemCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          // Shimmer for Add New Address button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.05),
                    AppTheme.primaryColor.withValues(alpha: 0.05)
                  ],
                ),
              ),
              child: const ShimmerWidget.rectangular(
                height: 50,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Shimmer for address items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(0),
              itemCount: itemCount,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => const AddressItemShimmer(),
            ),
          ),
        ],
      ),
    );
  }
}
