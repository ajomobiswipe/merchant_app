import 'dart:io';

import 'package:dio/dio.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/shared/data/data_sources/ui_api_service.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_request_model.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:anet_merchants/features/transactions/domain/repository/merchant_vpa_txn_repository.dart';

class MerchantVpaTxnRepositoryImpl implements MerchantVpaTxnRepository {
  final MerchantUiApiService apiService;

  MerchantVpaTxnRepositoryImpl({required this.apiService});

  @override
  Future<DataState<MerchantVpaTxnResponseModel>> getMerchantVpaTxnData({
    required String bearerToken,
    required String creditVpa,
    required String from,
    required String to,
    required int page,
    required int size,
    String? mappedMerchantId,
  }) async {
    try {
      final httpResponse = await apiService.getMerchantVpaTxnData(
        _authorizationHeader(bearerToken),
        MerchantVpaTxnRequestModel(
          from: from,
          to: to,
          creditVpa: creditVpa,
        ),
        page: page,
        size: size,
        mappedMerchantId: mappedMerchantId,
      );

      if (httpResponse.response.statusCode == HttpStatus.ok) {
        return DataSuccess(httpResponse.data);
      }

      return DataFailed(
        DioException(
          requestOptions: httpResponse.response.requestOptions,
          response: httpResponse.response,
          error: httpResponse.response.statusMessage,
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

