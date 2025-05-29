import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_button.dart';

class SaveAddressButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final bool isEditing;

  const SaveAddressButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text:
          isEditing ? 'update_address'.tr(context) : 'add_address'.tr(context),
      onPressed: isLoading ? null : onPressed,
      isLoading: isLoading,
      textColor: AppTheme.white,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
      textStyle: context.titleSmall!.copyWith(color: AppTheme.white,fontWeight: FontWeight.w800),
      borderRadius: 8.0,
    );
  }
}
