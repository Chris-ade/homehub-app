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
        bg = AppColors.forest.withValues(alpha: 0.12);
        fg = isDark ? Colors.lightGreenAccent : AppColors.forest;
        break;
      case 'premium':
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        break;
      case 'student-friendly':
        bg = const Color(0xFFE1F5FE);
        fg = const Color(0xFF0288D1);
        break;
      case 'new':
        bg = AppColors.terracotta.withValues(alpha: 0.15);
        fg = AppColors.terracotta;
        break;
      default:
        bg = AppColors.creamAlt;
        fg = AppColors.ink;
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
    final bg = backgroundColor ?? AppColors.creamAlt;
    final fg = textColor ?? AppColors.ink;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            label,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
