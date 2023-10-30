/* ===============================================================
| Project : SIFR
| Page    : BOX_STORAGE.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies
import 'package:hive_flutter/hive_flutter.dart';

// Box Storage Class to Store User Details
class BoxStorage {
  var box = Hive.box('SIFR_USER_CONTROLS');

  save(key, value) {
    box.put(key, value);
  }

  //Get Details Based on Key
  get(key) {
    return box.get(key);
  }

  //Save User Details
  saveUserDetails(user) {
    box.put('user', user);
  }

  //Get User Details
  getUserDetails() {
    return box.get('user');
  }

  //Get User Name
  getUsername() {
    var user = getUserDetails();
    return user['userName'].toString();
  }

  //Get Customer Id
  getCustomerId() {
    var user = getUserDetails();
    return user['custId'].toString();
  }

  //Get Role
  getRole() {
    var user = getUserDetails();
    return user['role'].toString();
  }

  //Get Token
  getToken() {
    var user = getUserDetails();
    return user['bearerToken'].toString();
  }

  //Get Merchant Id
  getMerchantId() {
    var user = getUserDetails();
    return user['merchantId'].toString();
  }

  //Get Terminal Id
  getTerminalId() {
    var user = getUserDetails();
    return user['terminalId'].toString();
  }

  //Get Kyc Alert
  getKycAlert() {
    var user = getUserDetails();
    return user['kycExpiryAlertMsg'].toString();
  }

  //Get Notification Token
  getNotificationToken() {
    var user = getUserDetails();
    return user['notificationToken'].toString();
  }

  //Set Notification Token
  setNotificationToken(token) {
    var user = getUserDetails();
    box.put(user['notificationToken'], token);
  }
}
