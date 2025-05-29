import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/di/injection_container.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/helpers/ui_helper.dart';
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
import '../../../../core/utils/widgets/language_switcher.dart';
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
        extendBodyBehindAppBar: true,
        // Important: extend body behind app bar
        backgroundColor: const Color(0xFFF2F2F2),
        // Match the light gray of the background
        // Remove app bar completely
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, _) =>
              Form(
                key: _formKey,
                child: Stack(
                  children: [
                    // Background image
                    Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
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

                              // Language switcher at the top right
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const LanguageSwitcher(),
                                  FadeInLeft(
                                    duration: const Duration(milliseconds: 500),
                                    child: InkWell(
                                        onTap: () {
                                          Provider.of<LayoutProvider>(context,listen: false).currentIndex=0;
                                          AppRoutes.navigateTo(
                                            context,
                                            AppRoutes.mainLayoutScreen,
                                          );
                                        },
                                        child: const Icon(Icons.arrow_forward_ios,color: AppTheme.primaryColor,size: 24)
                                    ),
                                  ),

                                ],
                              ),

                              const SizedBox(height: 60),

                              // Logo/Brand name
                              Center(
                                child: Text(
                                  'app_name'.tr(context),
                                  style: context.displayLarge.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 60),

                              // Welcome Back text
                              Center(
                                child: Text(
                                    'welcome_back'.tr(context),
                                    style: Directionality.of(context) == TextDirection.rtl
                                      ? GoogleFonts.tajawal(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w200,
                                          color: Colors.black54,
                                        )
                                      : GoogleFonts.jost(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w200,
                                          color: Colors.black54,
                                        )
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Email field
                              CustomTextFormField(
                                controller: emailController,
                                hint: 'email_address'.tr(context),
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: null,
                                isBorderAvailable: false,
                              ),

                              const SizedBox(height: 16),

                              // Password field
                              CustomTextFormField(
                                controller: passwordController,
                                hint: 'password'.tr(context),
                                isPassword: true,
                                prefixIcon: null,
                                isBorderAvailable: false,
                              ),

                              const SizedBox(height: 35),

                              // Login button
                              authProvider.isLoading
                                  ? const CustomLoadingWidget()
                                  : CustomButton(
                                onPressed: () =>
                                    _handleLogin(context, authProvider),
                                text: 'login'.tr(context),
                                fullWidth: true,
                              ),

                              const SizedBox(height: 24),

                              // Forgot password
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    AppRoutes.navigateTo(
                                      context,
                                      AppRoutes.forgetPassword,
                                    );
                                  },
                                  child: Text(
                                    'forgot_password'.tr(context),
                                    style: context.titleLarge.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w900
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Divider with "or" text
                              Row(
                                children: [
                                  Expanded(child: Divider(
                                      color: Colors.grey.shade300)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      'or'.tr(context),
                                      style: context.bodyLarge.copyWith(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(
                                      color: Colors.grey.shade300)),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Social login options
                              const SocialLoginWidget(isLoginScreen: true),

                              const SizedBox(height: 24),

                              // Sign up prompt
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "t_have_an_account?".tr(context),
                                      style: context.titleLarge.copyWith(
                                        color: Colors.black54,
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
                                        style: context.titleLarge.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
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
