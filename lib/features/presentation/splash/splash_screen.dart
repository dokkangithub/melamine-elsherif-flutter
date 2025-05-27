import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melamine_elsherif/core/config/app_config.dart/app_config.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/services/business_settings_service.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import '../../../core/config/routes.dart/routes.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/local_storage/local_storage_keys.dart';
import '../../../core/utils/local_storage/secure_storage.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;
  
  // Loading flags
  bool _isBusinessSettingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _preloadData();
  }

  void _setupAnimations() {
    // Fade in animation controller
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeInAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeIn,
    );

    // Start animations
    _fadeInController.forward();
  }

  // Preload all necessary data
  Future<void> _preloadData() async {
    // Load business settings
    try {
      final businessSettingsService = sl<BusinessSettingsService>();
      debugPrint('Splash screen: Loading business settings...');
      await businessSettingsService.init();
      
      // Verify we got the banner images
      final bannerImages = businessSettingsService.getHomeBannerImages();
      debugPrint('Splash screen: Loaded business settings. Banner images: ${bannerImages.length}');
      
      setState(() {
        _isBusinessSettingsLoaded = true;
      });
    } catch (e) {
      debugPrint('Splash screen: Error loading business settings: $e');
      setState(() {
        _isBusinessSettingsLoaded = true; // Still mark as loaded to avoid blocking the app
      });
    }
    
    // Check navigation after preloading and animations
    _checkNavigationPath();
  }

  Future<void> _checkNavigationPath() async {
    // Delay to allow animations to complete
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final secureStorage = sl<SecureStorage>();
    final hasCompletedOnboarding = await secureStorage.get<bool>(LocalStorageKey.hasCompletedOnboarding) ?? false;

    if (!hasCompletedOnboarding) {
      // First time: Navigate to onboarding
      AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.onboarding);
    } else {
      // Already logged in: Navigate to home
      AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.mainLayoutScreen);
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.splashBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // Main content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ALSHERIF text
                      Text(
                        'splash_alsherif'.tr(context),
                        style: context.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontFamily: GoogleFonts.tajawal().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // MELAMINE text
                      Text(
                        'splash_melamine'.tr(context),
                        style: context.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          fontFamily: GoogleFonts.tajawal().fontFamily,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Tagline
                      Text(
                        'splash_tagline'.tr(context),
                        style: context.titleSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontFamily: GoogleFonts.tajawal().fontFamily,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}