part of 'home_page.dart';

/// Desktop web dashboard. It reads the existing blocs so no duplicate data
/// source is introduced for the browser layout.
class WebHomeDashboard extends StatelessWidget {
  final String merchantId;
  final bool showDashboard;
  final List<MerchantDropdownItem> merchantItems;
  final String selectedMerchantId;
  final ValueChanged<String?> onMerchantChanged;
  final TransactionTab selectedTab;
  final ValueChanged<TransactionTab> onTabSelected;
  final ValueChanged<int> onNavigationSelected;
  final VoidCallback onViewAll;
  final VoidCallback onRefresh;
  final ValueChanged<int> onPosPageRequested;
  final ValueChanged<int> onQrPageRequested;
  final ValueChanged<int> onSettlementPageRequested;
  final String? selectedVpa;
  final ValueChanged<String?> onVpaChanged;

  const WebHomeDashboard({
    super.key,
    required this.merchantId,
    required this.showDashboard,
    required this.merchantItems,
    required this.selectedMerchantId,
    required this.onMerchantChanged,
    required this.selectedTab,
    required this.onTabSelected,
    required this.onNavigationSelected,
    required this.onViewAll,
    required this.onRefresh,
    required this.onPosPageRequested,
    required this.onQrPageRequested,
    required this.onSettlementPageRequested,
    required this.selectedVpa,
    required this.onVpaChanged,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xffFCFBFF),
        body: SafeArea(
          child: Column(
            children: [
              WebMerchantAppBar(
                key: ValueKey(selectedMerchantId),
                onNavigationSelected: onNavigationSelected,
                showDashboard: showDashboard,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, availableSpace) {
                    // The browser menu remains available at every width. Hide
                    // the wide rail before it squeezes dashboard content.
                    final showSidebar = availableSpace.maxWidth >= 1280;

                    return Row(
                      children: [
                        if (showSidebar)
                          _WebDashboardSidebar(
                            onSelected: onNavigationSelected,
                            showDashboard: showDashboard,
                          ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, viewport) =>
                                SingleChildScrollView(
                              padding: EdgeInsets.all(
                                viewport.maxWidth < 1120 ? 12 : 14,
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: 1320,
                                    minHeight: viewport.maxHeight - 28,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (merchantItems.isNotEmpty) ...[
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 460,
                                            ),
                                            child: _MerchantDropdown(
                                              items: merchantItems,
                                              selectedMerchantId:
                                                  selectedMerchantId.isEmpty
                                                      ? merchantItems
                                                          .first.merchantId
                                                      : selectedMerchantId,
                                              onChanged: onMerchantChanged,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      _WebDashboardMetrics(
                                        selectedTab: selectedTab,
                                      ),
                                      const SizedBox(height: 12),
                                      _WebTransactionTabs(
                                        selected: selectedTab,
                                        onSelected: onTabSelected,
                                      ),
                                      const SizedBox(height: 12),
                                      _WebRecentTransactions(
                                        selectedTab: selectedTab,
                                        onViewAll: onViewAll,
                                        onRefresh: onRefresh,
                                        onPosPageRequested: onPosPageRequested,
                                        onQrPageRequested: onQrPageRequested,
                                        onSettlementPageRequested:
                                            onSettlementPageRequested,
                                        selectedVpa: selectedVpa,
                                        onVpaChanged: onVpaChanged,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}

class _WebDashboardSidebar extends StatelessWidget {
  final ValueChanged<int> onSelected;
  final bool showDashboard;

  const _WebDashboardSidebar({
    required this.onSelected,
    required this.showDashboard,
  });
  @override
  Widget build(BuildContext context) => Container(
        width: 228,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Color(0xffE7E2EE)))),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _WebNavItem(
              icon: Icons.home_rounded,
              label: context.tr('home'),
              selected: true,
              onTap: () => onSelected(0)),
          _WebNavItem(
              icon: Icons.support_agent_rounded,
              label: context.tr('support'),
              onTap: () => onSelected(1)),
          if (showDashboard)
            _WebNavItem(
                icon: Icons.bar_chart_rounded,
                label: context.tr('dashboard'),
                onTap: () => onSelected(2)),
          _WebNavItem(
              icon: Icons.person_rounded,
              label: context.tr('profile'),
              onTap: () => onSelected(3)),
          const Spacer(),
          WebHelpCard(onContactSupport: () => onSelected(1)),
          const SizedBox(height: 16),
          const WebTrademarkFooter(),
        ]),
      );
}

class _WebNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _WebNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: selected ? const Color(0xffF1E8FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(icon,
                      color: selected
                          ? AppColors.primaryPurple
                          : context.appTextSecondary),
                  const SizedBox(width: 16),
                  Text(label,
                      style: AppTextStyle.h4.copyWith(
                          color: selected
                              ? AppColors.primaryPurple
                              : context.appTextPrimary,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        ),
      );
}

class _WebDashboardMetrics extends StatelessWidget {
  final TransactionTab selectedTab;

  const _WebDashboardMetrics({required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    switch (selectedTab) {
      case TransactionTab.qr:
        return BlocBuilder<MerchantVpaTxnBloc, MerchantVpaTxnState>(
          builder: (context, state) => _buildMetrics(
            transactionLabel: 'QR Transactions Today',
            transactionCount: state.totalElements,
            amountLabel: 'QR Amount Today',
            amount: state.totalAmount,
          ),
        );
      case TransactionTab.settlements:
        return BlocBuilder<SettlementBloc, SettlementState>(
          builder: (context, state) => _buildMetrics(
            transactionLabel: 'Settlements Today',
            transactionCount: state.totalElements,
            amountLabel: 'Amount Settled Today',
            amount: state.totalAmount,
          ),
        );
      case TransactionTab.pos:
        return BlocBuilder<PosTransactionBloc, PosTransactionState>(
          builder: (context, state) => _buildMetrics(
            transactionLabel: 'Transactions Today',
            transactionCount: state.totalElements,
            amountLabel: 'Amount Today',
            amount: state.totalAmount,
          ),
        );
    }
  }

  Widget _buildMetrics({
    required String transactionLabel,
    required int transactionCount,
    required String amountLabel,
    required double amount,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: _webSurface(),
        child: Row(children: [
          _WebMetric(
            icon: Icons.account_balance_wallet_outlined,
            label: transactionLabel,
            value: '$transactionCount',
          ),
          const SizedBox(height: 42, child: VerticalDivider()),
          _WebMetric(
            icon: Icons.currency_rupee_rounded,
            label: amountLabel,
            value: 'Rs. ${amount.toStringAsFixed(2)}',
          ),
        ]),
      );
}

class _WebMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WebMetric(
      {required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
          child: Row(children: [
        Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: const Color(0xffF0E7FF),
                borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: AppColors.primaryPurple, size: 23)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: AppTextStyle.h5.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyle.h3.copyWith(
                  color: AppColors.primaryPurple, fontWeight: FontWeight.w900))
        ])
      ]));
}

class _WebTransactionTabs extends StatelessWidget {
  final TransactionTab selected;
  final ValueChanged<TransactionTab> onSelected;
  const _WebTransactionTabs({required this.selected, required this.onSelected});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(3),
      decoration: _webSurface(),
      child: Row(children: [
        _WebTab(
            icon: Icons.credit_card_rounded,
            label: 'POS Transactions',
            selected: selected == TransactionTab.pos,
            onTap: () => onSelected(TransactionTab.pos)),
        _WebTab(
            icon: Icons.qr_code_rounded,
            label: 'QR Transactions',
            selected: selected == TransactionTab.qr,
            onTap: () => onSelected(TransactionTab.qr)),
        _WebTab(
            icon: Icons.receipt_long_rounded,
            label: 'Settlement Summary',
            selected: selected == TransactionTab.settlements,
            onTap: () => onSelected(TransactionTab.settlements)),
      ]));
}

class _WebTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _WebTab(
      {required this.icon,
      required this.label,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
      child: Material(
          color: selected ? AppColors.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(children: [
                    Icon(icon,
                        color:
                            selected ? Colors.white : AppColors.primaryPurple),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(label,
                            style: AppTextStyle.h5.copyWith(
                                color: selected
                                    ? Colors.white
                                    : context.appTextPrimary,
                                fontWeight: FontWeight.w900))),
                    Icon(Icons.chevron_right_rounded,
                        color:
                            selected ? Colors.white : context.appTextSecondary)
                  ])))));
}

