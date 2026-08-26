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
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/logout_helper.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';
import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';
import 'package:anet_merchants/features/settlements/presentation/bloc/settlement/settlement_bloc.dart';
import 'package:anet_merchants/features/settlements/presentation/pages/settlement_navigation_data.dart';
import 'package:anet_merchants/features/transactions/presentation/pages/transaction_filter_data.dart';
import 'package:anet_merchants/features/shared/presentation/widgets/merchant_overview.dart';

class SettlementDashboardPage extends StatefulWidget {
  final TransactionFilterData filter;

  const SettlementDashboardPage({
    super.key,
    required this.filter,
  });

  @override
  State<SettlementDashboardPage> createState() =>
      _SettlementDashboardPageState();
}

class _SettlementDashboardPageState extends State<SettlementDashboardPage> {
  static const int _pageSize = 10;
  final SessionStorage _sessionStorage = SessionStorage();

  String _bearerToken = '';
  String _merchantId = '';
  String _acqMerchantId = '';

  @override
  void initState() {
    super.initState();
    _loadSettlements(page: 0);
  }

  Future<void> _loadSettlements({required int page}) async {
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

    if (!mounted || bearerToken.isEmpty || settlementMerchantId.isEmpty) {
      return;
    }

    _bearerToken = bearerToken;
    _merchantId = merchantId;
    _acqMerchantId = acqMerchantId;

    context.read<SettlementBloc>().add(
          GetSettlementHistoryRequested(
            bearerToken: bearerToken,
            merchantId: settlementMerchantId,
            fromDate: widget.filter.from,
            toDate: widget.filter.to,
            page: page,
            size: _pageSize,
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

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      selectedIndex: 0,
      onBottomNavItemSelected: _onBottomNavItemSelected,
      body: kIsWeb ? _buildWebDashboard() : _buildMobileDashboard(),
    );
  }

  Widget _buildMobileDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SettlementPageHeader(),
          const SizedBox(height: 30),
          const MerchantOverview(),
          const SizedBox(height: 18),
          _DateRangeLabel(widget.filter.dateLabel),
          const SizedBox(height: 22),
          BlocBuilder<SettlementBloc, SettlementState>(
            builder: (context, state) {
              return _SettlementSummaryCard(state: state);
            },
          ),
          const SizedBox(height: 28),
          Text(
            context.tr('utr_wise_settlement'),
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
          const SizedBox(height: 18),
          _buildSettlementList(),
        ],
      ),
    );
  }

  Widget _buildWebDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => NavigationHelper.backOrGo(
                      context,
                      AppRoutes.home,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: context.appTextPrimary,
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.appBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              widget.filter.dateLabel.isEmpty
                                  ? context.tr('settlements')
                                  : widget.filter.dateLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.h4.copyWith(
                                color: context.appTextPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              BlocBuilder<SettlementBloc, SettlementState>(
                builder: (context, state) =>
                    _WebSettlementSummaryCard(state: state),
              ),
              const SizedBox(height: 22),
              Text(
                context.tr('utr_wise_settlement'),
                style: AppTextStyle.h3.copyWith(
                  color: context.appTextPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 46,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              _buildWebSettlementList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettlementList() {
    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        if (state.isLoading && state.settlements.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            ),
          );
        }

        if (state.settlements.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Center(
              child: Text(
                context.tr('no_transactions'),
                style: AppTextStyle.h3.copyWith(
                  color: context.appTextSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            ...state.settlements.map(_buildSettlementTile),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: state.isLoading || state.first
                      ? null
                      : () => _loadSettlements(page: state.page - 1),
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: AppColors.primaryPurple,
                  tooltip: context.tr('previous_page'),
                ),
                Text(
                  '${context.tr('page')} ${state.page + 1} ${context.tr('of')} ${state.totalPages == 0 ? 1 : state.totalPages}',
                  style: AppTextStyle.h5.copyWith(
                    color: context.appTextPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: state.isLoading || state.last
                      ? null
                      : () => _loadSettlements(page: state.page + 1),
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: AppColors.primaryPurple,
                  tooltip: context.tr('next_page'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildWebSettlementList() {
    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        if (state.isLoading && state.settlements.isEmpty) {
          return const _WebSettlementDashboardMessage.loading();
        }

        if (state.settlements.isEmpty) {
          return const _WebSettlementDashboardMessage.empty();
        }

        return Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appBorder),
          ),
          child: Column(
            children: [
              _WebSettlementDashboardTable(
                children: [
                  for (final settlement in state.settlements)
                    _WebSettlementDashboardRow(
                      settlement: settlement,
                      onTap: () => context.push(
                        AppRoutes.settlementDetail,
                        extra: SettlementDetailData(
                          settlement: settlement,
                          filter: widget.filter,
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: state.isLoading || state.first
                          ? null
                          : () => _loadSettlements(page: state.page - 1),
                      icon: const Icon(Icons.chevron_left_rounded),
                      color: AppColors.primaryPurple,
                      tooltip: context.tr('previous_page'),
                    ),
                    Text(
                      '${context.tr('page')} ${state.page + 1} ${context.tr('of')} ${state.totalPages == 0 ? 1 : state.totalPages}',
                      style: AppTextStyle.h5.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      onPressed: state.isLoading || state.last
                          ? null
                          : () => _loadSettlements(page: state.page + 1),
                      icon: const Icon(Icons.chevron_right_rounded),
                      color: AppColors.primaryPurple,
                      tooltip: context.tr('next_page'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettlementTile(SettlementItemModel settlement) {
    return InkWell(
      onTap: () {
        context.push(
          AppRoutes.settlementDetail,
          extra: SettlementDetailData(
            settlement: settlement,
            filter: widget.filter,
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
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
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryPurple,
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rs. ${settlement.grossTransactionAmount.toStringAsFixed(1)}',
                    style: AppTextStyle.h3.copyWith(
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${settlement.transactionCount} ${context.tr('transactions')}',
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'UTR : ${settlement.utr.isEmpty ? 'N/A' : settlement.utr}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xffEAF7EE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    context.tr('settled_on'),
                    style: AppTextStyle.h5.copyWith(
                      color: const Color(0xff0B7A3A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(settlement.tranDate),
                    style: AppTextStyle.h5.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primaryPurple,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class _WebSettlementSummaryCard extends StatelessWidget {
  final SettlementState state;

  const _WebSettlementSummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final amount = 'Rs. ${state.totalAmount.toStringAsFixed(2)}';
    final metrics = [
      _WebSettlementMetric(
        icon: Icons.description_outlined,
        label: context.tr('total_settlements'),
        value: '${state.totalElements}',
      ),
      _WebSettlementMetric(
        icon: Icons.swap_horiz_rounded,
        label: context.tr('total_transactions'),
        value: '${state.transactionCount}',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xff11251C)
            : const Color(0xffF0FBF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode
              ? const Color(0xff1E5B3A)
              : const Color(0xffCFE8D8),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WebSettlementAmount(amount: amount),
                const SizedBox(height: 18),
                for (var index = 0; index < metrics.length; index++) ...[
                  metrics[index],
                  if (index != metrics.length - 1) const SizedBox(height: 14),
                ],
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 2, child: _WebSettlementAmount(amount: amount)),
              Container(width: 1, height: 88, color: context.appBorder),
              for (final metric in metrics) ...[
                const SizedBox(width: 28),
                Expanded(child: metric),
                if (metric != metrics.last)
                  Container(width: 1, height: 88, color: context.appBorder),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WebSettlementAmount extends StatelessWidget {
  final String amount;

  const _WebSettlementAmount({required this.amount});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('total_amount_settled'),
                  style: AppTextStyle.h4.copyWith(
                    color: const Color(0xff079447),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  amount,
                  style: AppTextStyle.h2.copyWith(
                    color: context.appTextPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xff078B3E),
            child: Icon(
              Icons.currency_rupee_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      );
}

class _WebSettlementMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WebSettlementMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xffDDF5E6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xff078B3E), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.h5.copyWith(
                    color: context.appTextSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyle.h3.copyWith(
                    color: const Color(0xff079447),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

/// Keeps settlement records readable on compact browsers, without changing the
/// existing mobile settlement cards.
class _WebSettlementDashboardTable extends StatelessWidget {
  final List<Widget> children;

  const _WebSettlementDashboardTable({required this.children});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          // A desktop-width table makes the first columns disappear when the
          // browser becomes a single column. Compact rows expose the same data
          // without requiring horizontal scrolling.
          if (constraints.maxWidth < 760) {
            return Column(children: children);
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth < 980 ? 980 : constraints.maxWidth,
              child: Column(
                children: [
                  const _WebSettlementTableColumnLabels(),
                  ...children,
                ],
              ),
            ),
          );
        },
      );
}

class _WebSettlementTableColumnLabels extends StatelessWidget {
  const _WebSettlementTableColumnLabels();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? context.appElevatedSurface
              : AppColors.primaryPurple.withValues(alpha: .10),
          border: Border(bottom: BorderSide(color: context.appBorder)),
        ),
        child: Row(
          children: [
            Expanded(
                flex: 18,
                child: _WebSettlementColumnLabel(context.tr('amount'))),
            Expanded(
              flex: 20,
              child: _WebSettlementColumnLabel(context.tr('settlement_date')),
            ),
            Expanded(
                flex: 25, child: _WebSettlementColumnLabel(context.tr('utr'))),
            Expanded(
              flex: 17,
              child: _WebSettlementColumnLabel(context.tr('transactions')),
            ),
            SizedBox(
              width: 142,
              child: _WebSettlementColumnLabel(context.tr('status')),
            ),
            const SizedBox(width: 32),
          ],
        ),
      );
}

class _WebSettlementColumnLabel extends StatelessWidget {
  final String label;

  const _WebSettlementColumnLabel(this.label);

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

class _WebSettlementDashboardRow extends StatelessWidget {
  final SettlementItemModel settlement;
  final VoidCallback onTap;

  const _WebSettlementDashboardRow({
    required this.settlement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final settled = settlement.merPayDone || settlement.reconciled;
    final statusColor =
        settled ? const Color(0xff0B7A3A) : const Color(0xffA66D00);
    final statusSurface =
        settled ? const Color(0xffEAF7EE) : const Color(0xffFFF6DF);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return _WebCompactSettlementRow(
            settlement: settlement,
            settled: settled,
            statusColor: statusColor,
            statusSurface: statusSurface,
            onTap: onTap,
          );
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.appBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 18,
                    child: Text(
                      'Rs. ${settlement.grossTransactionAmount.toStringAsFixed(2)}',
                      style: AppTextStyle.h5.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 20,
                    child: _WebSettlementCell(_formatDate(settlement.tranDate)),
                  ),
                  Expanded(
                    flex: 25,
                    child: _WebSettlementCell(
                      settlement.utr.trim().isEmpty ? 'N/A' : settlement.utr,
                    ),
                  ),
                  // Settlement batches can contain no reliable single RRN. Keep it
                  // out of the web table until the service guarantees the value.
                  Expanded(
                    flex: 17,
                    child: _WebSettlementCell('${settlement.transactionCount}'),
                  ),
                  SizedBox(
                    width: 142,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: statusSurface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          settled
                              ? context.tr('settled_on')
                              : context.tr('pending_settlements'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.h5.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
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
      },
    );
  }
}

class _WebCompactSettlementRow extends StatelessWidget {
  final SettlementItemModel settlement;
  final bool settled;
  final Color statusColor;
  final Color statusSurface;
  final VoidCallback onTap;

  const _WebCompactSettlementRow({
    required this.settlement,
    required this.settled,
    required this.statusColor,
    required this.statusSurface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Rs. ${settlement.grossTransactionAmount.toStringAsFixed(2)}',
                        style: AppTextStyle.h4.copyWith(
                          color: context.appTextPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 145),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: statusSurface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          settled
                              ? context.tr('settled_on')
                              : context.tr('pending_settlements'),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.h5.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primaryPurple,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _WebCompactSettlementFact(
                      icon: Icons.calendar_today_outlined,
                      value: _formatDate(settlement.tranDate),
                    ),
                    _WebCompactSettlementFact(
                      icon: Icons.swap_horiz_rounded,
                      value:
                          '${settlement.transactionCount} ${context.tr('transactions')}',
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                _WebCompactSettlementFact(
                  icon: Icons.account_balance_outlined,
                  value:
                      'UTR: ${settlement.utr.trim().isEmpty ? 'N/A' : settlement.utr}',
                  expanded: true,
                ),
              ],
            ),
          ),
        ),
      );
}

class _WebCompactSettlementFact extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool expanded;

  const _WebCompactSettlementFact({
    required this.icon,
    required this.value,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: context.appTextSecondary),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.h5.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );

    return expanded
        ? SizedBox(width: double.infinity, child: content)
        : content;
  }
}

class _WebSettlementCell extends StatelessWidget {
  final String value;

  const _WebSettlementCell(this.value);

  @override
  Widget build(BuildContext context) => Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.h5.copyWith(
          color: context.appTextPrimary,
          fontWeight: FontWeight.w700,
        ),
      );
}

class _WebSettlementDashboardMessage extends StatelessWidget {
  final bool loading;

  const _WebSettlementDashboardMessage.loading() : loading = true;
  const _WebSettlementDashboardMessage.empty() : loading = false;

  @override
  Widget build(BuildContext context) => Container(
        height: 280,
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appBorder),
        ),
        alignment: Alignment.center,
        child: loading
            ? CircularProgressIndicator(color: AppColors.primaryPurple)
            : Text(
                context.tr('no_transactions'),
                style: AppTextStyle.h3.copyWith(
                  color: context.appTextSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
      );
}

class _SettlementSummaryCard extends StatelessWidget {
  final SettlementState state;

  const _SettlementSummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xff11251C)
            : const Color(0xffEAF8EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.isDarkMode
              ? const Color(0xff1E5B3A)
              : const Color(0xffCFE8D8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('total_amount_settled'),
            style: AppTextStyle.h4.copyWith(
              color: const Color(0xff079447),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rs. ${state.totalAmount.toStringAsFixed(2)}',
                  style: AppTextStyle.h2.copyWith(
                    color: context.appTextPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xff078B3E),
                child: Icon(
                  Icons.currency_rupee_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: context.appBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.description_rounded,
                  label: context.tr('total_settlements'),
                  value: '${state.totalElements}',
                ),
              ),
              Container(width: 1, height: 48, color: context.appBorder),
              Expanded(
                child: _SummaryMetric(
                  icon: Icons.swap_horiz_rounded,
                  label: context.tr('total_transactions'),
                  value: '${state.transactionCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xffDDF5E6),
          child: Icon(icon, color: const Color(0xff078B3E), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.h5.copyWith(
                  color: context.appTextSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                value,
                style: AppTextStyle.h4.copyWith(
                  color: const Color(0xff078B3E),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateRangeLabel extends StatelessWidget {
  final String label;

  const _DateRangeLabel(this.label);

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          color: AppColors.primaryPurple,
          size: 24,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.h4.copyWith(
              color: context.appTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettlementPageHeader extends StatelessWidget {
  const _SettlementPageHeader();

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

String _formatDate(DateTime? value) {
  if (value == null) return 'N/A';
  return DateFormat('dd MMM yyyy').format(value);
}
