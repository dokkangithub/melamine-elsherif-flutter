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
  final bool isLoading;

  const PaymentMethodSection({
    super.key,
    required this.paymentTypes,
    required this.selectedPaymentTypeKey,
    required this.onPaymentTypeSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment_outlined, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'payment_method'.tr(context),
                style: context.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
        Container(
          width: double.infinity,
          height: 60,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
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

    // Determine icon based on payment type key if image fails to load
    IconData getIconForPaymentType(String key) {
      switch (key) {
        case 'cash_on_delivery':
          return Icons.money;
        case 'wallet':
          return Icons.account_balance_wallet;
        case 'digital_wallet':
          return Icons.smartphone;
        case 'credit_card':
          return Icons.credit_card;
        case 'club_points':
          return Icons.star;
        default:
          return Icons.payment;
      }
    }

    // Default icon handling with error fallback
    paymentIcon = CustomImage(
      imageUrl: paymentType.image,
      width: 32,
      height: 24,
      fit: BoxFit.contain,
      errorWidget: Icon(
        getIconForPaymentType(paymentType.paymentTypeKey),
        size: 24,
        color: Colors.grey[600],
      ),
    );

    // Translate payment method name based on language
    String paymentMethodName = isArabic 
        ? _getArabicPaymentMethodName(paymentType.paymentTypeKey)
        : paymentType.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          width: isSelected ? 1 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: () => onPaymentTypeSelected(paymentType.paymentTypeKey),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Radio<String>(
                value: paymentType.paymentTypeKey,
                groupValue: selectedPaymentTypeKey,
                onChanged: (value) => onPaymentTypeSelected(value!),
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              paymentIcon,
              const SizedBox(width: 16),
              Text(
                paymentMethodName, 
                style: context.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal
                ),
              ),
            ],
          ),
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
      case 'digital_wallet':
        return 'المحفظة الرقمية';
      case 'credit_card':
        return 'بطاقة ائتمان';
      case 'club_points':
        return 'نقاط النادي';
      default:
        return paymentTypeKey;
    }
  }
}