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
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Multiple animation controllers for different effects
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _dividerController;
  
  // Logo animations
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoPulseAnimation;
  
  // Text animations
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  
  // Divider animations
  late Animation<double> _dividerScaleAnimation;
  late Animation<Color?> _dividerColorAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkNavigationPath();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    // Text animation controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Divider animation controller
    _dividerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Logo spinning and scaling animation
    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 1.5),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.5, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );
    
    // Pulse animation that repeats
    _logoPulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Text slide in animation
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.elasticOut,
      ),
    );
    
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    
    // Divider animations
    _dividerScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _dividerController,
        curve: Curves.elasticOut,
      ),
    );
    
    _dividerColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: AppTheme.accentColor,
    ).animate(
      CurvedAnimation(
        parent: _dividerController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    // Start animations in sequence
    _logoController.forward().then((_) {
      _textController.forward().then((_) {
        _dividerController.forward();
        
        // Set up a repeating pulse animation for logo after initial animations
        _logoController.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            // Only repeat the pulse part of the animation
            _logoController.repeat(min: 0.7, max: 1.0, period: const Duration(seconds: 1));
          }
        });
      });
    });
  }

  Future<void> _checkNavigationPath() async {
    // Increased delay to allow animations to complete
    await Future.delayed(const Duration(seconds: 4));
    
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
    _logoController.dispose();
    _textController.dispose();
    _dividerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Complex Logo Animation
                    AnimatedBuilder(
                      animation: Listenable.merge([_logoController, _textController, _dividerController]),
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _logoRotationAnimation.value,
                          child: Transform.scale(
                            scale: _logoScaleAnimation.value * _logoPulseAnimation.value,
                            child: Image.asset(
                              'assets/images/melamine_elsherif_logo.png',
                              width: 180,
                              height: 180,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Sliding Text Animation
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _textOpacityAnimation,
                          child: SlideTransition(
                            position: _textSlideAnimation,
                            child: Text(
                              'your_ultimate_shopping_destination'.tr(context),
                              style: context.titleSmall.copyWith(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Expanding and Color-changing Divider
                    AnimatedBuilder(
                      animation: _dividerController,
                      builder: (context, child) {
                        return Container(
                          width: 100 * _dividerScaleAnimation.value,
                          height: 3,
                          decoration: BoxDecoration(
                            color: _dividerColorAnimation.value,
                            borderRadius: BorderRadius.circular(1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentColor.withOpacity(0.3 * _dividerScaleAnimation.value),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer with delayed opacity animation
            AnimatedBuilder(
              animation: _dividerController,
              builder: (context, child) {
                return Opacity(
                  opacity: _dividerController.value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Text(
                      '2025_powered_by_dokkan_agency'.tr(context),
                      style: context.bodySmall.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}