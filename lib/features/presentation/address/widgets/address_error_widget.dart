import 'package:flutter/material.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_button.dart';

class AddressErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const AddressErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            '${'error_loading_addresses'.tr(context)}: $errorMessage',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'try_again'.tr(context),
            onPressed: onRetry,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
            icon: Icons.refresh.toString(),
          ),
        ],
      ),
    );
  }
}
