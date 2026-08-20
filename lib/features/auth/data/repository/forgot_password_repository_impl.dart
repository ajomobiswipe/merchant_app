import 'dart:io';

import 'package:dio/dio.dart';
import 'package:anet_merchants/core/config/end_points.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/auth/data/models/forgot_password_response_model.dart';
import 'package:anet_merchants/features/auth/domain/repository/forgot_password_repository.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  final Dio dio;

  const ForgotPasswordRepositoryImpl({required this.dio});

  @override
  Future<DataState<ForgotPasswordResponseModel>> requestForgotPassword({
    required String username,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${EndPoints.baseApiPublicNanoUMS}forgotPassword/${Uri.encodeComponent(username)}',
      );

      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return DataSuccess(
            ForgotPasswordResponseModel.fromJson(response.data!));
      }

      return DataFailed(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: response.statusMessage,
          type: DioExceptionType.badResponse,
        ),
      );
    } on DioException catch (error) {
      return DataFailed(error);
    }
  }
}

