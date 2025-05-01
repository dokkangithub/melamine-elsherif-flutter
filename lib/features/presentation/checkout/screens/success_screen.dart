import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/features/presentation/checkout/controller/payment_provider.dart';
import 'package:provider/provider.dart';

import '../../../data/payment/models/payment_type_model.dart';
import '../../main layout/controller/layout_provider.dart';

class SuccessScreen extends StatelessWidget {
  SuccessScreen({super.key, required this.orderDetails});
  final OrderResponseModel orderDetails;

  @override
  Widget build(BuildContext context) {
    PaymentProvider paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    
    // Format the order number
    String orderNumber = "#ORD-${orderDetails.combinedOrder!.id}";
    
    // Generate estimated delivery date (5 days from now)
    final now = DateTime.now();
    final deliveryDate = now.add(const Duration(days: 5));
    final formattedDate = "${_getMonthName(deliveryDate.month)} ${deliveryDate.day}, ${deliveryDate.year}";
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Success check icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFBD5B4D), // Adjusted to match image
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Thank you heading
              Center(
                child: Text('Thank You!'.tr(context),
                  style: context.displaySmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Order confirmation message
              Center(
                child: Text('Your order has been successfully placed'.tr(context),
                  style: context.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // Order details card
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Order number row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order number'.tr(context),
                          style: context.titleSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          orderNumber,
                          style: context.titleSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Estimated delivery row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Estimated delivery'.tr(context),
                          style: context.titleSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: context.titleSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Track Order button
              CustomButton(
                onPressed: () {
                  if (AppStrings.token != null) {
                    Provider.of<LayoutProvider>(context, listen: false).currentIndex = 4;
                    AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.mainLayoutScreen);
                  }
                },
                backgroundColor: const Color(0xFFBD5B4D),
                borderRadius: 8,
                child: Center(
                  child: Text(
                    "Track Order",
                    style: context.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Continue Shopping button
              CustomButton(
                onPressed: () {
                  Provider.of<LayoutProvider>(context, listen: false).currentIndex = 0;
                  AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.mainLayoutScreen);
                },
                isOutlined: true,
                borderRadius: 8,
                backgroundColor: const Color(0xFFBD5B4D),
                child: Center(
                  child: Text(
                    "Continue Shopping",
                    style: context.headlineSmall?.copyWith(
                      color: const Color(0xFFBD5B4D),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          SizedBox(height: 80)
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to convert month number to name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}