import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_button.dart';
import '../../../../core/utils/widgets/custom_form_field.dart';
import '../../../../core/utils/widgets/custom_loading.dart';
import '../../../../core/utils/widgets/custom_snackbar.dart';
import '../controller/auth_provider.dart';
import 'password_strength_indicator.dart';

class SignUpForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const SignUpForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    widget.passwordController.removeListener(_onPasswordChanged);
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder:
          (context, authProvider, _) => Form(
            key: widget.formKey,
            child: Column(
              children: [
                _buildInputField(
                  context,
                  controller: widget.nameController,
                  hintText: 'full_name'.tr(context),
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_name'.tr(context);
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  context,
                  controller: widget.emailController,
                  hintText: 'email_or_phone'.tr(context),
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_email_phone'.tr(context);
                    }
                    return null;
                  },
                ),
                _buildInputField(
                  context,
                  controller: widget.passwordController,
                  hintText: 'password'.tr(context),
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_password'.tr(context);
                    }
                    if (value.length < 8) {
                      return 'password_min_length'.tr(context);
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PasswordStrengthIndicator(
                    password: widget.passwordController.text,
                  ),
                ),
                _buildInputField(
                  context,
                  controller: widget.confirmPasswordController,
                  hintText: 'confirm_password'.tr(context),
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_confirm_password'.tr(context);
                    } else if (value != widget.passwordController.text) {
                      return 'passwords_not_match'.tr(context);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (authProvider.isLoading)
                  const CustomLoadingWidget()
                else
                  Column(
                    children: [
                      if (authProvider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      CustomButton(
                        text: 'sign_up'.tr(context),
                        onPressed: () => _handleSignUp(context, authProvider),
                      ),
                    ],
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CustomTextFormField(
        controller: controller,
        hint: hintText,
        prefixIcon: Icon(prefixIcon),
        isPassword: isPassword,
        validator: validator,
      ),
    );
  }

  void _handleSignUp(BuildContext context, AuthProvider authProvider) async {
    if (widget.formKey.currentState!.validate()) {
      final userData = {
        "name": widget.nameController.text,
        "password": widget.passwordController.text,
        "email_or_phone": widget.emailController.text,
        "password_confirmation": widget.confirmPasswordController.text,
        "register_by":
            widget.emailController.text.contains('@') ? 'email' : 'phone',
      };

      final isSuccess = await authProvider.signup(userData,context);
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: authProvider.errorMessage!,
          isError: !isSuccess,
        );
        if (isSuccess) {
          AppRoutes.navigateToAndRemoveUntil(
            context,
            AppRoutes.mainLayoutScreen,
          );
        }
      }
    }
  }
}
