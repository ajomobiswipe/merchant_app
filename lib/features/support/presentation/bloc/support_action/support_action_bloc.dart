import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/support/data/models/raise_support_response_model.dart';
import 'package:anet_merchants/features/support/data/models/support_action_response_model.dart';
import 'package:anet_merchants/features/support/domain/usecases/get_support_action_data.dart';
import 'package:anet_merchants/features/support/domain/usecases/raise_support_request.dart';

part 'support_action_event.dart';
part 'support_action_state.dart';

class SupportActionBloc extends Bloc<SupportActionEvent, SupportActionState> {
  final GetSupportActionData _getSupportActionData;
  final RaiseSupportRequest _raiseSupportRequest;

  SupportActionBloc(this._getSupportActionData, this._raiseSupportRequest)
      : super(SupportActionInitial()) {
    on<GetSupportActionDataRequested>((event, emit) async {
      emit(SupportActionLoading(actions: state.actions));

      try {
        final dataState = await _getSupportActionData(
          params: GetSupportActionDataParams(
            bearerToken: event.bearerToken,
          ),
        );

        if (dataState is DataSuccess<SupportActionResponseModel>) {
          emit(
            SupportActionSuccess(
              actions: dataState.data?.data ?? const [],
            ),
          );
          return;
        }

        if (dataState is DataFailed) {
          emit(
            SupportActionFailure(
              error: dataState.error!,
              actions: state.actions,
            ),
          );
        }
      } on DioException catch (e) {
        emit(
          SupportActionFailure(
            error: e,
            actions: state.actions,
          ),
        );
      }
    });

    on<RaiseSupportRequestSubmitted>((event, emit) async {
      emit(SupportRequestSubmitting(actions: state.actions));

      try {
        final dataState = await _raiseSupportRequest(
          params: RaiseSupportRequestParams(
            bearerToken: event.bearerToken,
            merchantId: event.merchantId,
            quickActionMessage: event.quickActionMessage,
          ),
        );

        if (dataState is DataSuccess<RaiseSupportResponseModel>) {
          emit(
            SupportRequestSuccess(
              actions: state.actions,
              response: dataState.data!,
            ),
          );
          return;
        }

        if (dataState is DataFailed) {
          emit(
            SupportActionFailure(
              error: dataState.error!,
              actions: state.actions,
            ),
          );
        }
      } on DioException catch (e) {
        emit(
          SupportActionFailure(
            error: e,
            actions: state.actions,
          ),
        );
      }
    });
  }
}

