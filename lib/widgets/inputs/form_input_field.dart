// lib/widgets/inputs/form_input_field.dart
// A reusable form input field with a label that wraps CustomInputField.

import 'package:flutter/material.dart';
import './custom_input_field.dart';
import '../../theme/app_theme.dart';

/// FormInputField provides a labeled input suitable for use inside a
/// [Form]. It forwards all styling to [CustomInputField] ensuring visual
/// consistency across the app.
class FormInputField extends StatelessWidget {
  const FormInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.label,
    required this.isDark,
    this.validator,
    this.prefixIcon,
    this.obscureText = false,
    this.customSuffixIcon,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.minLines,
    this.maxLines,
    this.textInputAction,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hintText;
  final String label;
  final bool isDark;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? customSuffixIcon;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.labelLarge,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        CustomInputField(
          controller: controller,
          hintText: hintText,
          focusNode: focusNode,
          isDark: isDark,
          obscureText: obscureText,
          customSuffixIcon: customSuffixIcon,
          validator: validator,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          minLines: minLines,
          maxLines: maxLines,
          textInputAction: textInputAction,
          prefixIcon: prefixIcon,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
        ),
      ],
    );
  }
}
