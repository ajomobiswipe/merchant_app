import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';
import 'package:anet_merchants/features/transactions/presentation/pages/transaction_filter_data.dart';

class SettlementDetailData {
  final SettlementItemModel settlement;
  final TransactionFilterData filter;

  const SettlementDetailData({
    required this.settlement,
    required this.filter,
  });
}

