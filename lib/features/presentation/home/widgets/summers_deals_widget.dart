import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import '../../../../core/config/themes.dart/theme.dart';

class SummerDealsWidgets extends StatelessWidget {
  const SummerDealsWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.7),
                        AppTheme.primaryColor.withValues(alpha: 0.5),
                      ],
                      stops: [0.4, 0.7, 0.99],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Summer Sale',
                        style: context.headlineMedium.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Up to 40% off',
                        style: context.titleSmall.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomImage(
                  assetPath: AppImages.summers_deals_image,
                  fit: BoxFit.cover,
                  height: 140,
                  borderRadius: BorderRadius.circular(15),
                ),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppTheme.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'new_arrival'.tr(context),
                        style: context.headlineMedium.copyWith(
                          color: AppTheme.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'shop_now'.tr(context),
                        style: context.titleMedium.copyWith(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
