import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/common/common_scaffold.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/logout_helper.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';
import 'package:anet_merchants/features/transactions/presentation/bloc/pos_transaction/pos_transaction_bloc.dart';
import 'package:anet_merchants/features/devices/presentation/bloc/sound_box/sound_box_bloc.dart';
import 'package:anet_merchants/features/transactions/presentation/pages/transaction_filter_data.dart';
import 'package:anet_merchants/features/shared/presentation/widgets/merchant_overview.dart';
import 'package:anet_merchants/features/shared/presentation/widgets/quick_actions.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TransactionFilterPage extends StatefulWidget {
  final TransactionTab tab;
  final String? initialVpa;

  const TransactionFilterPage({
    super.key,
    this.tab = TransactionTab.qr,
    this.initialVpa,
  });

  @override
  State<TransactionFilterPage> createState() => _TransactionFilterPageState();
}

class _TransactionFilterPageState extends State<TransactionFilterPage> {
  static const String _allTerminalsValue = 'ALL';

  final SessionStorage _sessionStorage = SessionStorage();

  _DateFilter? _dateFilter;
  _SearchBy _searchBy = _SearchBy.date;
  _CodeSearchType _codeSearchType = _CodeSearchType.rrn;
  DateTimeRange? _customDateRange;
  String? _selectedVpa;
  String? _selectedTerminalId = _allTerminalsValue;
  String _paymentMode = 'ALL';
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedVpa = widget.initialVpa;
    _loadDevices();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    if (widget.tab == TransactionTab.pos) {
      await _loadPosTerminals();
      return;
    }

    final bearerToken = await _sessionStorage.bearerToken;
    final merchantId = await _sessionStorage.merchantId;
    final acqMerchantId = await _sessionStorage.activeAcqMerchantId;
    final deviceMerchantId = acqMerchantId.isEmpty || acqMerchantId == '0'
        ? merchantId
        : acqMerchantId;
    final email = await _sessionStorage.email;

    if (!mounted || bearerToken.isEmpty || deviceMerchantId.isEmpty) {
      return;
    }

