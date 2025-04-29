import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'wishlist_item_shimmer.dart';

class WishlistScreenShimmer extends StatelessWidget {
  const WishlistScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return ShimmerProductItemInWishList();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
