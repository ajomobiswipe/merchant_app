/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : APP_COLOR.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';

class AppColors {
  // Primary colors

  // Basic colors
  static const Color white = Color(0xffffffff);
  static const Color white50 = Color(0x88ffffff);
  static const Color black = Color(0xff001424);
  static const Color black50 = Color(0x88001424);
  static const Color blackLight = Color(0xff011f35);

  // Gray shades
  static const Color grayDark = Color(0xffeaeaea);
  static const Color gray = Color(0xfff3f3f3);

  // Text colors
  static const Color text = Color(0xff000000);
  static const Color text50 = Color(0x88000000);

  // Specific use colors
  static const Color transactionRevert = Color(0xffDFF5FF);

  /// Merchant onboarding India colors
  static const Color kLightGreen = Color(0xff00bf63);
  static const Color kBorderColor = Color(0xffbfc1cf);
  // static const Color kRedColor = Color(0xfffe5657);
  static const Color kPrimaryColor = Color(0xffa16ce6);
  // static const Color kSelectedBackgroundColor = Color(0xfffaf5f3);
  static const Color kTileColor = Color(0xFFF0F0F0);
  // static const Color kheadingColor = Color(0xff2a3075);

  // List of primary colors
  // static List<Color> primaryColorOptions = const [
  //   primary,
  //   primaryOption2,
  //   primaryOption3,
  //   primaryOption4,
  //   primaryOption5,
  //   primaryOption6,
  //   primaryOption7,
  //   primaryOption8,
  // ];

  // Get shade color
  static MaterialColor getMaterialColorFromColor(Color color) {
    Map<int, Color> colorShades = {
      50: getShade(color, value: 0.5),
      100: getShade(color, value: 0.4),
      200: getShade(color, value: 0.3),
      300: getShade(color, value: 0.2),
      400: getShade(color, value: 0.1),
      500: color, //Primary value
      600: getShade(color, value: 0.1, darker: true),
      700: getShade(color, value: 0.15, darker: true),
      800: getShade(color, value: 0.2, darker: true),
      900: getShade(color, value: 0.25, darker: true),
    };
    return MaterialColor(color.value, colorShades);
  }

  // Get shade color
  static Color getShade(Color color, {bool darker = false, double value = .1}) {
    assert(value >= 0 && value <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness(
        (darker ? (hsl.lightness - value) : (hsl.lightness + value))
            .clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}
