import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../theme/app_theme.dart';

class BadgeChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutline;

  const BadgeChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.isOutline = false,
  });

  factory BadgeChip.status(String status, {bool isDark = false}) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'verified':
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.primary;
        break;
      case 'new':
        bg = isDark
            ? AppColors.white.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.12);
        fg = isDark ? AppColors.darkAccent : AppColors.accent;
        break;
      default:
        bg = AppColors.surfaceAlt;
        fg = AppColors.textPrimary;
    }

    return BadgeChip(
      label: status,
      backgroundColor: bg,
      textColor: fg,
      icon: status.toLowerCase() == 'verified' ? LucideIcons.badge_check : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.surfaceAlt;
    final fg = textColor ?? AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isOutline ? fg.withValues(alpha: 0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: fg,
              fontSize: AppFontSizes.bodySmall,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
