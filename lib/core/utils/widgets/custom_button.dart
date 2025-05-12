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
  final bool isGradient; // New parameter for gradient style
  final List<Color>? gradientColors; // Allow custom gradient colors

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
    this.isGradient = false,
    this.gradientColors,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
    final buttonColor = backgroundColor ?? AppTheme.primaryColor;
    final effectiveTextColor = isOutlined
        ? textColor ?? buttonColor
        : textColor ?? AppTheme.white;
    final borderColor = isOutlined ? AppTheme.accentColor : buttonColor;

    // Default gradient colors if not provided
    final colors = gradientColors ?? [
       AppTheme.primaryColor, // Darker reddish color
      AppTheme.secondaryColor, // Lighter pinkish color
    ];

    if (isGradient) {
      // Return gradient style button
      return Container(
        width: fullWidth ? double.infinity : null,
        height: 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: MaterialButton(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
          ),
          onPressed: isLoading ? null : onPressed,
          splashColor: splashColor ?? colors[0].withValues(alpha: 0.3),
          child: isLoading
              ? SizedBox(
                  width: loadingIndicatorSize,
                  height: loadingIndicatorSize,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : _buildContent(context, effectiveTextColor),
        ),
      );
    }

    // Return original button style if not gradient
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
          padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
              ? const Center(
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