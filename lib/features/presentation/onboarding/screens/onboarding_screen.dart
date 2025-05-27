import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/local_storage/local_storage_keys.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/di/injection_container.dart';
import 'package:melamine_elsherif/core/utils/local_storage/secure_storage.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
      'title': 'onboarding_designed_for_modern_living',
      'description': 'onboarding_elegant_durable',
      'image': AppImages.onboardingBg1,
    },
    {
      'title': 'onboarding_crafted_to_impress',
      'description': 'onboarding_premium_melamine',
      'image': AppImages.onboardingBg2,
    },
    {
      'title': 'onboarding_explore_collection',
      'description': 'onboarding_from_dinnerware',
      'image': AppImages.onboardingBg3,
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
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    // Mark onboarding as completed in secure storage
    await sl<SecureStorage>().save(LocalStorageKey.hasCompletedOnboarding, true);
    if (mounted) {
      AppRoutes.navigateToAndRemoveUntil(context, AppRoutes.mainLayoutScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Stack(
        children: [
          // Page View for full-screen background images
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: onboardingData.length,
            itemBuilder: (context, index) {
              final item = onboardingData[index];
              return _buildOnboardingPage(
                context,
                item['image'],
                item['title'],
                item['description'],
                index == onboardingData.length - 1,
              );
            },
          ),
          
          // Bottom navigation with dots and next/get started button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: onboardingData.length,
                  effect: const WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white54,
                    spacing: 8,
                  ),
                ),
                const SizedBox(height: 60),
                // Next/Get Started button
                Padding(
                  padding: EdgeInsets.only(left: MediaQuery.sizeOf(context).width/2),
                  child: CustomButton(
                    text: _currentPage == onboardingData.length - 1 
                        ? 'onboarding_get_started'.tr(context)
                        : 'onboarding_next'.tr(context),
                    onPressed: _onNextPressed,
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    fullWidth: true,
                    height: 50,
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildOnboardingPage(
    BuildContext context,
    String image,
    String title,
    String description,
    bool isLastPage,
  ) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                Text(
                  title.tr(context),
                  textAlign: TextAlign.center,
                  style: context.displayLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 1.2,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  description.tr(context),
                  textAlign: TextAlign.center,
                  style: context.headlineSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontWeight: FontWeight.normal,
                    fontFamily: GoogleFonts.montserrat().fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}