import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/property_model.dart';
import '../../theme/app_theme.dart';

/// Compact management row for a listing on the landlord dashboard: thumbnail,
/// title + rent, a status chip, and Edit/Delete actions. Presentational — the
/// dashboard wires [onTap]/[onEdit]/[onDelete] to navigation and API calls.
class LandlordPropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LandlordPropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onEdit,
    this.onDelete,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 96,
                    height: 88,
                    child: CachedNetworkImage(
                      imageUrl: property.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark
                            ? AppColors.darkSurfaceAlt
                            : AppColors.surfaceAlt,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? AppColors.white : AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark
                            ? AppColors.darkSurfaceAlt
                            : AppColors.surfaceAlt,
                        child: const Icon(
                          LucideIcons.building_2,
                          size: 28,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title, rent, status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cabinet Grotesk',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${property.type} · ${property.city}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _formatCurrency(property.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Cabinet Grotesk',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.darkAccent
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          Text(
                            " / ${property.period}",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _statusChip(isDark),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconButton(
                      context,
                      icon: LucideIcons.pencil,
                      color: isDark ? AppColors.darkAccent : AppColors.primary,
                      onTap: onEdit,
                      tooltip: "Edit",
                    ),
                    const SizedBox(height: 8),
                    _iconButton(
                      context,
                      icon: LucideIcons.trash_2,
                      color: AppColors.error,
                      onTap: onDelete,
                      tooltip: "Delete",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip(bool isDark) {
    final verified = property.status == "Verified";
    final bg = verified
        ? (isDark
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: 0.1))
        : (isDark ? AppColors.darkSurfaceAlt : AppColors.accentLight);
    final fg = verified
        ? (isDark ? AppColors.primaryLight : AppColors.primary)
        : (isDark ? AppColors.darkAccent : AppColors.accent);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        verified ? "Verified" : "New",
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _iconButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