class _WebRecentTransactions extends StatelessWidget {
  final TransactionTab selectedTab;
  final VoidCallback onViewAll;
  final VoidCallback onRefresh;
  final ValueChanged<int> onPosPageRequested;
  final ValueChanged<int> onQrPageRequested;
  final ValueChanged<int> onSettlementPageRequested;
  final String? selectedVpa;
  final ValueChanged<String?> onVpaChanged;

  const _WebRecentTransactions(
      {required this.selectedTab,
      required this.onViewAll,
      required this.onRefresh,
      required this.onPosPageRequested,
      required this.onQrPageRequested,
      required this.onSettlementPageRequested,
      required this.selectedVpa,
      required this.onVpaChanged});

  @override
  Widget build(BuildContext context) => Container(
        decoration: _webSurface(),
        child: selectedTab == TransactionTab.pos
            ? _buildPosTransactions()
            : selectedTab == TransactionTab.qr
                ? _buildQrTransactions()
                : _buildSettlements(),
      );

  Widget _buildPosTransactions() =>
      BlocBuilder<PosTransactionBloc, PosTransactionState>(
        builder: (context, state) => Column(children: [
          _WebTableHeader(
            onViewAll: onViewAll,
            onRefresh: state.transactionsLoading ? null : onRefresh,
          ),
          const Divider(height: 1),
          if (state.transactionsLoading && state.transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(60),
              child: CircularProgressIndicator(),
            )
          else if (state.transactions.isEmpty)
            const _WebEmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'No POS transactions available',
            )
          else ...[
            _WebHomeTransactionTable(
              isPos: true,
              children: state.transactions
                  .map((item) => _WebTransactionRow(transaction: item))
                  .toList(),
            ),
            _WebPagination(
              page: state.page,
              totalPages: state.totalPages,
              isLoading: state.transactionsLoading,
              canGoPrevious: !state.first,
              canGoNext: !state.last,
              onPrevious: () => onPosPageRequested(state.page - 1),
              onNext: () => onPosPageRequested(state.page + 1),
            ),
          ],
        ]),
      );

  Widget _buildQrTransactions() => Column(children: [
        BlocBuilder<MerchantVpaTxnBloc, MerchantVpaTxnState>(
          buildWhen: (previous, current) =>
              (previous is MerchantVpaTxnLoading) !=
              (current is MerchantVpaTxnLoading),
          builder: (context, state) => _WebQrTableHeader(
            onViewAll: onViewAll,
            onRefresh: state is MerchantVpaTxnLoading ? null : onRefresh,
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(22),
          child: BlocBuilder<SoundBoxBloc, SoundBoxState>(
            builder: (context, state) => VpaSelector(
              isLoading: state is SoundBoxLoading,
              vpas: state.devices,
              selectedVpa:
                  state.devices.contains(selectedVpa) ? selectedVpa : null,
              onChanged: onVpaChanged,
            ),
          ),
        ),
        const Divider(height: 1),
        BlocBuilder<MerchantVpaTxnBloc, MerchantVpaTxnState>(
          builder: (context, state) {
            if (state is MerchantVpaTxnLoading && state.transactions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              );
            }

            if (state is MerchantVpaTxnFailure && state.transactions.isEmpty) {
              return const _WebEmptyState(
                icon: Icons.error_outline_rounded,
                message: 'Unable to load QR transactions. Please try again.',
              );
            }

            if (state.transactions.isEmpty) {
              return const _WebEmptyState(
                icon: Icons.qr_code_rounded,
                message: 'No QR transactions available for this VPA',
              );
            }

            return Column(children: [
              _WebHomeTransactionTable(
                isPos: false,
                children: state.transactions
                    .map((item) => _WebQrTransactionRow(transaction: item))
                    .toList(),
              ),
              _WebPagination(
                page: state.page,
                totalPages: state.totalPages,
                isLoading: state is MerchantVpaTxnLoading,
                canGoPrevious: !state.first,
                canGoNext: !state.last,
                onPrevious: () => onQrPageRequested(state.page - 1),
                onNext: () => onQrPageRequested(state.page + 1),
              ),
            ]);
          },
        ),
      ]);

  Widget _buildSettlements() => BlocBuilder<SettlementBloc, SettlementState>(
        builder: (context, state) {
          if (state.isLoading && state.settlements.isEmpty) {
            return Column(children: [
              _WebSettlementTableHeader(
                onViewAll: onViewAll,
                onRefresh: null,
              ),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            ]);
          }

          if (state.error != null && state.settlements.isEmpty) {
            return Column(children: [
              _WebSettlementTableHeader(
                onViewAll: onViewAll,
                onRefresh: onRefresh,
              ),
              const Divider(height: 1),
              _WebSettlementSummary(state: state),
              const Divider(height: 1),
              const _WebEmptyState(
                icon: Icons.error_outline_rounded,
                message: 'Unable to load settlements. Please try again.',
              ),
            ]);
          }

          if (state.settlements.isEmpty) {
            return Column(children: [
              _WebSettlementTableHeader(
                onViewAll: onViewAll,
                onRefresh: onRefresh,
              ),
              const Divider(height: 1),
              _WebSettlementSummary(state: state),
              const Divider(height: 1),
              const _WebEmptyState(
                icon: Icons.account_balance_outlined,
                message: 'No settlements available today',
              ),
            ]);
          }

          return Column(children: [
            _WebSettlementTableHeader(
              onViewAll: onViewAll,
              onRefresh: state.isLoading ? null : onRefresh,
            ),
            const Divider(height: 1),
            _WebSettlementSummary(state: state),
            const Divider(height: 1),
            const _WebSettlementColumnLabels(),
            ...state.settlements.map(
              (item) => _WebSettlementRow(settlement: item),
            ),
            _WebPagination(
              page: state.page,
              totalPages: state.totalPages,
              isLoading: state.isLoading,
              canGoPrevious: !state.first,
              canGoNext: !state.last,
              onPrevious: () => onSettlementPageRequested(state.page - 1),
              onNext: () => onSettlementPageRequested(state.page + 1),
            ),
          ]);
        },
      );
}

