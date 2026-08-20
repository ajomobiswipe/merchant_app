import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/devices/data/models/sound_box_devices_response_model.dart';

abstract class SoundBoxRepository {
  Future<DataState<SoundBoxDevicesResponseModel>> getSoundBoxDevices({
    required String merchantId,
    required String bearerToken,
    required String clientUniqueId,
  });
}

