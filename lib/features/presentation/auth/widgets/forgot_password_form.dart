import 'package:flutter/material.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_button.dart';
import '../../../../core/utils/widgets/custom_form_field.dart';
import '../../../../core/utils/widgets/custom_loading.dart';

class ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isSendingEmail;
  final bool isLoading;
  final Function() onSubmit;
  final Function(bool) onToggleMethod;

  const ForgotPasswordForm({
    super.key,
    required this.formKey,
    required this.controller,
    required this.isSendingEmail,
    required this.isLoading,
    required this.onSubmit,
    required this.onToggleMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _buildToggleOptions(context),
          const SizedBox(height: 24),
          CustomTextFormField(
            controller: controller,
            hint: isSendingEmail ? 'email'.tr(context) : 'phone'.tr(context),
            prefixIcon: Icon(
              isSendingEmail ? Icons.email_outlined : Icons.phone_outlined,
              color: Colors.grey[600],
            ),
            keyboardType:
                isSendingEmail
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return isSendingEmail
                    ? 'please_enter_email'.tr(context)
                    : 'please_enter_phone'.tr(context);
              }
              if (isSendingEmail &&
                  !RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                return 'please_enter_valid_email'.tr(context);
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          isLoading
              ? const CustomLoadingWidget()
              : CustomButton(
                text:
                    isSendingEmail
                        ? 'send_reset_link'.tr(context)
                        : 'send_otp'.tr(context),
                onPressed: onSubmit,
              ),
        ],
      ),
    );
  }

  Widget _buildToggleOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleOption(
          title: 'email'.tr(context),
          isSelected: isSendingEmail,
          onTap: () => onToggleMethod(true),
        ),
        const SizedBox(width: 24),
        _buildToggleOption(
          title: 'phone'.tr(context),
          isSelected: !isSendingEmail,
          onTap: () => onToggleMethod(false),
        ),
      ],
    );
  }

  Widget _buildToggleOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.indigo[700] : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: isSelected ? Colors.indigo[700] : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
