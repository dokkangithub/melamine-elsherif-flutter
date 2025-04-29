import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import '../../../../core/utils/constants/app_assets.dart';

class PlatesWidgets extends StatelessWidget {
  const PlatesWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.5),
                AppTheme.primaryColor.withValues(alpha: 0.2),
              ],
              stops: [0.4, 0.8, 0.99],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'PLATES',
                    style: context.headlineMedium!.copyWith(
                      color: AppTheme.white,
                    ),
                  ),
                  Text(
                    '50% OFF',
                    style: context.titleMedium!.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
              CustomImage(assetPath: AppImages.plates_image),
            ],
          ),
        ),
      ],
    );
  }
}
