import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';

class CustomEmptyWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomEmptyWidget({
    super.key,
    this.title = "we_could't_find_anything_for_that",
    this.subtitle = "bring_your_vision to_life_with_melamine_elsherif",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(60),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightBackgroundColor,
            ),
            child: const CustomImage(
              assetPath: AppSvgs.no_data,

              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title.tr(context),
            style: context.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle.tr(context),
            style: context.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}