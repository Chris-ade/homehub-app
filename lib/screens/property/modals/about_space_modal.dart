import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';

void showAboutSpaceModal(BuildContext context, Property prop, bool isDark) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          controller: scrollController,
          children: [
            const SizedBox(height: 12),
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
              "About this space",
              style: TextStyle(
                fontFamily: 'Cabinet Grotesk',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              prop.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "The space",
              style: TextStyle(
                fontFamily: 'Cabinet Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Captivating ${prop.type} in the heart of ${prop.city}, ${prop.state}.\n\nWelcome to your perfect rental home! This modern property offers the ultimate convenience and comfort for tenants, families, and working professionals.",
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Key Features:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint("Prime Location: Situated in ${prop.area}.", isDark),
            _buildBulletPoint(
              "Cozy & Modern Living Space: Queen/King bed layout with quality finishes.",
              isDark,
            ),
            _buildBulletPoint(
              "Kitchen Provision: Dedicated kitchen space with fitted sink and counter.",
              isDark,
            ),
            _buildBulletPoint(
              "Stylish Bathroom: Tiled bathroom with running water fixtures.",
              isDark,
            ),
            _buildBulletPoint(
              "Safety and Security: Gated compound with perimeter security.",
              isDark,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

Widget _buildBulletPoint(String text, bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "• ",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}
