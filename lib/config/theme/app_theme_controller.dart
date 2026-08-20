import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference { system, light, dark }

class AppThemeController extends ChangeNotifier {
  static const _themePreferenceKey = 'theme_preference';

  AppThemePreference _themePreference = AppThemePreference.system;

  AppThemePreference get themePreference => _themePreference;

  ThemeMode get themeMode {
    // The browser experience uses the light brand system by default. This
    // deliberately ignores a device's saved/system dark preference so web
    // login and dashboard surfaces remain consistent.
    if (kIsWeb) return ThemeMode.light;

    switch (_themePreference) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  Future<void> loadThemePreference() async {
    if (kIsWeb) {
      _themePreference = AppThemePreference.light;
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    final savedPreference = preferences.getString(_themePreferenceKey);
    _themePreference = _preferenceFromName(savedPreference);
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    if (_themePreference == preference) {
      return;
    }

    _themePreference = preference;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themePreferenceKey, preference.name);
  }

  AppThemePreference _preferenceFromName(String? value) {
    return AppThemePreference.values.firstWhere(
      (preference) => preference.name == value,
      orElse: () => AppThemePreference.system,
    );
  }
}

final appThemeController = AppThemeController();
