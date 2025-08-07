import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart'; // 🔄
import 'package:melamine_elsherif/core/utils/helpers/ui_helper.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';

class TopHomeWidget extends StatelessWidget {
  const TopHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientShader = UIHelper.linearGradient;
    final messages = [
      'brand_message_1'.tr(context),
      'brand_message_2'.tr(context),
      'brand_message_3'.tr(context),
      'brand_message_4'.tr(context),
      'brand_message_5'.tr(context),
    ];
    final marqueeText = messages.join('    ✦    ');
    return Container(
      padding: const EdgeInsets.only(left: 16.0, top: 15.0, right: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'welcome'.tr(context),
            style: context.displayLarge!.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.normal,
              foreground: Paint()..shader = gradientShader,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 30,
            child: ShaderMask(
              shaderCallback: (bounds) => UIHelper.linearGradient,
              blendMode: BlendMode.srcIn,
              child: Marquee(
                text: marqueeText,
                style: context.displayLarge!.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w200,
                  color: Colors.white, // ← سيُستبدل بالـ gradient عبر ShaderMask
                ),
                textDirection: TextDirection.rtl,
                velocity: 30.0,
                blankSpace: 60,
                pauseAfterRound: const Duration(seconds: 1),
              ),
            ),

          ),
        ],
      ),
    );
  }
}
