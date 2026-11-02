import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum AppPlatform {
  mobile,
  web,
}

class AppTextStyle {
  const AppTextStyle(this.platform);

  final AppPlatform platform;

  static const String _fontFamily = 'Muli';

  /// Native iOS has its own scale. The compact sizes were too small there.
  /// Android keeps the pre-compact sizes. Narrow web still uses compact.
  double _size({
    required double web,
    required double ios,
    required double android,
    required double compact,
  }) {
    if (platform == AppPlatform.web) return web;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    return compact;
  }

  TextStyle get h2 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 22, ios: 18, android: 22, compact: 14),
        fontWeight: FontWeight.w700,
      );

  TextStyle get h3 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 16, ios: 14, android: 16, compact: 12),
        fontWeight: FontWeight.w700,
      );

  TextStyle get h4 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 15, ios: 13, android: 15, compact: 11),
        fontWeight: FontWeight.w600,
      );

  TextStyle get h5 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 12, ios: 11, android: 12, compact: 8),
        fontWeight: FontWeight.w600,
      );

  TextStyle get h4WhiteColor => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 15, ios: 13, android: 15, compact: 11),
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  TextStyle get h5WhiteColor => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 12, ios: 11, android: 12, compact: 8),
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
}
