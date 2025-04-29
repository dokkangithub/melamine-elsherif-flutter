import 'package:flutter/material.dart';
import '../../../../core/utils/constants/app_assets.dart';

class LoginScreenLogo extends StatelessWidget {
  const LoginScreenLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo',
      child: CircleAvatar(
        radius: 60,
        backgroundImage: AssetImage(AppImages.appLogo),
      ),
    );
  }
}
