import 'dart:io';

import 'package:dio/dio.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/shared/data/data_sources/ui_api_service.dart';
import 'package:anet_merchants/features/support/data/models/raise_support_request_model.dart';
import 'package:anet_merchants/features/support/data/models/raise_support_response_model.dart';
import 'package:anet_merchants/features/support/data/models/support_action_response_model.dart';
import 'package:anet_merchants/features/support/domain/repository/support_action_repository.dart';

class SupportActionRepositoryImpl implements SupportActionRepository {
  final MerchantUiApiService apiService;

  SupportActionRepositoryImpl({required this.apiService});

  @override
  Future<DataState<SupportActionResponseModel>> getSupportActionData({
    required String bearerToken,
  }) async {
    try {
      final httpResponse = await apiService.getSupportActionData(
        _authorizationHeader(bearerToken),
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

  @override
  Future<DataState<RaiseSupportResponseModel>> raiseSupportRequest({
    required String bearerToken,
    required String merchantId,
    required String quickActionMessage,
  }) async {
    try {
      final httpResponse = await apiService.raiseSupportRequest(
        _authorizationHeader(bearerToken),
        RaiseSupportRequestModel(
          merchantId: merchantId,
          quickActionMessage: quickActionMessage,
        ),
      );

      if (httpResponse.response.statusCode == HttpStatus.ok ||
          httpResponse.response.statusCode == HttpStatus.created) {
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

