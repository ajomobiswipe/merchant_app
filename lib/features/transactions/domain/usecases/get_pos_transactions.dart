import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/usecase/usecase.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_txn_history_response_model.dart';
import 'package:anet_merchants/features/transactions/domain/repository/pos_transaction_repository.dart';

class GetPosTransactionsParams {
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
  final String? sourceOfTxn;
  final String? mid;
  final String? creditVpa;
  final bool useMidEndpoint;
  final bool sendTxnReportToMail;

  const GetPosTransactionsParams({
    required this.bearerToken,
    required this.clientUniqueId,
    required this.merchantId,
    required this.acquirerId,
    required this.page,
    required this.size,
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
}

class GetPosTransactions
    implements
        UseCase<DataState<PosTxnHistoryResponseModel>,
            GetPosTransactionsParams> {
  final PosTransactionRepository _repository;

  GetPosTransactions(this._repository);

  @override
  Future<DataState<PosTxnHistoryResponseModel>> call({
    required GetPosTransactionsParams params,
  }) {
    return _repository.getPosTransactions(
      bearerToken: params.bearerToken,
      clientUniqueId: params.clientUniqueId,
      merchantId: params.merchantId,
      acquirerId: params.acquirerId,
      page: params.page,
      size: params.size,
      recordFrom: params.recordFrom,
      recordTo: params.recordTo,
      rrn: params.rrn,
      authCode: params.authCode,
      terminalId: params.terminalId,
      sourceOfTxn: params.sourceOfTxn,
      mid: params.mid,
      creditVpa: params.creditVpa,
      useMidEndpoint: params.useMidEndpoint,
      sendTxnReportToMail: params.sendTxnReportToMail,
    );
  }
}

