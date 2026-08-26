import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/common/common_scaffold.dart';
import 'package:anet_merchants/core/common/responsive_layout.dart';
import 'package:anet_merchants/core/di/injection_container.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/services/alert_service.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/logout_helper.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';
import 'package:anet_merchants/core/widgets/loading_action_content.dart';
import 'package:anet_merchants/features/settlements/settlements.dart';
import 'package:anet_merchants/features/shared/shared.dart';
import 'package:anet_merchants/features/transactions/transactions.dart';
import 'package:go_router/go_router.dart';

class TransactionListPage extends StatefulWidget {
  final TransactionFilterData filter;

  const TransactionListPage({
    super.key,
    required this.filter,
  });

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  static const int _pageSize = 10;

  final SessionStorage _sessionStorage = SessionStorage();
  final ScrollController _scrollController = ScrollController();

  String _bearerToken = '';
  String _merchantId = '';
  String _acqMerchantId = '';
  String _clientUniqueId = '';
  bool _isSendingEmail = false;

  bool get _supportsEmailReport => widget.filter.tab != TransactionTab.qr;
  bool get _isAllMerchantSelection =>
      widget.filter.tab == TransactionTab.pos && _acqMerchantId == '0';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadSelectedTransactions(page: 0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!AppBreakpoints.isSingleColumn(context)) return;
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter > 320) return;
    _loadMore();
  }

  void _scheduleLoadMoreIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent > 80) return;
      _loadMore();
    });
  }

  void _loadMore() {
    if (widget.filter.tab == TransactionTab.settlements) {
      final state = context.read<SettlementBloc>().state;
      if (state.isLoading || state.last || state.settlements.isEmpty) return;
      _loadSettlements(page: state.page + 1, append: true);
      return;
    }

    if (widget.filter.tab == TransactionTab.pos) {
      if (_isAllMerchantSelection) return;
      final state = context.read<PosTransactionBloc>().state;
      if (state.transactionsLoading ||
          state.last ||
          state.transactions.isEmpty) {
        return;
      }
      _loadPosTransactions(page: state.page + 1, append: true);
      return;
    }

    final state = context.read<MerchantVpaTxnBloc>().state;
    if (state is MerchantVpaTxnLoading ||
        state.last ||
        state.transactions.isEmpty) {
      return;
    }
    _loadQrTransactions(page: state.page + 1, append: true);
  }

  Future<void> _loadSelectedTransactions({
    required int page,
    bool append = false,
  }) async {
    if (widget.filter.tab == TransactionTab.settlements) {
      await _loadSettlements(page: page, append: append);
      return;
    }

    if (widget.filter.tab == TransactionTab.pos) {
      await _loadPosTransactions(page: page, append: append);
      return;
    }

    await _loadQrTransactions(page: page, append: append);
  }

  Future<void> _loadQrTransactions({
    required int page,
    bool append = false,
  }) async {
    final bearerToken =
        _bearerToken.isEmpty ? await _sessionStorage.bearerToken : _bearerToken;

    if (!mounted || bearerToken.isEmpty) {
      return;
    }

    _bearerToken = bearerToken;

    context.read<MerchantVpaTxnBloc>().add(
          GetMerchantVpaTxnDataRequested(
            bearerToken: bearerToken,
            creditVpa: widget.filter.creditVpa,
            from: widget.filter.from,
            to: widget.filter.to,
            page: page,
            size: _pageSize,
            append: append,
          ),
        );
  }

  Future<void> _loadPosTransactions({
    required int page,
    int? size,
    bool sendTxnReportToMail = false,
    String? creditVpa,
    bool append = false,
  }) async {
    final bearerToken =
        _bearerToken.isEmpty ? await _sessionStorage.bearerToken : _bearerToken;
    final merchantId =
        _merchantId.isEmpty ? await _sessionStorage.merchantId : _merchantId;
    final acqMerchantId = _acqMerchantId.isEmpty
        ? await _sessionStorage.activeAcqMerchantId
        : _acqMerchantId;
    final useMidEndpoint = acqMerchantId == '0';
    final posMerchantId =
        useMidEndpoint || acqMerchantId.isEmpty ? merchantId : acqMerchantId;
    final clientUniqueId =
        _clientUniqueId.isEmpty ? await _sessionStorage.email : _clientUniqueId;

    if (!mounted || bearerToken.isEmpty || posMerchantId.isEmpty) {
      return;
    }

    _bearerToken = bearerToken;
    _merchantId = merchantId;
    _acqMerchantId = acqMerchantId;
    _clientUniqueId = clientUniqueId;

    context.read<PosTransactionBloc>().add(
          GetPosTransactionsRequested(
            bearerToken: bearerToken,
            clientUniqueId: clientUniqueId,
            merchantId: useMidEndpoint ? '' : posMerchantId,
            mid: useMidEndpoint ? posMerchantId : null,
            acquirerId: 'OMAIND',
            page: page,
            size: size ?? _pageSize,
            recordFrom: widget.filter.from,
            recordTo: widget.filter.to,
            rrn: widget.filter.rrn,
            authCode: widget.filter.authCode,
            terminalId: widget.filter.terminalId,
            sourceOfTxn: widget.filter.sourceOfTxn,
            creditVpa: creditVpa,
            useMidEndpoint: useMidEndpoint,
            sendTxnReportToMail: sendTxnReportToMail,
            append: append,
          ),
        );
  }

  Future<void> _loadSettlements({
    required int page,
    bool sendSettlementReportToMail = false,
    bool append = false,
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
            sendSettlementReportToMail: sendSettlementReportToMail,
            append: append,
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
      bottomAction:
          kIsWeb || !_supportsEmailReport ? null : _buildEmailButton(),
      body: AppBreakpoints.isSingleColumn(context)
          ? _buildMobileTransactionLayout()
          : _buildWebTransactionLayout(),
    );
  }

  Widget _buildMobileTransactionLayout() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      children: [
        const _TransactionListHeader(),
        const SizedBox(height: 30),
        const MerchantOverview(),
        const SizedBox(height: 20),
        if (widget.filter.dateLabel.isNotEmpty)
          _DateRangeLabel(widget.filter.dateLabel),
        if (widget.filter.dateLabel.isNotEmpty) const SizedBox(height: 16),
        _buildSummary(),
        const SizedBox(height: 18),
        _buildSelectedTransactionList(),
      ],
    );
  }

  Widget _buildWebTransactionLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWebPageToolbar(),
              const SizedBox(height: 18),
              _buildSummary(),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffE9E2F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildWebTransactionTable(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebPageToolbar() {
    return Row(
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
        if (widget.filter.dateLabel.isNotEmpty) ...[
          const SizedBox(width: 10),
          Expanded(child: _DateRangeLabel(widget.filter.dateLabel)),
        ],
        if (_supportsEmailReport)
          OutlinedButton(
            onPressed: _isSendingEmail ? null : _sendCurrentReportToEmail,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
              disabledForegroundColor: AppColors.primaryPurple,
              side: BorderSide(color: AppColors.primaryPurple),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            child: _isSendingEmail
                ? LoadingActionContent(
                    label: context.tr('sending_email'),
                    color: AppColors.primaryPurple,
                    indicatorSize: 18,
                    textStyle: AppTextStyle.h5.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mail_outline_rounded),
                      const SizedBox(width: 9),
                      Text(context.tr('send_by_email')),
                    ],
                  ),
          ),
      ],
    );
  }

  Widget _buildEmailButton({bool inline = false}) {
    return Padding(
      padding:
          inline ? EdgeInsets.zero : const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isSendingEmail ? null : _sendCurrentReportToEmail,
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
          child: _isSendingEmail
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
  Widget _buildSelectedTransactionList() {
    if (widget.filter.tab == TransactionTab.pos) {
      return _buildPosTransactionList();
    }
    if (widget.filter.tab == TransactionTab.settlements) {
      return _buildSettlementList();
    }
    return _buildQrTransactionList();
  }

  Widget _buildWebTransactionTable() {
    if (widget.filter.tab == TransactionTab.pos) {
      return _buildWebPosTransactionTable();
    }

    if (widget.filter.tab == TransactionTab.settlements) {
      return _buildWebSettlementTable();
    }

    return _buildWebQrTransactionTable();
  }

  Widget _buildWebQrTransactionTable() {
    return BlocBuilder<MerchantVpaTxnBloc, MerchantVpaTxnState>(
      builder: (context, state) {
        if (state is MerchantVpaTxnLoading && state.transactions.isEmpty) {
          return const _LoadingTransactions();
        }
        if (state.transactions.isEmpty) return const _EmptyTransactions();

        return Column(
          children: [
            _WebResultTable(
              isPosTable: false,
              isQrTable: true,
              entries: state.transactions
                  .map(
                    (transaction) => _WebResultEntry(
                      date: transaction.addedOn,
                      amount: 'Rs. ${transaction.transactionAmount}',
                      customerName: _valueOrFallback(transaction.payerName, ''),
                      paymentName:
                          _valueOrFallback(transaction.customerVpa, ''),
                      method: _valueOrFallback(transaction.rrn, ''),
                      category: _valueOrFallback(transaction.refId, ''),
                      status: transaction.status,
                      successful: _isSuccessfulStatus(transaction.status),
                      onTap: () => context.push(
                        AppRoutes.vpaInvoice,
                        extra: transaction,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            _PaginationControls(
              page: state.page,
              totalPages: state.totalPages,
              isLoading: state is MerchantVpaTxnLoading,
              onPreviousPage: state.first
                  ? null
                  : () => _loadQrTransactions(page: state.page - 1),
              onNextPage: state.last
                  ? null
                  : () => _loadQrTransactions(page: state.page + 1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWebPosTransactionTable() {
    return BlocBuilder<PosTransactionBloc, PosTransactionState>(
      builder: (context, state) {
        if (state.transactionsLoading &&
            state.transactions.isEmpty &&
            state.terminalSummaries.isEmpty) {
          return const _LoadingTransactions();
        }

        if (_isAllMerchantSelection) {
          if (state.terminalSummaries.isEmpty) {
            return const _EmptyTransactions();
          }

          return _WebTerminalSummaryTable(
            summaries: state.terminalSummaries,
          );
        }

        if (state.transactions.isEmpty) return const _EmptyTransactions();

        return Column(
          children: [
            _WebResultTable(
              isPosTable: true,
              isQrTable: false,
              entries: state.transactions
                  .map(
                    (transaction) => _WebResultEntry(
                      date:
                          '${transaction.transactionDate} ${transaction.transactionTime}',
                      amount: 'Rs. ${transaction.amount}',
                      paymentName: _valueOrFallback(transaction.terminalId, ''),
                      method: _valueOrFallback(
                        transaction.schemeName,
                        _schemeFromCardNumber(transaction.cardNo),
                      ),
                      category:
                          _posTransactionType(transaction.transactionType),
                      entryMode: _posCardEntryMode(transaction.posEntryMode),
                      status: transaction.responseDesc,
                      successful: transaction.responseCode == '00' ||
                          _isSuccessfulStatus(transaction.responseDesc),
                      onTap: () => context.push(
                        AppRoutes.transactionInvoice,
                        extra: transaction,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            _PaginationControls(
              page: state.page,
              totalPages: state.totalPages,
              isLoading: state.transactionsLoading,
              onPreviousPage: state.first
                  ? null
                  : () => _loadPosTransactions(page: state.page - 1),
              onNextPage: state.last
                  ? null
                  : () => _loadPosTransactions(page: state.page + 1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWebSettlementTable() {
    return BlocBuilder<SettlementBloc, SettlementState>(
      builder: (context, state) {
        if (state.isLoading && state.settlements.isEmpty) {
          return const _LoadingTransactions();
        }
        if (state.settlements.isEmpty) return const _EmptyTransactions();

        return Column(
          children: [
            _WebResultTable(
              isPosTable: false,
              isQrTable: false,
              entries: state.settlements.map(
                (settlement) {
                  final successful =
                      settlement.merPayDone || settlement.reconciled;
                  return _WebResultEntry(
                    date: settlement.tranDate == null
                        ? '-'
                        : settlement.tranDate!
                            .toLocal()
                            .toString()
                            .split(' ')
                            .first,
                    amount:
                        'Rs. ${settlement.totalAmountPayable.toStringAsFixed(2)}',
                    paymentName:
                        _valueOrFallback(settlement.utr, settlement.rrn),
                    method: _valueOrFallback(settlement.mid, '-'),
                    category: '${settlement.transactionCount} transactions',
                    status: successful ? 'Settled' : 'Pending',
                    successful: successful,
                    onTap: () => context.push(
                      AppRoutes.settlementInvoice,
                      extra: settlement,
                    ),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 8),
            _PaginationControls(
              page: state.page,
              totalPages: state.totalPages,
              isLoading: state.isLoading,
              onPreviousPage: state.first
                  ? null
                  : () => _loadSettlements(page: state.page - 1),
              onNextPage: state.last
                  ? null
                  : () => _loadSettlements(page: state.page + 1),
            ),
          ],
        );
      },
    );
  }

  bool _isSuccessfulStatus(String status) {
    final normalized = status.toLowerCase();
    return normalized.contains('success') || normalized.contains('approved');
  }

  String _valueOrFallback(String value, String fallback) {
    return value.trim().isEmpty ? fallback : value;
  }

  String _posCardEntryMode(String value) {
    switch (value.trim()) {
      case '051':
        return 'Chip';
      case '071':
        return 'CTLS';
      default:
        return value.trim().isEmpty ? 'N/A' : value;
    }
  }

  String _posTransactionType(String value) {
    switch (value.trim()) {
      case 'OSAL001':
        return 'SALE';
      case 'VSAL001':
        return 'VOID-SALE';
      default:
        return value.trim().isEmpty ? 'N/A' : value;
    }
  }

  String _schemeFromCardNumber(String value) {
    final cardNumber = value.replaceAll(RegExp(r'\s+|-'), '');
    if (cardNumber.isEmpty) return 'N/A';
    if (cardNumber.startsWith('4')) return 'VISA';
    if (cardNumber.startsWith('5')) return 'MASTERCARD';
    if (cardNumber.startsWith('34') || cardNumber.startsWith('37')) {
      return 'AMERICAN EXPRESS';
    }
    if (cardNumber.startsWith('6')) return 'RUPAY';
    return 'UNKNOWN';
  }

  Future<void> _sendCurrentReportToEmail() async {
    if (_isSendingEmail || !_supportsEmailReport) {
      return;
    }

    setState(() {
      _isSendingEmail = true;
    });

    try {
      if (widget.filter.tab == TransactionTab.settlements) {
        await _sendSettlementReportToEmail();
        return;
      }

      await _sendPosReportToEmail();
    } finally {
      if (mounted) {
        setState(() {
          _isSendingEmail = false;
        });
      }
    }
  }

  Future<void> _sendPosReportToEmail() async {
    final totalTransactions =
        context.read<PosTransactionBloc>().state.totalElements;

    if (totalTransactions <= 0) {
      await _showNoTransactionsAlert();
      return;
    }

    final response = await _requestPosEmailReport(
      size: totalTransactions,
    );

    await _showEmailResult(response);
  }

  Future<void> _sendSettlementReportToEmail() async {
    final totalTransactions =
        context.read<SettlementBloc>().state.totalElements;

    if (totalTransactions <= 0) {
      await _showNoTransactionsAlert();
      return;
    }

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

    final result = await sl<GetSettlementHistory>()(
      params: GetSettlementHistoryParams(
        bearerToken: bearerToken,
        merchantId: settlementMerchantId,
        fromDate: widget.filter.from,
        toDate: widget.filter.to,
        page: 0,
        size: totalTransactions,
        sendSettlementReportToMail: true,
      ),
    );

    if (!mounted) return;

    if (result is DataSuccess<SettlementHistoryResponseModel>) {
      await _showSettlementEmailResult(result.data!);
      return;
    }

    await AlertService.error(
      context,
      title: context.tr('error'),
      message: result.error?.message ?? context.tr('email_report_failed'),
    );
  }

  Future<void> _showSettlementEmailResult(
    SettlementHistoryResponseModel response,
  ) async {
    final mailResponse = response.sendMailResponse;
    final message = mailResponse.responseMessage.isEmpty
        ? context.tr('email_report_sent')
        : mailResponse.responseMessage;

    if (mailResponse.hasMessage && !mailResponse.isSuccess) {
      await AlertService.error(
        context,
        title: context.tr('error'),
        message: message,
      );
      return;
    }

    await AlertService.success(
      context,
      title: context.tr('success'),
      message: message,
    );
  }

  Future<DataState<PosTxnHistoryResponseModel>> _requestPosEmailReport({
    required int size,
  }) async {
    final bearerToken =
        _bearerToken.isEmpty ? await _sessionStorage.bearerToken : _bearerToken;
    final merchantId =
        _merchantId.isEmpty ? await _sessionStorage.merchantId : _merchantId;
    final acqMerchantId = _acqMerchantId.isEmpty
        ? await _sessionStorage.activeAcqMerchantId
        : _acqMerchantId;
    final clientUniqueId =
        _clientUniqueId.isEmpty ? await _sessionStorage.email : _clientUniqueId;
    final useMidEndpoint = acqMerchantId == '0';
    final posMerchantId =
        useMidEndpoint || acqMerchantId.isEmpty ? merchantId : acqMerchantId;

    _bearerToken = bearerToken;
    _merchantId = merchantId;
    _acqMerchantId = acqMerchantId;
    _clientUniqueId = clientUniqueId;

    return sl<GetPosTransactions>()(
      params: GetPosTransactionsParams(
        bearerToken: bearerToken,
        clientUniqueId: clientUniqueId,
        merchantId: useMidEndpoint ? '' : posMerchantId,
        mid: useMidEndpoint ? posMerchantId : null,
        acquirerId: 'OMAIND',
        page: 0,
        size: size,
        recordFrom: widget.filter.from,
        recordTo: widget.filter.to,
        rrn: widget.filter.rrn,
        authCode: widget.filter.authCode,
        terminalId: widget.filter.terminalId,
        sourceOfTxn: widget.filter.sourceOfTxn,
        useMidEndpoint: useMidEndpoint,
        sendTxnReportToMail: true,
      ),
    );
  }

  Future<void> _showEmailResult(
    DataState<PosTxnHistoryResponseModel> response,
  ) async {
    if (!mounted) {
      return;
    }

    if (response is DataSuccess<PosTxnHistoryResponseModel>) {
      final mailResponse = response.data!.sendMailResponse;
      final message = mailResponse.responseMessage.isEmpty
          ? context.tr('email_report_sent')
          : mailResponse.responseMessage;

      if (mailResponse.hasMessage && !mailResponse.isSuccess) {
        await AlertService.error(
          context,
          title: context.tr('error'),
          message: message,
        );
        return;
      }

      await AlertService.success(
        context,
        title: context.tr('success'),
        message: message,
      );
      return;
    }

    await AlertService.error(
      context,
      title: context.tr('error'),
      message: response.error?.message ?? context.tr('email_report_failed'),
    );
  }

  Future<void> _showNoTransactionsAlert() {
    return AlertService.warning(
      context,
      title: context.tr('alert'),
      message: context.tr('no_transactions_to_send'),
    );
  }

  Widget _buildSummary() {
    if (widget.filter.tab == TransactionTab.settlements) {
      return BlocBuilder<SettlementBloc, SettlementState>(
        builder: (context, state) {
          return _TransactionSummary(
            count: state.totalElements,
            amount: state.totalAmount,
          );
        },
      );
    }

    if (widget.filter.tab == TransactionTab.pos) {
      return BlocBuilder<PosTransactionBloc, PosTransactionState>(
        builder: (context, state) {
          return _TransactionSummary(
            count: state.totalElements,
            amount: state.totalAmount,
          );
        },
      );
    }

    return BlocBuilder<MerchantVpaTxnBloc, MerchantVpaTxnState>(
      builder: (context, state) {
        return _TransactionSummary(
          count: state.totalElements,
          amount: state.totalAmount,
        );
      },
    );
  }

  Widget _buildQrTransactionList() {
    return BlocConsumer<MerchantVpaTxnBloc, MerchantVpaTxnState>(
      listener: (context, state) => _scheduleLoadMoreIfNeeded(),
      builder: (context, state) {
        if (state is MerchantVpaTxnLoading && state.transactions.isEmpty) {
          return const _LoadingTransactions();
        }

        if (state.transactions.isEmpty) {
          return const _EmptyTransactions();
        }

        return Column(
          children: [
            ...state.transactions.map(_buildQrTransactionItem),
            _LoadMoreIndicator(
              visible: state is MerchantVpaTxnLoading && !state.last,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPosTransactionList() {
    return BlocConsumer<PosTransactionBloc, PosTransactionState>(
      listener: (context, state) => _scheduleLoadMoreIfNeeded(),
      builder: (context, state) {
        if (state.transactionsLoading &&
            state.transactions.isEmpty &&
            state.terminalSummaries.isEmpty) {
          return const _LoadingTransactions();
        }

        if (_isAllMerchantSelection) {
          if (state.terminalSummaries.isEmpty) {
            return const _EmptyTransactions();
          }

          return _TerminalSummaryList(summaries: state.terminalSummaries);
        }

        if (state.transactions.isEmpty) {
          return const _EmptyTransactions();
        }

        return Column(
          children: [
            ...state.transactions.map(_buildPosTransactionItem),
            _LoadMoreIndicator(
              visible: state.transactionsLoading && !state.last,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettlementList() {
    return BlocConsumer<SettlementBloc, SettlementState>(
      listener: (context, state) => _scheduleLoadMoreIfNeeded(),
      builder: (context, state) {
        if (state.isLoading && state.settlements.isEmpty) {
          return const _LoadingTransactions();
        }

        if (state.settlements.isEmpty) {
          return const _EmptyTransactions();
        }

        return Column(
          children: [
            ...state.settlements.map(_buildSettlementItem),
            _LoadMoreIndicator(visible: state.isLoading && !state.last),
          ],
        );
      },
    );
  }

  Widget _buildQrTransactionItem(MerchantVpaTransactionModel transaction) {
    return TransactionListItem.fromVpa(
      transaction: transaction,
      cardStyle: true,
      onInfoPressed: () {
        context.push(AppRoutes.vpaInvoice, extra: transaction);
      },
    );
  }

  Widget _buildPosTransactionItem(PosTransactionModel transaction) {
    return TransactionListItem.fromPos(
      transaction: transaction,
      cardStyle: true,
      onInfoPressed: () {
        context.push(AppRoutes.transactionInvoice, extra: transaction);
      },
    );
  }

  Widget _buildSettlementItem(SettlementItemModel settlement) {
    return TransactionListItem.fromSettlement(
      settlement: settlement,
      onInfoPressed: () {
        context.push(AppRoutes.settlementInvoice, extra: settlement);
      },
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  final bool visible;

  const _LoadMoreIndicator({required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(height: 12);

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class _DateRangeLabel extends StatelessWidget {
  final String label;

  const _DateRangeLabel(this.label);

  @override
  Widget build(BuildContext context) {
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
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _WebResultEntry {
  final String date;
  final String amount;
  final String customerName;
  final String paymentName;
  final String method;
  final String category;
  final String entryMode;
  final String status;
  final bool successful;
  final VoidCallback onTap;

  const _WebResultEntry({
    required this.date,
    required this.amount,
    this.customerName = '',
    required this.paymentName,
    required this.method,
    required this.category,
    this.entryMode = '',
    required this.status,
    required this.successful,
    required this.onTap,
  });
}

class _WebTerminalSummaryTable extends StatelessWidget {
  final List<PosTerminalSummaryModel> summaries;

  const _WebTerminalSummaryTable({required this.summaries});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: constraints.maxWidth < 720 ? 720 : constraints.maxWidth,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? context.appElevatedSurface
                      : AppColors.primaryPurple.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _TerminalSummaryCell(
                      label: context.tr('terminals'),
                      header: true,
                    ),
                    _TerminalSummaryCell(
                      label: context.tr('total_transactions'),
                      header: true,
                    ),
                    _TerminalSummaryCell(
                      label: context.tr('total_amount'),
                      header: true,
                    ),
                  ],
                ),
              ),
              for (var index = 0; index < summaries.length; index++)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 17,
                  ),
                  decoration: BoxDecoration(
                    color: index.isOdd
                        ? context.appSurfaceAlt
                        : context.appSurface,
                    border: Border(
                      bottom: BorderSide(color: context.appBorder),
                    ),
                  ),
                  child: Row(
                    children: [
                      _TerminalSummaryCell(
                        label: summaries[index].serialNumber.isEmpty
                            ? context.tr('not_available')
                            : summaries[index].serialNumber,
                        bold: true,
                      ),
                      _TerminalSummaryCell(
                        label: '${summaries[index].count}',
                      ),
                      _TerminalSummaryCell(
                        label:
                            'Rs. ${summaries[index].totalAmount.toStringAsFixed(2)}',
                        bold: true,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TerminalSummaryCell extends StatelessWidget {
  final String label;
  final bool header;
  final bool bold;

  const _TerminalSummaryCell({
    required this.label,
    this.header = false,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.h5.copyWith(
          color: context.appTextPrimary,
          fontWeight: header || bold ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    );
  }
}

class _TerminalSummaryList extends StatelessWidget {
  final List<PosTerminalSummaryModel> summaries;

  const _TerminalSummaryList({required this.summaries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: summaries
          .map(
            (summary) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: context.appElevatedSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.appBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${context.tr('terminals')}: ${summary.serialNumber.isEmpty ? context.tr('not_available') : summary.serialNumber}',
                    style: AppTextStyle.h4.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.tr('total_transactions')}: ${summary.count}',
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${context.tr('total_amount')}: Rs. ${summary.totalAmount.toStringAsFixed(2)}',
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Browser-only table styling. The entries themselves continue to come from
/// the same mobile blocs and use the same detail/invoice navigation.
class _WebResultTable extends StatelessWidget {
  final List<_WebResultEntry> entries;
  final bool isPosTable;
  final bool isQrTable;

  const _WebResultTable({
    required this.entries,
    required this.isPosTable,
    required this.isQrTable,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: constraints.maxWidth < (isQrTable ? 1240 : 1040)
              ? (isQrTable ? 1240 : 1040)
              : constraints.maxWidth,
          child: Column(
            children: [
              _WebResultTableHeader(
                isPosTable: isPosTable,
                isQrTable: isQrTable,
              ),
              for (var index = 0; index < entries.length; index++)
                _WebResultTableRow(
                  entry: entries[index],
                  alternateSurface: index.isOdd,
                  isPosTable: isPosTable,
                  isQrTable: isQrTable,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebResultTableHeader extends StatelessWidget {
  final bool isPosTable;
  final bool isQrTable;

  const _WebResultTableHeader({
    required this.isPosTable,
    required this.isQrTable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? context.appElevatedSurface
            : AppColors.primaryPurple.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (isPosTable) ...[
            _WebResultTableCell(
                label: context.tr('amount'), flex: 12, header: true),
            _WebResultTableCell(
                label: context.tr('date_time'), flex: 16, header: true),
            _WebResultTableCell(
                label: context.tr('tid'), flex: 13, header: true),
            _WebResultTableCell(
                label: context.tr('card_type'), flex: 15, header: true),
            _WebResultTableCell(
                label: context.tr('transaction_type'), flex: 16, header: true),
            _WebResultTableCell(
                label: context.tr('entry_mode'), flex: 14, header: true),
            _WebResultTableCell(
                label: context.tr('status'), flex: 14, header: true),
          ] else if (isQrTable) ...[
            _WebResultTableCell(
                label: context.tr('amount'), flex: 13, header: true),
            _WebResultTableCell(
                label: context.tr('date_time'), flex: 16, header: true),
            _WebResultTableCell(
                label: context.tr('customer_name'), flex: 18, header: true),
            _WebResultTableCell(
                label: context.tr('customer_vpa'), flex: 20, header: true),
            _WebResultTableCell(
                label: context.tr('rrn'), flex: 14, header: true),
            _WebResultTableCell(
                label: context.tr('ref_id'), flex: 14, header: true),
            _WebResultTableCell(
                label: context.tr('status'), flex: 14, header: true),
          ] else ...[
            _WebResultTableCell(
                label: context.tr('date'), flex: 12, header: true),
            _WebResultTableCell(
                label: context.tr('amount'), flex: 12, header: true),
            _WebResultTableCell(
                label: context.tr('payment_name'), flex: 20, header: true),
            _WebResultTableCell(
                label: context.tr('method'), flex: 15, header: true),
            _WebResultTableCell(
                label: context.tr('category'), flex: 16, header: true),
            _WebResultTableCell(
                label: context.tr('status'), flex: 15, header: true),
          ],
        ],
      ),
    );
  }
}

class _WebResultTableRow extends StatelessWidget {
  final _WebResultEntry entry;
  final bool alternateSurface;
  final bool isPosTable;
  final bool isQrTable;

  const _WebResultTableRow({
    required this.entry,
    required this.alternateSurface,
    required this.isPosTable,
    required this.isQrTable,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: alternateSurface ? context.appSurfaceAlt : context.appSurface,
      child: InkWell(
        onTap: entry.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.appBorder)),
          ),
          child: Row(
            children: [
              if (isPosTable) ...[
                _WebResultTableCell(label: entry.amount, flex: 12, bold: true),
                _WebResultTableCell(label: entry.date, flex: 16),
                _WebResultTableCell(label: entry.paymentName, flex: 13),
                _WebResultTableCell(label: entry.method, flex: 15),
                _WebResultTableCell(label: entry.category, flex: 16),
                _WebResultTableCell(label: entry.entryMode, flex: 14),
                Expanded(
                  flex: 14,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _WebResultStatus(
                      label: entry.status,
                      successful: entry.successful,
                    ),
                  ),
                ),
              ] else if (isQrTable) ...[
                _WebResultTableCell(label: entry.amount, flex: 13, bold: true),
                _WebResultTableCell(label: entry.date, flex: 16),
                _WebResultTableCell(label: entry.customerName, flex: 18),
                _WebResultTableCell(label: entry.paymentName, flex: 20),
                _WebResultTableCell(label: entry.method, flex: 14),
                _WebResultTableCell(label: entry.category, flex: 14),
                Expanded(
                  flex: 14,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _WebResultStatus(
                      label: entry.status,
                      successful: entry.successful,
                    ),
                  ),
                ),
              ] else ...[
                _WebResultTableCell(label: entry.date, flex: 12),
                _WebResultTableCell(label: entry.amount, flex: 12, bold: true),
                _WebResultTableCell(
                    label: entry.paymentName, flex: 20, bold: true),
                _WebResultTableCell(label: entry.method, flex: 15),
                _WebResultTableCell(label: entry.category, flex: 16),
                Expanded(
                  flex: 15,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _WebResultStatus(
                      label: entry.status,
                      successful: entry.successful,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WebResultTableCell extends StatelessWidget {
  final String label;
  final int flex;
  final bool header;
  final bool bold;

  const _WebResultTableCell({
    required this.label,
    required this.flex,
    this.header = false,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.h5.copyWith(
          color: context.appTextPrimary,
          fontWeight: header || bold ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    );
  }
}

class _WebResultStatus extends StatelessWidget {
  final String label;
  final bool successful;

  const _WebResultStatus({
    required this.label,
    required this.successful,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = label.trim();
    final isPending = normalized.toLowerCase().contains('pending');
    final background = successful
        ? const Color(0xffE8F8ED)
        : isPending
            ? const Color(0xffFFF6DF)
            : const Color(0xffFEEBEC);
    final foreground = successful
        ? const Color(0xff18A957)
        : isPending
            ? const Color(0xffA66D00)
            : const Color(0xffE14343);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        normalized.isEmpty ? '-' : normalized,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.h5.copyWith(
          color: foreground,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LoadingTransactions extends StatelessWidget {
  const _LoadingTransactions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: CircularProgressIndicator(color: AppColors.primaryPurple),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 72),
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

class _TransactionSummary extends StatelessWidget {
  final int count;
  final double amount;

  const _TransactionSummary({
    required this.count,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    const isWeb = kIsWeb;
    final foregroundColor = isWeb ? context.appTextPrimary : Colors.white;
    final valueColor = isWeb ? AppColors.primaryPurple : Colors.white;

    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: isWeb ? context.appSurface : AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(12),
        border: isWeb
            ? Border.all(color: AppColors.primaryPurple.withValues(alpha: .45))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isWeb
                  ? AppColors.primaryPurple.withValues(alpha: .10)
                  : Colors.transparent,
              border: Border.all(
                color: isWeb
                    ? AppColors.primaryPurple.withValues(alpha: .35)
                    : Colors.white.withValues(alpha: .35),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: isWeb ? AppColors.primaryPurple : Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: AppTextStyle.h2.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                context.tr('total_transactions'),
                style: AppTextStyle.h5.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹ ${amount.toStringAsFixed(2)}',
                style: AppTextStyle.h2.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                context.tr('total_amount'),
                style: AppTextStyle.h5.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final int page;
  final int totalPages;
  final bool isLoading;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;

  const _PaginationControls({
    required this.page,
    required this.totalPages,
    required this.isLoading,
    this.onPreviousPage,
    this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _TransactionListHeader extends StatelessWidget {
  const _TransactionListHeader();

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
