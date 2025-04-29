import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_button.dart';

class EmptyAddressWidget extends StatelessWidget {
  final VoidCallback onAddAddress;

  const EmptyAddressWidget({Key? key, required this.onAddAddress})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImage(assetPath: 'assets/images/noLocation.png',height: 90,width: 90),
          const SizedBox(height: 16),
          Text(
            'no_addresses_found'.tr(context),
            style: context.headlineSmall
          ),
          const SizedBox(height: 8),
          Text(
            'add_address_to_continue'.tr(context),
            style: context.titleSmall?.copyWith(color: AppTheme.darkDividerColor)
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'add_new_address'.tr(context),
            onPressed: onAddAddress,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: context.titleMedium?.copyWith(color: AppTheme.white),
            icon: 'assets/images/noLocation.png',
          ),
        ],
      ),
    );
  }
}
