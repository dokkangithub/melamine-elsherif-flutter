import 'package:flutter/material.dart';
import 'shimmer_widget.dart';
import '../../../../../core/config/themes.dart/theme.dart';

class AddressItemShimmer extends StatelessWidget {
  const AddressItemShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and badge
          Row(
            children: [
              const ShimmerWidget.rectangular(
                width: 100,
                height: 18,
              ),
              const SizedBox(width: 10),
              Container(
                width: 70,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const ShimmerWidget.rectangular(
                  height: 24,
                ),
              ),
              const Spacer(),
              const ShimmerWidget.circular(width: 20, height: 20),
            ],
          ),
          const SizedBox(height: 12),

          // Address line
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerWidget.circular(width: 20, height: 20),
              const SizedBox(width: 8),
              Expanded(
                child: ShimmerWidget.rectangular(height: 16),
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
              const SizedBox(width: 8),
              const ShimmerWidget.circular(width: 20, height: 20),
            ],
          ),
          const SizedBox(height: 8),
          
          // Divider
          const ShimmerWidget.rectangular(
            height: 1,
          ),
        ],
      ),
    );
  }
}
