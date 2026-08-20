import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/devices/data/models/sound_box_devices_response_model.dart';
import 'package:anet_merchants/features/devices/domain/usecases/get_sound_box_devices.dart';

part 'sound_box_event.dart';
part 'sound_box_state.dart';

class SoundBoxBloc extends Bloc<SoundBoxEvent, SoundBoxState> {
  final GetSoundBoxDevices _getSoundBoxDevices;

  SoundBoxBloc(this._getSoundBoxDevices) : super(SoundBoxInitial()) {
    on<GetSoundBoxDevicesRequested>((event, emit) async {
      emit(SoundBoxLoading());

      try {
        final dataState = await _getSoundBoxDevices(
          params: GetSoundBoxDevicesParams(
            merchantId: event.merchantId,
            bearerToken: event.bearerToken,
            clientUniqueId: event.clientUniqueId,
          ),
        );

        if (dataState is DataSuccess<SoundBoxDevicesResponseModel>) {
          emit(
            SoundBoxSuccess(
              devices: dataState.data?.pageData.content ?? const [],
            ),
          );
          return;
        }

        if (dataState is DataFailed) {
          emit(SoundBoxFailure(error: dataState.error!));
        }
      } on DioException catch (e) {
        emit(SoundBoxFailure(error: e));
      }
    });
  }
}

