import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as ToastComponent;
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
import 'package:provider/provider.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_loading.dart';
import '../../../../core/utils/widgets/custom_snackbar.dart';
import '../controller/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color to white with dark icons
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) => Form(
          key: _formKey,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      const CustomImage(
                        assetPath: AppImages.appLogo,
                        height: 160,
                        width: 160,
                      ),
                      
                      // Welcome back text
                      Row(
                        children: [
                          Text('welcome_back_1'.tr(context),
                            style: context.displaySmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      Row(
                        children: [
                          Text(
                            'sign_in_continue'.tr(context),
                            style: context.titleMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Email Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'email'.tr(context),
                          style: context.titleMedium.copyWith(fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        controller: emailController,
                        hint: 'enter_your_email'.tr(context),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'password'.tr(context),
                          style: context.titleMedium.copyWith(fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        controller: passwordController,
                        hint: 'enter_password'.tr(context),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            AppRoutes.navigateTo(context, AppRoutes.forgetPassword);
                          },
                          child: Text(
                            'forgot_password'.tr(context),
                            style: context.titleSmall.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Sign In Button
                      if (authProvider.isLoading)
                        const CustomLoadingWidget()
                      else
                        CustomButton(
                          onPressed: () => _handleLogin(context, authProvider),
                          backgroundColor: AppTheme.primaryColor,
                          text: 'login'.tr(context),
                          fullWidth: true,
                        ),
                      
                      const SizedBox(height: 20),
                      CustomButton(
                          onPressed: () {AppRoutes.navigateTo(context, AppRoutes.mainLayoutScreen);},
                          backgroundColor: AppTheme.primaryColor,
                          isOutlined: true,
                          text: 'continue_as_guest'.tr(context),
                          fullWidth: true,
                        ),
                       const SizedBox(height: 32),
                      // Or continue with
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or_continue_with'.tr(context),
                              style: context.bodySmall.copyWith(color: Colors.grey),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Social Login Options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            icon: AppSvgs.google,
                            onTap: () {
                              // Handle Google login
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildSocialButton(
                            icon: AppSvgs.facebook,
                            onTap: () {
                              // Handle Facebook login
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildSocialButton(
                            icon: AppSvgs.apple,
                            onTap: () {
                              // Handle Apple login
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Sign Up Prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "don't_have_an_account?".tr(context),
                            style: context.bodyMedium.copyWith(color: Colors.grey[700]),
                          ),
                          GestureDetector(
                            onTap: () {
                              AppRoutes.navigateTo(context, AppRoutes.signUp);
                            },
                            child: Text(
                              'sign_up'.tr(context),
                              style: context.bodyMedium.copyWith(
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
      ),
    );
  }


  bool isGoogleLoggingIn =false;

  // onPressedGoogleLogin() async {
  //   setState(() {
  //     isGoogleLoggingIn = true;
  //   });
  //   try {
  //
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) {
  //       setState(() {
  //         isGoogleLoggingIn = false;
  //       });
  //       return; // Exit early if no account is selected
  //     }
  //     print(googleUser.toString());
  //
  //     GoogleSignInAuthentication googleSignInAuthentication =
  //     await googleUser.authentication;
  //     String? accessToken = googleSignInAuthentication.accessToken;
  //
  //     print("accessToken $accessToken");
  //     print("displayName ${googleUser.displayName}");
  //     print("email ${googleUser.email}");
  //     print("googleUser.id ${googleUser.id}");
  //
  //     var loginResponse = await Provider.of<AuthProvider>(context,listen: false).completeSocialLogin(
  //         "google", googleUser.displayName!, googleUser.email, googleUser.id,
  //         access_token: accessToken);
  //
  //     if (loginResponse.result == false) {
  //       ToastComponent.showDialog(loginResponse.message,
  //           gravity: Toast.center, duration: Toast.lengthLong);
  //       setState(() {
  //         isGoogleLoggingIn = false;
  //       });
  //     } else {
  //       ToastComponent.showDialog(loginResponse.message,
  //           gravity: Toast.center, duration: Toast.lengthLong);
  //       print(loginResponse);
  //       setState(() {
  //         isGoogleLoggingIn = false;
  //       });
  //       AuthHelper().setUserData(loginResponse);
  //       print('${is_logged_in.$} LOGIN RESPONSE');
  //       Navigator.pushAndRemoveUntil(context,
  //           MaterialPageRoute(builder: (context) {
  //             return Main();
  //           }), (route) => false);
  //     }
  //     GoogleSignIn().disconnect();
  //   } on Exception catch (e) {
  //     print("error is ....... $e");
  //     setState(() {
  //       isGoogleLoggingIn = false;
  //     });
  //   }
  // }



  Widget _buildSocialButton({required String icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: SvgPicture.asset(
            icon,
            width: 24,
            height: 24,
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
        context
      );
      if (isSuccess) {
        // Set the isLoggedIn flag in secure storage
        await sl<SecureStorage>().save(LocalStorageKey.isLoggedIn, true);
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