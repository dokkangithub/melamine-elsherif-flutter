import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/di/injection_container.dart';
import 'package:melamine_elsherif/core/services/business_settings_service.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/utils/widgets/custom_cached_image.dart';

class SecondHomeImageWidget extends StatefulWidget {
  const SecondHomeImageWidget({super.key});

  @override
  State<SecondHomeImageWidget> createState() => _SecondHomeImageWidgetState();
}

class _SecondHomeImageWidgetState extends State<SecondHomeImageWidget> {
  List<String> bannerImages = [];
  bool isLoading = true;
  int activeIndex = 0;
  final carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    _loadBannerImages();
  }

  Future<void> _loadBannerImages() async {
    try {
      // Since BusinessSettingsService doesn't have a specific method for second banner,
      // we'll use a default image for now. In a real implementation, you would add
      // a method to BusinessSettingsService or use an existing one.
      setState(() {
        bannerImages = [AppImages.second_home_image];
        isLoading = false;
      });
    } catch (e) {
      // Handle error and use default image
      debugPrint('Error loading second banner images: $e');
      setState(() {
        bannerImages = [AppImages.second_home_image];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        isLoading
            ? Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: const CustomImage(
                    assetPath: AppImages.second_home_image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              )
            : CarouselSlider.builder(
                itemCount: bannerImages.length,
                itemBuilder: (context, index, realIndex) {
                  return _buildBannerItem(bannerImages[index]);
                },
                options: CarouselOptions(
                  height: 180,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (index, reason) {
                    setState(() {
                      activeIndex = index;
                    });
                  },
                ),
              ),
        if (bannerImages.length > 1)
          Positioned(
            bottom: 15,
            child: AnimatedSmoothIndicator(
              activeIndex: activeIndex,
              count: bannerImages.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppTheme.primaryColor,
                dotColor: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          left: 20,
          child: CustomButton(
            text: 'learn_more'.tr(context),
            backgroundColor: AppTheme.accentColor,
            splashColor: AppTheme.accentColor,
            onPressed: () {
              // Navigate to learn more page or open a modal
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(String imageUrl) {
    return Stack(
      children: [
        // Image with full width and height
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: double.infinity,
            height: 180,
            child: CustomImage(
              imageUrl: imageUrl.startsWith('http') ? imageUrl : null,
              assetPath: imageUrl.startsWith('http') ? null : imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        // Overlay with gradient
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(12),
            height: double.infinity,
            width: double.infinity,
            color: Colors.black.withValues(alpha: 0.4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'transform_your_home_with'.tr(context),
                  style: context.titleLarge?.copyWith(color: AppTheme.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
