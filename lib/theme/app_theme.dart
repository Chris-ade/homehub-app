import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette — Deep Teal (premium, calming, property-appropriate)
  static const Color teal = Color(0xFF134E4A);
  static const Color tealHover = Color(0xFF0E3F3C);
  static const Color tealLight = Color(0xFF3D8F89);

  // Action / Accent — Amber (gold). One accent, one primary: amber is used
  // for highlights & CTAs, teal carries the identity.
  static const Color amber = Color(0xFFE0A63B);
  static const Color amberHover = Color(0xFFC98F2A);
  static const Color amberLight = Color(0xFFFBF3DF);
  // Deeper gold for amber text/icons on light surfaces (amber itself is too
  // pale for small text on white — this keeps WCAG 4.5:1 contrast).
  static const Color amberDeep = Color(0xFF9A6B14);

  // Background / Surface (Light Mode)
  static const Color offWhite = Color(0xFFF7F8F6);
  static const Color mist = Color(0xFFECEFEB);
  static const Color surface = Color(0xFFFFFFFF);

  // Typography & Lines
  static const Color ink = Color(0xFF0B1715);
  static const Color muted = Color(0xFF4C5C59);
  static const Color line = Color(0xFFE3E8E6);

  // Dark Mode Palette — cool charcoal with a whisper of teal, so the brand
  // reads through without bathing every surface in teal.
  static const Color darkBackground = Color(0xFF0F1414);
  static const Color darkSurface = Color(0xFF17201F);
  static const Color darkSurfaceAlt = Color(0xFF1F2B2A);
  static const Color darkLine = Color(0xFF2C3A38);
  static const Color darkInk = Color(0xFFF0F4F3);
  static const Color darkMuted = Color(0xFF9DAEAB);
  // Brightened amber for dark surfaces (the light-mode amber is too dim
  // against charcoal). Used as the dark accent/primary.
  static const Color darkAccent = Color(0xFFE8B84B);

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
    scaffoldBackgroundColor: AppColors.offWhite,
    colorScheme: const ColorScheme.light(
      primary: AppColors.teal,
      secondary: AppColors.amber,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: AppColors.ink,
      onSurface: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.teal),
      actionsIconTheme: IconThemeData(color: AppColors.teal),
      titleTextStyle: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        fontSize: 25,
        fontWeight: FontWeight.w800,
        color: AppColors.teal,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line, width: 1),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.mist,
      selectedColor: AppColors.amber,
      disabledColor: AppColors.line,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      side: const BorderSide(color: AppColors.line),
      labelStyle: const TextStyle(
        fontFamily: 'Satoshi',
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: AppFontSizes.displayLarge,
        fontWeight: FontWeight.w900,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: AppFontSizes.displayMedium,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: AppFontSizes.displaySmall,
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: AppFontSizes.headlineLarge,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: AppFontSizes.headlineMedium,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: AppFontSizes.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.muted,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.muted,
        fontSize: AppFontSizes.bodySmall,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.teal,
        fontSize: AppFontSizes.labelLarge,
        fontWeight: FontWeight.bold,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.muted,
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
      secondary: AppColors.tealLight,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: AppColors.ink,
      onSecondary: Colors.white,
      onSurface: AppColors.darkInk,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.darkInk),
      actionsIconTheme: IconThemeData(color: AppColors.darkInk),
      titleTextStyle: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        fontSize: 25,
        fontWeight: FontWeight.w800,
        color: AppColors.darkInk,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkLine, width: 1),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurfaceAlt,
      selectedColor: AppColors.darkAccent,
      disabledColor: AppColors.darkLine,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      side: const BorderSide(color: AppColors.darkLine),
      labelStyle: const TextStyle(
        fontFamily: 'Satoshi',
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkLine,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkInk,
        fontSize: 38,
        fontWeight: FontWeight.w900,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkInk,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkInk,
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkInk,
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkInk,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkInk,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkInk,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkInk,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.darkInk,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.darkInk,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.darkMuted,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.darkMuted,
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
        color: AppColors.darkMuted,
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
        color: color ?? (isDark ? AppColors.darkInk : AppColors.teal),
        letterSpacing: letterSpacing,
      ),
    );
  }
}
