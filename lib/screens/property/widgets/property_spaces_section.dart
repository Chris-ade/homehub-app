import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';

class PropertySpacesSection extends StatelessWidget {
  final Property property;
  final bool isDark;

  const PropertySpacesSection({
    super.key,
    required this.property,
    required this.isDark,
  });

  String _formatRoomTag(String? rawTag) {
    if (rawTag == null || rawTag.isEmpty) return "Room / Space";
    final t = rawTag.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ');
    if (t.contains('living') || t.contains('parlour') || t.contains('parlor') || t.contains('sitting')) {
      return "Living Room (Parlour)";
    }
    if (t.contains('bedroom') || t.contains('bed')) {
      return "Bedroom";
    }
    if (t.contains('kitchen')) {
      return "Kitchen";
    }
    if (t.contains('bathroom') || t.contains('toilet') || t.contains('restroom')) {
      return "Bathroom";
    }
    if (t.contains('balcony') || t.contains('terrace')) {
      return "Balcony / Terrace";
    }
    if (t.contains('dining')) {
      return "Dining Area";
    }
    return t.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  IconData _getRoomIcon(String? rawTag) {
    if (rawTag == null) return LucideIcons.door_open;
    final t = rawTag.toLowerCase();
    if (t.contains('bedroom') || t.contains('bed')) return LucideIcons.bed_double;
    if (t.contains('living') || t.contains('parlour') || t.contains('parlor') || t.contains('sitting')) {
      return LucideIcons.sofa;
    }
    if (t.contains('kitchen')) return LucideIcons.utensils;
    if (t.contains('bathroom') || t.contains('toilet')) return LucideIcons.bath;
    if (t.contains('balcony')) return LucideIcons.sun;
    return LucideIcons.door_open;
  }

  @override
  Widget build(BuildContext context) {
    final taggedImages = property.taggedRoomImages;
    if (taggedImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Spaces in this home",
          style: TextStyle(
            fontFamily: 'Cabinet Grotesk',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 205,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: taggedImages.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final img = taggedImages[index];
              final roomTitle = _formatRoomTag(img.tag);
              final roomIcon = _getRoomIcon(img.tag);

              return Container(
                width: 220,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceAlt
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: img.url,
                        height: 125,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 125,
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.surfaceAlt,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 125,
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.surfaceAlt,
                          child: Icon(
                            LucideIcons.image_off,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                roomIcon,
                                size: 14,
                                color: isDark
                                    ? AppColors.darkAccent
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  roomTitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            img.caption != null && img.caption!.isNotEmpty
                                ? img.caption!
                                : "Tagged room photo",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
