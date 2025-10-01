import 'package:flutter/material.dart';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:melamine_elsherif/core/utils/helpers/ui_helper.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';

import '../../../../core/config/themes.dart/theme.dart';

class TopHomeWidget extends StatefulWidget {
  const TopHomeWidget({super.key});

  @override
  State<TopHomeWidget> createState() => _TopHomeWidgetState();
}

class _TopHomeWidgetState extends State<TopHomeWidget> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _borderController;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('ar');

    final List<Color> borderColors = [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      AppTheme.secondaryColor,
      AppTheme.primaryColor.withOpacity(0.8),
      AppTheme.accentColor.withOpacity(0.9),
    ];

    final messages = [
      'brand_message_1'.tr(context),
      'brand_message_2'.tr(context),
      'brand_message_3'.tr(context),
      'brand_message_4'.tr(context),
      'brand_message_5'.tr(context),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0,top: 10),
          child: Image.asset(
            isArabic ? 'assets/images/7.png' : 'assets/images/8.png',
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
        AnimatedBuilder(
          animation: _borderController,
          builder: (context, child) {
            return Transform.translate(
              offset: const Offset(0, -20),
              child: CarouselSlider(
              options: CarouselOptions(

                height: 40,
                autoPlay: true,

                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.easeInOutCubic,
                pauseAutoPlayOnTouch: true,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: messages.asMap().entries.map((entry) {
                final int idx = entry.key;
                final String message = entry.value;
                final Color currentBorderColor = borderColors[idx % borderColors.length];

                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: currentBorderColor.withOpacity(0.6 + (_borderController.value * 0.4)),
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          message,
                          style: context.displayLarge!.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [
                                  currentBorderColor,
                                  currentBorderColor.withOpacity(0.7),
                                ],
                              ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}