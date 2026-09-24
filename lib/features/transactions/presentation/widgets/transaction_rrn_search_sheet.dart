import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/common/responsive_layout.dart';
import 'package:anet_merchants/core/di/injection_container.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/features/devices/devices.dart';
import 'package:anet_merchants/features/shared/presentation/widgets/quick_actions.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_txn_history_response_model.dart';
import 'package:anet_merchants/features/transactions/domain/usecases/get_merchant_vpa_txn_data.dart';
import 'package:anet_merchants/features/transactions/domain/usecases/get_pos_transactions.dart';
import 'package:anet_merchants/features/transactions/presentation/widgets/vpa_selector.dart';

Future<void> showTransactionRrnSearchSheet(
  BuildContext context, {
  required TransactionTab tab,
  String creditVpa = '',
  String initialFrom = '',
  String initialTo = '',
}) {
  if (tab == TransactionTab.settlements) {
    return Future.value();
  }

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(dialogContext).bottom,
            ),
            child: _TransactionRrnSearchSheet(
              tab: tab,
              creditVpa: creditVpa,
              initialFrom: initialFrom,
              initialTo: initialTo,
            ),
          ),
        ),
      );
    },
  );
}

class _TransactionRrnSearchSheet extends StatefulWidget {
  final TransactionTab tab;
  final String creditVpa;
  final String initialFrom;
  final String initialTo;

  const _TransactionRrnSearchSheet({
    required this.tab,
    required this.creditVpa,
    required this.initialFrom,
    required this.initialTo,
  });

  @override
  State<_TransactionRrnSearchSheet> createState() =>
      _TransactionRrnSearchSheetState();
}

