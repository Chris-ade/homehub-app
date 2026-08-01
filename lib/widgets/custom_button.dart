import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isTerracotta;
  final bool isOutline;
  final IconData? icon;
  final double height;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isTerracotta = false,
    this.isOutline = false,
    this.icon,
    this.height = 48,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;

    if (isOutline) {
      bg = Colors.transparent;
      fg = isTerracotta
          ? AppColors.terracotta
          : (isDark ? AppColors.darkInk : AppColors.forest);
    } else if (isTerracotta) {
      bg = AppColors.terracotta;
      fg = Colors.white;
    } else if (isPrimary) {
      bg = isDark ? AppColors.terracotta : AppColors.forest;
      fg = Colors.white;
    } else {
      bg = isDark ? AppColors.darkSurfaceAlt : AppColors.creamAlt;
      fg = isDark ? AppColors.darkInk : AppColors.ink;
    }

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: isOutline ? 0 : 2,
          shadowColor: bg.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isOutline
                ? BorderSide(
                    color: isTerracotta
                        ? AppColors.terracotta
                        : (isDark ? AppColors.darkLine : AppColors.forest),
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: fg,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
