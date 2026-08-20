import 'package:anet_merchants/features/shared/presentation/widgets/quick_actions.dart';

class TransactionFilterData {
  final TransactionTab tab;
  final String creditVpa;
  final String from;
  final String to;
  final String dateLabel;
  final String terminalId;
  final String rrn;
  final String authCode;
  final String sourceOfTxn;
  final bool searchedByCode;

  const TransactionFilterData({
    required this.tab,
    this.creditVpa = '',
    this.from = '',
    this.to = '',
    this.dateLabel = '',
    this.terminalId = '',
    this.rrn = '',
    this.authCode = '',
    this.sourceOfTxn = 'ALL',
    this.searchedByCode = false,
  });
}

