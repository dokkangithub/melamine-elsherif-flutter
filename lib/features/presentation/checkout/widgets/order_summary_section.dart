import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_form_field.dart';
import '../../../domain/cart/entities/cart.dart';
import './checkout_cart_item.dart';

class OrderSummarySection extends StatelessWidget {
  final CartSummary cartSummary;
  final List<CartItem> cartItems;
  final bool isUpdatingShipping;
  final String? shippingError;
  final bool isInitialLoading;
  final TextEditingController noteController;

  const OrderSummarySection({
    super.key,
    required this.cartSummary,
    required this.cartItems,
    this.isUpdatingShipping = false,
    this.shippingError,
    this.isInitialLoading = false,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCoupon =
        !isInitialLoading &&
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
          Row(
            children: [
              Icon(Icons.receipt_outlined, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text('order_summary'.tr(context),
                style: context.titleLarge!.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cart Items List
          if (isInitialLoading)
            _buildItemsShimmer()
          else
            ...cartItems.map(
              (item) => Column(
                children: [
                  CheckoutCartItem(item: item),
                  const Divider(color: Colors.grey, height: 1, thickness: 0.5),
                ],
              ),
            ),

          const SizedBox(height: 20),
          // Price Summary
          if (isInitialLoading)
            _buildShimmerEffect(context)
          else
            Column(
              children: [
                _buildPriceRow(
                  context: context,
                  label: 'subtotal'.tr(context),
                  value: '${(cartSummary.subtotal)} ${cartSummary.currencySymbol}',
                ),
                const SizedBox(height: 12),
                _buildPriceRow(
                  context: context,
                  label: 'shipping'.tr(context),
                  value:
                      cartSummary.shippingCost > 0
                          ? '${cartSummary.shippingCost.toStringAsFixed(2)} ${cartSummary.currencySymbol}'
                          : 'free_shipping'.tr(context),
                  isLoading: isUpdatingShipping,
                  color: AppTheme.successColor,
                ),
                if (hasCoupon)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildPriceRow(
                      context: context,
                      label: 'discount'.tr(context),
                      value:
                          '-${cartSummary.discount.toStringAsFixed(2)} ${cartSummary.currencySymbol}',
                      color: AppTheme.errorColor,
                    ),
                  ),
                const SizedBox(height: 12),
                _buildPriceRow(
                  context: context,
                  label: 'tax'.tr(context),
                  value:
                      '${cartSummary.tax.toStringAsFixed(2)} ${cartSummary.currencySymbol}',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: Colors.grey, thickness: 0.5, height: 1),
                ),
                _buildPriceRow(
                  context: context,
                  label: 'total'.tr(context),
                  value:
                      '${cartSummary.total.toStringAsFixed(2)} ${cartSummary.currencySymbol}',
                  valueStyle: context.headlineSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

          
          const SizedBox(height: 20),
          
          // Add note to order section
          _buildNoteSection(context),
          
        ],
      ),
    );
  }

  Widget _buildNoteSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: noteController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'add_note_to_order'.tr(context),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildItemsShimmer() {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 60, height: 60, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 12, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 80, height: 14, color: Colors.white),
                    ],
                  ),
                ),
                Container(width: 40, height: 20, color: Colors.white),
              ],
            ),
          ),
        ),
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
        Container(width: 80, height: isTotal ? 16 : 14, color: Colors.white),
        Container(width: 60, height: isTotal ? 16 : 14, color: Colors.white),
      ],
    );
  }

  Widget _buildPriceRow({
    required BuildContext context,
    required String label,
    required String value,
    bool isLoading = false,
    Color color = Colors.black,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.titleMedium!.copyWith(color: AppTheme.black)),
        if (isLoading)
          const CustomLoadingWidget()
        else
          Text(
            value, 
            style: valueStyle ?? context.titleMedium!.copyWith(color: color),
          ),
      ],
    );
  }
}
