import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/providers/localization/language_provider.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';
import 'package:provider/provider.dart';

import '../helpers/ui_helper.dart';

class SeeAllWidget extends StatelessWidget {
  const SeeAllWidget({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,

          style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w700,foreground: Paint()..shader = UIHelper.linearGradient,letterSpacing:
          Provider.of<LanguageProvider>(context, listen: false).locale.languageCode == 'en' ? 1.2 : 1)
          ),
        InkWell(
          onTap: onTap,
          child: Text(
            'see_all'.tr(context).toUpperCase(),
            style: context.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              foreground: Paint()..shader = UIHelper.linearGradient,
            ),
          ),
        ),
      ],
    );
  }
}