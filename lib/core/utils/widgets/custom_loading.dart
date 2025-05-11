import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_assets.dart';

class CustomLoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const CustomLoadingWidget({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      AppAnimations.loading,
      width: width ?? 80,
      height: height ?? 80,
      fit: BoxFit.contain,
    );
  }
}
