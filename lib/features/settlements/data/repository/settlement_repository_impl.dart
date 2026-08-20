import 'dart:io';

import 'package:dio/dio.dart';
import 'package:anet_merchants/core/config/end_points.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';
import 'package:anet_merchants/features/settlements/domain/repository/settlement_repository.dart';

class SettlementRepositoryImpl implements SettlementRepository {
  final Dio dio;

  SettlementRepositoryImpl({required this.dio});

  @override
  Future<DataState<SettlementHistoryResponseModel>> getSettlementHistory({
    required String bearerToken,
    required String merchantId,
    required String fromDate,
    required String toDate,
    required int page,
    required int size,
    bool sendSettlementReportToMail = false,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${EndPoints.uiApiBaseUrl}getSettlementHistoryReport',
        queryParameters: {
          'page': page,
          'pageNumber': page,
          'size': size,
          'sort': 'desc',
        },
        data: {
          'merchantId': merchantId,
          'fromDate': fromDate,
          'toDate': toDate,
          'reconciled': true,
          'merPayDone': true,
          'misDone': true,
          'pageDataRequired': true,
          'settlementAggregatesRequired': true,
          'settlementTotalRequired': true,
          'sendSettlementReportToMail': sendSettlementReportToMail,
        },
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: _authorizationHeader(bearerToken),
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return DataSuccess(
          SettlementHistoryResponseModel.fromJson(response.data!),
        );
      }

      return DataFailed(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.statusMessage,
          type: DioExceptionType.badResponse,
        ),
      );
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  String _authorizationHeader(String bearerToken) {
    if (bearerToken.startsWith('Bearer ')) {
      return bearerToken;
    }

    return 'Bearer $bearerToken';
  }
}

