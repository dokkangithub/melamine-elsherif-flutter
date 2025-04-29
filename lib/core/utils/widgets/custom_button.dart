import 'package:flutter/material.dart';
import 'package:melamine_elsherif/core/utils/extension/text_style_extension.dart';
import 'package:melamine_elsherif/core/utils/widgets/custom_cached_image.dart';
import '../../config/themes.dart/theme.dart';
import 'custom_loading.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final Color? backgroundColor;
  final Color? textColor;
  final String? icon;
  final Color? splashColor;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final VoidCallback? onPressed;
  final double? borderRadius;
  final TextStyle? textStyle;
  final bool isLoading;
  final double? loadingIndicatorSize;
  final bool isOutlined;
  final bool fullWidth; // Added parameter for full width

  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.backgroundColor,
    this.textColor,
    this.splashColor,
    this.padding,
    this.elevation,
    this.onPressed,
    this.borderRadius,
    this.textStyle,
    this.isLoading = false,
    this.loadingIndicatorSize = 24.0,
    this.icon,
    this.isOutlined = false,
    this.fullWidth = false,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
    final buttonColor = backgroundColor ?? AppTheme.primaryColor;
    final effectiveTextColor = isOutlined
        ? textColor ?? buttonColor
        : textColor ?? AppTheme.white;
    final borderColor = isOutlined ? AppTheme.accentColor : buttonColor;

    return Material(
      color: isOutlined ? Colors.transparent : buttonColor,
      elevation: isOutlined ? 0 : (elevation ?? 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
        side: BorderSide(color: borderColor, width: isOutlined ? 1.5 : 1.0),
      ),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        splashColor: splashColor ?? AppTheme.primaryColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          decoration: BoxDecoration(
            gradient: isOutlined
                ? null
                : LinearGradient(
              colors: [
                buttonColor,
                buttonColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? 25.0),
          ),
          child: isLoading
              ? Center(
            child: CustomLoadingWidget(),
          )
              : _buildContent(context, effectiveTextColor),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    if (child != null) {
      return child!;
    }

    return Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min, // Adjust mainAxisSize based on fullWidth
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          CustomImage(
            assetPath: icon!,
            width: 28,
            height: 28,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text!,
          style: textStyle ??
              context.titleSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}