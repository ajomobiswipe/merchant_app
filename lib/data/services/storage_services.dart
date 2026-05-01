import 'dart:convert';

import 'package:anet_merchant_app/domain/datasources/storage/secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServices {
  static Future<void> saveSecureStorage(
    Map<String, dynamic> decodeData, {
    required String userName,
    required String password,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final secureStorage = BoxStorage();

    final role = decodeData['role']?.toString();
    final isTerminalMerchant = role == "TERMINAL USER";
    final isMerchant = role == "MERCHANT" || role == "MERCHANT USER";

    final isDashboardVisible=decodeData['dashboardEnabled'] == "true";

    
    // Secure (Hive) Storage
    secureStorage.saveUserDetails(decodeData, userName: userName);
    secureStorage.save('lastLogin', dateStr);
    secureStorage.save('isLogged', true);

    // Shared Preferences Storage
    final pref = await SharedPreferences.getInstance();
    pref.setString('loggedUserType', "merchantSelf");
    pref.setString('token', decodeData['bearerToken'].toString());
    pref.setString('userName', userName);
    pref.setString('password', password);
    pref.setString('role', role ?? '');

    pref.setString('lastLogin', dateStr);
    pref.setBool('isLogged', true);
    pref.setString('custId', decodeData['custId'].toString());
    pref.setString('shopName', decodeData['shopName'].toString());

    pref.setString('acqMerchantId', decodeData['acqMerchantId'].toString());
    pref.setString('merchantIds', json.encode(decodeData['merchantIds']));
    pref.setString('merchantInfoForDashboard', json.encode(decodeData['merchantInfoForDashboard']));
    pref.setString('merchantId', decodeData['merchantId'].toString());

    pref.setBool('isDashboardVisible', isDashboardVisible);

    if (isTerminalMerchant) {
      String terminalId = isMerchant
          ? decodeData['terminalId']?.toString() ?? ''
          : userName.toString();
      // pref.setString('merchantId', decodeData['merchantId'].toString());
      pref.setString('terminalId', terminalId);
    }
    // if (isMerchant) {

    // pref.setString('terminalId', decodeData['terminalId'].toString());
    // }
  }
}
