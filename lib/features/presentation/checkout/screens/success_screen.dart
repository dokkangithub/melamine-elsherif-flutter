import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/constants/app_strings.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/features/presentation/checkout/controller/payment_provider.dart';
import 'package:provider/provider.dart';

import '../../../data/payment/models/payment_type_model.dart';
import '../../main layout/controller/layout_provider.dart';

class SuccessScreen extends StatelessWidget {
   SuccessScreen({super.key, required this.orderDetails});
  final OrderResponseModel orderDetails;

  @override
  Widget build(BuildContext context) {

    PaymentProvider paymentProvider=Provider.of<PaymentProvider>(context,listen: false);
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lotus flower icon in circle
              Center(
                child: CustomImage(
                  assetPath: AppSvgs.success_icon,
                ),
              ),
              const SizedBox(height: 32),

              // Thank you message
               Center(
                child: Text(
                  "thank_you_for_your_order".tr(context),
                  style: context.displaySmall?.copyWith(color: AppTheme.accentColor)
                ),
              ),
              const SizedBox(height: 16),

              // Order preparation message
               Center(
                child: Text(
                  "We're_preparing_your_order_with_care_You'll_receive_updates_soon".tr(context),
                  style: context.titleMedium?.copyWith(color: AppTheme.lightDividerColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),

              // Order details
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "order_id".tr(context),
                    style: context.titleSmall?.copyWith(color: AppTheme.lightSecondaryTextColor),
                  ),
                  Text(
                    orderDetails.combinedOrder!.id.toString(),
                    style: context.titleSmall?.copyWith(color: AppTheme.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),


               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "estimated_delivery".tr(context),
                    style: context.titleSmall?.copyWith(color: AppTheme.lightSecondaryTextColor),
                  ),
                  Text(
                    "3-5_business_days".tr(context),
                    style: context.titleSmall?.copyWith(color: AppTheme.white),
                  ),
                ],
              ),
              const SizedBox(height: 12),

               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "payment_method".tr(context),
                    style: context.titleSmall?.copyWith(color: AppTheme.lightSecondaryTextColor),
                  ),
                  Text(
                    orderDetails.combinedOrder!.orders![0].paymentType,
                    style: context.titleSmall?.copyWith(color: AppTheme.white),
                  ),
                ],
              ),

              const Spacer(),

              // Track Order button (gold)
              CustomButton(
                onPressed: () {
                  if (AppStrings.token != null) {
                    Provider.of<LayoutProvider>(context, listen: false).currentIndex = 4;
                    AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.mainLayoutScreen);
                  }
                },
                backgroundColor: AppTheme.accentColor,
                child: Center(
                  child: Text(
                    "track_order".tr(context),
                    style: context.headlineSmall?.copyWith(color: AppTheme.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Back to Home button (outlined)
              CustomButton(
                onPressed: () {
                  Provider.of<LayoutProvider>(context,listen: false).currentIndex=0;
                  AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.mainLayoutScreen);
                },
                isOutlined: true,
                child: Center(
                  child: Text(
                    "continue_shopping".tr(context),
                    style: context.headlineSmall?.copyWith(color: AppTheme.accentColor),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}