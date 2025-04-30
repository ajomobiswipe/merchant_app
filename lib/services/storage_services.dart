import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anet_merchant_app/pages/users/enums/user_type_enums.dart';
import 'package:anet_merchant_app/storage/secure_storage.dart';

class StorageServices {
  static Future<void> saveSecureStorage(
    Map<String, dynamic> decodeData, {
    required String userName,
    required String password,
    required UserTypes userTypes,
  }) async {
    switch (userTypes) {
      case UserTypes.salesTeam:
        final dateStr =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        final secureStorage = BoxStorage();

        final role = decodeData['role']?.toString();

        // Secure (Hive) Storage
        secureStorage.saveUserDetails(decodeData, userName: userName);
        secureStorage.save('lastLogin', dateStr);
        secureStorage.save('isLogged', true);

        // Shared Preferences Storage
        final pref = await SharedPreferences.getInstance();
        pref.setString('loggedUserType', userTypes.toString().split('.').last);
        pref.setString('token', decodeData['bearerToken'].toString());
        pref.setString('userName', userName);
        pref.setString('password', password);
        pref.setString('role', role ?? '');
        pref.setString('role', userTypes.toString().split('.').last);
        pref.setString('lastLogin', dateStr);
        pref.setBool('isLogged', true);
        pref.setString('custId', decodeData['custId'].toString());

        break;
      case UserTypes.merchantSelf:
        final dateStr =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        final secureStorage = BoxStorage();

        final role = decodeData['role']?.toString();
        final isMerchant = role == "MERCHANT";

        // Secure (Hive) Storage
        secureStorage.saveUserDetails(decodeData, userName: userName);
        secureStorage.save('lastLogin', dateStr);
        secureStorage.save('isLogged', true);

        // Shared Preferences Storage
        final pref = await SharedPreferences.getInstance();
        pref.setString('loggedUserType', userTypes.toString().split('.').last);
        pref.setString('token', decodeData['bearerToken'].toString());
        pref.setString('userName', userName);
        pref.setString('password', password);
        pref.setString('role', role ?? '');

        pref.setString('lastLogin', dateStr);
        pref.setBool('isLogged', true);
        pref.setString('custId', decodeData['custId'].toString());

        if (isMerchant) {
          pref.setString('merchantId', decodeData['merchantId'].toString());
          pref.setString('terminalId', decodeData['terminalId'].toString());
        }
        break;
    }
  }
}
