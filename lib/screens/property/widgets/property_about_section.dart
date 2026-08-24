import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';

class PropertyAboutSection extends StatelessWidget {
  final Property property;
  final bool isDark;
  final VoidCallback onShowMore;

  const PropertyAboutSection({
    super.key,
    required this.property,
    required this.isDark,
    required this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.description,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onShowMore,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Show more",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                LucideIcons.chevron_right,
                size: 16,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
