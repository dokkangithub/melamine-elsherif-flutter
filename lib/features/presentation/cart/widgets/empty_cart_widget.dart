import 'package:flutter/material.dart';
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
          CustomImage(
            assetPath: AppImages.emptyCart,
            height: 150,
            width: 150,
          ),
          const SizedBox(height: 16),
          Text(
            'your_cart_is_empty'.tr(context),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'add_items_to_cart'.tr(context),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: () {
              Provider.of<LayoutProvider>(context,listen: false).currentIndex=0;
            },
            child: Text('continue_shopping'.tr(context),style: context.titleMedium?.copyWith(color: AppTheme.white)),
          ),
        ],
      ),
    );
  }
}

