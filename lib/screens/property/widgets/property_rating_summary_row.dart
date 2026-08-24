import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';
import 'laurel_branch_painter.dart';

class PropertyRatingSummaryRow extends StatelessWidget {
  final Property property;
  final bool isDark;
  final VoidCallback onShowAllReviews;

  const PropertyRatingSummaryRow({
    super.key,
    required this.property,
    required this.isDark,
    required this.onShowAllReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Rating & Stars
        Expanded(
          child: Column(
            children: [
              Text(
                property.rating.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 1,
          height: 36,
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),

        // 2. Listing Status Badge with Laurel Wreath
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                size: const Size(14, 28),
                painter: LaurelBranchPainter(isLeft: true, isDark: isDark),
              ),
              const SizedBox(width: 6),
              Column(
                children: [
                  Text(
                    property.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    "listing",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              CustomPaint(
                size: const Size(14, 28),
                painter: LaurelBranchPainter(isLeft: false, isDark: isDark),
              ),
            ],
          ),
        ),

        Container(
          width: 1,
          height: 36,
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),

        // 3. Reviews count
        Expanded(
          child: InkWell(
            onTap: onShowAllReviews,
            child: Column(
              children: [
                Text(
                  "${property.reviewCount}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Reviews",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
