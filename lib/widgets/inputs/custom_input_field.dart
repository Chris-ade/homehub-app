// lib/widgets/inputs/custom_input_field.dart
// A reusable, styled input field matching the app's design language.
// It incorporates all form decoration styles (filled background, rounded corners,
// line borders, focus glow, error state highlights, prefix icon, optional clear suffix)
// for complete visual consistency across all forms and screens.

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../theme/app_theme.dart';

/// A reusable input widget that follows the app's design system.
class CustomInputField extends StatelessWidget {
  const CustomInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.minLines,
    this.maxLines,
    this.textInputAction,
    required this.isDark,
    this.onClear,
    this.obscureText = false,
    this.customSuffixIcon,
    this.validator,
    this.prefixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.hideBorder = false,
  });

  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final bool isDark;
  final VoidCallback? onClear;
  final bool obscureText;
  final Widget? customSuffixIcon;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool hideBorder;

  @override
  Widget build(BuildContext context) {
    final suffix = customSuffixIcon ??
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(LucideIcons.x, size: 16),
              onPressed: () {
                controller.clear();
                if (onClear != null) onClear!();
                if (onChanged != null) onChanged!("");
              },
            );
          },
        );

    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: hideBorder
          ? BorderSide.none
          : BorderSide(
              color: isDark ? AppColors.darkLine : AppColors.line,
            ),
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      minLines: obscureText ? 1 : minLines,
      maxLines: obscureText ? 1 : maxLines,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      style: TextStyle(
        fontFamily: 'Satoshi',
        color: isDark ? AppColors.darkInk : AppColors.ink,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Satoshi',
          color: isDark ? AppColors.darkMuted : AppColors.muted,
          fontSize: 15,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 20,
                color: isDark ? AppColors.mist : AppColors.teal,
              )
            : const Icon(
                LucideIcons.search,
                size: 20,
                color: AppColors.teal,
              ),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.mist,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: defaultBorder,
        enabledBorder: defaultBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: hideBorder
              ? BorderSide.none
              : BorderSide(
                  color: isDark ? AppColors.amber : AppColors.teal,
                  width: 1.5,
                ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: hideBorder
              ? BorderSide.none
              : const BorderSide(
                  color: Colors.red,
                  width: 1.0,
                ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: hideBorder
              ? BorderSide.none
              : const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
        ),
      ),
    );
  }
}
