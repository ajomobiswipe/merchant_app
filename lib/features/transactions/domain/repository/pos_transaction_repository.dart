import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_terminal_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_txn_history_response_model.dart';

abstract class PosTransactionRepository {
  Future<DataState<PosTerminalResponseModel>> getPosTerminals({
    required String bearerToken,
    required String merchantId,
    required int page,
    required int size,
  });

  Future<DataState<PosTxnHistoryResponseModel>> getPosTransactions({
    required String bearerToken,
    required String clientUniqueId,
    required String merchantId,
    required String acquirerId,
    required int page,
    required int size,
    String? recordFrom,
    String? recordTo,
    String? rrn,
    String? authCode,
    String? terminalId,
    String? sourceOfTxn = 'ALL',
    String? mid,
    String? creditVpa,
    bool useMidEndpoint = false,
    bool sendTxnReportToMail = false,
  });
}

