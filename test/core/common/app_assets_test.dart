import 'package:flutter/material.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ANET image asset paths point to registered screen assets', () {
    expect(AppAssets.anetLogo, 'assets/screen/anet_logo_black_text.png');
    expect(AppAssets.anetLogoDark, 'assets/screen/anet_logo_white_text.png');
    expect(AppAssets.anetIcon, 'assets/screen/anet_icon.png');
    expect(
      AppAssets.webResetPasswordIllustration,
      'assets/screen/web_reset_password_illustration.png',
    );
    expect(AppAssets.anetLauncherIcon, AppAssets.anetIcon);
    expect(
      AppAssets.anetLogoForBrightness(Brightness.light),
      AppAssets.anetLogo,
    );
    expect(
      AppAssets.anetLogoForBrightness(Brightness.dark),
      AppAssets.anetLogoDark,
    );
  });
}
