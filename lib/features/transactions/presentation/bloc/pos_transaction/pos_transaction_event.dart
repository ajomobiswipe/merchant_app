part of 'pos_transaction_bloc.dart';

sealed class PosTransactionEvent extends Equatable {
  const PosTransactionEvent();

  @override
  List<Object?> get props => [];
}

class GetPosTerminalsRequested extends PosTransactionEvent {
  final String bearerToken;
  final String merchantId;
  final int page;
  final int size;

  const GetPosTerminalsRequested({
    required this.bearerToken,
    required this.merchantId,
    this.page = 0,
    this.size = 10,
  });

  @override
  List<Object?> get props => [bearerToken, merchantId, page, size];
}

class GetPosTransactionsRequested extends PosTransactionEvent {
  final String bearerToken;
  final String clientUniqueId;
  final String merchantId;
  final String acquirerId;
  final int page;
  final int size;
  final String? recordFrom;
  final String? recordTo;
  final String? rrn;
  final String? authCode;
  final String? terminalId;
  final String sourceOfTxn;
  final String? mid;
  final String? creditVpa;
  final bool useMidEndpoint;
  final bool sendTxnReportToMail;

  const GetPosTransactionsRequested({
    required this.bearerToken,
    required this.clientUniqueId,
    required this.merchantId,
    required this.acquirerId,
    required this.page,
    this.size = 10,
    this.recordFrom,
    this.recordTo,
    this.rrn,
    this.authCode,
    this.terminalId,
    this.sourceOfTxn = 'ALL',
    this.mid,
    this.creditVpa,
    this.useMidEndpoint = false,
    this.sendTxnReportToMail = false,
  });

  @override
  List<Object?> get props => [
        bearerToken,
        clientUniqueId,
        merchantId,
        acquirerId,
        page,
        size,
        recordFrom,
        recordTo,
        rrn,
        authCode,
        terminalId,
        sourceOfTxn,
        mid,
        creditVpa,
        useMidEndpoint,
        sendTxnReportToMail,
      ];
}
