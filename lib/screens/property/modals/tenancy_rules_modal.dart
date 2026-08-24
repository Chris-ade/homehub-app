import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../theme/app_theme.dart';

void showTenancyRulesModal(BuildContext context, bool isDark) {
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
            "Tenancy rules",
            style: TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Please review these tenancy conditions before booking an inspection.",
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Occupancy",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildRuleItem(
            LucideIcons.users,
            "Tenant and immediate family only",
            isDark,
          ),
          _buildRuleItem(
            LucideIcons.user_x,
            "No subletting without written consent",
            isDark,
          ),
          _buildRuleItem(
            LucideIcons.door_open,
            "Agent or landlord access for inspections",
            isDark,
          ),
          const SizedBox(height: 16),
          Text(
            "Property use",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildRuleItem(
            LucideIcons.shield_off,
            "No illegal activities on the premises",
            isDark,
          ),
          _buildRuleItem(
            LucideIcons.wrench,
            "No structural alterations without approval",
            isDark,
          ),
          _buildRuleItem(
            LucideIcons.trash_2,
            "Keep common areas and bins clean",
            isDark,
          ),
          _buildRuleItem(
            LucideIcons.music,
            "No excessive noise after 10:00 PM",
            isDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

Widget _buildRuleItem(IconData icon, String label, bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}
