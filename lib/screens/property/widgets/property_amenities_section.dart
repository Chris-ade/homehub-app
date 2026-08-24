import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';
import 'amenity_helpers.dart';

class PropertyAmenitiesSection extends StatelessWidget {
  final Property property;
  final bool isDark;
  final VoidCallback onShowAll;

  const PropertyAmenitiesSection({
    super.key,
    required this.property,
    required this.isDark,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What this place offers",
          style: TextStyle(
            fontFamily: 'Cabinet Grotesk',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        if (property.amenities.isNotEmpty) ...[
          ...property.amenities.take(5).map(
                (amenity) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildAmenityRow(
                    getAmenityIcon(amenity),
                    amenity,
                  ),
                ),
              ),
        ] else ...[
          _buildAmenityRow(LucideIcons.wifi, "WiFi"),
          const SizedBox(height: 14),
          _buildAmenityRow(LucideIcons.zap, "24hr Power supply"),
          const SizedBox(height: 14),
          _buildAmenityRow(LucideIcons.car_front, "Parking space"),
          const SizedBox(height: 14),
          _buildAmenityRow(LucideIcons.shield_check, "Security / Gateman"),
          const SizedBox(height: 14),
          _buildAmenityRow(LucideIcons.droplets, "Running water"),
        ],

        const SizedBox(height: 18),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onShowAll,
          child: Text(
            property.amenities.isEmpty
                ? "Show all amenities"
                : "Show all ${property.amenities.length} amenities",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
