import 'package:flutter/material.dart';

/// Semantic color tokens — named by role, not hue, mirroring the web version
/// (`--surface`, `--primary`, `--accent`, …). Teal is the brand primary;
/// terracotta is the accent. Dark surfaces are neutral charcoal (no teal tint)
/// exactly like the web's dark scheme.
class AppColors {
  // Primary — Deep Teal (brand identity)
  static const Color primary = Color(0xFF134E4A);
  static const Color primaryHover = Color(0xFF0E3F3C);
  static const Color primaryLight = Color(0xFF3D8F89);

  // Accent — Terracotta (highlights & CTAs). The web brightens it for dark.
  static const Color accent = Color(0xFFdb6143);
  static const Color accentHover = Color(0xFFdb6143);
  static const Color accentLight = Color(0xFFFBF3DF);

  // Background / Surface (Light)
  static const Color background = Color(0xFFF7F8F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFECEFEB);

  // Typography & Borders (Light)
  static const Color textPrimary = Color(0xFF0B1715);
  static const Color textSecondary = Color(0xFF4C5C59);
  static const Color border = Color(0xFFE3E8E6);

  // Utility white (was misleadingly called "amber" — it's plain white).
  static const Color white = Color(0xFFFFFFFF);

  // Dark Mode — neutral charcoal, matching the web's dark scheme. Surfaces
  // carry no teal tint; teal survives only as the brand primary (darkPrimary).
  static const Color darkBackground = Color(0xFF1B1B1B);
  static const Color darkSurface = Color(0xFF252525);
  static const Color darkSurfaceAlt = Color(0xFF2B2B2B);
  static const Color darkBorder = Color(0xFF363636);
  static const Color darkTextPrimary = Color(0xFFEDEDED);
  static const Color darkTextSecondary = Color(0xFF999999);
  static const Color darkAccent = Color(0xFFE0845C);
  static const Color darkAccentHover = Color(0xFFCC7048);
  static const Color darkPrimary = Color(0xFF134E4A);

  // Status & Utility
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);
}

class AppFontSizes {
  static const double displayLarge = 38;
  static const double displayMedium = 32;
  static const double displaySmall = 28;
  static const double headlineLarge = 26;
  static const double headlineMedium = 24;
  static const double headlineSmall = 22;
  static const double titleLarge = 20;
  static const double titleMedium = 18;
  static const double titleSmall = 16;
  static const double bodyLarge = 18;
  static const double bodyMedium = 16;
  static const double bodySmall = 14;
  static const double labelLarge = 16;
  static const double labelMedium = 14;
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Satoshi',
    // Remove the spreading ink ripple on taps (buttons, nav bar, cards).
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.white,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.primary),
      actionsIconTheme: IconThemeData(color: AppColors.primary),
      titleTextStyle: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        fontSize: 25,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceAlt,
      selectedColor: AppColors.white,
      disabledColor: AppColors.border,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      side: const BorderSide(color: AppColors.border),
      labelStyle: const TextStyle(
        fontFamily: 'Satoshi',
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.textPrimary,
        fontSize: AppFontSizes.displayLarge,
        fontWeight: FontWeight.w900,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.textPrimary,
        fontSize: AppFontSizes.displayMedium,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.textPrimary,
        fontSize: AppFontSizes.displaySmall,
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.textPrimary,
        fontSize: AppFontSizes.headlineLarge,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.textPrimary,
        fontSize: AppFontSizes.headlineMedium,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.textPrimary,
        fontSize: AppFontSizes.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.textSecondary,
        fontSize: AppFontSizes.bodySmall,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.primary,
        fontSize: AppFontSizes.labelLarge,
        fontWeight: FontWeight.bold,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.textSecondary,
        fontSize: AppFontSizes.labelMedium,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Satoshi',
    // Remove the spreading ink ripple on taps (buttons, nav bar, cards).
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkAccent,
      secondary: AppColors.primaryLight,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: AppColors.textPrimary,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      actionsIconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      titleTextStyle: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        fontSize: 25,
        fontWeight: FontWeight.w800,
        color: AppColors.darkTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurfaceAlt,
      selectedColor: AppColors.darkAccent,
      disabledColor: AppColors.darkBorder,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      side: const BorderSide(color: AppColors.darkBorder),
      labelStyle: const TextStyle(
        fontFamily: 'Satoshi',
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkTextPrimary,
        fontSize: 38,
        fontWeight: FontWeight.w900,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkTextPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkTextPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkTextPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.darkTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.darkAccent,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// Convenience reusable HeadingText widget that automatically applies 'Cabinet Grotesk'
class HeadingText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpacing;

  const HeadingText(
    this.text, {
    super.key,
    this.fontSize = 22,
    this.fontWeight = FontWeight.w800,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.primary),
        letterSpacing: letterSpacing,
      ),
    );
  }
}