class _WebPagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final bool isLoading;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _WebPagination({
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
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
        ]),
      );
}

class _WebTableHeader extends StatelessWidget {
  final VoidCallback onViewAll;
  final VoidCallback? onRefresh;
  const _WebTableHeader({required this.onViewAll, required this.onRefresh});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Text('Recent POS Transactions',
            style: AppTextStyle.h4.copyWith(fontWeight: FontWeight.w900)),
        const Spacer(),
        _WebRefreshButton(onPressed: onRefresh),
        const SizedBox(width: 8),
        TextButton.icon(
            onPressed: onViewAll,
            icon: const Icon(Icons.format_list_bulleted_rounded),
            label: const Text('View All Transactions'))
      ]));
}

class _WebQrTableHeader extends StatelessWidget {
  final VoidCallback onViewAll;
  final VoidCallback? onRefresh;
  const _WebQrTableHeader({
    required this.onViewAll,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Text('Recent QR Transactions',
              style: AppTextStyle.h4.copyWith(fontWeight: FontWeight.w900)),
          const Spacer(),
          _WebRefreshButton(onPressed: onRefresh),
          const SizedBox(width: 8),
          TextButton.icon(
              onPressed: onViewAll,
              icon: const Icon(Icons.format_list_bulleted_rounded),
              label: const Text('View All Transactions')),
        ]),
      );
}

