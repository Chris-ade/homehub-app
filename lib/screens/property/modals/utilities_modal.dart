import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../theme/app_theme.dart';

void showUtilitiesModal(BuildContext context, bool isDark) {
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
            "Power, water & utilities",
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
            "Key information regarding electricity, water, and building maintenance utilities.",
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Electricity & Power",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildUtilityItem(
            LucideIcons.zap,
            "Dedicated prepaid electricity meter (Pay-as-you-go)",
            isDark,
          ),
          _buildUtilityItem(
            LucideIcons.battery_charging,
            "Generator / Inverter backup available (Inquire with agent)",
            isDark,
          ),
          const SizedBox(height: 16),
          Text(
            "Water & Sanitation",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildUtilityItem(
            LucideIcons.droplets,
            "Borehole water supply with overhead storage tanks",
            isDark,
          ),
          _buildUtilityItem(
            LucideIcons.shield_check,
            "Water filtration / treatment system",
            isDark,
          ),
          const SizedBox(height: 16),
          Text(
            "Security & Service Charge",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildUtilityItem(
            LucideIcons.cctv,
            "Perimeter CCTV cameras & gated compound",
            isDark,
          ),
          _buildUtilityItem(
            LucideIcons.receipt,
            "Service charge covers waste management, water pumping & security",
            isDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
}

Widget _buildUtilityItem(IconData icon, String label, bool isDark) {
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
