import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_back_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_loading.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/utils/constants/app_assets.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../../../core/utils/widgets/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  bool _isSendingEmail = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Implement actual password reset logic

    setState(() => _isLoading = false);

    if (mounted) {
      CustomSnackbar.show(
        context,
        message: _isSendingEmail
            ? 'Reset link has been sent to your email'
            : 'OTP has been sent to your phone',
        isError: false,
      );
    }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: FadeInLeft(
          duration: const Duration(milliseconds: 500),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 24.0),
                      child: CustomImage(
                        assetPath:  AppImages.appLogo,
                        height: 150,
                        width: 250,
                      ),
                    ),
                  ),

                  // Forgot Password Title
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'forgot_password'.tr(context),
                      style: context.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Subtitle
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      _isSendingEmail
                        ? 'forgot_password_email_desc'.tr(context)
                        : 'forgot_password_phone_desc'.tr(context),
                      style: context.titleSmall.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email/Phone Field Label
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 300),
                    child: Align(
                      alignment: Directionality.of(context) == TextDirection.rtl
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        _isSendingEmail ? 'email'.tr(context) : 'phone'.tr(context),
                        style: context.titleSmall,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Email/Phone TextFormField
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 350),
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: _isSendingEmail ? 'enter_your_email'.tr(context) : 'enter_your_phone_number'.tr(context),
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        hintTextDirection: Directionality.of(context),
                        alignLabelWithHint: true,
                      ),
                      keyboardType: _isSendingEmail
                        ? TextInputType.emailAddress
                        : TextInputType.phone,
                      textDirection: Directionality.of(context),
                      textAlign: Directionality.of(context) == TextDirection.rtl ? TextAlign.right : TextAlign.left,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return _isSendingEmail
                            ? 'please_enter_email'.tr(context)
                            : 'please_enter_phone'.tr(context);
                        }
                        if (_isSendingEmail && !value.contains('@')) {
                          return 'please_enter_valid_email'.tr(context);
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Toggle Method Button
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 400),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isSendingEmail = !_isSendingEmail;
                          _controller.clear();
                        });
                      },
                      child: Text(
                        _isSendingEmail
                            ? 'use_phone_number_instead'.tr(context)
                            : 'use_email_address_instead'.tr(context),
                        style: context.titleSmall.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 500),
                    child: _isLoading
                      ? const Center(child: CustomLoadingWidget())
                      : CustomButton(
                          onPressed: _handleResetPassword,
                          backgroundColor: AppTheme.primaryColor,
                          text: _isSendingEmail ? 'send_reset_link'.tr(context) : 'send_otp'.tr(context),
                          fullWidth: true,
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Back to Login
                  FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    delay: const Duration(milliseconds: 600),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('remember_your_password'.tr(context),
                          style: context.titleMedium.copyWith(color: Colors.grey[700]),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('sign_in'.tr(context),
                            style: context.titleMedium.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}