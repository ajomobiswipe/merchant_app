import 'package:flutter/material.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_txn_history_response_model.dart';
import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  final String amount;
  final String status;
  final String dateTimeText;
  final String? detailsText;
  final VoidCallback? onInfoPressed;
  final bool cardStyle;
  final IconData leadingIcon;
  final bool compact;

  const TransactionListItem._({
    super.key,
    required this.amount,
    required this.status,
    required this.dateTimeText,
    this.detailsText,
    this.onInfoPressed,
    this.cardStyle = false,
    this.leadingIcon = Icons.credit_card_rounded,
    this.compact = false,
  });

  factory TransactionListItem.fromVpa({
    Key? key,
    required MerchantVpaTransactionModel transaction,
    VoidCallback? onInfoPressed,
    bool cardStyle = false,
    bool compact = false,
  }) {
    return TransactionListItem._(
      key: key,
      amount: transaction.transactionAmount,
      status: transaction.status,
      dateTimeText: _formatIsoDate(transaction.addedOn),
      onInfoPressed: onInfoPressed,
      cardStyle: cardStyle,
      leadingIcon: Icons.qr_code_2_rounded,
      compact: compact,
    );
  }

  factory TransactionListItem.fromPos({
    Key? key,
    required PosTransactionModel transaction,
    VoidCallback? onInfoPressed,
    bool cardStyle = false,
    bool compact = false,
  }) {
    return TransactionListItem._(
      key: key,
      amount: transaction.amount,
      status: transaction.responseDesc.isEmpty
          ? transaction.responseCode
          : transaction.responseDesc,
      dateTimeText: _formatPosDate(
        transaction.transactionDate,
        transaction.transactionTime,
      ),
      onInfoPressed: onInfoPressed,
      cardStyle: cardStyle,
      compact: compact,
    );
  }

  factory TransactionListItem.fromSettlement({
    Key? key,
    required SettlementItemModel settlement,
    VoidCallback? onInfoPressed,
    bool cardStyle = true,
    bool compact = true,
  }) {
    return TransactionListItem._(
      key: key,
      amount: settlement.totalAmountPayable == 0
          ? settlement.grossTransactionAmount.toStringAsFixed(2)
          : settlement.totalAmountPayable.toStringAsFixed(2),
      status: 'Settled',
      dateTimeText: settlement.tranDate == null
          ? (settlement.utr.isEmpty ? '-' : settlement.utr)
          : DateFormat('d MMM yy').format(settlement.tranDate!),
      detailsText: _settlementDetails(settlement),
      onInfoPressed: onInfoPressed,
      cardStyle: cardStyle,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardBackground =
        cardStyle ? context.appElevatedSurface : Colors.transparent;

    final row = Row(
      children: [
        Container(
          width: compact ? 44 : 58,
          height: compact ? 44 : 58,
          decoration: BoxDecoration(
            color:
                cardStyle ? const Color(0xffEAF4FF) : const Color(0xffB995E3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            leadingIcon,
            color: cardStyle ? const Color(0xff438BF7) : Colors.white,
            size: compact ? 25 : 34,
          ),
        ),
        SizedBox(width: compact ? 10 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formattedAmount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (compact ? AppTextStyle.h4 : AppTextStyle.h3).copyWith(
                  color: context.appTextPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: compact ? 5 : 8),
              Text(
                dateTimeText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (compact ? AppTextStyle.h5 : AppTextStyle.h4).copyWith(
                  color: context.appTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (detailsText != null && detailsText!.isNotEmpty) ...[
                SizedBox(height: compact ? 3 : 6),
                Text(
                  detailsText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.h5.copyWith(
                    color: context.appTextSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: compact ? 6 : 10),
        Container(
          height: compact ? 28 : 38,
          constraints: BoxConstraints(minWidth: compact ? 78 : 112),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.successGreen,
            borderRadius: BorderRadius.circular(22),
          ),
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
          child: Text(
            status.isEmpty ? 'Success' : _titleCase(status),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (compact
                    ? AppTextStyle.h5WhiteColor
                    : AppTextStyle.h4WhiteColor)
                .copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: onInfoPressed,
          icon: const Icon(Icons.info_outline_rounded),
          color: const Color(0xff438BF7),
          iconSize: compact ? 27 : 32,
          constraints: BoxConstraints.tightFor(
            width: compact ? 38 : 48,
            height: compact ? 38 : 48,
          ),
          padding: EdgeInsets.zero,
          tooltip: 'Transaction details',
        ),
      ],
    );

    if (!cardStyle) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: row,
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 8 : 20),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 16,
        vertical: compact ? 10 : 18,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.appShadow,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: row,
    );
  }

  String get _formattedAmount {
    final parsedAmount = double.tryParse(amount) ?? 0;
    return 'Rs. ${parsedAmount.toStringAsFixed(2)}';
  }

  static String _formatIsoDate(String value) {
    final parsedDate = DateTime.tryParse(value);

    if (parsedDate == null) {
      return value.isEmpty ? '-' : value;
    }

    return DateFormat('d MMM yy | h:mm a').format(parsedDate);
  }

  static String _formatPosDate(String date, String time) {
    try {
      final parsedDate = DateFormat('MM/dd/yyyy HH:mm:ss').parse('$date $time');
      return DateFormat('d MMM yy | h:mm a').format(parsedDate);
    } on FormatException {
      return [date, time].where((value) => value.isNotEmpty).join(' | ');
    }
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    final lower = value.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  static String _settlementDetails(SettlementItemModel settlement) {
    final rrn = settlement.rrn.trim().isEmpty ? 'N/A' : settlement.rrn;
    final appCode =
        settlement.approveCode.trim().isEmpty ? 'N/A' : settlement.approveCode;
    return 'RRN: $rrn | App Code: $appCode';
  }
}

