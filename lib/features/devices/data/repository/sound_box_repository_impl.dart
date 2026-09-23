import 'dart:io';

import 'package:dio/dio.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/shared/data/data_sources/ui_api_service.dart';
import 'package:anet_merchants/features/devices/data/models/sound_box_devices_request_model.dart';
import 'package:anet_merchants/features/devices/data/models/sound_box_devices_response_model.dart';
import 'package:anet_merchants/features/devices/domain/repository/sound_box_repository.dart';

class SoundBoxRepositoryImpl implements SoundBoxRepository {
  final MerchantUiApiService apiService;

  SoundBoxRepositoryImpl({required this.apiService});

  @override
  Future<DataState<SoundBoxDevicesResponseModel>> getSoundBoxDevices({
    required String merchantId,
    required String bearerToken,
    required String clientUniqueId,
  }) async {
    try {
      final httpResponse = await apiService.getListOfSoundBoxDevices(
        _authorizationHeader(bearerToken),
        clientUniqueId,
        SoundBoxDevicesRequestModel(merchantId: merchantId),
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
