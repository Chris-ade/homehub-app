import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';

class PropertyCardSkeleton extends StatelessWidget {
  final bool isHorizontal;
  final bool isLandlord;
  const PropertyCardSkeleton({
    super.key,
    this.isHorizontal = false,
    this.isLandlord = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    if (isLandlord) {
      return Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
              ),
              // Info rows
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 18, width: double.infinity, color: base),
                    const SizedBox(height: 8),
                    Container(height: 13, width: 120, color: base),
                    const SizedBox(height: 10),
                    Container(height: 18, width: 100, color: base),
                  ],
                ),
              ),
              // Action buttons placeholder
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: base,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: base,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: isHorizontal ? 290 : double.infinity,
        margin: EdgeInsets.only(bottom: isHorizontal ? 0 : 20, right: isHorizontal ? 16 : 0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: isHorizontal ? 165 : 185,
              width: double.infinity,
              decoration: BoxDecoration(
                color: base,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            const SizedBox(height: 12),
            // Title placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(height: 20, color: base),
            ),
            const SizedBox(height: 4),
            // Price placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Container(height: 16, width: 80, color: base),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
