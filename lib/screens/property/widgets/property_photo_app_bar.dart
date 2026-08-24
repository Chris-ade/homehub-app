import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';

class PropertyPhotoAppBar extends StatelessWidget {
  final Property property;
  final int activeIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onToggleFavorite;
  final bool isDark;

  const PropertyPhotoAppBar({
    super.key,
    required this.property,
    required this.activeIndex,
    required this.onPageChanged,
    required this.onBack,
    required this.onShare,
    required this.onToggleFavorite,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 330,
      pinned: true,
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.surface,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Center(
          child: _buildCircleButton(
            icon: LucideIcons.arrow_left,
            isDark: isDark,
            onTap: onBack,
          ),
        ),
      ),
      actions: [
        _buildCircleButton(
          icon: LucideIcons.share_2,
          isDark: isDark,
          onTap: onShare,
        ),
        const SizedBox(width: 10),
        _buildCircleButton(
          icon: property.isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          iconColor: property.isFavorite
              ? (isDark ? AppColors.darkAccent : AppColors.accent)
              : null,
          isDark: isDark,
          onTap: onToggleFavorite,
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: property.gallery.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: property.gallery[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: isDark
                        ? AppColors.darkSurfaceAlt
                        : AppColors.surfaceAlt,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: isDark
                        ? AppColors.darkSurfaceAlt
                        : AppColors.surfaceAlt,
                    child: Icon(
                      LucideIcons.image_off,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),

            // Image counter pill badge (e.g. 1/13)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "${activeIndex + 1}/${property.gallery.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    Color? iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkSurface : Colors.white).withValues(
            alpha: 0.95,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: iconColor ??
                (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
