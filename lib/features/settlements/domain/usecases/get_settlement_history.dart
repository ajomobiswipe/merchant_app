import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/usecase/usecase.dart';
import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';
import 'package:anet_merchants/features/settlements/domain/repository/settlement_repository.dart';

class GetSettlementHistoryParams {
  final String bearerToken;
  final String merchantId;
  final String fromDate;
  final String toDate;
  final int page;
  final int size;
  final bool sendSettlementReportToMail;

  const GetSettlementHistoryParams({
    required this.bearerToken,
    required this.merchantId,
    required this.fromDate,
    required this.toDate,
    required this.page,
    required this.size,
    this.sendSettlementReportToMail = false,
  });
}

class GetSettlementHistory
    implements
        UseCase<DataState<SettlementHistoryResponseModel>,
            GetSettlementHistoryParams> {
  final SettlementRepository _repository;

  GetSettlementHistory(this._repository);

  @override
  Future<DataState<SettlementHistoryResponseModel>> call({
    required GetSettlementHistoryParams params,
  }) {
    return _repository.getSettlementHistory(
      bearerToken: params.bearerToken,
      merchantId: params.merchantId,
      fromDate: params.fromDate,
      toDate: params.toDate,
      page: params.page,
      size: params.size,
      sendSettlementReportToMail: params.sendSettlementReportToMail,
    );
  }
}

