import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../domain/payment/entities/payment_type.dart';

class PaymentMethodSection extends StatelessWidget {
  final List<PaymentType> paymentTypes;
  final String selectedPaymentTypeKey;
  final Function(String) onPaymentTypeSelected;
  final bool isLoading; // Add a loading state

  const PaymentMethodSection({
    super.key,
    required this.paymentTypes,
    required this.selectedPaymentTypeKey,
    required this.onPaymentTypeSelected,
    this.isLoading = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'payment_method'.tr(context),
              style: context.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (isLoading)
            _buildShimmerEffect(context)
          else if (paymentTypes.isEmpty)
            Center(child: Text('no_payment_methods'.tr(context)))
          else
            Column(
              children: paymentTypes.map((paymentType) {
                final isSelected = selectedPaymentTypeKey == paymentType.paymentTypeKey;
                return _buildPaymentMethodItem(
                  context,
                  paymentType,
                  isSelected,
                );
              }).toList(),
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
        children: List.generate(2, (index) =>
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 100,
                  height: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(
      BuildContext context,
      PaymentType paymentType,
      bool isSelected,
      ) {
    Widget paymentIcon;

    // Default icon handling with error fallback
    paymentIcon = CustomImage(
      imageUrl: paymentType.image,
      width: 40,
      height: 24,
      fit: BoxFit.contain,
    );

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          children: [
            Radio<String>(
              value: paymentType.paymentTypeKey,
              groupValue: selectedPaymentTypeKey,
              onChanged: (value) => onPaymentTypeSelected(value!),
              activeColor: AppTheme.primaryColor,
            ),
            paymentIcon,
            const SizedBox(width: 12),
            Text(paymentType.name, style: context.titleSmall),
          ],
        ),
      ),
    );
  }
}