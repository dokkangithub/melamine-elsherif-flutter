import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melamine_elsherif/core/services/business_settings_service.dart';
import '../../../core/config/routes.dart/routes.dart';
import '../../../core/config/themes.dart/theme.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/local_storage/local_storage_keys.dart';
import '../../../core/utils/local_storage/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isBusinessSettingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _preloadData();
  }

  Future<void> _preloadData() async {
    try {
      final businessSettingsService = sl<BusinessSettingsService>();
      debugPrint('Splash screen: Loading business settings...');
      await businessSettingsService.init();

      final bannerImages = businessSettingsService.getHomeBannerImages();
      debugPrint(
        'Splash screen: Loaded business settings. Banner images: ${bannerImages.length}',
      );

      setState(() {
        _isBusinessSettingsLoaded = true;
      });
    } catch (e) {
      debugPrint('Splash screen: Error loading business settings: $e');
      setState(() {
        _isBusinessSettingsLoaded = true;
      });
    }

    _checkNavigationPath();
  }

  Future<void> _checkNavigationPath() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final secureStorage = sl<SecureStorage>();
    final hasCompletedOnboarding =
        await secureStorage.get<bool>(LocalStorageKey.hasCompletedOnboarding) ??
            false;

    // Stop the looping animation before navigating away
    if (mounted) {
      _controller.stop();
    }

    if (!hasCompletedOnboarding) {
      AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.onboarding);
    } else {
      AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.mainLayoutScreen);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final double progress = _controller.value.clamp(0.0, 1.0);

          double logoOpacity;
          if (progress < 0.5) {
            final double t = (progress / 0.5).clamp(0.0, 1.0);
            logoOpacity = Curves.easeIn.transform(t);
          } else if (progress < 0.7) {
            logoOpacity = 1.0;
          } else {
            final double t = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
            logoOpacity = 1.0 - Curves.easeOut.transform(t);
          }

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withOpacity(0.95),
                      primary.withOpacity(0.85),
                      Colors.white.withOpacity(0.95),
                    ],
                  ),
                ),
              ),

              Center(
                child: Opacity(
                  opacity: logoOpacity,
                  child: Image.asset(
                    'assets/cups/splash_alsherif_logo.png',
                    height: 150,
                  ),
                ),
              ),

              // Dokkan logo at the bottom
              Positioned(
                bottom: 35,
                left: 0,
                right: 0,
                child: Center(
                    child: Image.asset(
                      'assets/images/dokkan.png',
                      height: 25,
                      color: AppTheme.accentColor,
                      fit: BoxFit.contain,
                    ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}