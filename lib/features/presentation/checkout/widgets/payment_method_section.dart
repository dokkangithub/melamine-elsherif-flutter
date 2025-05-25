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
    bool isArabic = Directionality.of(context) == TextDirection.rtl;

    // Default icon handling with error fallback
    paymentIcon = CustomImage(
      imageUrl: paymentType.image,
      width: 40,
      height: 24,
      fit: BoxFit.contain,
    );

    // Translate payment method name based on language
    String paymentMethodName = isArabic 
        ? _getArabicPaymentMethodName(paymentType.paymentTypeKey)
        : paymentType.name;

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
            Text(paymentMethodName, style: context.titleSmall),
          ],
        ),
      ),
    );
  }

  // Helper method to get Arabic translations for payment methods
  String _getArabicPaymentMethodName(String paymentTypeKey) {
    switch (paymentTypeKey) {
      case 'cash_on_delivery':
        return 'الدفع عند الاستلام';
      case 'wallet':
        return 'المحفظة';
      case 'cash_payment':
        return 'الدفع نقدا';
      case 'bank_payment':
        return 'تحويل بنكي';
      case 'kashier':
        return 'الدفع الالكترونى';
      case 'paypal':
        return 'باي بال';
      case 'stripe':
        return 'سترايب';
      case 'paytm':
        return 'باي تي إم';
      case 'sslcommerz':
        return 'إس إس إل كوميرز';
      case 'instamojo':
        return 'انستاموجو';
      case 'razorpay':
        return 'رازورباي';
      case 'paystack':
        return 'بايستاك';
      case 'voguepay':
        return 'فوجباي';
      case 'payhere':
        return 'باي هير';
      case 'ngenius':
        return 'إن جينيوس';
      case 'iyzico':
        return 'إيزيكو';
      case 'bkash':
        return 'بي كاش';
      case 'nagad':
        return 'ناجاد';
      case 'flutterwave':
        return 'فلاترويف';
      case 'mpesa':
        return 'إم بيسا';
      case 'mercadopago':
        return 'ميركادو باجو';
      default:
        return paymentTypeKey; // Fallback to original key if no translation available
    }
  }
}