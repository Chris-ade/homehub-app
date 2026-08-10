import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../theme/app_theme.dart';

class PropertyCardSkeleton extends StatelessWidget {
  final bool isHorizontal;
  const PropertyCardSkeleton({super.key, this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;
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
