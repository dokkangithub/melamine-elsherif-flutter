import 'package:flutter/material.dart';
import 'address_item_shimmer.dart';

class AddressListShimmer extends StatelessWidget {
  final int itemCount;

  const AddressListShimmer({
    Key? key,
    this.itemCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const AddressItemShimmer(),
    );
  }
}
