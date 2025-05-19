import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';

import '../../main layout/controller/layout_provider.dart';

class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Card(
          //   elevation: 4,
          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
          //   child: const Padding(
          //     padding: EdgeInsets.all(50.0),
          //     child: CustomImage(
          //       assetPath: AppSvgs.emptyCart,
          //       height: 100,
          //       width: 100,
          //
          //     ),
          //   ),
          // ),
          Lottie.asset(AppAnimations.emptyCart,fit: BoxFit.cover,height: 250,width: 250),
          const SizedBox(height: 16),
          Text(
            'your_cart_is_empty'.tr(context),
            style: context.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'add_items_to_cart'.tr(context),
            style: context.bodyMedium!.copyWith(color: AppTheme.darkDividerColor),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: () {
              Provider.of<LayoutProvider>(context,listen: false).currentIndex=0;
            },
            child: Text('continue_shopping'.tr(context),style: context.titleSmall?.copyWith(color: AppTheme.white)),
          ),
        ],
      ),
    );
  }
}

