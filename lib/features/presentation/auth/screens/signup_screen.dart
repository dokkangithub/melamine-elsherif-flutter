import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/helpers/ui_helper.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';
import 'package:melamine_elsherif/core/utils/widgets/cutsom_toast.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_quick_alart_widget.dart';
import '../../../../core/utils/widgets/custom_snackbar.dart';
import '../../../../core/utils/widgets/language_switcher.dart';
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
  void initState() {
    super.initState();
    // Force the status bar to be transparent at startup using our helper
    UIHelper.setTransparentStatusBar();
  }

  @override
  Widget build(BuildContext context) {
    // Use our helper to wrap the Scaffold
    return UIHelper.wrapWithStatusBarConfig(
      Scaffold(
        extendBodyBehindAppBar: true, // Important: extend body behind app bar
        backgroundColor: const Color(0xFFF2F2F2), // Match the light gray of the background
        // Remove app bar
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              // Background image
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage(AppImages.loginBackground),
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                    colorFilter: ColorFilter.mode(
                      AppTheme.white.withValues(alpha: 0.8),
                      BlendMode.lighten,
                    ),
                  ),
                ),
              ),
              
              // Content
              SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        
                        // Top row with back button and language switcher
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                              onPressed: () => Navigator.of(context).pop(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            
                            // Language switcher
                            const LanguageSwitcher(),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Logo/Brand name
                        Center(
                          child: Text(
                            'app_name'.tr(context),
                            style: context.displayMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Create new account text
                        Center(
                          child: Text(
                            'create_new_account'.tr(context),
                            style: context.headlineMedium.copyWith(
                              fontWeight: FontWeight.w300,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Name field
                        CustomTextFormField(
                          controller: _nameController,
                          hint: 'name'.tr(context),
                          isBorderAvailable: false,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Email field
                        CustomTextFormField(
                          controller: _emailController,
                          hint: 'email_address'.tr(context),
                          keyboardType: TextInputType.emailAddress,
                          isBorderAvailable: false,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Password field
                        CustomTextFormField(
                          controller: _passwordController,
                          hint: 'password'.tr(context),
                          isPassword: true,
                          isBorderAvailable: false,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Sign up button
                        Consumer<AuthProvider>(
                          builder: (context, provider, _) {
                            return CustomButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  if (_passwordController.text == _confirmPasswordController.text) {
                                    _handleSignUp(context, provider);
                                  } else {
                                    CustomToast.showToast(
                                      message: 'passwords_not_match'.tr(context),
                                      type: ToastType.error,
                                    );
                                  }
                                }
                              },
                              text: 'sign_up'.tr(context),
                              fullWidth: true,
                              isLoading: provider.isLoading,
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Divider with "or" text
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or'.tr(context),
                                style: context.bodySmall.copyWith(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Social login options
                        const SocialLoginWidget(isLoginScreen: false),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
        "password_confirmation": _passwordController.text,
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
