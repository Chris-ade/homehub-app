import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeProvider extends ChangeNotifier {
  static const String _prefsKey = 'theme_mode';

  // Defaults to following the device until the user makes an explicit choice.
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Whether the app is currently rendering dark. When the mode follows the
  /// device (`ThemeMode.system`) this reads the platform's current brightness,
  /// so binary UI (the dark-mode switch / icon) stays in sync with what's shown.
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  /// Load the persisted preference. Call once before/at app start. Absent or
  /// unknown values fall back to following the device.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      _themeMode = _decode(stored);
    } catch (_) {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  /// Flip between an explicit light and dark override. Used by the quick toggle
  /// (home icon / profile switch); resolves the current appearance first so the
  /// first tap while following the device does the intuitive thing.
  void toggleTheme() {
    setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  /// Set the mode explicitly (`system`, `light`, or `dark`) and persist it.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    _persist(mode);
  }

  Future<void> _persist(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _encode(mode));
    } catch (_) {}
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _decode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
