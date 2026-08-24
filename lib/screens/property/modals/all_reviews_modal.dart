import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';
import '../widgets/laurel_branch_painter.dart';

void showAllReviewsModal(
  BuildContext context,
  Property prop,
  List<Map<String, dynamic>> mockReviews,
  bool isDark,
) {
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

            // Rating Header — large rating + laurel branch painter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: const Size(22, 44),
                  painter: LaurelBranchPainter(isLeft: true, isDark: isDark),
                ),
                const SizedBox(width: 8),
                Text(
                  prop.rating.toStringAsFixed(2),
                  style: TextStyle(
                    fontFamily: 'Cabinet Grotesk',
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                CustomPaint(
                  size: const Size(22, 44),
                  painter: LaurelBranchPainter(isLeft: false, isDark: isDark),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                "${prop.reviewCount} Reviews",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Rating breakdown grid
            _buildRatingBreakdownGrid(isDark),

            const SizedBox(height: 20),
            Divider(color: isDark ? AppColors.darkBorder : AppColors.border),

            // Reviews list
            ...mockReviews.map((rev) => _buildFullReviewItem(rev, isDark)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

Widget _buildRatingBreakdownGrid(bool isDark) {
  return Column(
    children: [
      _buildRatingBarRow("Cleanliness", 4.7, LucideIcons.sparkles, isDark),
      _buildRatingBarRow("Accuracy", 4.8, LucideIcons.circle_check, isDark),
      _buildRatingBarRow("Check-in", 4.9, LucideIcons.key_round, isDark),
      _buildRatingBarRow(
        "Communication",
        4.9,
        LucideIcons.message_circle,
        isDark,
      ),
      _buildRatingBarRow("Location", 4.8, LucideIcons.map_pin, isDark),
      _buildRatingBarRow("Value", 4.7, LucideIcons.tag, isDark),
    ],
  );
}

Widget _buildRatingBarRow(
  String label,
  double rating,
  IconData icon,
  bool isDark,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (rating / 5.0),
              minHeight: 4,
              backgroundColor: isDark
                  ? AppColors.darkBorder
                  : AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

Widget _buildFullReviewItem(Map<String, dynamic> review, bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(review['avatar']),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['name'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    review['location'] ?? review['tenure'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Row(
              children: List.generate(
                review['rating'] as int,
                (i) => const Icon(
                  Icons.star_rounded,
                  size: 13,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${review['date']} · ${review['stay']}",
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          review['comment'],
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: isDark ? AppColors.darkBorder : AppColors.border),
      ],
    ),
  );
}
