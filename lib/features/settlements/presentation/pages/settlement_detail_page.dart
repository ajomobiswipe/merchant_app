import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/common/common_scaffold.dart';
import 'package:anet_merchants/core/di/injection_container.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/services/alert_service.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/logout_helper.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';
import 'package:anet_merchants/core/widgets/loading_action_content.dart';
import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';
import 'package:anet_merchants/features/settlements/domain/usecases/get_settlement_history.dart';
import 'package:anet_merchants/features/settlements/presentation/bloc/settlement/settlement_bloc.dart';
import 'package:anet_merchants/features/settlements/presentation/pages/settlement_navigation_data.dart';
import 'package:anet_merchants/features/shared/presentation/widgets/merchant_overview.dart';
import 'package:anet_merchants/features/shared/presentation/widgets/transaction_list_item.dart';

class SettlementDetailPage extends StatefulWidget {
  final SettlementDetailData data;

  const SettlementDetailPage({
    super.key,
    required this.data,
  });

  @override
  State<SettlementDetailPage> createState() => _SettlementDetailPageState();
}

class _SettlementDetailPageState extends State<SettlementDetailPage> {
  static const int _pageSize = 10;
  final SessionStorage _sessionStorage = SessionStorage();

  bool _showDeductions = true;
  String _bearerToken = '';
  String _merchantId = '';
  String _acqMerchantId = '';
  bool _isSendingEmail = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions(page: 0);
  }

  Future<void> _loadTransactions({
    required int page,
    int? size,
    bool sendSettlementReportToMail = false,
  }) async {
    final bearerToken =
        _bearerToken.isEmpty ? await _sessionStorage.bearerToken : _bearerToken;
    final merchantId =
        _merchantId.isEmpty ? await _sessionStorage.merchantId : _merchantId;
    final acqMerchantId = _acqMerchantId.isEmpty
        ? await _sessionStorage.activeAcqMerchantId
        : _acqMerchantId;
    final settlementMerchantId = acqMerchantId.isEmpty || acqMerchantId == '0'
        ? merchantId
        : acqMerchantId;
    final settlementDate = _apiDate(widget.data.settlement.tranDate);

    if (!mounted ||
        bearerToken.isEmpty ||
        settlementMerchantId.isEmpty ||
        settlementDate.isEmpty) {
      return;
    }

    _bearerToken = bearerToken;
    _merchantId = merchantId;
    _acqMerchantId = acqMerchantId;

    context.read<SettlementBloc>().add(
          GetSettlementHistoryRequested(
            bearerToken: bearerToken,
            merchantId: settlementMerchantId,
            fromDate: settlementDate,
            toDate: settlementDate,
            page: page,
            size: size ?? _pageSize,
            sendSettlementReportToMail: sendSettlementReportToMail,
          ),
        );
  }

  void _onBottomNavItemSelected(int index) {
    if (index == 3) {
      NavigationHelper.goToRoot(context, AppRoutes.profile);
      return;
    }
    NavigationHelper.goHomeAndClearStack(context, AppRoutes.home);
  }

  Future<void> _sendSettlementReportToEmail() async {
    if (_isSendingEmail) return;

    setState(() => _isSendingEmail = true);

    try {
      final bearerToken = _bearerToken.isEmpty
          ? await _sessionStorage.bearerToken
          : _bearerToken;
      final merchantId =
          _merchantId.isEmpty ? await _sessionStorage.merchantId : _merchantId;
      final acqMerchantId = _acqMerchantId.isEmpty
          ? await _sessionStorage.activeAcqMerchantId
          : _acqMerchantId;
      final settlementMerchantId = acqMerchantId.isEmpty || acqMerchantId == '0'
          ? merchantId
          : acqMerchantId;
      final settlementDate = _apiDate(widget.data.settlement.tranDate);
      if (!mounted) return;

      // This page represents one settlement date. Its aggregate response
      // supplies the exact transaction count for that date, whereas the
      // bloc's totalElements describes the paginated detail response.
      final selectedSettlementCount = widget.data.settlement.transactionCount;
      final loadedTransactionCount =
          context.read<SettlementBloc>().state.totalElements;
      final requestedSize = selectedSettlementCount > 0
          ? selectedSettlementCount
          : loadedTransactionCount;

      if (bearerToken.isEmpty ||
          settlementMerchantId.isEmpty ||
          settlementDate.isEmpty ||
          requestedSize <= 0) {
        await AlertService.warning(
          context,
          title: context.tr('alert'),
          message: context.tr('no_transactions_to_send'),
        );
        return;
      }

      final result = await sl<GetSettlementHistory>()(
        params: GetSettlementHistoryParams(
          bearerToken: bearerToken,
          merchantId: settlementMerchantId,
          fromDate: settlementDate,
          toDate: settlementDate,
          page: 0,
          size: requestedSize,
          sendSettlementReportToMail: true,
        ),
      );

      if (!mounted) return;

      if (result is DataSuccess<SettlementHistoryResponseModel>) {
        final mailResponse = result.data!.sendMailResponse;
        final message = mailResponse.responseMessage.isEmpty
            ? context.tr('email_report_sent')
            : mailResponse.responseMessage;

        if (mailResponse.hasMessage && !mailResponse.isSuccess) {
          await AlertService.error(
            context,
            title: context.tr('error'),
            message: message,
          );
        } else {
          await AlertService.success(
            context,
            title: context.tr('success'),
            message: message,
          );
        }
      } else {
        await AlertService.error(
          context,
          title: context.tr('error'),
          message: result.error?.message ?? context.tr('email_report_failed'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingEmail = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settlement = widget.data.settlement;

    return CommonScaffold(
      selectedIndex: 0,
      onBottomNavItemSelected: _onBottomNavItemSelected,
      bottomAction: _EmailButton(
        onPressed: _isSendingEmail ? null : _sendSettlementReportToEmail,
        isLoading: _isSendingEmail,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (kIsWeb) ...[
              TextButton.icon(
                onPressed: () => NavigationHelper.backOrGo(
                  context,
                  AppRoutes.home,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(context.tr('back')),
                style: TextButton.styleFrom(
                  foregroundColor: context.appTextPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 10,
                  ),
                  textStyle: AppTextStyle.h4.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (!kIsWeb) ...[
              const _SettlementDetailHeader(),
              const SizedBox(height: 30),
              const MerchantOverview(),
              const SizedBox(height: 18),
            ],
            _SettlementHeroCard(settlement: settlement),
            const SizedBox(height: 18),
            _BreakdownCard(
              settlement: settlement,
              showDeductions: _showDeductions,
              onToggle: () {
                setState(() {
                  _showDeductions = !_showDeductions;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('transaction_activity'),
              style: AppTextStyle.h3.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 46,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),
            _buildTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions() {
    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        if (state.isLoading && state.settledTransactions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            ),
          );
        }

        if (state.settledTransactions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                context.tr('no_transactions'),
                style: AppTextStyle.h4.copyWith(
                  color: context.appTextSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }

        if (kIsWeb) {
          final pageSize = state.size > 0 ? state.size : _pageSize;
          final countedPages = widget.data.settlement.transactionCount > 0
              ? (widget.data.settlement.transactionCount / pageSize)
                  .ceil()
              : 0;
          final totalPages = [
            state.transactionTotalPages,
            countedPages,
            state.settledTransactions.isEmpty ? 0 : 1,
          ].reduce((a, b) => a > b ? a : b);
          final page = state.transactionPage;
          final canGoPrevious = page > 0;
          final canGoNext = totalPages == 0 ? false : page < totalPages - 1;

          return Column(
            children: [
              _WebSettlementActivityTable(
                transactions: state.settledTransactions,
                onTransactionSelected: (transaction) => context.push(
                  AppRoutes.settlementInvoice,
                  extra: transaction,
                ),
              ),
              _SettlementActivityPagination(
                page: page,
                totalPages: totalPages,
                isLoading: state.isLoading,
                canGoPrevious: canGoPrevious,
                canGoNext: canGoNext,
                onPrevious: () => _loadTransactions(page: page - 1),
                onNext: () => _loadTransactions(page: page + 1),
              ),
            ],
          );
        }

        return Column(
          children: [
            ...state.settledTransactions.map(
              (transaction) => TransactionListItem.fromSettlement(
                settlement: transaction,
                onInfoPressed: () {
                  context.push(AppRoutes.settlementInvoice, extra: transaction);
                },
              ),
            ),
            if (widget.data.settlement.transactionCount >
                state.settledTransactions.length)
              TextButton.icon(
                onPressed: () {
                  _loadTransactions(
                    page: 0,
                    size: widget.data.settlement.transactionCount,
                  );
                },
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                label: Text(
                  '${context.tr('view_all_transactions')} (${widget.data.settlement.transactionCount})',
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Browser-only history table. Values are deliberately sourced from the
/// settlement invoice model, so the list and the invoice show the same facts.
class _SettlementActivityPagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final bool isLoading;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _SettlementActivityPagination({
    required this.page,
    required this.totalPages,
    required this.isLoading,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: isLoading || !canGoPrevious ? null : onPrevious,
              icon: const Icon(Icons.chevron_left_rounded),
              label: Text(context.tr('previous_page')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                '${context.tr('page')} ${page + 1} ${context.tr('of')} ${totalPages == 0 ? 1 : totalPages}',
                style: AppTextStyle.h5.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            OutlinedButton.icon(
              onPressed: isLoading || !canGoNext ? null : onNext,
              icon: const Icon(Icons.chevron_right_rounded),
              label: Text(context.tr('next_page')),
            ),
          ],
        ),
      );
}

class _WebSettlementActivityTable extends StatelessWidget {
  final List<SettlementItemModel> transactions;
  final ValueChanged<SettlementItemModel> onTransactionSelected;

  const _WebSettlementActivityTable({
    required this.transactions,
    required this.onTransactionSelected,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appBorder),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth < 1060 ? 1060 : constraints.maxWidth,
              child: Column(
                children: [
                  const _WebSettlementActivityTableHeader(),
                  for (final transaction in transactions)
                    _WebSettlementActivityRow(
                      transaction: transaction,
                      onTap: () => onTransactionSelected(transaction),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _WebSettlementActivityTableHeader extends StatelessWidget {
  const _WebSettlementActivityTableHeader();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? context.appElevatedSurface
              : AppColors.primaryPurple.withValues(alpha: .10),
          border: Border(bottom: BorderSide(color: context.appBorder)),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 14,
                child: _WebActivityColumnLabel(context.tr('amount'))),
            Expanded(
                flex: 17, child: _WebActivityColumnLabel(context.tr('date'))),
            Expanded(
                flex: 18, child: _WebActivityColumnLabel(context.tr('rrn'))),
            Expanded(
              flex: 18,
              child: _WebActivityColumnLabel(context.tr('approval_code')),
            ),
            Expanded(
                flex: 15, child: _WebActivityColumnLabel(context.tr('mid'))),
            Expanded(
                flex: 18, child: _WebActivityColumnLabel(context.tr('utr'))),
            SizedBox(
                width: 104,
                child: _WebActivityColumnLabel(context.tr('status'))),
            const SizedBox(width: 32),
          ],
        ),
      );
}

class _WebActivityColumnLabel extends StatelessWidget {
  final String label;

  const _WebActivityColumnLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.h5.copyWith(
          color: context.appTextSecondary,
          fontWeight: FontWeight.w900,
        ),
      );
}

class _WebSettlementActivityRow extends StatelessWidget {
  final SettlementItemModel transaction;
  final VoidCallback onTap;

  const _WebSettlementActivityRow({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSettled = transaction.isSettledStatus;
    final amount = transaction.totalAmountPayable == 0
        ? transaction.grossTransactionAmount
        : transaction.totalAmountPayable;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.appBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 14,
                child: _WebActivityCell(
                  'Rs. ${amount.toStringAsFixed(2)}',
                  bold: true,
                ),
              ),
              Expanded(
                flex: 17,
                child: _WebActivityCell(_displayDate(transaction.tranDate)),
              ),
              Expanded(
                flex: 18,
                child: _WebActivityCell(_valueOrDash(transaction.rrn)),
              ),
              Expanded(
                flex: 18,
                child: _WebActivityCell(_valueOrDash(transaction.approveCode)),
              ),
              Expanded(
                flex: 15,
                child: _WebActivityCell(_valueOrDash(transaction.mid)),
              ),
              Expanded(
                flex: 18,
                child: _WebActivityCell(_valueOrDash(transaction.utr)),
              ),
              SizedBox(
                width: 104,
                child: _WebSettlementStatusBadge(isSettled: isSettled),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryPurple,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebActivityCell extends StatelessWidget {
  final String value;
  final bool bold;

  const _WebActivityCell(this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) => Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.h5.copyWith(
          color: context.appTextPrimary,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
        ),
      );
}

class _WebSettlementStatusBadge extends StatelessWidget {
  final bool isSettled;

  const _WebSettlementStatusBadge({required this.isSettled});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSettled ? const Color(0xffE8F8ED) : const Color(0xffFFF6DF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          isSettled
              ? context.tr('settled')
              : context.tr('pending_settlements'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyle.h5.copyWith(
            color:
                isSettled ? const Color(0xff18A957) : const Color(0xffA66D00),
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

class _SettlementHeroCard extends StatelessWidget {
  final SettlementItemModel settlement;

  const _SettlementHeroCard({required this.settlement});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff079447),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.currency_rupee_rounded,
              color: Color(0xff079447),
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rs. ${settlement.grossTransactionAmount.toStringAsFixed(1)}',
                  style: AppTextStyle.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${settlement.transactionCount} ${context.tr('transactions')}',
                  style: AppTextStyle.h5WhiteColor.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${context.tr('settled_on')} ${_displayDate(settlement.tranDate)}',
                  style: AppTextStyle.h5WhiteColor.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('settled_to_na'),
                  style: AppTextStyle.h5WhiteColor.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'UTR No',
                style: AppTextStyle.h5WhiteColor.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 90,
                child: Text(
                  settlement.utr.isEmpty ? 'N/A' : settlement.utr,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.h5WhiteColor.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final SettlementItemModel settlement;
  final bool showDeductions;
  final VoidCallback onToggle;

  const _BreakdownCard({
    required this.settlement,
    required this.showDeductions,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final settledAmount = settlement.totalAmountPayable == 0
        ? settlement.grossTransactionAmount -
            settlement.mdrAmount -
            settlement.gst
        : settlement.totalAmountPayable;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: context.appShadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xffDDF5E6),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xff079447),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('settlement_breakdown'),
                      style: AppTextStyle.h4.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      context.tr('tap_deduction_details'),
                      style: AppTextStyle.h5.copyWith(
                        color: context.appTextSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onToggle,
                icon: Icon(
                  showDeductions
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                label: Text(
                  showDeductions
                      ? context.tr('hide_deductions')
                      : context.tr('view_deductions'),
                ),
              ),
            ],
          ),
          if (showDeductions) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final rows = <Widget>[
                  _BreakdownRow(
                    context.tr('amt_packed_settlement'),
                    settlement.grossTransactionAmount,
                  ),
                  _BreakdownRow(context.tr('refund_amount'), 0),
                  _BreakdownRow(context.tr('chargeback_amount'), 0),
                  _BreakdownRow(context.tr('loan_recovery_amount'), 0),
                  _BreakdownRow(
                    context.tr('msf_mdr'),
                    settlement.mdrAmount,
                  ),
                  const _BreakdownRow('MAR', 0),
                  _BreakdownRow(context.tr('late_stl_fee'), 0),
                  _BreakdownRow('GST', settlement.gst),
                  _BreakdownRow(context.tr('others'), 0),
                ];

                if (constraints.maxWidth < 680) {
                  return Column(children: rows);
                }

                const spacing = 28.0;
                final columnWidth = (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: 0,
                  children: [
                    for (final row in rows)
                      SizedBox(width: columnWidth, child: row),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffEAF8EF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _BreakdownRow(
                context.tr('settled_amount'),
                settledAmount,
                highlight: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool highlight;

  const _BreakdownRow(
    this.label,
    this.amount, {
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyle.h5.copyWith(
                color: highlight
                    ? const Color(0xff079447)
                    : context.appTextPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            'Rs. ${amount.toStringAsFixed(2)}',
            style: AppTextStyle.h5.copyWith(
              color: highlight
                  ? const Color(0xff079447)
                  : context.appTextSecondary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _EmailButton({
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: SizedBox(
        height: 54,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            disabledBackgroundColor:
                AppColors.primaryPurple.withValues(alpha: .82),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? LoadingActionContent(
                  label: context.tr('sending_email'),
                  color: Colors.white,
                  textStyle: AppTextStyle.h4WhiteColor.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mail_outline_rounded, size: 26),
                    const SizedBox(width: 10),
                    Text(
                      context.tr('send_by_email'),
                      style: AppTextStyle.h4WhiteColor.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SettlementDetailHeader extends StatelessWidget {
  const _SettlementDetailHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => NavigationHelper.backOrGo(
            context,
            AppRoutes.home,
          ),
          icon: const Icon(Icons.arrow_back_rounded),
          color: context.appTextPrimary,
          iconSize: 32,
          tooltip: context.tr('back'),
        ),
        const Spacer(),
        Image.asset(
          AppAssets.anetLauncherIcon,
          width: 42,
          height: 36,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        IconButton(
          onPressed: () => context.push(AppRoutes.notifications),
          icon: const Icon(Icons.notifications_none_rounded),
          color: context.appIconColor,
          iconSize: 32,
          tooltip: context.tr('notifications'),
        ),
        IconButton(
          onPressed: () => LogoutHelper.logout(context),
          icon: const Icon(Icons.logout_rounded),
          color: context.appIconColor,
          iconSize: 32,
          tooltip: context.tr('logout'),
        ),
      ],
    );
  }
}

String _apiDate(DateTime? value) {
  if (value == null) return '';
  return DateFormat('yyyy-MM-dd').format(value);
}

String _displayDate(DateTime? value) {
  if (value == null) return 'N/A';
  return DateFormat('dd-MM-yyyy').format(value);
}

String _valueOrDash(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? '—' : normalized;
}
