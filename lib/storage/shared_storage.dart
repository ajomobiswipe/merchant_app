/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : STORAGE.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies
import 'package:shared_preferences/shared_preferences.dart';

// Storage Class to Get Customer Id
class Storage {
  Future<String> getCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerId = prefs.getString('custId').toString();
    return customerId;
  }
}
