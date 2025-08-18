import 'dart:convert';

import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/core/endpoints.dart';
import 'package:anet_merchant_app/core/static_functions.dart';
import 'package:anet_merchant_app/data/services/connection.dart';
import 'package:anet_merchant_app/domain/datasources/storage/secure_storage.dart';
import 'package:anet_merchant_app/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class MerchantServices {
  final BoxStorage boxStorage = BoxStorage();

  Future<dynamic> refreshToken() async {
    final token = boxStorage.getToken();
    final url = '${EndPoints.baseApiPublicNanoUMS}refreshToken/$token';

    final response = await DioClient().get(url); // token-based

    if (kDebugMode) print('url ${response.data}');

    if (response.statusCode == 401) {
      NavigationService.navigatorKey.currentState
          ?.pushReplacementNamed('login');
      alertService.error(Constants.unauthorized);
      clearStorage();
      return;
    }

    final decodedData = response.data;
    BoxStorage secureStorage = BoxStorage();
    var user = secureStorage.getUserDetails();
    user['bearerToken'] = decodedData['bearerToken'];
    await secureStorage.saveUserDetails(user);

    if (response.statusCode == 200) {
      return decodedData;
    }
  }

  Future<dynamic> merchantSelfLogin(Map<String, dynamic> requestModel) async {
    final url = "${EndPoints.baseApiPublicNanoUMS}login";
    print(url);
    print(jsonEncode(requestModel));
    return await DioClient().postWithoutToken(url, requestModel);
  }

  Future<dynamic> restPassword(Map<String, dynamic> requestModel) async {
    final url = "${EndPoints.baseApiPublicNanoUMS}ResetPassword";
    return await DioClient().postWithoutToken(url, requestModel);
  }

  Future<dynamic> verifyOtp(Map<String, dynamic> requestModel) async {
    final url = "${EndPoints.baseApiPublicNanoUMS}ums/verifyEmailOtp";
    return await DioClient().postWithoutToken(url, requestModel);
  }

  Future<dynamic> fetchTransactionHistory(Map<String, dynamic> requestModel,
      {required int pageNumber, required int pageSize}) async {
    final url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getPosTxnHistoryReport?page=$pageNumber&size=$pageSize&sort=insertDateTime%2Cdesc";
    return await DioClient().post(url, requestModel);
  }

  Future<Response<dynamic>> fetchVpaTransactionHistory(
      Map<String, dynamic> requestModel,
      {required int pageNumber,
      required int pageSize}) async {
    final url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/merchantVpaTxnData?page=$pageNumber&size=$pageSize&sort=insertDateTime%2Cdesc";
    return await DioClient().post(url, requestModel);
  }

  Future<dynamic> getTidByMerchantId(Map<String, dynamic> requestModel,
      {required int pageNumber,
      required int pageSize,
      required String merchantId}) async {
    final url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getPosTerminalsByMerchantId?page=$pageNumber&size=$pageSize&sort=insertDateTime%2Cdesc&merchantId=$merchantId";
    return await DioClient().post(url, requestModel);
  }

  Future<dynamic> getVpaByMerchantId(Map<String, dynamic> requestModel,
      {required int pageNumber,
      required int pageSize,
      required String merchantId}) async {
    final url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getListOfSoundBoxDevices?pageNumber=$pageNumber&size=$pageSize&sort=insertDateTime%2Cdesc";
    return await DioClient().getWithReqBody(url, requestModel);
  }

  Future<dynamic> getSupportActionData() async {
    final url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getSupportActionData";
    return await DioClient().get(url);
  }

  Future<dynamic> raiseSupportRequest(Map<String, dynamic> requestModel) async {
    final url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/raiseSupportRequest";
    return await DioClient().post(url, requestModel);
  }

  Future<dynamic> fetchDailySettlementTxnSummary(
      Map<String, dynamic> requestModel) async {
    final url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/dailySettlementTxnSummary";
    return await DioClient().post(url, requestModel);
  }

  Future<dynamic> fetchDailyMerchantTxnSummary(
      Map<String, dynamic> requestModel) async {
    final url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/dailyMerchantTxnSummary";
    return await DioClient().post(url, requestModel);
  }

  Future<dynamic> getSettlementDashboardReport(
      Map<String, dynamic> requestModel,
      {required int pageNumber,
      required int pageSize}) async {
    final url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getSettlementHistoryReport?page=$pageNumber&size=$pageSize&sort=desc";
    return await DioClient().post(url, requestModel);
  }

  Future<dynamic> getSettlementHistoryReport(Map<String, dynamic> requestModel,
      {required int pageNumber, required int pageSize}) async {
    final url =
        "${EndPoints.baseApiPublic}/NanoPay/Middleware/UiApi/getSettlementHistoryReport?pageNumber=$pageNumber&size=$pageSize&sort=desc";
    return await DioClient().post(url, requestModel);
  }
}
