import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/local_storage/local_storage_keys.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/di/injection_container.dart';
import 'package:melamine_elsherif/core/utils/local_storage/secure_storage.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import '../widgets/onboarding_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      'title': 'Shop Smarter, Live Better',
      'description': 'Discover millions of products from trusted sellers worldwide',
      'image': AppImages.onboarding1,
      'type': ContentType.image,
    },
    {
      'type': ContentType.features,
      'features': [
        FeatureItem(
          icon: AppSvgs.on2_1,
          title: 'Fast Delivery',
          description: 'Get your orders delivered within 24 hours',
        ),
        FeatureItem(
          icon: AppSvgs.on2_2,
          title: 'Secure Payments',
          description: 'Shop safely with multiple payment options',
        ),
        FeatureItem(
          icon: AppSvgs.on2_3,
          title: '24/7 Support',
          description: 'Our team is here to help you anytime',
        ),
      ],
    },
    {
      'title': 'Ready to Start Shopping?',
      'description': 'Join millions of happy shoppers today',
      'image': AppImages.onboarding3,
      'type': ContentType.final_page,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNextPressed() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSkipPressed() {
    _completeOnboarding();
    AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.login);
  }

  void _onSignUpPressed() {
    _completeOnboarding();
    AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.signUp);
  }

  void _onLoginPressed() {
    _completeOnboarding();
    AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.login);
  }

  Future<void> _completeOnboarding() async {
    // Mark onboarding as completed in secure storage
    await sl<SecureStorage>().save(LocalStorageKey.hasCompletedOnboarding, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppTheme.white,
          statusBarIconBrightness: Brightness.dark
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [

            Column(
              children: [
                // Add space for the skip button
                const SizedBox(height: 60),
                
                // PageView for content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: onboardingData.length,
                    itemBuilder: (context, index) {
                      final item = onboardingData[index];
                      final ContentType type = item['type'] as ContentType;
                      
                      return OnboardingContent(
                        title: item['title'] ?? '',
                        description: item['description'] ?? '',
                        image: item['image'] ?? '',
                        contentType: type,
                        features: type == ContentType.features 
                            ? (item['features'] as List<FeatureItem>) 
                            : null,
                        onSignUp: type == ContentType.final_page ? _onSignUpPressed : null,
                        onLogin: type == ContentType.final_page ? _onLoginPressed : null,
                      );
                    },
                  ),
                ),
                
                // Bottom navigation with dots and next button in column
                if (_currentPage < 2) 
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Dots in a row but centered
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            onboardingData.length,
                            (index) => _buildDot(index),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Next button with full width
                        CustomButton(
                          text: 'Next',
                          onPressed: _onNextPressed,
                          isGradient: true,
                          backgroundColor: AppTheme.primaryColor,
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? AppTheme.primaryColor 
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}