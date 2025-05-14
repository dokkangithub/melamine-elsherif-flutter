import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:melamine_elsherif/core/config/routes.dart/routes.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/constants/app_assets.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_button.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_form_field.dart';

import '../../../../core/utils/widgets/custom_cached_image.dart';

class TopHomeWidget extends StatefulWidget {
  final VoidCallback? onShopNowTapped;
  const TopHomeWidget({super.key, this.onShopNowTapped});

  @override
  State<TopHomeWidget> createState() => _TopHomeWidgetState();
}

class _TopHomeWidgetState extends State<TopHomeWidget> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: Stack(
            children: [
              // Image with color filter
              const CustomImage(
                assetPath: AppImages.home_banner,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

              // Bottom gradient overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 220,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3)
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'transform_your_home'.tr(context),
                style: context.displaySmall!.copyWith(
                  color: AppTheme.white
                ),
              ),
              Text(
                'up_to_30%_off_on_selected_premium_appliances'.tr(context),
                style: context.titleLarge!.copyWith(
                    color: AppTheme.white
                ),
              ),
              const SizedBox(height: 15),
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
              )
            ],
          ),
        )
      ],
    );
  }
}
