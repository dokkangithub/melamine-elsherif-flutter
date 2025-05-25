import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/extension/translate_extension.dart';

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
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w700),
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            'see_all'.tr(context),
            style: context.titleSmall.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}