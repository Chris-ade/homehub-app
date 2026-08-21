import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isAmber;
  final bool isOutline;
  final IconData? icon;
  final double height;
  final double? width;
  final bool? isDisabled;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isAmber = false,
    this.isOutline = false,
    this.icon,
    this.height = 48,
    this.width,
    this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;

    if (isOutline) {
      bg = Colors.transparent;
      fg = isAmber
          ? (isDark ? AppColors.darkAccent : AppColors.amberDeep)
          : (isDark ? AppColors.darkInk : AppColors.teal);
    } else if (isAmber) {
      // Amber/gold fills need dark text for adequate contrast.
      bg = isDark ? AppColors.darkAccent : AppColors.amber;
      fg = AppColors.ink;
    } else if (isPrimary) {
      bg = isDark ? AppColors.darkAccent : AppColors.teal;
      fg = isDark ? AppColors.ink : Colors.white;
    } else {
      bg = isDark ? AppColors.darkSurfaceAlt : AppColors.mist;
      fg = isDark ? AppColors.darkInk : AppColors.ink;
    }

    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        statesController: isDisabled == true
            ? WidgetStatesController({WidgetState.disabled})
            : null,
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
                    color: isAmber
                        ? (isDark ? AppColors.darkAccent : AppColors.amberDeep)
                        : (isDark ? AppColors.darkLine : AppColors.teal),
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
                fontSize: AppFontSizes.bodyLarge,
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
