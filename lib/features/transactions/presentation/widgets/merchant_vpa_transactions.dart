import 'package:flutter/material.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:anet_merchants/features/shared/presentation/widgets/transaction_list_item.dart';
import 'package:go_router/go_router.dart';

class MerchantVpaTransactions extends StatelessWidget {
  final List<MerchantVpaTransactionModel> transactions;
  final bool isLoading;
  final int page;
  final int totalPages;
  final int totalElements;
  final double totalAmount;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;

  const MerchantVpaTransactions({
    super.key,
    required this.transactions,
    required this.isLoading,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.totalAmount,
    this.onPreviousPage,
    this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Text(
            context.tr('no_vpa_transactions'),
            style: AppTextStyle.h3.copyWith(
              color: context.appTextSecondary,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$totalElements ${context.tr('transactions')}',
                style: AppTextStyle.h5.copyWith(
                  color: context.appTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'Rs. ${totalAmount.toStringAsFixed(2)}',
              style: AppTextStyle.h4.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...transactions.map(
          (transaction) => TransactionListItem.fromVpa(
            transaction: transaction,
            cardStyle: true,
            compact: true,
            onInfoPressed: () {
              context.push(AppRoutes.vpaInvoice, extra: transaction);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: isLoading ? null : onPreviousPage,
              icon: const Icon(Icons.chevron_left_rounded),
              color: AppColors.primaryPurple,
              tooltip: context.tr('previous_page'),
            ),
            Text(
              '${context.tr('page')} ${page + 1} ${context.tr('of')} ${totalPages == 0 ? 1 : totalPages}',
              style: AppTextStyle.h5.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            IconButton(
              onPressed: isLoading ? null : onNextPage,
              icon: const Icon(Icons.chevron_right_rounded),
              color: AppColors.primaryPurple,
              tooltip: context.tr('next_page'),
            ),
          ],
        ),
      ],
    );
  }
}

