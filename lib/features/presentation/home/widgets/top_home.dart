import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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

class TopHomeWidget extends StatelessWidget {
  const TopHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, top: 15.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'welcome'.tr(context),
            style: context.displayLarge!.copyWith(
                fontFamily: GoogleFonts.jost().fontFamily,
              fontSize: 36,
              fontWeight: FontWeight.normal
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'discover_luxury'.tr(context),
            style: context.displayLarge!.copyWith(
                fontFamily: GoogleFonts.jost().fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.normal
            ),
          ),
        ],
      ),
    );
  }
}
