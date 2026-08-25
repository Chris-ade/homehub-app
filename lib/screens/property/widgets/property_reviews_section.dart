import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_toast.dart';
import 'laurel_branch_painter.dart';

class PropertyReviewsSection extends StatelessWidget {
  final Property property;
  final List<Map<String, dynamic>> mockReviews;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final VoidCallback onShowAllReviews;
  final bool isDark;

  const PropertyReviewsSection({
    super.key,
    required this.property,
    required this.mockReviews,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.onShowAllReviews,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (property.reviewCount == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              LucideIcons.star,
              size: 32,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              "No reviews yet",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Be the first to review this property after your visit.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusBanner(context),
        const SizedBox(height: 18),
        _buildReviewMentionChips(),
        const SizedBox(height: 16),
        SizedBox(
          height: 195,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: mockReviews.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final review = mockReviews[index];
              return _buildReviewCard(review);
            },
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1.2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onShowAllReviews,
          child: Text(
            "Show all ${property.reviewCount} reviews",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner(BuildContext context) {
    final statusTitle = property.status.isNotEmpty
        ? "${property.status} Listing"
        : "Verified Listing";

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(26, 52),
              painter: LaurelBranchPainter(
                isLeft: true,
                isDark: isDark,
                strokeWidth: 2.2,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              property.rating.toStringAsFixed(2),
              style: TextStyle(
                fontFamily: 'Cabinet Grotesk',
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(width: 10),
            CustomPaint(
              size: const Size(26, 52),
              painter: LaurelBranchPainter(
                isLeft: false,
                isDark: isDark,
                strokeWidth: 2.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          statusTitle,
          style: TextStyle(
            fontFamily: 'Cabinet Grotesk',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "This property is verified for quality, pricing accuracy, and physical inspection on HomeHub",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {
            AppToast.showInfo(
              context,
              message:
                  "Verified listings on HomeHub undergo physical inspection and price verification by our field agents.",
            );
          },
          child: Text(
            "How verification works",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewMentionChips() {
    final chips = [
      {"icon": LucideIcons.accessibility, "label": "Hospitality", "count": 15},
      {"icon": LucideIcons.star, "label": "Cleanliness", "count": 8},
      {"icon": LucideIcons.map_pin, "label": "Location", "count": 7},
      {"icon": LucideIcons.sofa, "label": "Comfort", "count": 5},
      {"icon": LucideIcons.key, "label": "Check-in", "count": 9},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Guest reviews mention",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: chips.map((chip) {
              final isSelected = selectedFilter == chip['label'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        chip['icon'] as IconData,
                        size: 16,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${chip['label']}  ${chip['count']}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.accent,
                  backgroundColor: isDark
                      ? AppColors.darkSurfaceAlt
                      : AppColors.surfaceAlt,
                  onSelected: (selected) {
                    onFilterSelected(
                      selected ? (chip['label'] as String) : "All",
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: CachedNetworkImageProvider(review['avatar']),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      review['tenure'],
                      style: TextStyle(
                        fontSize: 11,
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
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "·  ${review['date']}",
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              review['comment'],
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
