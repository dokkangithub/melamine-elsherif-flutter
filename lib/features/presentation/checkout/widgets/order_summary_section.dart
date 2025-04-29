import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../domain/cart/entities/cart.dart';

class OrderSummarySection extends StatelessWidget {
  final CartSummary cartSummary;
  final bool isUpdatingShipping;
  final String? shippingError;
  final bool isInitialLoading; // Added for initial loading state

  const OrderSummarySection({
    super.key,
    required this.cartSummary,
    this.isUpdatingShipping = false,
    this.shippingError,
    this.isInitialLoading = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCoupon = !isInitialLoading &&
        cartSummary.couponApplied &&
        cartSummary.couponCode != null &&
        cartSummary.couponCode!.isNotEmpty;

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          if (isInitialLoading)
            _buildShimmerEffect(context)
          else
            Column(
              children: [
                _buildPriceRow(
                  context: context,
                  label: 'Subtotal',
                  value:
                  '${cartSummary.currencySymbol}${cartSummary.subtotal.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 12),
                _buildPriceRow(
                  context: context,
                  label: 'Shipping fee',
                  value:
                  '${cartSummary.currencySymbol}${cartSummary.shippingCost.toStringAsFixed(2)}',
                  isLoading: isUpdatingShipping,
                ),
                const SizedBox(height: 12),
                _buildPriceRow(
                  context: context,
                  label: 'Discount',
                  value: hasCoupon
                      ? '${cartSummary.currencySymbol}${cartSummary.discount.toStringAsFixed(2)}'
                      : '${cartSummary.currencySymbol}0.00',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.grey, thickness: 0.5, height: 1),
                ),
                _buildPriceRow(
                  context: context,
                  label: 'Total',
                  value:
                  '${cartSummary.currencySymbol}${cartSummary.total.toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          _buildShimmerPriceRow(),
          const SizedBox(height: 12),
          _buildShimmerPriceRow(),
          const SizedBox(height: 12),
          _buildShimmerPriceRow(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey, thickness: 0.5, height: 1),
          ),
          _buildShimmerPriceRow(isTotal: true),
        ],
      ),
    );
  }

  Widget _buildShimmerPriceRow({bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 80,
          height: isTotal ? 16 : 14,
          color: Colors.white,
        ),
        Container(
          width: 60,
          height: isTotal ? 16 : 14,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildPriceRow({
    required BuildContext context,
    required String label,
    required String value,
    bool isLoading = false,
    bool isGreen = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.black : Colors.black87,
            ),
          ),
      ],
    );
  }
}