import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/common/common_scaffold.dart';
import 'package:anet_merchants/core/common/responsive_layout.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';

import 'package:anet_merchants/features/auth/auth.dart';
import 'package:anet_merchants/features/dashboard/dashboard.dart';
import 'package:anet_merchants/features/devices/devices.dart';
import 'package:anet_merchants/features/profile/profile.dart';
import 'package:anet_merchants/features/settlements/settlements.dart';
import 'package:anet_merchants/features/shared/shared.dart';
import 'package:anet_merchants/features/support/support.dart';
import 'package:anet_merchants/features/transactions/transactions.dart';

part 'web_home_dashboard.dart';

class HomePage extends StatefulWidget {
  final int initialBottomIndex;

  const HomePage({
    super.key,
    this.initialBottomIndex = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int _transactionPageSize = 10;

  final SessionStorage _sessionStorage = SessionStorage();

  int _selectedBottomIndex = 0;
  TransactionTab _selectedTransactionTab = TransactionTab.pos;
  String? _selectedVpa;
  String _bearerToken = '';
  String _merchantId = '';
  String _acqMerchantId = '';
  String _clientUniqueId = '';
  String _userType = '';
  String _terminalId = '';
  bool _isDashboardEnabled = false;
  List<MerchantDropdownItem> _merchantDropdownItems = const [];

  // "All merchants" is represented by acquirer merchant id "0" in the
  // login response / dropdown payload. In that mode the home screen forces
  // the POS flow because QR/VPA history depends on a single mapped merchant.
  bool get _isAllMerchantSelection => !_isTerminalUser && _acqMerchantId == '0';

  DateTime get _homeTransactionStartDate {
    final today = DateTime.now();
    final targetYear = today.year - 2;
    final lastDayOfTargetMonth = DateTime(targetYear, today.month + 1, 0).day;
    final targetDay =
        today.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : today.day;

    return DateTime(targetYear, today.month, targetDay);
  }

  String get _homeTransactionFromDate {
    return DateFormat('dd-MM-yyyy').format(_homeTransactionStartDate);
  }

  String get _homeTransactionToDate {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _selectedBottomIndex = widget.initialBottomIndex;
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    final bearerToken = await _sessionStorage.bearerToken;
    final merchantId = await _sessionStorage.merchantId;
    var acqMerchantId = await _sessionStorage.activeAcqMerchantId;
    final email = await _sessionStorage.email;
    final userType = await _sessionStorage.userType;
    final terminalId = await _sessionStorage.terminalId;
    final merchantDropdownItems = await _sessionStorage.merchantDropdownItems;
    final isDashboardEnabled = await _sessionStorage.isDashboardEnabled;
    final isTerminalUser = userType == 'terminal';

    // Match the production mobile flow: a multi-store merchant always enters
    // Home at the aggregate "All" option. Terminal users retain their own
    // single terminal identity.
    if (!isTerminalUser && merchantDropdownItems.isNotEmpty) {
      final selectedMerchant = merchantDropdownItems.firstWhere(
        (item) => item.isAll,
        orElse: () => merchantDropdownItems.first,
      );
      acqMerchantId = selectedMerchant.merchantId;
      await _sessionStorage.setActiveMerchantSelection(
        acqMerchantId: selectedMerchant.merchantId,
        shopName: selectedMerchant.displayLabel,
      );
    }

    if (!mounted) return;

    setState(() {
      if (!isDashboardEnabled && _selectedBottomIndex == 2) {
        _selectedBottomIndex = 0;
      }
      _bearerToken = bearerToken;
      _merchantId = merchantId;
      _acqMerchantId = acqMerchantId;
      _clientUniqueId = email;
      _userType = userType;
      _terminalId = terminalId;
      _merchantDropdownItems = merchantDropdownItems;
      _isDashboardEnabled = isDashboardEnabled;
      if (!isTerminalUser && acqMerchantId == '0') {
        _selectedTransactionTab = TransactionTab.pos;
      }
    });

    _resetStoreScopedState();
    _loadSelectedMerchantData();
  }

  void _resetStoreScopedState() {
    context.read<SoundBoxBloc>().add(const ResetSoundBoxRequested());
    context
        .read<MerchantVpaTxnBloc>()
        .add(const ResetMerchantVpaTxnRequested());
    context.read<SettlementBloc>().add(const ResetSettlementRequested());
  }

  void _loadSelectedMerchantData() {
    _loadPosTransactions(page: 0);

    if (_isAllMerchantSelection) return;

    _loadSettlements(page: 0);
    _loadSoundBoxDevices();
  }

  void _loadSoundBoxDevices() {
    final merchantId = _effectiveMerchantId;

    if (merchantId.isEmpty || _bearerToken.isEmpty) {
      return;
    }

    context.read<SoundBoxBloc>().add(
          GetSoundBoxDevicesRequested(
            merchantId: merchantId,
            bearerToken: _bearerToken,
            clientUniqueId: _clientUniqueId,
          ),
        );
  }

  void _onSoundBoxStateChanged(BuildContext context, SoundBoxState state) {
    if (_isAllMerchantSelection ||
        state is! SoundBoxSuccess ||
        state.devices.isEmpty) {
      return;
    }

    final nextSelectedVpa =
        _selectedVpa != null && state.devices.contains(_selectedVpa)
            ? _selectedVpa
            : state.devices.first;

    if (_selectedVpa == nextSelectedVpa) {
      return;
    }

    setState(() {
      _selectedVpa = nextSelectedVpa;
    });
    _loadMerchantVpaTransactions(page: 0);
  }

  void _onVpaChanged(String? vpa) {
    if (vpa == null || vpa == _selectedVpa) {
      return;
    }

    setState(() {
      _selectedVpa = vpa;
    });
    _loadMerchantVpaTransactions(page: 0);
  }

  void _onTransactionTabSelected(TransactionTab tab) {
    if (_isAllMerchantSelection && tab != TransactionTab.pos) return;

    if (_selectedTransactionTab == tab) {
      return;
    }

    setState(() {
      _selectedTransactionTab = tab;
    });

    if (tab == TransactionTab.qr) {
      _loadMerchantVpaTransactions(page: 0);
      return;
    }

    if (tab == TransactionTab.pos) {
      _loadPosTransactions(page: 0);
      return;
    }

    if (tab == TransactionTab.settlements) {
      _loadSettlements(page: 0);
    }
  }

  void _refreshSelectedTransactions() {
    if (_selectedTransactionTab == TransactionTab.qr) {
      _loadMerchantVpaTransactions(page: 0);
      return;
    }

    if (_selectedTransactionTab == TransactionTab.pos) {
      _loadPosTransactions(page: 0);
      return;
    }

    _loadSettlements(page: 0);
  }

  Future<void> _onMerchantChanged(String? merchantId) async {
    if (merchantId == null || merchantId == _acqMerchantId) {
      return;
    }

    final selectedMerchant = _merchantDropdownItems.firstWhere(
      (item) => item.merchantId == merchantId,
      orElse: () => MerchantDropdownItem(
        merchantId: merchantId,
        shopName: merchantId == '0' ? 'All' : merchantId,
      ),
    );

    await _sessionStorage.setActiveMerchantSelection(
      acqMerchantId: selectedMerchant.merchantId,
      shopName: selectedMerchant.displayLabel,
    );

    if (!mounted) return;

    _resetStoreScopedState();

    setState(() {
      _acqMerchantId = selectedMerchant.merchantId;
      _selectedVpa = null;
      // The aggregated "All" option only supports POS summary/history APIs,
      // so we snap back to the POS tab immediately after selection.
      if (selectedMerchant.merchantId == '0') {
        _selectedTransactionTab = TransactionTab.pos;
      }
    });

    _loadSelectedMerchantData();
  }

  void _openTransactionFilter() {
    context.push(
      AppRoutes.transactionFilter,
      extra: TransactionFilterData(
        tab: _selectedTransactionTab,
        creditVpa: _selectedVpa ?? '',
        from: '',
        to: '',
        dateLabel: '',
      ),
    );
  }

  void _loadMerchantVpaTransactions({required int page}) {
    final selectedVpa = _resolveSelectedVpa();

    if (_bearerToken.isEmpty || selectedVpa == null) {
      if (_bearerToken.isNotEmpty && _effectiveMerchantId.isNotEmpty) {
        _loadSoundBoxDevices();
      }
      return;
    }

    context.read<MerchantVpaTxnBloc>().add(
          GetMerchantVpaTxnDataRequested(
            bearerToken: _bearerToken,
            creditVpa: selectedVpa,
            from: _homeTransactionFromDate,
            to: _homeTransactionToDate,
            page: page,
            size: _transactionPageSize,
          ),
        );
  }

  String? _resolveSelectedVpa() {
    final soundBoxState = context.read<SoundBoxBloc>().state;
    final devices = soundBoxState.devices;

    if (_selectedVpa != null && devices.contains(_selectedVpa)) {
      return _selectedVpa;
    }

    if (_selectedVpa != null && devices.isEmpty) {
      return _selectedVpa;
    }

    if (devices.isEmpty) {
      return null;
    }

    final nextVpa = devices.first;

    if (mounted && _selectedVpa != nextVpa) {
      setState(() {
        _selectedVpa = nextVpa;
      });
    }

    return nextVpa;
  }

  void _loadPosTransactions({required int page}) {
    final useMidEndpoint = _acqMerchantId == '0';
    final posMerchantId = useMidEndpoint ? _merchantId : _effectiveMerchantId;

    if (_bearerToken.isEmpty || posMerchantId.isEmpty) {
      return;
    }

    context.read<PosTransactionBloc>().add(
          GetPosTransactionsRequested(
            bearerToken: _bearerToken,
            clientUniqueId: _clientUniqueId,
            merchantId: useMidEndpoint ? '' : posMerchantId,
            mid: useMidEndpoint ? posMerchantId : null,
            acquirerId: 'OMAIND',
            page: useMidEndpoint ? 0 : page,
            size: useMidEndpoint ? 1 : _transactionPageSize,
            recordFrom: _homeTransactionFromDate,
            recordTo: _homeTransactionToDate,
            terminalId: _isTerminalUser ? _terminalId : null,
            useMidEndpoint: useMidEndpoint,
          ),
        );
  }

  void _loadSettlements({required int page}) {
    final settlementMerchantId = _effectiveMerchantId;

    if (_bearerToken.isEmpty || settlementMerchantId.isEmpty) {
      return;
    }

    final formatter = DateFormat('yyyy-MM-dd');
    final fromDate = formatter.format(_homeTransactionStartDate);
    final toDate = formatter.format(DateTime.now());

    context.read<SettlementBloc>().add(
          GetSettlementHistoryRequested(
            bearerToken: _bearerToken,
            merchantId: settlementMerchantId,
            fromDate: fromDate,
            toDate: toDate,
            page: page,
            size: _transactionPageSize,
          ),
        );
  }

  bool get _isTerminalUser => _userType == 'terminal';

  String get _effectiveMerchantId {
    if (_acqMerchantId.isEmpty || _acqMerchantId == '0') {
      return _merchantId;
    }

    return _acqMerchantId;
  }

  void _onBottomNavItemSelected(int index) {
    if (index == 2 && !_isDashboardEnabled) {
      return;
    }

    if (_selectedBottomIndex == index) {
      return;
    }

    if (index == 0 && GoRouterState.of(context).uri.path != AppRoutes.home) {
      NavigationHelper.goHomeAndClearStack(context, AppRoutes.home);
      return;
    }

    setState(() {
      _selectedBottomIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (kIsWeb &&
        AppBreakpoints.isTabletOrLarger(context) &&
        _selectedBottomIndex == 0) {
      return BlocListener<SoundBoxBloc, SoundBoxState>(
        listener: _onSoundBoxStateChanged,
        child: WebHomeDashboard(
          merchantId: _effectiveMerchantId,
          showDashboard: _isDashboardEnabled,
          merchantItems: _merchantDropdownItems,
          selectedMerchantId: _acqMerchantId,
          onMerchantChanged: _onMerchantChanged,
          isAllMerchantSelection: _isAllMerchantSelection,
          selectedTab: _selectedTransactionTab,
          selectedVpa: _selectedVpa,
          onTabSelected: _onTransactionTabSelected,
          onNavigationSelected: _onBottomNavItemSelected,
          onViewAll: _openTransactionFilter,
          onRefresh: _refreshSelectedTransactions,
          onPosPageRequested: (page) => _loadPosTransactions(page: page),
          onQrPageRequested: (page) => _loadMerchantVpaTransactions(page: page),
          onSettlementPageRequested: (page) => _loadSettlements(page: page),
          onVpaChanged: _onVpaChanged,
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: context.appBackground,
        systemNavigationBarColor: Colors.black,
      ),
      child: CommonScaffold(
        selectedIndex: _selectedBottomIndex,
        onBottomNavItemSelected: _onBottomNavItemSelected,
        showDashboard: _isDashboardEnabled,
        bottomAction: _selectedBottomIndex == 0
            ? ViewAllTransactionsButton(
                label: _selectedTransactionTab == TransactionTab.settlements
                    ? context.tr('view_all_settlements')
                    : context.tr('view_all_transactions'),
                onPressed: _openTransactionFilter,
              )
            : null,
        body: _buildSelectedBody(),
      ),
    );
  }

  Widget _buildSelectedBody() {
    switch (_selectedBottomIndex) {
      case 1:
        return const SupportPage();
      case 2:
        return const DashboardPage();
      case 3:
        return const ProfilePage();
      case 0:
      default:
        return _buildHomeBody();
    }
  }

  Widget _buildHomeBody() {
    return BlocListener<SoundBoxBloc, SoundBoxState>(
      listener: _onSoundBoxStateChanged,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!kIsWeb) ...[
              const HomeHeader(),
              const SizedBox(height: 18),
            ],
            MerchantOverview(key: ValueKey(_acqMerchantId)),
            if (!_isTerminalUser && _merchantDropdownItems.isNotEmpty) ...[
              const SizedBox(height: 10),
              _MerchantDropdown(
                items: _merchantDropdownItems,
                selectedMerchantId: _acqMerchantId.isEmpty
                    ? _merchantDropdownItems.first.merchantId
                    : _acqMerchantId,
                onChanged: _onMerchantChanged,
              ),
            ],
            const SizedBox(height: 12),
            _buildHomeSummaryCard(),
            if (!_isAllMerchantSelection) ...[
              const SizedBox(height: 12),
              QuickActions(
                selectedTab: _selectedTransactionTab,
                onTabSelected: _onTransactionTabSelected,
              ),
              const SizedBox(height: 12),
              if (_selectedTransactionTab == TransactionTab.qr) ...[
                BlocBuilder<SoundBoxBloc, SoundBoxState>(
                  builder: (context, state) {
                    return VpaSelector(
                      isLoading: state is SoundBoxLoading,
                      vpas: state.devices,
                      selectedVpa: state.devices.contains(_selectedVpa)
                          ? _selectedVpa
                          : null,
                      onChanged: _onVpaChanged,
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
              RecentTransactionsHeader(
                title: _selectedTransactionTab == TransactionTab.settlements
                    ? context.tr('today_settlements')
                    : _selectedTransactionTab.localizedTitle(context),
                onRefresh: _refreshSelectedTransactions,
              ),
              const SizedBox(height: 10),
            ] else ...[
              const SizedBox(height: 12),
              RecentTransactionsHeader(
                title: context.tr('all_merchants'),
                onRefresh: _refreshSelectedTransactions,
              ),
              const SizedBox(height: 10),
            ],
            _buildSelectedTransactionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeSummaryCard() {
    if (_isAllMerchantSelection ||
        _selectedTransactionTab == TransactionTab.pos) {
      return BlocBuilder<PosTransactionBloc, PosTransactionState>(
        builder: (context, state) => SuccessSummaryCard(
          transactionCount: state.totalElements,
          amount: state.totalAmount,
        ),
      );
    }

    if (_selectedTransactionTab == TransactionTab.settlements) {
      return BlocBuilder<SettlementBloc, SettlementState>(
        builder: (context, state) => SuccessSummaryCard(
          transactionCount: state.transactionCount,
          amount: state.totalAmount,
        ),
      );
    }

    return BlocBuilder<MerchantVpaTxnBloc, MerchantVpaTxnState>(
      builder: (context, state) => SuccessSummaryCard(
        transactionCount: state.totalElements,
        amount: state.totalAmount,
      ),
    );
  }

  Widget _buildSelectedTransactionList() {
    if (_isAllMerchantSelection) {
      return _buildPosTransactionList();
    }

    if (_selectedTransactionTab != TransactionTab.qr) {
      if (_selectedTransactionTab == TransactionTab.pos) {
        return _buildPosTransactionList();
      }

      if (_selectedTransactionTab == TransactionTab.settlements) {
        return _buildSettlementList();
      }

      return _emptyTransactions();
    }

    return BlocBuilder<MerchantVpaTxnBloc, MerchantVpaTxnState>(
      builder: (context, state) {
        return MerchantVpaTransactions(
          transactions: state.transactions,
          isLoading: state is MerchantVpaTxnLoading,
          page: state.page,
          totalPages: state.totalPages,
          totalElements: state.totalElements,
          totalAmount: state.totalAmount,
          onPreviousPage: state.first
              ? null
              : () => _loadMerchantVpaTransactions(
                    page: state.page - 1,
                  ),
          onNextPage: state.last
              ? null
              : () => _loadMerchantVpaTransactions(
                    page: state.page + 1,
                  ),
        );
      },
    );
  }

  Widget _buildSettlementList() {
    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        if (state.isLoading && state.settlements.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            ),
          );
        }

        if (state.settlements.isEmpty) {
          return _buildSettlementSummary(state);
        }

        return _buildSettlementSummary(state);
      },
    );
  }

  Widget _buildSettlementSummary(SettlementState state) {
    final deductions = state.settlements.fold<double>(
      0,
      (total, item) => total + item.gst + item.mdrAmount,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 90),
      child: Column(
        children: [
          _SettlementSummaryRow(
            label: context.tr('settled_amount'),
            subtitle: context.tr('total_amount_settled_today'),
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.primaryPurple,
            amount: state.totalAmount,
          ),
          const SizedBox(height: 10),
          _SettlementSummaryRow(
            label: context.tr('deductions'),
            subtitle: context.tr('total_deductions_today'),
            icon: Icons.percent_rounded,
            iconColor: const Color(0xffB03060),
            amount: deductions,
          ),
          const SizedBox(height: 10),
          _SettlementSummaryRow(
            label: context.tr('pending_settlements'),
            subtitle: context.tr('total_pending_settlements'),
            icon: Icons.schedule_rounded,
            iconColor: const Color(0xffB89116),
            amount: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildPosTransactionList() {
    return BlocBuilder<PosTransactionBloc, PosTransactionState>(
      builder: (context, state) {
        if (state.transactionsLoading &&
            state.transactions.isEmpty &&
            state.terminalSummaries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(color: AppColors.primaryPurple),
            ),
          );
        }

        if (_isAllMerchantSelection) {
          return _buildAllMerchantTerminalSummaryList(state);
        }

        if (state.transactions.isEmpty) {
          return _emptyTransactions();
        }

        return Column(
          children: [
            ...state.transactions.map(
              (transaction) => TransactionListItem.fromPos(
                transaction: transaction,
                cardStyle: true,
                compact: true,
                onInfoPressed: () {
                  context.push(AppRoutes.transactionInvoice,
                      extra: transaction);
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: state.transactionsLoading || state.first
                      ? null
                      : () => _loadPosTransactions(page: state.page - 1),
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
                  onPressed: state.transactionsLoading || state.last
                      ? null
                      : () => _loadPosTransactions(page: state.page + 1),
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

  Widget _buildAllMerchantTerminalSummaryList(PosTransactionState state) {
    if (state.terminalSummaries.isEmpty) {
      return _emptyTransactions();
    }

    return Column(
      children: [
        ...state.terminalSummaries.map(
          (summary) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: context.appElevatedSurface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: context.appShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${context.tr('terminals')}: ${summary.serialNumber.isEmpty ? context.tr('not_available') : summary.serialNumber}',
                    style: AppTextStyle.h3.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.tr('total_transactions')}: ${summary.count}',
                    style: AppTextStyle.h3.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${context.tr('total_amount')}: Rs ${summary.totalAmount.toStringAsFixed(0)}',
                    style: AppTextStyle.h3.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyTransactions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 120),
        child: Text(
          context.tr('no_transactions'),
          style: AppTextStyle.h3.copyWith(
            color: context.appTextSecondary,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SettlementSummaryRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final double amount;

  const _SettlementSummaryRow({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: context.appShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.h4.copyWith(
                    color: context.appTextPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.h5.copyWith(
                    color: context.appTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Rs. ${amount.toStringAsFixed(1)}',
            style: AppTextStyle.h3.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.appTextSecondary,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _MerchantDropdown extends StatelessWidget {
  final List<MerchantDropdownItem> items;
  final String selectedMerchantId;
  final ValueChanged<String?> onChanged;

  const _MerchantDropdown({
    required this.items,
    required this.selectedMerchantId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedExists =
        items.any((item) => item.merchantId == selectedMerchantId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedExists ? selectedMerchantId : items.first.merchantId,
          isExpanded: true,
          dropdownColor: context.appSurface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primaryPurple,
          ),
          items: items.map((item) {
            final label =
                item.isAll ? context.tr('all_merchants') : item.displayLabel;

            return DropdownMenuItem<String>(
              value: item.merchantId,
              child: Row(
                children: [
                  Icon(
                    Icons.storefront_rounded,
                    color: AppColors.primaryPurple,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.h5.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
