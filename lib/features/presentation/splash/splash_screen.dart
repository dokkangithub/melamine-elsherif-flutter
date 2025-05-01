import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/app_config.dart/app_config.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import '../../../core/config/routes.dart/routes.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/local_storage/local_storage_keys.dart';
import '../../../core/utils/local_storage/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigationPath();
  }

  Future<void> _checkNavigationPath() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final secureStorage = sl<SecureStorage>();
    final hasCompletedOnboarding = await secureStorage.get<bool>(LocalStorageKey.hasCompletedOnboarding) ?? false;

    if (!hasCompletedOnboarding) {
      // First time: Navigate to onboarding
      AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.onboarding);
    }  else {
      // Already logged in: Navigate to home
      AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.mainLayoutScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/melamine_elsherif_logo.png',
                      width: 180,
                      height: 180,
                    ),
                    const SizedBox(height: 16),
                    Text('your_ultimate_shopping_destination'.tr(context),
                      style: context.titleSmall.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 2,
                      color: AppTheme.accentColor,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                children: [
                  Text('2025_powered_by_dokkan_agency'.tr(context),
                    style: context.bodySmall.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
               
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}