import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 16),
      borderRadius: 8.0,
    );
  }
}
