import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/usecase/usecase.dart';
import 'package:anet_merchants/features/devices/data/models/sound_box_devices_response_model.dart';
import 'package:anet_merchants/features/devices/domain/repository/sound_box_repository.dart';

class GetSoundBoxDevicesParams {
  final String merchantId;
  final String bearerToken;
  final String clientUniqueId;

  const GetSoundBoxDevicesParams({
    required this.merchantId,
    required this.bearerToken,
    required this.clientUniqueId,
  });
}

class GetSoundBoxDevices
    implements
        UseCase<DataState<SoundBoxDevicesResponseModel>,
            GetSoundBoxDevicesParams> {
  final SoundBoxRepository _soundBoxRepository;

  GetSoundBoxDevices(this._soundBoxRepository);

  @override
  Future<DataState<SoundBoxDevicesResponseModel>> call({
    required GetSoundBoxDevicesParams params,
  }) {
    return _soundBoxRepository.getSoundBoxDevices(
      merchantId: params.merchantId,
      bearerToken: params.bearerToken,
      clientUniqueId: params.clientUniqueId,
    );
  }
}

