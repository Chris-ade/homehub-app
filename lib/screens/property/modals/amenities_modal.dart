import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';
import '../widgets/amenity_helpers.dart';

void showAllAmenitiesModal(
  BuildContext context,
  Property prop,
  bool isDark,
) {
  final List<String> source = prop.amenities.isNotEmpty
      ? prop.amenities
      : [
          "WiFi",
          "24hr Power supply",
          "Generator backup",
          "Running water",
          "Borehole",
          "Parking space",
          "Security / Gateman",
          "CCTV cameras",
          "Air conditioning",
          "Ceiling fan",
          "Tiled floors",
          "POP ceiling",
          "Kitchen",
          "Wardrobe",
          "Prepaid meter",
        ];

  Map<String, List<String>> grouped = {};
  for (final a in source) {
    final cat = getAmenityCategory(a);
    grouped.putIfAbsent(cat, () => []).add(a);
  }

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
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(LucideIcons.arrow_left, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Text(
              "What this place offers",
              style: TextStyle(
                fontFamily: 'Cabinet Grotesk',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Render each category + its amenities from real data
            ...grouped.entries.expand(
              (entry) => [
                _buildAmenityCategoryHeader(entry.key, isDark),
                ...entry.value.map(
                  (amenity) => _buildAmenityItem(
                    getAmenityIcon(amenity),
                    amenity,
                    isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

Widget _buildAmenityCategoryHeader(String title, bool isDark) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: isDark ? AppColors.darkBorder : AppColors.border),
      ],
    ),
  );
}

Widget _buildAmenityItem(IconData icon, String label, bool isDark) {
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
