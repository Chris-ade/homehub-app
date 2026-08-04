import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../theme/app_theme.dart';

/// Consistent section header used across the home screen: an optional small
/// terracotta "eyebrow" label, a Cabinet Grotesk title, an optional subtitle,
/// and an optional trailing text action (e.g. "Browse all →").
class SectionHeader extends StatelessWidget {
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Cabinet Grotesk',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.terracotta,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cabinet Grotesk',
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkInk : AppColors.forest,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      actionLabel!,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        color: AppColors.terracotta,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.arrow_up_right,
                      size: 16,
                      color: AppColors.terracotta,
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 15,
              height: 1.35,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
            ),
          ),
        ],
      ],
    );
  }
}
