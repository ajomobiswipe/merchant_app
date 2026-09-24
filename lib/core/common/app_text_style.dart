import 'package:flutter/material.dart';


enum AppPlatform {
  mobile,
  web,
}

class AppTextStyle {

  const AppTextStyle(this.platform);

  final AppPlatform platform;

  static const String _fontFamily = 'Muli';

  TextStyle get h2 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: platform == AppPlatform.web ? 22 : 14,
    fontWeight: FontWeight.w700,
  );

  TextStyle get h3 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: platform == AppPlatform.web ? 16:12,
    fontWeight: FontWeight.w700,
  );

   TextStyle get h4 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: platform == AppPlatform.web ?15:11,
    fontWeight: FontWeight.w600,
  );

   TextStyle get h5 => TextStyle(
    fontFamily: _fontFamily,
    fontSize: platform == AppPlatform.web ?12:8,
    fontWeight: FontWeight.w600,
  );

    TextStyle get h4WhiteColor => TextStyle(
    fontFamily: _fontFamily,
    fontSize: platform == AppPlatform.web ?15:11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

    TextStyle get h5WhiteColor => TextStyle(
    fontFamily: _fontFamily,
    fontSize: platform == AppPlatform.web ?12:8,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
