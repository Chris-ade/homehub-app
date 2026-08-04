import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color forest = Color(0xFF0F3820);
  static const Color forestHover = Color(0xFF16502E);
  static const Color forestLight = Color(0xFF1E5233);
  
  // Action / Accent
  static const Color terracotta = Color(0xFFD36B46);
  static const Color terracottaHover = Color(0xFFBF5D3B);
  static const Color terracottaLight = Color(0xFFF9EAE5);

  // Background / Surface (Light Mode)
  static const Color warmCream = Color(0xFFF9F8F5);
  static const Color creamAlt = Color(0xFFF0EFEA);
  static const Color surface = Color(0xFFFFFFFF);

  // Typography & Lines
  static const Color ink = Color(0xFF0A170F);
  static const Color muted = Color(0xFF4A5B50);
  static const Color line = Color(0xFFE5E3DB);

  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF07140B);
  static const Color darkSurface = Color(0xFF0F2317);
  static const Color darkSurfaceAlt = Color(0xFF162D1F);
  static const Color darkLine = Color(0xFF1F3D2B);
  static const Color darkInk = Color(0xFFEBF3ED);
  static const Color darkMuted = Color(0xFFA1B5A8);

  // Status & Utility
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0277BD);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Satoshi',
    scaffoldBackgroundColor: AppColors.warmCream,
    colorScheme: const ColorScheme.light(
      primary: AppColors.forest,
      secondary: AppColors.terracotta,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.forest),
      actionsIconTheme: IconThemeData(color: AppColors.forest),
      titleTextStyle: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        fontSize: 25,
        fontWeight: FontWeight.w800,
        color: AppColors.forest,
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
      backgroundColor: AppColors.creamAlt,
      selectedColor: AppColors.terracotta,
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
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: 38,
        fontWeight: FontWeight.w900,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Cabinet Grotesk',
        color: AppColors.ink,
        fontSize: 22,
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
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.forest,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Satoshi',
        color: AppColors.muted,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Satoshi',
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.terracotta,
      secondary: AppColors.forestLight,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
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
      selectedColor: AppColors.terracotta,
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
        color: AppColors.terracotta,
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
        color: color ?? (isDark ? AppColors.darkInk : AppColors.forest),
        letterSpacing: letterSpacing,
      ),
    );
  }
}
