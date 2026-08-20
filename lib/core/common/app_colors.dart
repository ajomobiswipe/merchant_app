import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppColorSchemePreference {
  anetPurple,
  royalPurple,
  emeraldBlack,
  graphiteGreen,
}

class AppColorPalette {
  final String name;
  final Color primary;
  final Color success;
  final Color headline;
  final Color darkSurface;

  const AppColorPalette({
    required this.name,
    required this.primary,
    required this.success,
    required this.headline,
    required this.darkSurface,
  });
}

class AppColorPaletteController extends ChangeNotifier {
  static const _colorSchemePreferenceKey = 'color_scheme_preference';

  AppColorSchemePreference _preference = AppColorSchemePreference.anetPurple;

  AppColorSchemePreference get preference => _preference;

  AppColorPalette get palette => palettes[_preference]!;

  Future<void> loadPreference() async {
    final preferences = await SharedPreferences.getInstance();
    final savedPreference = preferences.getString(_colorSchemePreferenceKey);
    _preference = AppColorSchemePreference.values.firstWhere(
      (preference) => preference.name == savedPreference,
      orElse: () => AppColorSchemePreference.anetPurple,
    );
  }

  Future<void> setPreference(AppColorSchemePreference preference) async {
    if (_preference == preference) {
      return;
    }

    _preference = preference;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_colorSchemePreferenceKey, preference.name);
  }
}

final appColorPaletteController = AppColorPaletteController();

const Map<AppColorSchemePreference, AppColorPalette> palettes = {
  /// Purple + Emerald
  AppColorSchemePreference.anetPurple: AppColorPalette(
    name: 'Purple Emerald',
    primary: Color(0xFF7C3AED), // Vibrant Purple
    success: Color(0xFF10B981), // Emerald
    headline: Color(0xFF111827),
    darkSurface: Color(0xFF111827),
  ),

  /// Royal Blue + Cyan
  AppColorSchemePreference.royalPurple: AppColorPalette(
    name: 'Royal Blue',
    primary: Color(0xFF2563EB), // Royal Blue
    success: Color(0xFF06B6D4), // Cyan
    headline: Color(0xFF111827),
    darkSurface: Color(0xFF0B1220),
  ),

  /// Crimson + Gold
  AppColorSchemePreference.emeraldBlack: AppColorPalette(
    name: 'Crimson Gold',
    primary: Color(0xFFDC2626), // Crimson Red
    success: Color(0xFFF59E0B), // Gold/Amber
    headline: Color(0xFF111827),
    darkSurface: Color(0xFF1A0F0F),
  ),

  /// Teal + Orange
  AppColorSchemePreference.graphiteGreen: AppColorPalette(
    name: 'Teal Sunset',
    primary: Color(0xFF0F766E), // Deep Teal
    success: Color(0xFFFB923C), // Soft Orange
    headline: Color(0xFF111827),
    darkSurface: Color(0xFF0A1615),
  ),
};

class AppColors {
  AppColors._();

  static Color get primaryPurple => appColorPaletteController.palette.primary;
  static Color get successGreen => appColorPaletteController.palette.success;
  static Color get headlineBlack => appColorPaletteController.palette.headline;
  static const Color lightGrey = Color(0xffE3E3E3);
  static const Color mutedGrey = Color(0xff9E9E9E);
  static const Color iconGrey = Color(0xff444047);
  static const Color brandRed = Color(0xffC91C32);
}

extension AppThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get appBackground =>
      isDarkMode ? appColorPaletteController.palette.darkSurface : Colors.white;

  Color get appSurface => isDarkMode ? const Color(0xff1A1A22) : Colors.white;

  Color get appSurfaceAlt =>
      isDarkMode ? const Color(0xff242331) : const Color(0xffF5F0FB);

  Color get appElevatedSurface =>
      isDarkMode ? const Color(0xff202938) : const Color(0xffEAF6FF);

  Color get appTextPrimary =>
      isDarkMode ? const Color(0xffF7F4FC) : Colors.black;

  Color get appTextSecondary =>
      isDarkMode ? const Color(0xffC8C3D1) : AppColors.mutedGrey;

  Color get appIconColor =>
      isDarkMode ? const Color(0xffD8D2E4) : AppColors.iconGrey;

  Color get appBorder =>
      isDarkMode ? const Color(0xff343141) : const Color(0xffEEE7F8);

  Color get appShadow => isDarkMode
      ? Colors.black.withValues(alpha: .34)
      : Colors.black.withValues(alpha: .08);
}
