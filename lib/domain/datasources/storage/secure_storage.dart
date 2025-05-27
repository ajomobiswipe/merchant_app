/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : BOX_STORAGE.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    return '''eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ7XCJpbnN0SWRcIjpcIkFESUJPTUEwMDAxXCIsXCJ1c2VyTmFtZVwiOlwiYXVzb2Z0cG9zYWRtaW5cIixcInJvbGVcIjpcInNvZnRwb3NhZG1pblwiLFwiYXNzaWduZWRSb2xlSWRcIjoyLFwicHJvZHVjdElkXCI6NixcImRldmljZVR5cGVcIjpcIldFQlwiLFwiYXBwbGljYXRpb25BY2Nlc3NcIjpudWxsLFwiZXhwaXJhdGlvblRpbWVcIjoxODAwMDAsXCJtb2JpbGVDb3VudHJ5Q29kZVwiOm51bGwsXCJtb2JpbGVOdW1iZXJcIjpcIjUwMzE0NTYxMlwiLFwiZW1haWxJZFwiOlwidHJpa2VzaC5yQG9tYWVtaXJhdGVzLmNvbVwiLFwiY3VzdElkXCI6XCIzXCIsXCJ3YWxsZXRJZFwiOm51bGwsXCJjYXJkUmVmZXJlbmNlTnVtYmVyXCI6bnVsbCxcImRldmljZUlkXCI6bnVsbCxcIm5vdGlmaWNhdGlvblRva2VuXCI6bnVsbCxcIm1lcmNoYW50SWRcIjpudWxsLFwiY2lkXCI6bnVsbH0iLCJleHAiOjE3NDc5OTkxNjcsImlhdCI6MTc0NzgxOTE2N30.a1VKM_1opbW4L13USt_Gx1ji09noAiIxpZ-dwPFU1CHF5fVIOASPNm3-Lqs91pgu1lALbnyZFP78eF-Xnj0RjAVoURUYDRAEEIRGSqTT0pjt6h3IRPfV3GQm_-YXz2aI963by1TE6I8La6x_Y4bSHJhs_UxIKXJOZdE-E7-FMkujNNQJC9puwIJwwnQ_TaQoDUO9HnD9TvopWIQH-Kf-cJjO427b_Yyqop9nZRm_By2mFmS_9VxELrkMsZ2BUUzwCTb2-AjGMYZXaUyhlz2rQcnmk0W2MPnEVu9OfGvd1zx8heR7JW7jX4NYNXBteIRl7MwLpAcysBefBismHx9rbQ''';
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
