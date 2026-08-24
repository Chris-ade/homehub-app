import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';

class PropertyHighlightsSection extends StatelessWidget {
  final Property property;
  final bool isDark;

  const PropertyHighlightsSection({
    super.key,
    required this.property,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHighlightItem(
          icon: LucideIcons.door_open,
          title: "Self check-in",
          description: "You can check in with the building staff.",
          isDark: isDark,
        ),
        const SizedBox(height: 18),
        _buildHighlightItem(
          icon: LucideIcons.message_square_check,
          title: "Great host communication",
          description:
              "Recent guests loved ${property.agent.name.split(' ').first}'s communication.",
          isDark: isDark,
        ),
        const SizedBox(height: 18),
        _buildHighlightItem(
          icon: LucideIcons.paw_print,
          title: "Furry friends welcome",
          description: "Bring your pets along for the stay.",
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildHighlightItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        const SizedBox(width: 16),
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
              const SizedBox(height: 2),
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
      ],
    );
  }
}
