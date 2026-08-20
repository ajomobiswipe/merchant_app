import 'package:flutter/material.dart';

class AppAssets {
  const AppAssets._();

  static const String anetLogo = 'assets/screen/anet_logo_black_text.png';
  static const String anetLogoDark = 'assets/screen/anet_logo_white_text.png';
  static const String anetIcon = 'assets/screen/anet_icon.png';
  static const String webLoginIllustration =
      'assets/screen/web_login_illustration.png';
  static const String loginMerchantHero =
      'assets/screen/login_merchant_hero.png';
  static const String webPromoSecurity = 'assets/screen/web_promo_security.png';
  static const String webPromoDashboard =
      'assets/screen/web_promo_dashboard.png';
  static const String webForgotPasswordIllustration =
      'assets/screen/web_forgot_password_illustration.png';
  static const String webResetPasswordIllustration =
      'assets/screen/web_reset_password_illustration.png';
  static const String anetLauncherIcon = anetIcon;

  static String anetLogoForBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? anetLogoDark : anetLogo;
  }
}