class _WebSettlementTableHeader extends StatelessWidget {
  final VoidCallback? onViewAll;
  final VoidCallback? onRefresh;

  const _WebSettlementTableHeader({this.onViewAll, this.onRefresh});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(children: [
          Text(
            'Today\'s Settlements',
            style: AppTextStyle.h4.copyWith(fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          _WebRefreshButton(onPressed: onRefresh),
          const SizedBox(width: 8),
          if (onViewAll != null)
            TextButton.icon(
              onPressed: onViewAll,
              icon: const Icon(Icons.format_list_bulleted_rounded),
              label: const Text('View All Settlements'),
            ),
        ]),
      );
}

class _WebRefreshButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _WebRefreshButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: onPressed == null
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync_rounded, size: 19),
        label: Text(context.tr('refresh')),
      );
}

class _WebTransactionColumnLabels extends StatelessWidget {
  final bool isPos;

  const _WebTransactionColumnLabels({required this.isPos});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? context.appElevatedSurface
              : AppColors.primaryPurple.withValues(alpha: .10),
          border: Border(bottom: BorderSide(color: context.appBorder)),
        ),
        child: Row(children: [
          const Expanded(flex: 15, child: _WebColumnLabel('AMOUNT')),
          const Expanded(flex: 18, child: _WebColumnLabel('DATE & TIME')),
          if (isPos) ...const [
            Expanded(flex: 16, child: _WebColumnLabel('TID')),
            Expanded(flex: 15, child: _WebColumnLabel('CARD TYPE')),
            Expanded(flex: 16, child: _WebColumnLabel('TRANSACTION TYPE')),
            Expanded(flex: 15, child: _WebColumnLabel('ENTRY MODE')),
          ] else ...const [
            Expanded(flex: 18, child: _WebColumnLabel('CUSTOMER NAME')),
            Expanded(flex: 20, child: _WebColumnLabel('CUSTOMER VPA')),
            Expanded(flex: 14, child: _WebColumnLabel('RRN')),
            Expanded(flex: 14, child: _WebColumnLabel('REF ID')),
          ],
          const SizedBox(width: 112, child: _WebColumnLabel('STATUS')),
          const SizedBox(width: 32),
        ]),
      );
}

