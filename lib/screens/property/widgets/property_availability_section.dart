import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../theme/app_theme.dart';

class PropertyAvailabilitySection extends StatelessWidget {
  final String availableStr;
  final bool isDark;

  const PropertyAvailabilitySection({
    super.key,
    required this.availableStr,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          LucideIcons.calendar_check,
          size: 22,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Available from",
              style: TextStyle(
                fontFamily: 'Cabinet Grotesk',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              availableStr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
