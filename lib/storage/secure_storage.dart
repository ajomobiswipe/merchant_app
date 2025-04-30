/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : BOX_STORAGE.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies
import 'package:hive_flutter/hive_flutter.dart';
import 'package:anet_merchant_app/config/constants.dart';

// Box Storage Class to Store User Details
class BoxStorage {
  var box = Hive.box(Constants.hiveName);

  save(key, value) {
    box.put(key, value);
  }

  //Get Details Based on Key
  get(key) {
    return box.get(key);
  }

  //Save User Details
  saveUserDetails(user, {String? userName}) {
    box.put('user', user);
    if (userName != null) box.put('userName', userName);
  }

  //Get User Details
  getUserDetails() {
    return box.get('user');
  }

  getUserName() {
    return box.get('userName');
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

  getFirstNameAndLastName() {
    var user = getUserName();
    if (user == null) return 'Vinay';
    return user;
  }
}
