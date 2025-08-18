/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : STATIC_FUNCTIONS.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global function to clear shared preferences
clearStorage() async {
  await Hive.box(Constants.hiveName).clear();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('isLogged');
  prefs.remove('lastLogin');

  if (prefs.getBool('rememberMe') == null) {
    prefs.clear();
  } else {
    if (!(prefs.getBool('rememberMe')!)) {
      prefs.clear();
    }
  }
}
