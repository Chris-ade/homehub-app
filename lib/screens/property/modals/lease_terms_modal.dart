import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../theme/app_theme.dart';

void showLeaseTermsModal(BuildContext context, bool isDark) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            "Lease & Payment terms",
            style: TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          _buildPolicyRow(
            "Lease duration",
            "Minimum 1 year",
            "Tenancy begins on the agreed move-in date and runs for at least 12 months.",
            isDark,
          ),
          const SizedBox(height: 14),
          _buildPolicyRow(
            "Notice period",
            "30 days to vacate",
            "Tenant must give 30 days written notice before the end of tenancy.",
            isDark,
          ),
          const SizedBox(height: 14),
          _buildPolicyRow(
            "Security deposit",
            "Refund within 14 days",
            "Caution fee is refunded within 14 days of a satisfactory move-out inspection, minus any deductions.",
            isDark,
          ),
          const SizedBox(height: 20),
          Text(
            "Early termination",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Early termination before the end of the agreed lease period may result in forfeiture of the security deposit. Please review the full tenancy agreement for specific conditions.",
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

Widget _buildPolicyRow(String date, String title, String sub, bool isDark) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 120,
        child: Text(
          date,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 12,
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
