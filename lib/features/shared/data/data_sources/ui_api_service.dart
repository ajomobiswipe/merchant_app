import 'package:dio/dio.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_request_model.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:anet_merchants/features/support/data/models/raise_support_request_model.dart';
import 'package:anet_merchants/features/support/data/models/raise_support_response_model.dart';
import 'package:anet_merchants/features/devices/data/models/sound_box_devices_request_model.dart';
import 'package:anet_merchants/features/devices/data/models/sound_box_devices_response_model.dart';
import 'package:anet_merchants/features/support/data/models/support_action_response_model.dart';
import 'package:retrofit/retrofit.dart';

part 'ui_api_service.g.dart';

@RestApi()
abstract class MerchantUiApiService {
  factory MerchantUiApiService(Dio dio, {String baseUrl}) =
      _MerchantUiApiService;

  @GET('getListOfSoundBoxDevices')
  Future<HttpResponse<SoundBoxDevicesResponseModel>> getListOfSoundBoxDevices(
    @Header('Authorization') String authorization,
    @Header('x-client-unique-id') String clientUniqueId,
    @Body() SoundBoxDevicesRequestModel request, {
    @Query('pageNumber') int pageNumber = 0,
    @Query('size') int size = 100,
    @Query('sort') String sort = 'insertDateTime,desc',
  });

  @POST('merchantVpaTxnData')
  Future<HttpResponse<MerchantVpaTxnResponseModel>> getMerchantVpaTxnData(
    @Header('Authorization') String authorization,
    @Body() MerchantVpaTxnRequestModel request, {
    @Header('Accept') String accept = 'application/json, text/plain, */*',
    @Header('Accept-Language')
    String acceptLanguage = 'en-GB,en-US;q=0.9,en;q=0.8',
    @Query('page') int page = 0,
    @Query('size') int size = 10,
    @Query('sortDir') String sortDir = 'DESC',
    @Query('mappedMerchantId') String? mappedMerchantId,
  });

  @GET('getSupportActionData')
  Future<HttpResponse<SupportActionResponseModel>> getSupportActionData(
    @Header('Authorization') String authorization,
  );

  @POST('raiseSupportRequest')
  Future<HttpResponse<RaiseSupportResponseModel>> raiseSupportRequest(
    @Header('Authorization') String authorization,
    @Body() RaiseSupportRequestModel request,
  );
}

