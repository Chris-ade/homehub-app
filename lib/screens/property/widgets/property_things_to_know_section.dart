import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../theme/app_theme.dart';

class PropertyThingsToKnowSection extends StatelessWidget {
  final VoidCallback onLeaseTerms;
  final VoidCallback onTenancyRules;
  final VoidCallback onUtilities;
  final VoidCallback onReportListing;
  final bool isDark;

  const PropertyThingsToKnowSection({
    super.key,
    required this.onLeaseTerms,
    required this.onTenancyRules,
    required this.onUtilities,
    required this.onReportListing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Things to know",
          style: TextStyle(
            fontFamily: 'Cabinet Grotesk',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        _buildItem(
          icon: LucideIcons.calendar_clock,
          title: "Lease & Payment terms",
          description:
              "Min. 1-year lease · 30-day notice to vacate · Security deposit refunded within 14 days of move-out",
          onTap: onLeaseTerms,
        ),
        const SizedBox(height: 18),
        _buildItem(
          icon: LucideIcons.key_round,
          title: "Tenancy rules",
          description:
              "No sublet without consent · No illegal activities · Keep common areas clean",
          onTap: onTenancyRules,
        ),
        const SizedBox(height: 18),
        _buildItem(
          icon: LucideIcons.zap,
          title: "Power, water & utilities",
          description:
              "Prepaid electricity meter · Borehole water supply · Service charge applies",
          onTap: onUtilities,
        ),

        const SizedBox(height: 24),

        // Report listing link
        InkWell(
          onTap: onReportListing,
          child: Row(
            children: [
              Icon(
                LucideIcons.flag,
                size: 15,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                "Report this listing",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevron_right,
            size: 18,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
