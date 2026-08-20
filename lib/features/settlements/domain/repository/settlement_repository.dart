import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';

abstract class SettlementRepository {
  Future<DataState<SettlementHistoryResponseModel>> getSettlementHistory({
    required String bearerToken,
    required String merchantId,
    required String fromDate,
    required String toDate,
    required int page,
    required int size,
    bool sendSettlementReportToMail = false,
  });
}