    context.read<SoundBoxBloc>().add(
          GetSoundBoxDevicesRequested(
            merchantId: deviceMerchantId,
            bearerToken: bearerToken,
            clientUniqueId: email,
          ),
        );
  }

  Future<void> _loadPosTerminals() async {
    final bearerToken = await _sessionStorage.bearerToken;
    final merchantId = await _sessionStorage.merchantId;
    final acqMerchantId = await _sessionStorage.activeAcqMerchantId;
    final terminalMerchantId = acqMerchantId.isEmpty || acqMerchantId == '0'
        ? merchantId
        : acqMerchantId;

    if (!mounted || bearerToken.isEmpty || terminalMerchantId.isEmpty) {
      return;
    }

    context.read<PosTransactionBloc>().add(
          GetPosTerminalsRequested(
            bearerToken: bearerToken,
            merchantId: terminalMerchantId,
          ),
        );
  }

  void _syncSelectedVpa(List<String> devices) {
    if (devices.isEmpty || _selectedVpa != null) {
      return;
    }

    setState(() {
      _selectedVpa = devices.first;
    });
  }

  void _syncSelectedTerminal(List<String> terminals) {
    if (_selectedTerminalId != null) {
      return;
    }

    setState(() {
      _selectedTerminalId = _allTerminalsValue;
    });
  }

  void _onBottomNavItemSelected(int index) {
    if (index == 3) {
      NavigationHelper.goToRoot(context, AppRoutes.profile);
      return;
    }
    NavigationHelper.goHomeAndClearStack(context, AppRoutes.home);
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final fallbackStart = _customDateRange?.start ??
        now.subtract(
          const Duration(days: 6),
        );
    final fallbackEnd = _customDateRange?.end ?? now;

    final fromDate = await _pickCalendarDate(
      initialDate: fallbackStart,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );

    if (fromDate == null || !mounted) {
      return;
    }

    final toDate = await _pickCalendarDate(
      initialDate: fallbackEnd.isBefore(fromDate) ? fromDate : fallbackEnd,
      firstDate: fromDate,
      lastDate: DateTime(now.year + 1),
    );

    if (toDate == null || !mounted) {
      return;
    }

    setState(() {
      _customDateRange = DateTimeRange(start: fromDate, end: toDate);
      _dateFilter = _DateFilter.custom;
    });
  }

  Future<DateTime?> _pickCalendarDate({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: context.tr('select_date'),
      cancelText: context.tr('cancel'),
      confirmText: context.tr('ok'),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final pickerSurface =
            isDark ? const Color(0xff1A1A22) : const Color(0xffF7F0FA);

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryPurple,
                  onPrimary: Colors.white,
                  surface: pickerSurface,
                  onSurface: context.appTextPrimary,
                ),
            dialogTheme: DialogThemeData(
              backgroundColor: pickerSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: pickerSurface,
              headerBackgroundColor: pickerSurface,
              headerForegroundColor: context.appTextPrimary,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                if (states.contains(WidgetState.disabled)) {
                  return context.appTextSecondary;
                }
                return context.appTextPrimary;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? AppColors.primaryPurple
                    : null;
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? Colors.white
                    : AppColors.primaryPurple;
              }),
              todayBorder: BorderSide(color: AppColors.primaryPurple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
                textStyle: AppTextStyle.h4.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _reset() {
    final devices = context.read<SoundBoxBloc>().state.devices;

    setState(() {
      _selectedVpa = devices.isEmpty ? null : devices.first;
      _selectedTerminalId = _allTerminalsValue;
      _dateFilter = null;
      _searchBy = _SearchBy.date;
      _codeSearchType = _CodeSearchType.rrn;
      _paymentMode = 'ALL';
      _customDateRange = null;
      _codeController.clear();
    });
  }

  void _apply() {
    if (widget.tab == TransactionTab.settlements) {
      _applySettlementFilter();
      return;
    }

    if (widget.tab == TransactionTab.pos) {
      _applyPosFilter();
      return;
    }

    final selectedVpa = _selectedVpa;
    final activeRange = _activeRange;

    if (activeRange == null) {
      _showValidationDialog(context.tr('select_date_range'));
      return;
    }

    if (selectedVpa == null || selectedVpa.isEmpty) {
      _showValidationDialog(context.tr('select_vpa'));
      return;
    }

    context.push(
      AppRoutes.transactions,
      extra: TransactionFilterData(
        tab: widget.tab,
        creditVpa: selectedVpa,
        from: activeRange.from,
        to: activeRange.to,
        dateLabel: activeRange.label,
      ),
    );
  }

  void _applySettlementFilter() {
    final activeRange = _activeSettlementRange;

    if (activeRange == null) {
      _showValidationDialog(context.tr('select_date_range'));
      return;
    }

    context.push(
      AppRoutes.settlementDashboard,
      extra: TransactionFilterData(
        tab: widget.tab,
        from: activeRange.from,
        to: activeRange.to,
        dateLabel: activeRange.label,
      ),
    );
  }

  void _applyPosFilter() {
    final isCodeSearch = _searchBy == _SearchBy.rrnOrAppCode;
    final codeValue = _codeController.text.trim();

    if (isCodeSearch && codeValue.isEmpty) {
      _showValidationDialog(
        _codeSearchType == _CodeSearchType.rrn
            ? context.tr('enter_rrn')
            : context.tr('enter_app_code'),
      );
      return;
    }

    final activeRange = _activeRange;
    final hasTerminal = _selectedTerminalId != null &&
        _selectedTerminalId!.isNotEmpty &&
        _selectedTerminalId != _allTerminalsValue;

    if (!isCodeSearch && activeRange == null && !hasTerminal) {
      _showValidationDialog(
        context.tr('select_filter_any'),
      );
      return;
    }

    context.push(
      AppRoutes.transactions,
      extra: TransactionFilterData(
        tab: widget.tab,
        from: isCodeSearch ? '' : activeRange?.from ?? '',
        to: isCodeSearch ? '' : activeRange?.to ?? '',
        dateLabel: isCodeSearch
            ? context.tr('search_result')
            : activeRange?.label ?? '',
        terminalId: isCodeSearch || _selectedTerminalId == _allTerminalsValue
            ? ''
            : _selectedTerminalId ?? '',
        rrn: isCodeSearch && _codeSearchType == _CodeSearchType.rrn
            ? codeValue
            : '',
        authCode: isCodeSearch && _codeSearchType == _CodeSearchType.appCode
            ? codeValue
            : '',
        sourceOfTxn: _paymentMode,
        searchedByCode: isCodeSearch,
      ),
    );
  }

  Future<void> _showValidationDialog(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            context.tr('filter_required'),
            style: AppTextStyle.h4.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            message,
            style: AppTextStyle.h5.copyWith(
              color: context.appTextSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.tr('ok'),
                style: AppTextStyle.h5.copyWith(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      selectedIndex: 0,
      onBottomNavItemSelected: _onBottomNavItemSelected,
      bottomAction: kIsWeb
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: _buildFilterActions(),
            ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SoundBoxBloc, SoundBoxState>(
            listener: (context, state) => _syncSelectedVpa(state.devices),
          ),
          BlocListener<PosTransactionBloc, PosTransactionState>(
            listener: (context, state) =>
                _syncSelectedTerminal(state.terminals),
          ),
        ],
        child: kIsWeb ? _buildWebFilterLayout() : _buildMobileFilterLayout(),
      ),
    );
  }

  Widget _buildMobileFilterLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TransactionPageHeader(),
          const SizedBox(height: 30),
          const MerchantOverview(),
          const SizedBox(height: 30),
          _buildFilterContent(),
        ],
      ),
    );
  }

  Widget _buildWebFilterLayout() {
    final compact = MediaQuery.sizeOf(context).width < 720;

    return SingleChildScrollView(
      padding: EdgeInsets.all(compact ? 12 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Container(
            padding: EdgeInsets.all(compact ? 16 : 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffE9E2F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x100D0620),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
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
                      tooltip: context.tr('back'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _webFilterTitle,
                      style: AppTextStyle.h3.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildFilterContent(),
                const SizedBox(height: 30),
                _buildFilterActions(isWeb: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _webFilterTitle {
    switch (widget.tab) {
      case TransactionTab.pos:
        return context.tr('payment_tid');
      case TransactionTab.qr:
        return context.tr('vpa');
      case TransactionTab.settlements:
        return context.tr('settlements');
    }
  }

  Widget _buildFilterContent() {
    if (widget.tab == TransactionTab.pos) {
      return _buildPosFilterContent();
    }

    if (widget.tab == TransactionTab.settlements) {
      return _buildSettlementFilterContent();
    }

    return _buildQrFilterContent();
  }

  Widget _buildFilterActions({bool isWeb = false}) {
    final resetButton = SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _reset,
        icon: const Icon(Icons.restart_alt_rounded),
        label: Text(context.tr('reset')),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xffF34D4D),
          side: const BorderSide(color: Color(0xffF34D4D)),
          textStyle: AppTextStyle.h4.copyWith(fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
    final applyButton = SizedBox(
      height: 54,
      child: isWeb
          ? OutlinedButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(context.tr('apply')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
                side: BorderSide(color: AppColors.primaryPurple),
                textStyle:
                    AppTextStyle.h4.copyWith(fontWeight: FontWeight.w900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(context.tr('apply')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                textStyle: AppTextStyle.h4WhiteColor
                    .copyWith(fontWeight: FontWeight.w900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );

    if (!isWeb) {
      return Row(children: [
        SizedBox(width: 112, child: resetButton),
        const SizedBox(width: 14),
        Expanded(child: applyButton),
      ]);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final resetWidth = constraints.maxWidth < 520 ? 112.0 : 208.0;
        return Row(children: [
          SizedBox(width: resetWidth, child: resetButton),
          const SizedBox(width: 14),
          Expanded(child: applyButton),
        ]);
      },
    );
  }

  Widget _buildQrFilterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 34),
        Text(
          context.tr('vpa'),
          style: AppTextStyle.h4.copyWith(
            color: context.appTextPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<SoundBoxBloc, SoundBoxState>(
          builder: (context, state) {
            return _FilterDropdown(
              icon: Icons.point_of_sale_rounded,
              isLoading: state is SoundBoxLoading,
              values: state.devices,
              selectedValue:
                  state.devices.contains(_selectedVpa) ? _selectedVpa : null,
              hint: context.tr('select'),
              onChanged: (value) {
                setState(() {
                  _selectedVpa = value;
                });
              },
            );
          },
        ),
        const SizedBox(height: 20),
        _buildDateSection(),
      ],
    );
  }

  Widget _buildPosFilterContent() {
    if (kIsWeb) {
      return _buildWebPosFilterContent();
    }

    const sectionInset = 36.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: sectionInset),
          child: Text(
            context.tr('payment_tid'),
            style: AppTextStyle.h4.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: sectionInset),
          child: Text(
            context.tr('search_by'),
            style: AppTextStyle.h4.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const SizedBox(width: sectionInset),
            _SearchOption(
              label: context.tr('date'),
              selected: _searchBy == _SearchBy.date,
              onTap: () => setState(() => _searchBy = _SearchBy.date),
            ),
            const SizedBox(width: 22),
            _SearchOption(
              label: context.tr('rrn_app_code'),
              selected: _searchBy == _SearchBy.rrnOrAppCode,
              onTap: () => setState(() => _searchBy = _SearchBy.rrnOrAppCode),
            ),
          ],
        ),
        const SizedBox(height: 22),
        if (_searchBy == _SearchBy.date) ...[
          _buildTerminalRow(),
          const SizedBox(height: 22),
          _buildDateSection(),
          const SizedBox(height: 24),
          _buildPaymentModeRow(),
        ] else ...[
          _buildCodeSearchDropdown(),
          const SizedBox(height: 20),
          _buildCodeInput(),
        ],
      ],
    );
  }

  Widget _buildWebPosFilterContent() {
    final isDateSearch = _searchBy == _SearchBy.date;

    return LayoutBuilder(
      builder: (context, constraints) {
        final selector = isDateSearch
            ? _buildWebTerminalDropdown()
            : _buildCodeSearchDropdown();
        final narrow = constraints.maxWidth < 720;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('search_by'),
              style: AppTextStyle.h4.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            if (narrow) ...[
              _buildWebSearchOptions(isDateSearch),
              const SizedBox(height: 16),
              selector,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: _buildWebSearchOptions(isDateSearch),
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(flex: 2, child: selector),
                ],
              ),
            const SizedBox(height: 22),
            if (isDateSearch) ...[
              _buildDateSection(),
              const SizedBox(height: 24),
              _buildPaymentModeRow(),
            ] else ...[
              _buildCodeInput(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildWebSearchOptions(bool isDateSearch) => Row(
        children: [
          _SearchOption(
            label: context.tr('date'),
            selected: isDateSearch,
            onTap: () => setState(() => _searchBy = _SearchBy.date),
          ),
          const SizedBox(width: 22),
          _SearchOption(
            label: context.tr('rrn_app_code'),
            selected: !isDateSearch,
            onTap: () => setState(() => _searchBy = _SearchBy.rrnOrAppCode),
          ),
        ],
      );

  Widget _buildWebTerminalDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('tid_vpa'),
          style: AppTextStyle.h4.copyWith(
            color: context.appTextPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<PosTransactionBloc, PosTransactionState>(
          builder: (context, state) {
            final terminals = <String>[_allTerminalsValue, ...state.terminals];
            return _FilterDropdown(
              icon: Icons.point_of_sale_rounded,
              isLoading: state.terminalsLoading,
              values: terminals,
              selectedValue: terminals.contains(_selectedTerminalId)
                  ? _selectedTerminalId
                  : _allTerminalsValue,
              hint: context.tr('select'),
              onChanged: (value) {
                setState(() {
                  _selectedTerminalId = value ?? _allTerminalsValue;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTerminalRow() {
    if (kIsWeb) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('tid_vpa'),
            style: AppTextStyle.h4.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<PosTransactionBloc, PosTransactionState>(
            builder: (context, state) {
              final terminals = <String>[
                _allTerminalsValue,
                ...state.terminals,
              ];

              return _FilterDropdown(
                icon: Icons.point_of_sale_rounded,
                isLoading: state.terminalsLoading,
                values: terminals,
                selectedValue: terminals.contains(_selectedTerminalId)
                    ? _selectedTerminalId
                    : _allTerminalsValue,
                hint: context.tr('select'),
                onChanged: (value) {
                  setState(() {
                    _selectedTerminalId = value ?? _allTerminalsValue;
                  });
                },
              );
            },
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            context.tr('tid_vpa'),
            style: AppTextStyle.h4.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BlocBuilder<PosTransactionBloc, PosTransactionState>(
            builder: (context, state) {
              final terminals = <String>[
                _allTerminalsValue,
                ...state.terminals,
              ];

              return _FilterDropdown(
                icon: Icons.point_of_sale_rounded,
                isLoading: state.terminalsLoading,
                values: terminals,
                selectedValue: terminals.contains(_selectedTerminalId)
                    ? _selectedTerminalId
                    : _allTerminalsValue,
                hint: context.tr('select'),
                onChanged: (value) {
                  setState(() {
                    _selectedTerminalId = value ?? _allTerminalsValue;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettlementFilterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 34),
        _buildDateSection(),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: AppTextStyle.h4.copyWith(
            color: context.appTextPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        ..._availableDateFilters.map(_buildDateOption),
      ],
    );
  }

  List<_DateFilter> get _availableDateFilters => [
        _DateFilter.today,
        _DateFilter.yesterday,
        _DateFilter.last7Days,
        _DateFilter.lastMonth,
        if (kIsWeb && kDebugMode) _DateFilter.last3Years,
        _DateFilter.custom,
      ];

  Widget _buildPaymentModeRow() {
    if (kIsWeb) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('payment_mode'),
            style: AppTextStyle.h4.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          _FilterDropdown(
            icon: Icons.credit_card_rounded,
            values: const ['ALL', 'CARD'],
            selectedValue: _paymentMode,
            hint: 'ALL',
            onChanged: (value) {
              setState(() {
                _paymentMode = value ?? 'ALL';
              });
            },
          ),
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            context.tr('payment_mode'),
            style: AppTextStyle.h4.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: _FilterDropdown(
            icon: Icons.credit_card_rounded,
            values: const ['ALL', 'CARD'],
            selectedValue: _paymentMode,
            hint: 'ALL',
            onChanged: (value) {
              setState(() {
                _paymentMode = value ?? 'ALL';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCodeSearchDropdown() {
    return _FilterDropdown(
      icon: Icons.receipt_long_rounded,
      values: const ['RRN', 'App Code'],
      selectedValue:
          _codeSearchType == _CodeSearchType.rrn ? 'RRN' : 'App Code',
      hint: 'RRN',
      onChanged: (value) {
        setState(() {
          _codeSearchType = value == 'App Code'
              ? _CodeSearchType.appCode
              : _CodeSearchType.rrn;
          _codeController.clear();
        });
      },
    );
  }

  Widget _buildCodeInput() {
    final label = _codeSearchType == _CodeSearchType.rrn
        ? context.tr('enter_rrn_hint')
        : context.tr('enter_app_code_hint');

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.appSurfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            Icons.pin_rounded,
            color: AppColors.primaryPurple,
            size: 30,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: TextField(
              controller: _codeController,
              style: AppTextStyle.h5.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: label,
                hintStyle: AppTextStyle.h5.copyWith(
                  color: context.appTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _codeController.clear,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.primaryPurple,
            iconSize: 32,
            tooltip: context.tr('clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOption(_DateFilter filter) {
    final selected = _dateFilter == filter;

    return InkWell(
      onTap: () {
        if (filter == _DateFilter.custom) {
          _selectCustomDateRange();
          return;
        }

        setState(() {
          _dateFilter = filter;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            _DateSelectorDot(selected: selected),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _labelFor(filter),
                style: AppTextStyle.h5.copyWith(
                  color: context.appTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed:
                  filter == _DateFilter.custom ? _selectCustomDateRange : null,
              icon: const Icon(Icons.calendar_month_outlined),
              color:
                  selected ? AppColors.primaryPurple : context.appTextSecondary,
              iconSize: 26,
              tooltip: context.tr('select_date_range_tooltip'),
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(_DateFilter filter) {
    final now = DateTime.now();

    switch (filter) {
      case _DateFilter.today:
        return '${context.tr('today')} - ${DateFormat('d MMM yyyy').format(now)}';
      case _DateFilter.yesterday:
        return '${context.tr('yesterday')} - ${DateFormat('d MMM yyyy').format(now.subtract(const Duration(days: 1)))}';
      case _DateFilter.last7Days:
        return context.tr('last_7_days');
      case _DateFilter.lastMonth:
        return context.tr('last_1_month');
      case _DateFilter.last3Years:
        return context.tr('last_3_years');
      case _DateFilter.custom:
        if (_customDateRange == null) {
          return context.tr('custom_date_range');
        }
        return '${DateFormat('d MMM yyyy').format(_customDateRange!.start)} - ${DateFormat('d MMM yyyy').format(_customDateRange!.end)}';
    }
  }

  _ActiveDateRange? get _activeRange {
    final dateFilter = _dateFilter;
    if (dateFilter == null) {
      return null;
    }

    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy');

    switch (dateFilter) {
      case _DateFilter.today:
        return _ActiveDateRange(
          from: formatter.format(now),
          to: formatter.format(now),
          label: _labelFor(_DateFilter.today),
        );
      case _DateFilter.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return _ActiveDateRange(
          from: formatter.format(yesterday),
          to: formatter.format(yesterday),
          label: _labelFor(_DateFilter.yesterday),
        );
      case _DateFilter.last7Days:
        return _ActiveDateRange(
          from: formatter.format(now.subtract(const Duration(days: 6))),
          to: formatter.format(now),
          label: _labelFor(_DateFilter.last7Days),
        );
      case _DateFilter.lastMonth:
        return _ActiveDateRange(
          from: formatter.format(DateTime(now.year, now.month - 1, now.day)),
          to: formatter.format(now),
          label: _labelFor(_DateFilter.lastMonth),
        );
      case _DateFilter.last3Years:
        return _ActiveDateRange(
          from: formatter.format(DateTime(now.year - 3, now.month, now.day)),
          to: formatter.format(now),
          label: _labelFor(_DateFilter.last3Years),
        );
      case _DateFilter.custom:
        final range = _customDateRange;
        if (range == null) {
          return null;
        }
        return _ActiveDateRange(
          from: formatter.format(range.start),
          to: formatter.format(range.end),
          label: _labelFor(_DateFilter.custom),
        );
    }
  }

  _ActiveDateRange? get _activeSettlementRange {
    final dateFilter = _dateFilter;
    if (dateFilter == null) {
      return null;
    }

    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');

    switch (dateFilter) {
      case _DateFilter.today:
        return _ActiveDateRange(
          from: formatter.format(now),
          to: formatter.format(now),
          label: _labelFor(_DateFilter.today),
        );
      case _DateFilter.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return _ActiveDateRange(
          from: formatter.format(yesterday),
          to: formatter.format(yesterday),
          label: _labelFor(_DateFilter.yesterday),
        );
      case _DateFilter.last7Days:
        return _ActiveDateRange(
          from: formatter.format(now.subtract(const Duration(days: 7))),
          to: formatter.format(now),
          label: _labelFor(_DateFilter.last7Days),
        );
      case _DateFilter.lastMonth:
        return _ActiveDateRange(
          from: formatter.format(now.subtract(const Duration(days: 30))),
          to: formatter.format(now),
          label: _labelFor(_DateFilter.lastMonth),
        );
      case _DateFilter.last3Years:
        return _ActiveDateRange(
          from: formatter.format(DateTime(now.year - 3, now.month, now.day)),
          to: formatter.format(now),
          label: _labelFor(_DateFilter.last3Years),
        );
      case _DateFilter.custom:
        final range = _customDateRange;
        if (range == null) {
          return null;
        }
        return _ActiveDateRange(
          from: formatter.format(range.start),
          to: formatter.format(range.end),
          label: _labelFor(_DateFilter.custom),
        );
    }
  }
}

class _FilterDropdown extends StatelessWidget {
  final IconData icon;
  final List<String> values;
  final String? selectedValue;
  final String hint;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.icon,
    required this.values,
    required this.selectedValue,
    required this.hint,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.appSurfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primaryPurple,
            size: 30,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: isLoading
                ? Text(
                    context.tr('loading'),
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedValue,
                      isExpanded: true,
                      dropdownColor: context.appSurface,
                      style: AppTextStyle.h5.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primaryPurple,
                      ),
                      hint: Text(
                        hint,
                        style: AppTextStyle.h5.copyWith(
                          color: context.appTextSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      items: values
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: values.isEmpty ? null : onChanged,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SearchOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          _DateSelectorDot(selected: selected),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyle.h5.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelectorDot extends StatelessWidget {
  final bool selected;

  const _DateSelectorDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primaryPurple : context.appIconColor,
          width: 2.5,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

class _TransactionPageHeader extends StatelessWidget {
  const _TransactionPageHeader();

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

enum _DateFilter {
  today,
  yesterday,
  last7Days,
  lastMonth,
  last3Years,
  custom,
}

enum _SearchBy {
  date,
  rrnOrAppCode,
}

enum _CodeSearchType {
  rrn,
  appCode,
}

class _ActiveDateRange {
  final String from;
  final String to;
  final String label;

  const _ActiveDateRange({
    required this.from,
    required this.to,
    required this.label,
  });
}
