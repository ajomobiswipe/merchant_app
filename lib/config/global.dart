/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : GLOBAL.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/
// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

// Global Class
class Global {
  // Global function to get unique device id
  static getUniqueId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id;
    }
    return null;
  }

  // Global function to get Device Available Biometrics
  static availableBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    List availableBiometrics = await auth.getAvailableBiometrics();
    return availableBiometrics;
  }

  static authenticate() async {
    LocalAuthentication auth = LocalAuthentication();
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please verify your identity.',
        options:
            const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      //if(kDebugMode)print(e.code);
      if (e.code == auth_error.notEnrolled) {
      } else if (e.code == auth_error.notAvailable) {
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
      } else {}
      return null;
    }
  }
}

// Global function to get theme mode
extension DarkMode on BuildContext {
  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }
}
