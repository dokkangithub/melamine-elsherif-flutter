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

class TopHomeWidget extends StatefulWidget {
  final VoidCallback? onShopNowTapped;
  const TopHomeWidget({super.key, this.onShopNowTapped});

  @override
  State<TopHomeWidget> createState() => _TopHomeWidgetState();
}

class _TopHomeWidgetState extends State<TopHomeWidget> {
  TextEditingController searchController = TextEditingController();
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
      final businessSettingsService = sl<BusinessSettingsService>();
      
      // The business settings should already be initialized in SplashScreen
      final homeSliderImages = businessSettingsService.getHomeBannerImages();
      debugPrint('Retrieved banner images: $homeSliderImages');
      
      if (homeSliderImages.isNotEmpty) {
        setState(() {
          bannerImages = homeSliderImages;
          isLoading = false;
        });
        debugPrint('Successfully set banner images: ${bannerImages.length} images');
      } else {
        // Fallback to default image if no images are available
        debugPrint('No banner images found, using default image');
        setState(() {
          bannerImages = [AppImages.home_banner];
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle error and use default image
      debugPrint('Error loading banner images: $e');
      setState(() {
        bannerImages = [AppImages.home_banner];
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
                height: 300,
                width: double.infinity,
                color: Colors.grey[100],
                child: const CustomImage(
                  assetPath: AppImages.home_banner,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : CarouselSlider.builder(
                itemCount: bannerImages.length,
                itemBuilder: (context, index, realIndex) {
                  return _buildBannerItem(bannerImages[index]);
                },
                options: CarouselOptions(
                  height: 300,
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
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    onPressed: widget.onShopNowTapped,
                    backgroundColor: AppTheme.accentColor,
                    splashColor: AppTheme.accentColor,
                    child: Text(
                      'shop_now'.tr(context),
                      style: context.titleSmall!.copyWith(
                          color: AppTheme.white
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBannerItem(String imageUrl) {
    return Stack(
      children: [
        // Image with full width and height
        SizedBox(
          width: double.infinity,
          height: 300,
          child: CustomImage(
            imageUrl: imageUrl.startsWith('http') ? imageUrl : null,
            assetPath: imageUrl.startsWith('http') ? null : imageUrl,
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
        ),

      ],
    );
  }
}
