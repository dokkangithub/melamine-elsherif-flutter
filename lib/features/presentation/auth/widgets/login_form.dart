import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_button.dart';
import '../../../../core/utils/widgets/custom_form_field.dart';
import '../../../../core/utils/widgets/custom_loading.dart';
import '../../../../core/utils/widgets/custom_snackbar.dart';
import '../controller/auth_provider.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder:
          (context, authProvider, _) => Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextFormField(
                  controller: emailController,
                  hint: 'email'.tr(context),
                  prefixIcon: const Icon(Icons.email),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_email'.tr(context);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextFormField(
                  controller: passwordController,
                  isPassword: true,
                  hint: 'Password'.tr(context),
                  prefixIcon: const Icon(Icons.lock_clock_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'please_enter_password'.tr(context);
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      AppRoutes.navigateTo(context, AppRoutes.forgetPassword);
                    },
                    child: Text(
                      'forgot_password'.tr(context),
                      style: TextStyle(
                        color: Colors.indigo[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
                        text: 'login'.tr(context),
                        onPressed: () => _handleLogin(context, authProvider),
                      ),
                    ],
                  ),
              ],
            ),
          ),
    );
  }

  void _handleLogin(BuildContext context, AuthProvider authProvider) async {
    if (formKey.currentState!.validate()) {
      bool isSuccess = await authProvider.login(
        emailController.text,
        passwordController.text,
        emailController.text.contains('@') ? 'email' : 'phone',context
      );
      if (isSuccess) {
        AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.mainLayoutScreen);
      } else {
        CustomSnackbar.show(
          context,
          message: authProvider.errorMessage ?? 'login_failed'.tr(context),
          isError: true,
        );
      }
    }
  }
}
