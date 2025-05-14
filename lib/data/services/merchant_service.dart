/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : USER_SERVICE.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

import 'dart:convert';

import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/core/endpoints.dart';
import 'package:anet_merchant_app/core/static_functions.dart';
import 'package:anet_merchant_app/domain/datasources/storage/secure_storage.dart';
import 'package:anet_merchant_app/main.dart';
import 'package:flutter/foundation.dart';


import 'connection.dart';

class MerchantServices {
  late String token;

  merchantSelfLogin(requestModel) async {
    Connection connection = Connection();

    var url = "${EndPoints.baseApiPublicNanoUMS}login";

    var response = await connection.postWithOutToken(url, requestModel);

    return response;
  }

  BoxStorage boxStorage = BoxStorage();
  Future refreshToken() async {
    Connection connection = Connection();
    String token = boxStorage.getToken();
    var url = '${EndPoints.baseApiPublicNanoUMS}refreshToken/$token';

    var response = await connection.get(url, fromRefreshTokenAPI: true);

    if (kDebugMode) print('url ${response.body}');

    var decodedData = jsonDecode(response.body);

    if (response.statusCode == 401) {
      NavigationService.navigatorKey.currentState
          ?.pushReplacementNamed('login');
      alertService.errorToast(Constants.unauthorized);
      clearStorage();
      return;
    }

    BoxStorage secureStorage = BoxStorage();
    await secureStorage.saveUserDetails(decodedData);

    if (response.statusCode == 200) {
      return decodedData;
    }
  }
}
