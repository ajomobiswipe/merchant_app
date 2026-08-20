part of 'support_action_bloc.dart';

sealed class SupportActionEvent extends Equatable {
  const SupportActionEvent();

  @override
  List<Object> get props => [];
}

class GetSupportActionDataRequested extends SupportActionEvent {
  final String bearerToken;

  const GetSupportActionDataRequested({
    required this.bearerToken,
  });

  @override
  List<Object> get props => [bearerToken];
}

class RaiseSupportRequestSubmitted extends SupportActionEvent {
  final String bearerToken;
  final String merchantId;
  final String quickActionMessage;

  const RaiseSupportRequestSubmitted({
    required this.bearerToken,
    required this.merchantId,
    required this.quickActionMessage,
  });

  @override
  List<Object> get props => [
        bearerToken,
        merchantId,
        quickActionMessage,
      ];
}
