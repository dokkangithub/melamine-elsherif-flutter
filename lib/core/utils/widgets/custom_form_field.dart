import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melamine_elsherif/core/config/themes.dart/theme.dart';
import 'package:melamine_elsherif/core/utils/extension/text_theme_extension.dart';

import '../vaidation/phone_validator.dart';


class CustomTextFormField extends StatefulWidget {

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool isPassword;
  final bool isMobileNumber;
  final bool isReadOnly;
  final bool autoFocus;
  final bool isBorderAvailable;  // New parameter to control border visibility
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Function(String)? onChanged;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextStyle? textStyle;
  final double borderRadius;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.isPassword = false,
    this.isMobileNumber = false,
    this.isReadOnly = false,
    this.autoFocus = false,
    this.isBorderAvailable = true,  // Default to having borders
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textStyle,
    this.borderRadius = 10.0,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  String? _errorText;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _errorText = widget.errorText;
    _obscureText = widget.isPassword;
  }

  String? _validateInput(String? value) {
    String? mobileError;
    if (widget.isMobileNumber) {
      mobileError = PhoneValidation.validateMobileNumber(value);
    }

    String? customError;
    if (widget.validator != null) {
      customError = widget.validator!(value);
    }

    final error = mobileError ?? customError;
    setState(() {
      _errorText = error ?? widget.errorText;
    });
    return error;
  }

  // Toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create password visibility toggle icon if it's a password field
    Widget? passwordSuffixIcon = widget.isPassword
        ? IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,
        color: AppTheme.darkDividerColor,
      ),
      onPressed: _togglePasswordVisibility,
    )
        : widget.suffixIcon;

    // Determine fill color based on isBorderAvailable
    Color fillColor = widget.isBorderAvailable
        ? Colors.white
        : AppTheme.darkTextColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword && _obscureText,  // Use the _obscureText state
        readOnly: widget.isReadOnly,
        autofocus: widget.autoFocus,
        keyboardType: widget.isMobileNumber ? TextInputType.phone : widget.keyboardType,
        textInputAction: widget.textInputAction,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        style: widget.textStyle ?? context.bodyMedium,
        inputFormatters: widget.isMobileNumber
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          errorText: _errorText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: passwordSuffixIcon,  // Use our custom suffix icon for password fields
          labelStyle: context.bodyMedium?.copyWith(color: AppTheme.lightSecondaryTextColor),
          hintStyle: context.titleMedium?.copyWith(color: AppTheme.lightSecondaryTextColor),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          enabledBorder: widget.isBorderAvailable
              ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(
              color: AppTheme.darkDividerColor.withValues(alpha: 0.3),
              width: 1,
            ),
          )
              : OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide.none,  // No border
          ),
          focusedBorder: widget.isBorderAvailable
              ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 1.5,
            ),
          )
              : OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide.none,  // No border
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          _validateInput(value); // Validate on change
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        onFieldSubmitted: widget.onFieldSubmitted,
        validator: _validateInput,
      ),
    );
  }
}