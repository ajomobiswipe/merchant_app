part of 'sound_box_bloc.dart';

abstract class SoundBoxState extends Equatable {
  final List<String> devices;
  final DioException? error;

  const SoundBoxState({
    this.devices = const [],
    this.error,
  });

  @override
  List<Object?> get props => [
        devices,
        error,
      ];
}

class SoundBoxInitial extends SoundBoxState {}

class SoundBoxLoading extends SoundBoxState {}

class SoundBoxSuccess extends SoundBoxState {
  const SoundBoxSuccess({
    required List<String> devices,
  }) : super(devices: devices);
}

class SoundBoxFailure extends SoundBoxState {
  const SoundBoxFailure({
    required DioException error,
  }) : super(error: error);
}
