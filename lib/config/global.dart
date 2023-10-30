/* ===============================================================
| Project : SIFR
| Page    : GLOBAL.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/
// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

import 'config.dart';

// Global Class
class Global {
  // Global list to store business type
  static List businessTypeList = [
    {"value": 'Public Limited Company', "label": 'Public Limited Company'},
    {"value": 'Private Limited Company', "label": 'Private Limited Company'},
    {"value": 'Joint-Venture Company', "label": 'Joint-Venture Company'},
    {"value": 'Partnership Firm', "label": 'Partnership Firm'},
    {"value": 'One Person Company', "label": 'One Person Company'},
    {"value": 'Sole Proprietorship', "label": 'Sole Proprietorship'},
    {"value": 'Branch Office', "label": 'Branch Office'},
    {
      "value": 'Non-Government Organization (NGO)',
      "label": 'Non-Government Organization (NGO)'
    },
  ];

  // No data found widget
  static noDataFound(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            Constants.noDataFoundImage,
            height: 250,
          ),
          Text("No $title found!"),
        ],
      ),
    );
  }

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
      print(e.code);
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
