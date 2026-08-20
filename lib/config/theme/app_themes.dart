import 'package:flutter/material.dart';
import 'package:anet_merchants/core/common/app_colors.dart';

ThemeData theme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Muli',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: Brightness.light,
    ),
    appBarTheme: appBarTheme(),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: appColorPaletteController.palette.darkSurface,
    fontFamily: 'Muli',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: Brightness.dark,
    ),
    cardColor: const Color(0xff1A1A22),
    dividerColor: const Color(0xff343141),
    appBarTheme: appBarTheme(isDark: true),
  );
}

AppBarTheme appBarTheme({bool isDark = false}) {
  return AppBarTheme(
    backgroundColor:
        isDark ? appColorPaletteController.palette.darkSurface : Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(color: Color(0XFF8B8B8B)),
    titleTextStyle: const TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
  );
}
