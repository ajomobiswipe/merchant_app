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
import 'package:anet_merchant_app/presentation/pages/users/merchant/sampledata/sampledata.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'connection.dart';

class MerchantServices {
  late String token;

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

  merchantSelfLogin(requestModel) async {
    Connection connection = Connection();

    var url = "${EndPoints.baseApiPublicNanoUMS}login";

    var response = await connection.postWithOutToken(url, requestModel);

    return response;
  }

  verifyOtp(requestModel) async {
    Connection connection = Connection();

    var url = "${EndPoints.baseApiPublicNanoUMS}ums/verifyEmailOtp";

    var response = await connection.postWithOutToken(url, requestModel);

    return response;
  }

  fetchTransactionHistory(requestModel,
      {required int pageNumber, required int pageSize}) async {
    Connection connection = Connection();

    var url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getPosTxnHistoryReport?page=$pageNumber&size=$pageSize&sort=insertDateTime%2Cdesc";
    // Response response = Response(
    //     getDummyPosTxnHistoryReport(pageNumber: pageNumber, pageSize: pageSize),
    //     200);
    //        await Future.delayed(const Duration(seconds: 2));
    var response = await connection.post(url, requestModel);

    return response;
  }

  getSupportActionData() async {
    Connection connection = Connection();

    var url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getSupportActionData";

    // Response response = Response(getDummyDailySettlementTxnSummary(), 200);
    // await Future.delayed(const Duration(seconds: 2));
    var response = await connection.get(
      url,
    );
    return response;
  }

  raiseSupportRequest(
    requestModel,
  ) async {
    Connection connection = Connection();

    var url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/raiseSupportRequest";

    var response = await connection.post(url, requestModel);
    return response;
  }

  fetchDailySettlementTxnSummary(
    requestModel,
  ) async {
    Connection connection = Connection();

    var url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/dailySettlementTxnSummary";

    // Response response = Response(getDummyDailySettlementTxnSummary(), 200);
    // await Future.delayed(const Duration(seconds: 2));
    var response = await connection.post(url, requestModel);
    return response;
  }

  fetchDailyMerchantTxnSummary(
    requestModel,
  ) async {
    Connection connection = Connection();

    var url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/dailyMerchantTxnSummary";

    var response = await connection.post(url, requestModel);
    return response;
  }

  getSettlementDashboardReport(requestModel,
      {required int pageNumber, required int pageSize}) async {
    Connection connection = Connection();

    var url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getSettlementHistoryReport?page=$pageNumber&size=$pageSize&sort=desc";

    // Response response = Response(getDummySettlementHistoryReport(), 200); //
    // await Future.delayed(const Duration(seconds: 2));
    var response = await connection.post(url, requestModel);
    return response;
  }

  getSettlementHistoryReport(requestModel,
      {required int pageNumber, required int pageSize}) async {
    Connection connection = Connection();

    var url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getSettlementHistoryReport?pageNumber=$pageNumber&size=$pageSize&sort=desc";

    // Response response = Response(getDummySettlementHistoryReport(), 200);
    // await Future.delayed(const Duration(seconds: 2));
    var response = await connection.post(url, requestModel);
    return response;
  }
}
