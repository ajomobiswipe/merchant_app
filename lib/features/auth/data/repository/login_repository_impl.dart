import 'dart:io';

import 'package:dio/dio.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/auth/data/data_sources/merchant_login_api_service.dart';
import 'package:anet_merchants/features/auth/data/models/login_request_model.dart';
import 'package:anet_merchants/features/auth/data/models/user_info.dart';
import 'package:anet_merchants/features/auth/domain/repository/merchant_login_repository.dart';

class LoginRepositoryImpl implements MerchantLoginRepository {
  final MerchantLoginApiService apiService;

  LoginRepositoryImpl({required this.apiService});

  @override
  Future<DataState<UserInfoModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      final httpResponse = await apiService.login(
        LoginRequestModel(username: username, password: password),
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
}