class _TransactionRrnSearchSheetState
    extends State<_TransactionRrnSearchSheet> {
  final SessionStorage _sessionStorage = SessionStorage();
  final TextEditingController _rrnController = TextEditingController();
  late final TextEditingController _creditVpaController;
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  late DateTime _from;
  late DateTime _to;
  String? _creditVpa;
  bool _searching = false;
  String? _error;
  List<MerchantVpaTransactionModel> _vpaResults = const [];
  List<PosTransactionModel> _posResults = const [];
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _from = _parseOr(
      widget.initialFrom,
      DateTime(today.year - 3, today.month, today.day),
    );
    _to = _parseOr(widget.initialTo, today);
    _creditVpa = widget.creditVpa.trim().isEmpty ? null : widget.creditVpa;
    _creditVpaController = TextEditingController(text: _creditVpa ?? '');
  }

  @override
  void dispose() {
    _rrnController.dispose();
    _creditVpaController.dispose();
    super.dispose();
  }

  DateTime _parseOr(String value, DateTime fallback) {
    if (value.trim().isEmpty) return fallback;
    try {
      return _dateFormat.parseStrict(value.trim());
    } catch (_) {
      return fallback;
    }
  }

  AppTextStyle _textStyle(BuildContext context) {
    return AppTextStyle(
      kIsWeb && AppBreakpoints.isTabletOrLarger(context)
          ? AppPlatform.web
          : AppPlatform.mobile,
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _from : _to;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to.isBefore(_from)) _to = _from;
      } else {
        _to = picked;
        if (_from.isAfter(_to)) _from = _to;
      }
    });
  }

  Future<void> _search() async {
    final rrn = _rrnController.text.trim();
    if (rrn.isEmpty) {
      setState(() => _error = context.tr('enter_rrn'));
      return;
    }

    if (widget.tab == TransactionTab.qr &&
        (_creditVpa == null || _creditVpa!.trim().isEmpty)) {
      setState(() => _error = context.tr('select_vpa'));
      return;
    }

    setState(() {
      _searching = true;
      _error = null;
    });

    final bearerToken = await _sessionStorage.bearerToken;
    final merchantId = await _sessionStorage.merchantId;
    final acqMerchantId = await _sessionStorage.activeAcqMerchantId;
    if (!mounted) return;

    if (bearerToken.isEmpty) {
      setState(() {
        _searching = false;
        _error = context.tr('report_download_failed');
      });
      return;
    }

    final from = _dateFormat.format(_from);
    final to = _dateFormat.format(_to);

    if (widget.tab == TransactionTab.qr) {
      final mappedMerchantId = acqMerchantId.isEmpty || acqMerchantId == '0'
          ? merchantId
          : acqMerchantId;
      final result = await sl<GetMerchantVpaTxnData>()(
        params: GetMerchantVpaTxnDataParams(
          bearerToken: bearerToken,
          creditVpa: _creditVpa!.trim(),
          from: from,
          to: to,
          rrn: rrn,
          page: 0,
          size: 50,
          mappedMerchantId: mappedMerchantId.isEmpty ? null : mappedMerchantId,
        ),
      );
      if (!mounted) return;
      setState(() {
        _searching = false;
        _searched = true;
        if (result is DataSuccess<MerchantVpaTxnResponseModel>) {
          _vpaResults = result.data?.pageData.content ?? const [];
          _error = null;
        } else {
          _vpaResults = const [];
          _error = result.error?.message ??
              context.tr('unable_load_qr_transactions');
        }
      });
      return;
    }

    final clientUniqueId = await _sessionStorage.email;
    final useMidEndpoint = acqMerchantId == '0';
    final posMerchantId =
        useMidEndpoint || acqMerchantId.isEmpty ? merchantId : acqMerchantId;
    if (!mounted) return;

    final result = await sl<GetPosTransactions>()(
      params: GetPosTransactionsParams(
        bearerToken: bearerToken,
        clientUniqueId: clientUniqueId,
        merchantId: useMidEndpoint ? '' : posMerchantId,
        acquirerId: 'OMAIND',
        page: 0,
        size: 50,
        recordFrom: from,
        recordTo: to,
        rrn: rrn,
        mid: useMidEndpoint ? posMerchantId : null,
        useMidEndpoint: useMidEndpoint,
      ),
    );
    if (!mounted) return;
    setState(() {
      _searching = false;
      _searched = true;
      if (result is DataSuccess<PosTxnHistoryResponseModel>) {
        _posResults = result.data?.responsePage.content ?? const [];
        _error = null;
      } else {
        _posResults = const [];
        _error = result.error?.message ?? context.tr('no_pos_transactions');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = _textStyle(context);
    final resultCount = widget.tab == TransactionTab.qr
        ? _vpaResults.length
        : _posResults.length;

    final resultTiles = widget.tab == TransactionTab.qr
        ? _vpaResults.map(_vpaTile).toList()
        : _posResults.map(_posTile).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('search_transaction'),
            style: style.h3.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: context.tr('from_date'),
                  value: _dateFormat.format(_from),
                  onTap: () => _pickDate(isFrom: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: context.tr('to_date'),
                  value: _dateFormat.format(_to),
                  onTap: () => _pickDate(isFrom: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rrnController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: context.tr('rrn'),
              hintText: context.tr('enter_rrn_hint'),
            ),
          ),
          if (widget.tab == TransactionTab.qr) ...[
            const SizedBox(height: 12),
            BlocBuilder<SoundBoxBloc, SoundBoxState>(
              builder: (context, state) {
                final vpas = state.devices;
                final selected = vpas.contains(_creditVpa) ? _creditVpa : null;
                if (vpas.isEmpty) {
                  return TextField(
                    decoration: InputDecoration(
                      labelText: context.tr('credit_vpa'),
                    ),
                    controller: _creditVpaController,
                    onChanged: (value) => _creditVpa = value,
                  );
                }
                return VpaSelector(
                  isLoading: state is SoundBoxLoading,
                  vpas: vpas,
                  selectedVpa: selected,
                  onChanged: (value) => setState(() => _creditVpa = value),
                );
              },
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: style.h5.copyWith(color: Colors.red.shade700),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _searching ? null : _search,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _searching
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(context.tr('search')),
          ),
          if (_searched) ...[
            const SizedBox(height: 14),
            Text(
              resultCount == 0
                  ? context.tr('no_matching_transactions')
                  : context.tr('search_result'),
              style: style.h4.copyWith(fontWeight: FontWeight.w800),
            ),
            if (resultTiles.isNotEmpty) ...[
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView(
                  shrinkWrap: true,
                  children: resultTiles,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _vpaTile(MerchantVpaTransactionModel transaction) {
    final status =
        transaction.status.trim().isEmpty ? 'Pending' : transaction.status;
    return _ResultTile(
      title: transaction.transactionAmount,
      subtitle:
          '${transaction.addedOn.replaceFirst('T', ' ')}  ${transaction.rrn}',
      detail: transaction.customerVpa,
      status: status,
      successful: _isApprovedStatus(status),
      onTap: () {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.push(AppRoutes.vpaInvoice, extra: transaction);
      },
    );
  }

  Widget _posTile(PosTransactionModel transaction) {
    final when = [
      transaction.transactionDate,
      transaction.transactionTime,
    ].where((part) => part.trim().isNotEmpty).join(' ');
    final status = transaction.responseDesc.trim().isEmpty
        ? 'Pending'
        : transaction.responseDesc;
    return _ResultTile(
      title: transaction.amount,
      subtitle: '$when  ${transaction.rrn}',
      detail: transaction.terminalId,
      status: status,
      successful: transaction.responseCode == '00' ||
          transaction.responseCode == '000' ||
          _isApprovedStatus(status),
      onTap: () {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        router.push(AppRoutes.transactionInvoice, extra: transaction);
      },
    );
  }

  bool _isApprovedStatus(String status) {
    final normalized = status.toLowerCase();
    return normalized.contains('success') || normalized.contains('approved');
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(value),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String detail;
  final String status;
  final bool successful;
  final VoidCallback onTap;

  const _ResultTile({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.status,
    required this.successful,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = successful ? const Color(0xff18A957) : const Color(0xffE11D48);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [subtitle, detail].where((part) => part.trim().isNotEmpty).join('\n'),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
