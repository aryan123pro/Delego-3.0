import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _themeKey = 'theme_mode';
  // Dark ("void") is Mumbai MUN's default identity — light is opt-in only.
  ThemeMode _mode = ThemeMode.dark;

  ThemeMode get mode => _mode;
  bool get isLight => _mode == ThemeMode.light;

  // Load saved theme mode
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);

    switch (saved) {
      case 'light':
        _mode = ThemeMode.light;
        break;
      default:
        _mode = ThemeMode.dark;
    }
    notifyListeners();
  }

  // Save theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(_themeKey, 'light');
        break;
      case ThemeMode.dark:
        await prefs.setString(_themeKey, 'dark');
        break;
      default:
        await prefs.setString(_themeKey, 'system');
    }
  }

  // Optional helpers
  void useSystem() => setThemeMode(ThemeMode.system);
  void useLight() => setThemeMode(ThemeMode.light);
  void useDark() => setThemeMode(ThemeMode.dark);
}
