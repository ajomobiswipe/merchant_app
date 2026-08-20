import 'dart:io';

import 'package:dio/dio.dart';
import 'package:anet_merchants/core/config/end_points.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/auth/data/models/otp_validation_response_model.dart';
import 'package:anet_merchants/features/auth/domain/repository/otp_validation_repository.dart';

class OtpValidationRepositoryImpl implements OtpValidationRepository {
  final Dio dio;

  const OtpValidationRepositoryImpl({required this.dio});

  @override
  Future<DataState<OtpValidationResponseModel>> verifyEmailOtp({
    required String username,
    required String otp,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${EndPoints.baseApiPublicNanoUMS}ums/verifyEmailOtp',
        data: {
          'userName': username,
          'otp': otp,
        },
      );

      if (response.statusCode == HttpStatus.ok && response.data != null) {
        return DataSuccess(
          OtpValidationResponseModel.fromJson(response.data!),
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
    } on DioException catch (error) {
      return DataFailed(error);
    }
  }
}

