part of 'settlement_bloc.dart';

sealed class SettlementEvent extends Equatable {
  const SettlementEvent();

  @override
  List<Object?> get props => [];
}

class ResetSettlementRequested extends SettlementEvent {
  const ResetSettlementRequested();
}

class GetSettlementHistoryRequested extends SettlementEvent {
  final String bearerToken;
  final String merchantId;
  final String fromDate;
  final String toDate;
  final int page;
  final int size;
  final bool sendSettlementReportToMail;

  const GetSettlementHistoryRequested({
    required this.bearerToken,
    required this.merchantId,
    required this.fromDate,
    required this.toDate,
    required this.page,
    this.size = 10,
    this.sendSettlementReportToMail = false,
  });

  @override
  List<Object?> get props => [
        bearerToken,
        merchantId,
        fromDate,
        toDate,
        page,
        size,
        sendSettlementReportToMail,
      ];
}
