import 'package:flutter/material.dart';
import 'shimmer_widget.dart';

class AddressItemShimmer extends StatelessWidget {
  const AddressItemShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and badge
            Row(
              children: [
                const Expanded(
                  child: ShimmerWidget.rectangular(height: 20),
                ),
                const SizedBox(width: 8),
                ShimmerWidget.rectangular(
                  width: 60,
                  height: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Address line
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerWidget.circular(width: 20, height: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerWidget.rectangular(height: 16),
                      SizedBox(height: 4),
                      ShimmerWidget.rectangular(height: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Location line
            Row(
              children: [
                const ShimmerWidget.circular(width: 20, height: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: ShimmerWidget.rectangular(height: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Phone line
            Row(
              children: [
                const ShimmerWidget.circular(width: 20, height: 20),
                const SizedBox(width: 8),
                ShimmerWidget.rectangular(width: 120, height: 14),
              ],
            ),

            // Action buttons
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ShimmerWidget.rectangular(height: 36),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ShimmerWidget.rectangular(height: 36),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ShimmerWidget.rectangular(height: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
