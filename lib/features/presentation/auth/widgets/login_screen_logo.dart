import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import '../../../../core/utils/constants/app_assets.dart';

class LoginScreenLogo extends StatelessWidget {
  const LoginScreenLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Hero(
      tag: 'logo',
      child: CustomImage(
        assetPath: AppImages.linearAppLogo,
        fit: BoxFit.contain,
        height: 140,
        width: 200,
      ),
    );
  }
}
