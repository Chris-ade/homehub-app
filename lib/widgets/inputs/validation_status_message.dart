// lib/widgets/inputs/validation_status_message.dart
// A reusable validation status message and suffix icon builder for input fields
// supporting asynchronous availability checks (e.g. email and phone verification).

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../theme/app_theme.dart';

/// Reusable validation message widget displayed below input fields.
class ValidationStatusMessage extends StatelessWidget {
  const ValidationStatusMessage({
    super.key,
    required this.isChecking,
    required this.isAvailable,
    required this.isDark,
    required this.loadingText,
    required this.availableText,
    required this.unavailableText,
    this.customMessage,
  });

  final bool isChecking;
  final bool? isAvailable;
  final bool isDark;
  final String loadingText;
  final String availableText;
  final String unavailableText;
  final String? customMessage;

  /// Helper to generate the suffix icon for an input field undergoing verification.
  static Widget? buildSuffixIcon({
    required bool isChecking,
    required bool? isAvailable,
    required bool isDark,
  }) {
    if (isChecking) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.terracotta,
          ),
        ),
      );
    } else if (isAvailable == true) {
      return Icon(
        LucideIcons.circle_check,
        color: isDark ? AppColors.creamAlt : AppColors.success,
        size: 20,
      );
    } else if (isAvailable == false) {
      return Icon(
        LucideIcons.circle_alert,
        color: isDark ? AppColors.creamAlt : AppColors.error,
        size: 20,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!isChecking && isAvailable == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          if (isChecking) ...[
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.terracotta,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              loadingText,
              style: TextStyle(
                fontSize: AppFontSizes.bodySmall,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
            ),
          ] else if (isAvailable == true) ...[
            Icon(
              LucideIcons.circle_check,
              color: isDark ? AppColors.creamAlt : AppColors.success,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              customMessage ?? availableText,
              style: TextStyle(
                fontSize: AppFontSizes.bodySmall,
                color: isDark ? AppColors.creamAlt : AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else if (isAvailable == false) ...[
            Icon(
              LucideIcons.circle_alert,
              color: isDark ? AppColors.creamAlt : AppColors.error,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                customMessage ?? unavailableText,
                style: TextStyle(
                  fontSize: AppFontSizes.bodySmall,
                  color: isDark ? AppColors.creamAlt : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
