part of 'sound_box_bloc.dart';

sealed class SoundBoxEvent extends Equatable {
  const SoundBoxEvent();

  @override
  List<Object> get props => [];
}

class ResetSoundBoxRequested extends SoundBoxEvent {
  const ResetSoundBoxRequested();
}

class GetSoundBoxDevicesRequested extends SoundBoxEvent {
  final String merchantId;
  final String bearerToken;
  final String clientUniqueId;

  const GetSoundBoxDevicesRequested({
    required this.merchantId,
    required this.bearerToken,
    required this.clientUniqueId,
  });

  @override
  List<Object> get props => [
        merchantId,
        bearerToken,
        clientUniqueId,
      ];
}
