import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import '../../../../../core/config/routes.dart/routes.dart';

class CheckoutButton extends StatelessWidget {
  const CheckoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0,left: 20,right: 20),
      child: CustomButton(
        backgroundColor: AppTheme.accentColor,
        fullWidth: true,
        onPressed: () {
          AppRoutes.navigateTo(context, AppRoutes.newCheckoutScreen);
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            CustomImage(assetPath: AppSvgs.category_1,height: 20,width: 20,),
            Text(
              'proceed_to_royal_checkout'.tr(context),
              style: context.titleMedium?.copyWith(color: AppTheme.white),
            ),
          ],
        ),
      ),
    );
  }
}


