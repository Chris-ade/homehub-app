import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/property_model.dart';
import '../theme/app_theme.dart';
import 'badge_chip.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isHorizontal;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onFavoriteToggle,
    this.isHorizontal = false,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isHorizontal) {
      return Container(
        width: 290,
        margin: const EdgeInsets.only(right: 16),
        child: _buildCardContent(context, isDark),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: _buildCardContent(context, isDark),
    );
  }

  Widget _buildCardContent(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkLine : AppColors.line,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.forest.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Header matching web ratio with Badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: SizedBox(
                      height: isHorizontal ? 165 : 185,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: property.image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.creamAlt,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.terracotta,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.creamAlt,
                          child: const Icon(
                            LucideIcons.building_2,
                            size: 40,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Top Left Status Badge (Verified / New)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: BadgeChip.status(property.status, isDark: isDark),
                  ),

                  // Top Right Type Badge (Flat, Apartment, Studio, etc.)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.darkBackground : Colors.white)
                                .withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.darkLine : AppColors.line,
                        ),
                      ),
                      child: Text(
                        property.type,
                        style: TextStyle(
                          color: isDark ? AppColors.darkInk : AppColors.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Rating Badge (Bottom Right of Image)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${property.rating}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Content Body matching web layout
              Padding(
                padding: EdgeInsets.all(isHorizontal ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Heart Bookmark Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            property.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkInk
                                  : AppColors.forest,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurfaceAlt
                                  : AppColors.creamAlt,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.heart,
                              color: property.isFavorite
                                  ? AppColors.terracotta
                                  : (isDark
                                        ? AppColors.darkInk
                                        : AppColors.forest),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Location Address Row with Terracotta Pin Icon
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.map_pin,
                          size: 14,
                          color: AppColors.terracotta,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.area,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isHorizontal ? 8 : 12),

                    // Specs Row: Bed, Bath, Sqft
                    Row(
                      children: [
                        _buildSpecItem(
                          LucideIcons.bed_double,
                          "${property.beds} bd",
                          isDark,
                        ),
                        const SizedBox(width: 14),
                        _buildSpecItem(
                          LucideIcons.bath,
                          "${property.baths} ba",
                          isDark,
                        ),
                        const SizedBox(width: 14),
                        _buildSpecItem(
                          LucideIcons.maximize,
                          "${property.sqft} sqft",
                          isDark,
                        ),
                      ],
                    ),

                    SizedBox(height: isHorizontal ? 8 : 12),
                    Divider(
                      height: 1,
                      color: isDark ? AppColors.darkLine : AppColors.line,
                    ),
                    SizedBox(height: isHorizontal ? 8 : 12),

                    // Bottom Row: Listed By Agent on Left, Price on Right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundImage: NetworkImage(
                                  property.agent.avatarUrl,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "${property.agent.name} · ${property.agent.role.contains("Landlord") ? "Landlord" : "Agent"}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkMuted
                                        : AppColors.muted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Price in NGN
                        Row(
                          children: [
                            Text(
                              _formatCurrency(property.price),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.terracotta
                                    : AppColors.forest,
                              ),
                            ),
                            Text(
                              " / ${property.period}",
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: isDark ? AppColors.terracotta : AppColors.forest,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkInk : AppColors.ink,
          ),
        ),
      ],
    );
  }
}
