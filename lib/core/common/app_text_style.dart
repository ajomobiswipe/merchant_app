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

  /// Compact sizes read on iOS. The same sizes are too small on Android,
  /// so Android keeps the sizes from before that scale.
  double _size({
    required double web,
    required double compact,
    required double android,
  }) {
    if (platform == AppPlatform.web) return web;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    return compact;
  }

  TextStyle get h2 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 22, compact: 14, android: 22),
        fontWeight: FontWeight.w700,
      );

  TextStyle get h3 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 16, compact: 12, android: 16),
        fontWeight: FontWeight.w700,
      );

  TextStyle get h4 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 15, compact: 11, android: 15),
        fontWeight: FontWeight.w600,
      );

  TextStyle get h5 => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 12, compact: 8, android: 12),
        fontWeight: FontWeight.w600,
      );

  TextStyle get h4WhiteColor => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 15, compact: 11, android: 15),
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  TextStyle get h5WhiteColor => TextStyle(
        fontFamily: _fontFamily,
        fontSize: _size(web: 12, compact: 8, android: 12),
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
}
