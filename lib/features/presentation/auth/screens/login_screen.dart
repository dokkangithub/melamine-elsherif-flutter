import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/di/injection_container.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/local_storage/local_storage_keys.dart';
import 'package:melamine_elsherif/core/utils/local_storage/secure_storage.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';
import 'package:melamine_elsherif/features/presentation/main%20layout/controller/layout_provider.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_loading.dart';
import '../../../../core/utils/widgets/custom_snackbar.dart';
import '../../../../core/utils/widgets/cutsom_toast.dart';
import '../controller/auth_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widgets/login_screen_logo.dart';
import '../widgets/social_login_widget.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
      body: Consumer<AuthProvider>(
        builder:
            (context, authProvider, _) => Form(
              key: _formKey,
              child: SafeArea(
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo
                              FadeInDown(
                                duration: const Duration(milliseconds: 500),
                                child: const LoginScreenLogo(),
                              ),

                              // Welcome back text
                              FadeInLeft(
                                duration: const Duration(milliseconds: 600),
                                delay: const Duration(milliseconds: 100),
                                child: Row(
                                  children: [
                                    Text(
                                      'welcome_back_1'.tr(context),
                                      style: context.displaySmall.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Subtitle
                              FadeInLeft(
                                duration: const Duration(milliseconds: 600),
                                delay: const Duration(milliseconds: 200),
                                child: Row(
                                  children: [
                                    Text(
                                      'sign_in_continue'.tr(context),
                                      style: context.titleSmall.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Email Field
                              FadeInUp(
                                duration: const Duration(milliseconds: 700),
                                delay: const Duration(milliseconds: 300),
                                child: Align(
                                  alignment: Directionality.of(context) == TextDirection.rtl 
                                      ? Alignment.centerRight 
                                      : Alignment.centerLeft,
                                  child: Text(
                                    'email'.tr(context),
                                    style: context.titleMedium.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              FadeInUp(
                                duration: const Duration(milliseconds: 700),
                                delay: const Duration(milliseconds: 350),
                                child: CustomTextFormField(
                                  controller: emailController,
                                  hint: 'enter_your_email'.tr(context),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              FadeInUp(
                                duration: const Duration(milliseconds: 700),
                                delay: const Duration(milliseconds: 400),
                                child: Align(
                                  alignment: Directionality.of(context) == TextDirection.rtl 
                                      ? Alignment.centerRight 
                                      : Alignment.centerLeft,
                                  child: Text(
                                    'password'.tr(context),
                                    style: context.titleMedium.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              FadeInUp(
                                duration: const Duration(milliseconds: 700),
                                delay: const Duration(milliseconds: 450),
                                child: CustomTextFormField(
                                  controller: passwordController,
                                  hint: 'enter_password'.tr(context),
                                  keyboardType: TextInputType.emailAddress,
                                  isPassword: true,
                                ),
                              ),

                              // Forgot Password
                              FadeInUp(
                                duration: const Duration(milliseconds: 700),
                                delay: const Duration(milliseconds: 500),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      AppRoutes.navigateTo(
                                        context,
                                        AppRoutes.forgetPassword,
                                      );
                                    },
                                    child: Text(
                                      'forgot_password'.tr(context),
                                      style: context.titleSmall.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Sign In Button
                              FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 600),
                                child: authProvider.isLoading
                                    ? const CustomLoadingWidget()
                                    : CustomButton(
                                        onPressed:
                                            () => _handleLogin(context, authProvider),
                                        isGradient: true,
                                        backgroundColor: AppTheme.primaryColor,
                                        text: 'sign_in'.tr(context),
                                        fullWidth: true,
                                      ),
                              ),

                              const SizedBox(height: 32),
                              // Or continue with
                              FadeIn(
                                duration: const Duration(milliseconds: 900),
                                delay: const Duration(milliseconds: 700),
                                child: Row(
                                  children: [
                                    const Expanded(child: Divider()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        'or_continue_with'.tr(context),
                                        style: context.bodyLarge.copyWith(
                                          color: Colors.grey[900],
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Social Login Options
                              FadeInUp(
                                duration: const Duration(milliseconds: 1000),
                                delay: const Duration(milliseconds: 800),
                                child: const SocialLoginWidget(isLoginScreen: true,),
                              ),

                              const SizedBox(height: 24),

                              // Sign Up Prompt
                              FadeInUp(
                                duration: const Duration(milliseconds: 1100),
                                delay: const Duration(milliseconds: 900),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "don't_have_an_account?".tr(context),
                                      style: context.bodyLarge.copyWith(
                                        color: Colors.grey[900],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        AppRoutes.navigateTo(
                                          context,
                                          AppRoutes.signUp,
                                        );
                                      },
                                      child: Text(
                                        'sign_up'.tr(context),
                                        style: context.bodyLarge.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FadeInLeft(
                      duration: const Duration(milliseconds: 500),
                      child: TextButton(
                        onPressed: () {
                          Provider.of<LayoutProvider>(context,listen: false).currentIndex=0;
                          AppRoutes.navigateTo(
                            context,
                            AppRoutes.mainLayoutScreen,
                          );
                        },
                          style: ButtonStyle(
                            overlayColor: WidgetStateProperty.all(Colors.transparent),
                            splashFactory: NoSplash.splashFactory,
                          ),
                        child: const CustomImage(
                          assetPath:  AppSvgs.back,
                          fit: BoxFit.cover,
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }


  void _handleLogin(BuildContext context, AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      bool isSuccess = await authProvider.login(
        emailController.text,
        passwordController.text,
        emailController.text.contains('@') ? 'email' : 'phone',
        context,
      );
      if (isSuccess) {
        // Set the isLoggedIn flag in secure storage
        await sl<SecureStorage>().save(LocalStorageKey.isLoggedIn, true);
        AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.mainLayoutScreen);
        CustomToast.showToast(
          message: 'login_successfully'.tr(context),
          type: ToastType.success,
        );
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