/// Keeps the richer web-only transaction columns readable on narrower desktop
/// windows without changing the compact mobile transaction cards.
class _WebHomeTransactionTable extends StatelessWidget {
  final List<Widget> children;
  final bool isPos;

  const _WebHomeTransactionTable({
    required this.children,
    required this.isPos,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < (isPos ? 1040 : 1240)
                ? (isPos ? 1040 : 1240)
                : constraints.maxWidth,
            child: Column(
              children: [
                _WebTransactionColumnLabels(isPos: isPos),
                ...children
              ],
            ),
          ),
        ),
      );
}

/// Mirrors the settlement totals shown on mobile while using a wider web card
/// layout. The API currently does not expose a pending amount, so it remains
/// zero, consistent with the mobile experience.
class _WebSettlementSummary extends StatelessWidget {
  final SettlementState state;

  const _WebSettlementSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final deductions = state.settlements.fold<double>(
      0,
      (total, item) => total + item.gst + item.mdrAmount,
    );
    final cards = [
      _WebSettlementSummaryCard(
        label: context.tr('settled_amount'),
        subtitle: context.tr('total_amount_settled_today'),
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.primaryPurple,
        amount: state.totalAmount,
      ),
      _WebSettlementSummaryCard(
        label: context.tr('deductions'),
        subtitle: context.tr('total_deductions_today'),
        icon: Icons.percent_rounded,
        color: const Color(0xffB03060),
        amount: deductions,
      ),
      _WebSettlementSummaryCard(
        label: context.tr('pending_settlements'),
        subtitle: context.tr('total_pending_settlements'),
        icon: Icons.schedule_rounded,
        color: const Color(0xffB89116),
        amount: 0,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 720) {
            return Column(
              children: [
                for (var index = 0; index < cards.length; index++) ...[
                  cards[index],
                  if (index != cards.length - 1) const SizedBox(height: 12),
                ],
              ],
            );
          }

          return Row(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                Expanded(child: cards[index]),
                if (index != cards.length - 1) const SizedBox(width: 14),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _WebSettlementSummaryCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double amount;

  const _WebSettlementSummaryCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffFCFBFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE9E2F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.h5.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.h5.copyWith(
                    color: context.appTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs. ${amount.toStringAsFixed(2)}',
                  style: AppTextStyle.h4.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSettlementColumnLabels extends StatelessWidget {
  const _WebSettlementColumnLabels();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? context.appElevatedSurface
              : AppColors.primaryPurple.withValues(alpha: .10),
          border: Border(bottom: BorderSide(color: context.appBorder)),
        ),
        child: const Row(children: [
          SizedBox(width: 60),
          Expanded(flex: 2, child: _WebColumnLabel('SETTLEMENT DATE')),
          Expanded(flex: 2, child: _WebColumnLabel('UTR / TRANSACTIONS')),
          Expanded(flex: 2, child: _WebColumnLabel('GROSS AMOUNT')),
          Expanded(flex: 2, child: _WebColumnLabel('NET PAYABLE')),
          SizedBox(width: 98, child: _WebColumnLabel('STATUS')),
          SizedBox(width: 50),
        ]),
      );
}

class _WebColumnLabel extends StatelessWidget {
  final String label;

  const _WebColumnLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.h5.copyWith(
          color: context.appTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      );
}

class _WebEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _WebEmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
        child: Column(children: [
          Icon(icon, size: 40, color: context.appTextSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.h4.copyWith(
              color: context.appTextSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),
      );
}

class _WebQrTransactionRow extends StatelessWidget {
  final MerchantVpaTransactionModel transaction;
  const _WebQrTransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final successful = transaction.status.toLowerCase().contains('success') ||
        transaction.status.toLowerCase().contains('approved');
    return InkWell(
      onTap: () => context.push(AppRoutes.vpaInvoice, extra: transaction),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        decoration: const BoxDecoration(
          color: Color(0xffFCFBFF),
          border: Border(bottom: BorderSide(color: Color(0xffEEEAF3))),
        ),
        child: Row(children: [
          Expanded(
            flex: 15,
            child: _WebHomeTableText(
              'Rs. ${transaction.transactionAmount}',
              isAmount: true,
            ),
          ),
          Expanded(
            flex: 18,
            child: _WebHomeTableText(transaction.addedOn),
          ),
          Expanded(
            flex: 18,
            child: _WebHomeTableText(_webValueOrDash(transaction.payerName)),
          ),
          Expanded(
            flex: 20,
            child: _WebHomeTableText(_webValueOrDash(transaction.customerVpa)),
          ),
          Expanded(
            flex: 14,
            child: _WebHomeTableText(_webValueOrDash(transaction.rrn)),
          ),
          Expanded(
            flex: 14,
            child: _WebHomeTableText(_webValueOrDash(transaction.refId)),
          ),
          SizedBox(
            width: 112,
            child: _WebHomeStatusBadge(
              label:
                  transaction.status.isEmpty ? 'Pending' : transaction.status,
              successful: successful,
            ),
          ),
          const SizedBox(width: 32),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
    );
  }
}

class _WebSettlementRow extends StatelessWidget {
  final SettlementItemModel settlement;

  const _WebSettlementRow({required this.settlement});

  @override
  Widget build(BuildContext context) {
    final isSettled = settlement.merPayDone || settlement.reconciled;
    final date = settlement.tranDate == null
        ? 'N/A'
        : DateFormat('d MMM yyyy').format(settlement.tranDate!);
    final utr = settlement.utr.trim().isEmpty ? 'N/A' : settlement.utr;

    return InkWell(
      onTap: () => context.push(
        AppRoutes.settlementDetail,
        extra: SettlementDetailData(
          settlement: settlement,
          filter: const TransactionFilterData(tab: TransactionTab.settlements),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 17),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffEEEAF3))),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xffE7F8EC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: Color(0xff18A957),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            flex: 2,
            child: Text(
              date,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.h5.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UTR: $utr',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.h5.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${settlement.transactionCount} transactions',
                  style: AppTextStyle.h5.copyWith(
                    color: context.appTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rs. ${settlement.grossTransactionAmount.toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.h5.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Rs. ${settlement.totalAmountPayable.toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.h5.copyWith(
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            width: 98,
            child: _WebSettlementStatusBadge(isSettled: isSettled),
          ),
          const SizedBox(width: 26),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
    );
  }
}

class _WebSettlementStatusBadge extends StatelessWidget {
  final bool isSettled;

  const _WebSettlementStatusBadge({required this.isSettled});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSettled ? const Color(0xffE8F8ED) : const Color(0xffFFF6DF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          isSettled ? 'Settled' : 'Pending',
          textAlign: TextAlign.center,
          style: AppTextStyle.h5.copyWith(
            color:
                isSettled ? const Color(0xff18A957) : const Color(0xffA66D00),
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

class _WebTransactionRow extends StatelessWidget {
  final PosTransactionModel transaction;
  const _WebTransactionRow({required this.transaction});
  @override
  Widget build(BuildContext context) {
    final successful =
        transaction.responseDesc.toLowerCase().contains('success') ||
            transaction.responseCode == '00';
    return InkWell(
        onTap: () =>
            context.push(AppRoutes.transactionInvoice, extra: transaction),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            decoration: const BoxDecoration(
              color: Color(0xffFCFBFF),
              border: Border(bottom: BorderSide(color: Color(0xffEEEAF3))),
            ),
            child: Row(children: [
              Expanded(
                flex: 15,
                child: _WebHomeTableText(
                  'Rs. ${transaction.amount}',
                  isAmount: true,
                ),
              ),
              Expanded(
                flex: 18,
                child: _WebHomeTableText(
                  '${transaction.transactionDate} | ${transaction.transactionTime}',
                ),
              ),
              Expanded(
                flex: 16,
                child:
                    _WebHomeTableText(_webValueOrDash(transaction.terminalId)),
              ),
              Expanded(
                flex: 15,
                child: _WebHomeTableText(_webValueOrDash(
                  transaction.schemeName,
                  fallback: _webCardScheme(transaction.cardNo),
                )),
              ),
              Expanded(
                flex: 16,
                child: _WebHomeTableText(
                  _webTransactionType(transaction.transactionType),
                ),
              ),
              Expanded(
                flex: 15,
                child: _WebHomeTableText(
                    _webCardEntryMode(transaction.posEntryMode)),
              ),
              SizedBox(
                width: 112,
                child: _WebHomeStatusBadge(
                  label: successful ? 'Success' : 'Failed',
                  successful: successful,
                ),
              ),
              const SizedBox(width: 32),
              const Icon(Icons.chevron_right_rounded)
            ])));
  }
}

class _WebHomeTableText extends StatelessWidget {
  final String value;
  final bool isAmount;

  const _WebHomeTableText(this.value, {this.isAmount = false});

  @override
  Widget build(BuildContext context) => Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.h5.copyWith(
          color: context.appTextPrimary,
          fontWeight: isAmount ? FontWeight.w900 : FontWeight.w700,
        ),
      );
}

class _WebHomeStatusBadge extends StatelessWidget {
  final String label;
  final bool successful;

  const _WebHomeStatusBadge({required this.label, required this.successful});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: successful ? const Color(0xffE8F8ED) : const Color(0xffFEEBEC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyle.h5.copyWith(
            color: successful ? const Color(0xff18A957) : Colors.red,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}

String _webValueOrDash(String value, {String fallback = ''}) {
  final primary = value.trim();
  if (primary.isNotEmpty) return primary;
  final alternate = fallback.trim();
  return alternate.isEmpty ? '—' : alternate;
}

String _webCardEntryMode(String value) {
  switch (value.trim()) {
    case '051':
      return 'Chip';
    case '071':
      return 'CTLS';
    default:
      return value.trim().isEmpty ? 'N/A' : value;
  }
}

String _webTransactionType(String value) {
  switch (value.trim()) {
    case 'OSAL001':
      return 'SALE';
    case 'VSAL001':
      return 'VOID-SALE';
    default:
      return value.trim().isEmpty ? 'N/A' : value;
  }
}

String _webCardScheme(String cardNumber) {
  final normalized = cardNumber.replaceAll(RegExp(r'\s+|-'), '');
  if (normalized.isEmpty) return 'N/A';
  if (normalized.startsWith('4')) return 'VISA';
  if (normalized.startsWith('5')) return 'MASTERCARD';
  if (normalized.startsWith('34') || normalized.startsWith('37')) {
    return 'AMERICAN EXPRESS';
  }
  if (normalized.startsWith('6')) return 'RUPAY';
  return 'UNKNOWN';
}

BoxDecoration _webSurface() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE7E2EE)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0C171023), blurRadius: 14, offset: Offset(0, 4))
        ]);
