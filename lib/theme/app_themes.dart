import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sifr_latest/config/app_color.dart';
import 'package:sifr_latest/theme/app_theme_model.dart';

class AppThemes {
  static ThemeData main({
    bool isDark = false,
    Color primaryColor = AppColors.primary,
  }) {
    return ThemeData(
      fontFamily: "Poppins",
      // brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      textTheme: TextTheme(
          bodySmall: TextStyle(
              color: isDark ? Colors.grey.shade50 : Colors.black54,
              fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(
            color: primaryColor,
          ),
          bodyLarge: TextStyle(
            color: isDark ? Colors.white70 : primaryColor,
          ),
          titleLarge: TextStyle(
            color: isDark ? Colors.white70 : primaryColor,
          ),
          titleSmall: TextStyle(
            color: isDark ? AppColors.white50 : AppColors.blackLight,
          ),
          titleMedium: TextStyle(
            color: isDark ? AppColors.white50 : AppColors.blackLight,
          ),
          displayMedium: TextStyle(
            color: isDark ? AppColors.white50 : AppColors.blackLight,
            // fontSize:
          ),
          displaySmall: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              fontSize: 14)),
      cupertinoOverrideTheme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(), // This is required
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        shape: const RoundedRectangleBorder(),
        textTheme: ButtonTextTheme.accent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 10,
          foregroundColor: Colors.white,
          backgroundColor: primaryColor),
      scaffoldBackgroundColor: isDark ? AppColors.blackLight : AppColors.white,
      // cardColor: isDark ? AppColors.white.withOpacity(0) : AppColors.white,
      cardTheme: CardTheme(
        color: isDark ? AppColors.blackLight : AppColors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: isDark ? Colors.grey : AppColors.white, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      ),
      dividerColor: isDark
          ? AppColors.white.withOpacity(0.2)
          : AppColors.black.withOpacity(0.1),
      shadowColor: isDark ? AppColors.text : AppColors.grayDark,
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 3,
        backgroundColor: primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      colorScheme: ColorScheme.fromSwatch(
              primarySwatch: AppColors.getMaterialColorFromColor(primaryColor))
          .copyWith(
        background: isDark ? AppColors.blackLight : AppColors.gray,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  static List<AppTheme> appThemeOptions = [
    AppTheme(
      mode: ThemeMode.light,
      title: 'Light',
      icon: Icons.brightness_5_rounded,
    ),
    AppTheme(
      mode: ThemeMode.dark,
      title: 'Dark',
      icon: Icons.brightness_2_rounded,
    ),
    AppTheme(
      mode: ThemeMode.system,
      title: 'System',
      icon: Icons.brightness_4_rounded,
    ),
  ];
}
