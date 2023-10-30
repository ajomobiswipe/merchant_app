/* ===============================================================
| Project : SIFR
| Page    : STORAGE.DART
| Date    : 22-MAR-2023
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
