import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// An Airbnb-style "See all" card placed at the end of horizontal carousels.
/// Displays an overlapping, fanned collage of 3 thumbnail images followed by
/// a bold "See all" text label.
class SeeAllCarouselCard extends StatelessWidget {
  final List<String> images;
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double cardRadius;
  final EdgeInsetsGeometry margin;

  const SeeAllCarouselCard({
    super.key,
    required this.images,
    required this.onTap,
    this.label = "See all",
    this.width = 180,
    this.height = 245,
    this.cardRadius = 20,
    this.margin = const EdgeInsets.only(right: 16),
  });

  static const List<String> _fallbackImages = [
    'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=300&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=300&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=300&auto=format&fit=crop&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Gather 3 thumbnail URLs
    final validImages = images.where((s) => s.trim().isNotEmpty).toList();
    final List<String> displayImages = [];
    for (int i = 0; i < 3; i++) {
      if (i < validImages.length) {
        displayImages.add(validImages[i]);
      } else {
        displayImages.add(_fallbackImages[i % _fallbackImages.length]);
      }
    }

    // Scale thumbnails based on card height
    final double thumbSize = height < 180 ? 50.0 : 66.0;
    final double stackHeight = height < 180 ? 82.0 : 108.0;
    final double stackWidth = height < 180 ? 100.0 : 130.0;
    final double fontSize = height < 180 ? 14.5 : 16.5;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1.2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cardRadius),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fanned 3-card stack
              SizedBox(
                width: stackWidth,
                height: stackHeight,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // 1. Back image (top left, tilted counter-clockwise)
                    Transform.translate(
                      offset: Offset(
                        height < 180 ? -12 : -16,
                        height < 180 ? -6 : -8,
                      ),
                      child: Transform.rotate(
                        angle: -0.14,
                        child: _buildThumb(
                          displayImages[0],
                          thumbSize,
                          isDark,
                        ),
                      ),
                    ),

                    // 2. Middle image (top right, tilted clockwise)
                    Transform.translate(
                      offset: Offset(
                        height < 180 ? 14 : 18,
                        height < 180 ? -3 : -4,
                      ),
                      child: Transform.rotate(
                        angle: 0.12,
                        child: _buildThumb(
                          displayImages[1],
                          thumbSize,
                          isDark,
                        ),
                      ),
                    ),

                    // 3. Front image (lower center, subtle tilt)
                    Transform.translate(
                      offset: Offset(
                        height < 180 ? -4 : -6,
                        height < 180 ? 10 : 14,
                      ),
                      child: Transform.rotate(
                        angle: -0.03,
                        child: _buildThumb(
                          displayImages[2],
                          thumbSize,
                          isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height < 180 ? 12 : 18),

              // Label
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cabinet Grotesk',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumb(String url, double size, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkSurface : Colors.white,
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
          ),
          errorWidget: (context, url, error) => Container(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
            child: Icon(
              Icons.image_outlined,
              size: size * 0.45,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
