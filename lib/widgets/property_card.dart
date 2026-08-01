import 'package:flutter/material.dart';
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
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        child: _buildCardContent(context, isDark),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                : AppColors.forest.withValues(alpha: 0.06),
            blurRadius: 16,
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
              // Image Header with Badge and Favorite Button
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: property.image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.terracotta),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt,
                          child: const Icon(Icons.apartment_rounded, size: 40, color: AppColors.muted),
                        ),
                      ),
                    ),
                  ),

                  // Gradient Overlay for readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.2),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Status Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: BadgeChip.status(property.status, isDark: isDark),
                  ),

                  // Favorite Bookmark Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: Icon(
                          property.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: property.isFavorite ? AppColors.terracotta : Colors.white,
                          size: 20,
                        ),
                        onPressed: onFavoriteToggle,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  // Rating Pill
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            "${property.rating} (${property.reviewCount})",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            _formatCurrency(property.price),
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.terracotta : AppColors.forest,
                            ),
                          ),
                        ),
                        Text(
                          " / ${property.period}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkMuted : AppColors.muted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Property Title
                    Text(
                      property.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkInk : AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Location Area
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.area,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkMuted : AppColors.muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(height: 1, color: isDark ? AppColors.darkLine : AppColors.line),
                    const SizedBox(height: 12),

                    // Specs Row (Beds, Baths, Sqft)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSpecItem(Icons.king_bed_outlined, "${property.beds} Beds", isDark),
                        _buildSpecItem(Icons.bathtub_outlined, "${property.baths} Baths", isDark),
                        _buildSpecItem(Icons.square_foot_outlined, "${property.sqft} sqft", isDark),
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
