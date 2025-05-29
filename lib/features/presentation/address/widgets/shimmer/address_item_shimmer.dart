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
                  borderRadius: BorderRadius.circular(0),
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
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerWidget.circular(width: 20, height: 20),
              SizedBox(width: 8),
              Expanded(
                child: ShimmerWidget.rectangular(height: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Location line
          const Row(
            children: [
              ShimmerWidget.circular(width: 20, height: 20),
              SizedBox(width: 8),
              Expanded(
                child: ShimmerWidget.rectangular(height: 14),
              ),
              SizedBox(width: 8),
              ShimmerWidget.circular(width: 20, height: 20),
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
