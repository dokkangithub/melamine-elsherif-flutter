import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/extension/translate_extension.dart';
import '../../main layout/controller/layout_provider.dart';

class EmptyWishlistWidget extends StatelessWidget {
  const EmptyWishlistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Background image with blend mode overlay
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: 0.65),
            BlendMode.lighten,
          ),
          child: const CustomImage(
            assetPath: AppSvgs.empty_wishlist,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        
        // Content overlay
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: Column(
            children: [
              // Top space - approximately 40% of screen height
              SizedBox(height: screenHeight * 0.35),
              
              // Text content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    FadeIn(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        'wishlist_empty_message'.tr(context),
                        style: context.displaySmall?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 24,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        'wishlist_empty_subtitle'.tr(context),
                        style: context.titleMedium?.copyWith(
                          color: Colors.black45,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Expandable space before button
              const SizedBox(height: 50),
              
              // Button at bottom
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: CustomButton(
                      onPressed: () {
                        Provider.of<LayoutProvider>(context, listen: false).currentIndex = 0;
                      },
                      child: Text(
                        'browse_products'.tr(context),
                        style: context.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
