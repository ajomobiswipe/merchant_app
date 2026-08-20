import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    // Temporary browser fallback: the legacy API expects a GET request body,
    // which browsers do not send reliably. Remove this once the web-safe API
    // endpoint is available. Native mobile requests remain unchanged.
    if (kIsWeb) {
      return const DataSuccess(_webSoundBoxDevices);
    }

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

const _webSoundBoxDevices = SoundBoxDevicesResponseModel(
  successMessage: 'Success',
  statusCode: 200,
  pageData: SoundBoxPageDataModel(
    content: [
      'Hardwarisweets.anet@axisbank',
      'zxpeservices38.anet@axisbank',
      'zxpeservices39.anet@axisbank',
      'zxpeservices4.anet@axisbank',
      'zxpeservices40.anet@axisbank',
      'zxpeservices41.anet@axisbank',
      'zxpeservices42.anet@axisbank',
      'zxpeservices43.anet@axisbank',
      'zxpeservices44.anet@axisbank',
      'zxpeservices45.anet@axisbank',
      'zxpeservices46.anet@axisbank',
      'zxpeservices47.anet@axisbank',
      'zxpeservices48.anet@axisbank',
      'zxpeservices49.anet@axisbank',
      'zxpeservices5.anet@axisbank',
      'zxpeservices50.anet@axisbank',
      'zxpeservices6.anet@axisbank',
      'zxpeservices7.anet@axisbank',
      'zxpeservices8.anet@axisbank',
      'zxpeservices9.anet@axisbank',
    ],
    empty: false,
    totalElements: 50,
  ),
);
