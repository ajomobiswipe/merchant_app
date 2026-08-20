part of 'support_action_bloc.dart';

abstract class SupportActionState extends Equatable {
  final List<SupportActionModel> actions;
  final DioException? error;
  final RaiseSupportResponseModel? raiseSupportResponse;

  const SupportActionState({
    this.actions = const [],
    this.error,
    this.raiseSupportResponse,
  });

  @override
  List<Object?> get props => [actions, error, raiseSupportResponse];
}

class SupportActionInitial extends SupportActionState {}

class SupportActionLoading extends SupportActionState {
  const SupportActionLoading({super.actions});
}

class SupportActionSuccess extends SupportActionState {
  const SupportActionSuccess({
    required List<SupportActionModel> actions,
  }) : super(actions: actions);
}

class SupportActionFailure extends SupportActionState {
  const SupportActionFailure({
    required DioException error,
    super.actions,
  }) : super(error: error);
}

class SupportRequestSubmitting extends SupportActionState {
  const SupportRequestSubmitting({super.actions});
}

class SupportRequestSuccess extends SupportActionState {
  const SupportRequestSuccess({
    required List<SupportActionModel> actions,
    required RaiseSupportResponseModel response,
  }) : super(
          actions: actions,
          raiseSupportResponse: response,
        );
}
