import 'dart:io';

import 'package:dio/dio.dart';
import 'package:anet_merchants/core/config/end_points.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_terminal_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_txn_history_response_model.dart';
import 'package:anet_merchants/features/transactions/domain/repository/pos_transaction_repository.dart';

class PosTransactionRepositoryImpl implements PosTransactionRepository {
  final Dio dio;

  PosTransactionRepositoryImpl({required this.dio});

  @override
  Future<DataState<PosTerminalResponseModel>> getPosTerminals({
    required String bearerToken,
    required String merchantId,
    required int page,
    required int size,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${EndPoints.uiApiBaseUrl}getPosTerminalsByMerchantId',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': 'insertDateTime,desc',
          'merchantId': merchantId,
        },
        data: const <String, dynamic>{},
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: _authorizationHeader(bearerToken),
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return DataSuccess(PosTerminalResponseModel.fromJson(response.data!));
      }

      return DataFailed(_badResponse(response));
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<PosTxnHistoryResponseModel>> getPosTransactions({
    required String bearerToken,
    required String clientUniqueId,
    required String merchantId,
    required String acquirerId,
    required int page,
    required int size,
    String? recordFrom,
    String? recordTo,
    String? rrn,
    String? authCode,
    String? terminalId,
    String? sourceOfTxn = 'ALL',
    String? mid,
    String? creditVpa,
    bool useMidEndpoint = false,
    bool sendTxnReportToMail = false,
  }) async {
    try {
      final body = <String, dynamic>{
        'merchantId': useMidEndpoint ? '' : merchantId,
        'mid':
            useMidEndpoint ? (mid?.isEmpty == true ? merchantId : mid) : null,
        'recordFrom': recordFrom?.isEmpty == true ? null : recordFrom,
        'recordTo': recordTo?.isEmpty == true ? null : recordTo,
        'acquirerId': acquirerId,
        'rrn': rrn ?? '',
        'authCode': authCode ?? '',
        'sourceOftxn': sourceOfTxn?.isEmpty == true ? null : sourceOfTxn,
        'terminalId': terminalId?.isEmpty == true ? null : terminalId,
        'creditVpa': creditVpa?.isEmpty == true ? null : creditVpa,
        'sendTxnReportToMail': sendTxnReportToMail,
      };
      final path = useMidEndpoint
          ? 'getPosTxnHistoryReportbyMid'
          : 'getPosTxnHistoryReport';

      final response = await dio.post<dynamic>(
        '${EndPoints.uiApiBaseUrl}$path',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': 'insertDateTime,desc',
        },
        data: body,
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: _authorizationHeader(bearerToken),
            'x-client-unique-id': clientUniqueId,
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return DataSuccess(
          PosTxnHistoryResponseModel.fromDynamic(response.data),
        );
      }

      return DataFailed(_badResponse(response));
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  DioException _badResponse(Response<dynamic> response) {
    return DioException(
      requestOptions: response.requestOptions,
      response: response,
      error: response.statusMessage,
      type: DioExceptionType.badResponse,
    );
  }

  String _authorizationHeader(String bearerToken) {
    if (bearerToken.startsWith('Bearer ')) {
      return bearerToken;
    }

    return 'Bearer $bearerToken';
  }
}

