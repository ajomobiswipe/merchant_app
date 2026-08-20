import 'dart:io';

import 'package:dio/dio.dart';
import 'package:anet_merchants/core/config/end_points.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/auth/data/models/password_reset_response_model.dart';
import 'package:anet_merchants/features/auth/domain/repository/password_reset_repository.dart';

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  final Dio dio;

  PasswordResetRepositoryImpl({required this.dio});

  @override
  Future<DataState<PasswordResetResponseModel>> resetPassword({
    required String username,
    required String currentPassword,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${EndPoints.baseApiPublicNanoUMS}ResetPassword',
        data: {
          'userName': username,
          'currentPassword': currentPassword,
          'password': password,
          'confirmPassword': confirmPassword,
          'type': 'resetCurrentPassword',
        },
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return DataSuccess(
          PasswordResetResponseModel.fromJson(response.data!),
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
}

