import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';
import 'package:melamine_elsherif/core/utils/widgets/cutsom_toast.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/routes.dart/routes.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_button.dart';
import '../../../../core/utils/widgets/custom_quick_alart_widget.dart';
import '../../../../core/utils/widgets/custom_snackbar.dart';
import '../controller/auth_provider.dart';
import '../widgets/social_login_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color to white with dark icons
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Create Account Title
                    Text(
                      'create_account'.tr(context),
                      style: context.displayMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'sign_up_to_start'.tr(context),
                      style: context.titleLarge.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Social Login Options
                    const SocialLoginWidget(isLoginScreen: false),

                    const SizedBox(height: 32),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: context.titleMedium.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Name Field
                    CustomTextFormField(
                      controller: _nameController,
                      hint: 'full_name'.tr(context),
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    CustomTextFormField(
                      controller: _emailController,
                      hint: 'email_or_phone'.tr(context),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    CustomTextFormField(
                      controller: _passwordController,
                      hint: 'password'.tr(context),
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    CustomTextFormField(
                      controller: _confirmPasswordController,
                      hint: 'confirm_password'.tr(context),
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),

                    /// Terms and Conditions
                    // Row(
                    //   children: [
                    //     SizedBox(
                    //       width: 24,
                    //       height: 24,
                    //       child: Checkbox(
                    //         value: _acceptTerms,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _acceptTerms = value ?? false;
                    //           });
                    //         },
                    //         activeColor: AppTheme.primaryColor,
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(4),
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(width: 8),
                    //     Expanded(
                    //       child: Wrap(
                    //         children: [
                    //           Text(
                    //             'I agree to the '.tr(context),
                    //             style: context.bodySmall,
                    //           ),
                    //           GestureDetector(
                    //             onTap: () {
                    //               // Navigate to Terms of Service
                    //             },
                    //             child: Text(
                    //               'Terms of Service'.tr(context),
                    //               style: context.bodySmall.copyWith(
                    //                 color: AppTheme.primaryColor,
                    //               ),
                    //             ),
                    //           ),
                    //           Text(
                    //             ' and '.tr(context),
                    //             style: context.bodySmall,
                    //           ),
                    //           GestureDetector(
                    //             onTap: () {
                    //               // Navigate to Privacy Policy
                    //             },
                    //             child: Text(
                    //               'Privacy Policy'.tr(context),
                    //               style: context.bodySmall.copyWith(
                    //                 color: AppTheme.primaryColor,
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 24),

                    // Sign Up Button
                    Consumer<AuthProvider>(
                      builder: (context, provider, _) {
                        return CustomButton(
                          onPressed: () {

                            if (_passwordController.text ==
                                _confirmPasswordController.text) {
                              _handleSignUp(context, provider);
                            } else {
                              CustomToast.showToast(
                                message: 'passwords_not_match'.tr(context),
                                type: ToastType.error,
                              );
                            }
                          },
                          backgroundColor: AppTheme.primaryColor,
                          isGradient: true,
                          text: 'sign_up'.tr(context),
                          fullWidth: true,
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Login Prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'already_have_account'.tr(context),
                          style: context.titleMedium.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            AppRoutes.navigateToAndRemoveUntil(
                              context,
                              AppRoutes.login,
                            );
                          },
                          child: Text(
                            'login'.tr(context),
                            style: context.titleMedium.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignUp(BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final userData = {
        "name": _nameController.text,
        "password": _passwordController.text,
        "email_or_phone": _emailController.text,
        "password_confirmation": _confirmPasswordController.text,
        "register_by": _emailController.text.contains('@') ? 'email' : 'phone',
      };

      final isSuccess = await authProvider.signup(userData, context);

      if (isSuccess) {
        CustomQuickAlert.showSuccess(
          context,
          title: 'success!'.tr(context),
          subTitleText: 'create_account_successfully'.tr(context),
          titleStyle: context.displaySmall,
          subtitleStyle:context.titleMedium,
          confirmBtnTextStyle: context.titleLarge.copyWith(color: AppTheme.white,fontWeight: FontWeight.w900),
          confirmBtnText: 'sign_in'.tr(context),
          onConfirmBtnTap: () {
            AppRoutes.navigateTo(context, AppRoutes.login);
          },
        );
      } else {
        CustomSnackbar.show(
          context,
          message: authProvider.errorMessage ?? 'Failed to sign up',
          isError: true,
        );
      }
    }
  }
}
