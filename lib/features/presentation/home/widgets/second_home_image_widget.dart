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

class SecondHomeImageWidget extends StatefulWidget {
  const SecondHomeImageWidget({super.key});

  @override
  State<SecondHomeImageWidget> createState() => _SecondHomeImageWidgetState();
}

class _SecondHomeImageWidgetState extends State<SecondHomeImageWidget> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CustomImage(
                    assetPath: AppImages.second_home_image,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: 0.4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Transform Your Home With Smart Appliances'.tr(context),
                          style: context.titleLarge?.copyWith(color: AppTheme.white),
                        ),
                        SizedBox(height: 20),
                        CustomButton(
                          text: 'Learn more'.tr(context),
                        )
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }
}
