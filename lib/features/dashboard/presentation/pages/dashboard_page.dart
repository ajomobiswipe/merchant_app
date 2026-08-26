import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/di/injection_container.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/resources/data_state.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/features/shared/shared.dart';
import 'package:anet_merchants/features/transactions/transactions.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final SessionStorage _sessionStorage = SessionStorage();
  final DateFormat _apiDateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');

  late DateTimeRange _selectedRange;
  bool _isLoading = false;
  String? _errorMessage;
  PosTxnHistoryResponseModel? _dashboardData;
  Map<String, double> _upiMonthlyValues = const {};

  @override
  void initState() {
    super.initState();
    _selectedRange = _lastThreeMonthsRange();
    _loadDashboardData();
  }

  DateTimeRange _lastThreeMonthsRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 2, 1);
    return DateTimeRange(start: start, end: now);
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final bearerToken = await _sessionStorage.bearerToken;
    final merchantId = await _sessionStorage.merchantId;
    final acqMerchantId = await _sessionStorage.activeAcqMerchantId;
    final email = await _sessionStorage.email;
    final useMidEndpoint = acqMerchantId == '0';
    final posMerchantId =
        useMidEndpoint || acqMerchantId.isEmpty ? merchantId : acqMerchantId;

    if (!mounted) return;

    if (bearerToken.isEmpty || posMerchantId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = context.tr('not_available');
      });
      return;
    }

    final result = await sl<GetPosTransactions>()(
      params: GetPosTransactionsParams(
        bearerToken: bearerToken,
        clientUniqueId: email,
        merchantId: useMidEndpoint ? '' : posMerchantId,
        mid: useMidEndpoint ? posMerchantId : null,
        acquirerId: 'OMAIND',
        page: 0,
        size: 1,
        recordFrom: _apiDateFormat.format(_selectedRange.start),
        recordTo: _apiDateFormat.format(_selectedRange.end),
        sourceOfTxn: null,
        useMidEndpoint: useMidEndpoint,
      ),
    );

    final upiResult = await sl<GetMerchantVpaTxnData>()(
      params: GetMerchantVpaTxnDataParams(
        bearerToken: bearerToken,
        creditVpa: '',
        from: _apiDateFormat.format(_selectedRange.start),
        to: _apiDateFormat.format(_selectedRange.end),
        page: 0,
        size: 1,
        mappedMerchantId: merchantId.isEmpty ? null : merchantId,
      ),
    );

    if (!mounted) return;

    if (result is DataSuccess<PosTxnHistoryResponseModel>) {
      setState(() {
        _dashboardData = result.data;
        _upiMonthlyValues =
            upiResult is DataSuccess<MerchantVpaTxnResponseModel>
                ? upiResult.data!.monthlyUpiTxnAmount
                : const {};
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = false;
      _errorMessage = result.error?.message ?? context.tr('unknown_error');
    });
  }

  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final fromDate = await _pickCalendarDate(
      initialDate: _selectedRange.start,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (fromDate == null || !mounted) {
      return;
    }

    final maxToDate = _maximumToDate(fromDate);
    final nextToDate = _selectedRange.end.isBefore(fromDate)
        ? fromDate
        : _selectedRange.end.isAfter(maxToDate)
            ? maxToDate
            : _selectedRange.end;

    setState(() {
      _selectedRange = DateTimeRange(start: fromDate, end: nextToDate);
    });
    _loadDashboardData();
  }

  Future<void> _pickToDate() async {
    final toDate = await _pickCalendarDate(
      initialDate: _selectedRange.end,
      firstDate: _selectedRange.start,
      lastDate: _maximumToDate(_selectedRange.start),
    );

    if (toDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedRange = DateTimeRange(start: _selectedRange.start, end: toDate);
    });
    _loadDashboardData();
  }

  DateTime _maximumToDate(DateTime fromDate) {
    final now = DateTime.now();
    final sixMonthsFromStart = DateTime(
      fromDate.year,
      fromDate.month + 6,
      fromDate.day,
    );

    return sixMonthsFromStart.isAfter(now) ? now : sixMonthsFromStart;
  }

  Future<DateTime?> _pickCalendarDate({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final normalizedInitialDate = initialDate.isBefore(firstDate)
        ? firstDate
        : initialDate.isAfter(lastDate)
            ? lastDate
            : initialDate;

    return showDatePicker(
      context: context,
      initialDate: normalizedInitialDate,
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

  @override
  Widget build(BuildContext context) {
    final data = _dashboardData;
    final chartPoints = _buildChartPoints();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!kIsWeb) ...[
            const HomeHeader(),
            const SizedBox(height: 26),
          ],
          const MerchantOverview(),
          const SizedBox(height: 18),
          SuccessSummaryCard(
            title: context.tr('total_transactions'),
            transactionCount: data?.count ?? 0,
            amount: data?.totalAmount ?? 0,
          ),
          const SizedBox(height: 18),
          _DashboardDateControls(
            fromLabel: _displayDateFormat.format(_selectedRange.start),
            toLabel: _displayDateFormat.format(_selectedRange.end),
            onFromTap: _pickFromDate,
            onToTap: _pickToDate,
          ),
          const SizedBox(height: 18),
          Text(
            context.tr('month_vs_transaction_amount'),
            style: AppTextStyle.h3.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child:
                    CircularProgressIndicator(color: AppColors.primaryPurple),
              ),
            )
          else if (_errorMessage != null)
            _DashboardMessage(message: _errorMessage!)
          else
            _MonthlyValuesChart(points: chartPoints),
        ],
      ),
    );
  }

  List<_DashboardMonthPoint> _buildChartPoints() {
    final data = _dashboardData;

    if (data == null) {
      return const [];
    }

    final points = <_DashboardMonthPoint>[];
    var cursor =
        DateTime(_selectedRange.start.year, _selectedRange.start.month, 1);
    final end = DateTime(_selectedRange.end.year, _selectedRange.end.month, 1);

    while (!cursor.isAfter(end)) {
      final monthKey = DateFormat('MMMM').format(cursor);
      final shortLabel = DateFormat('MMM').format(cursor);

      points.add(
        _DashboardMonthPoint(
          label: shortLabel,
          posAmount: data.monthlyValues[monthKey] ?? 0,
          emiMdrAmount: data.sumEmiMdrValues[monthKey] ?? 0,
          upiAmount: _upiMonthlyValues[monthKey] ?? 0,
        ),
      );

      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }

    return points;
  }
}

class _DashboardDateControls extends StatelessWidget {
  final String fromLabel;
  final String toLabel;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  const _DashboardDateControls({
    required this.fromLabel,
    required this.toLabel,
    required this.onFromTap,
    required this.onToTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateButton(
            label: context.tr('from'),
            value: fromLabel,
            onTap: onFromTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DateButton(
            label: context.tr('to'),
            value: toLabel,
            onTap: onToTap,
          ),
        ),
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appBorder),
        ),
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
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primaryPurple,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyValuesChart extends StatelessWidget {
  final List<_DashboardMonthPoint> points;

  const _MonthlyValuesChart({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _DashboardMessage(message: context.tr('no_transactions'));
    }

    final maxValue = points
        .expand((point) => [
              point.posAmount,
              point.emiMdrAmount,
              point.upiAmount,
            ])
        .fold<double>(
          0,
          (current, value) => value > current ? value : current,
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
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
      child: SizedBox(
        height: 270,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: points.map((point) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 84,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Rs. ${point.total.toStringAsFixed(1)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.h5.copyWith(
                                color: context.appTextPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _ChartBar(
                                    value: point.posAmount,
                                    maxValue: maxValue,
                                    color: const Color(0xff5096F1),
                                  ),
                                  const SizedBox(width: 6),
                                  _ChartBar(
                                    value: point.emiMdrAmount,
                                    maxValue: maxValue,
                                    color: const Color(0xffEB7B30),
                                  ),
                                  const SizedBox(width: 6),
                                  _ChartBar(
                                    value: point.upiAmount,
                                    maxValue: maxValue,
                                    color: const Color(0xff58E009),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              point.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.h5.copyWith(
                                color: context.appTextSecondary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _DashboardLegend(),
          ],
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color color;

  const _ChartBar({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedHeight =
        maxValue == 0 ? 0.04 : (value / maxValue).clamp(0.04, 1.0);

    return FractionallySizedBox(
      heightFactor: normalizedHeight,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _DashboardLegend extends StatelessWidget {
  const _DashboardLegend();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendItem(
          color: const Color(0xff5096F1),
          label: context.tr('pos_amount'),
        ),
        const SizedBox(height: 8),
        _LegendItem(
          color: const Color(0xffEB7B30),
          label: context.tr('emi_mdr'),
        ),
        const SizedBox(height: 8),
        _LegendItem(
          color: const Color(0xff58E009),
          label: context.tr('upi_amount'),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyle.h5.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardMonthPoint {
  final String label;
  final double posAmount;
  final double emiMdrAmount;
  final double upiAmount;

  const _DashboardMonthPoint({
    required this.label,
    required this.posAmount,
    required this.emiMdrAmount,
    required this.upiAmount,
  });

  double get total => posAmount + emiMdrAmount + upiAmount;
}

class _DashboardMessage extends StatelessWidget {
  final String message;

  const _DashboardMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appBorder),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyle.h4.copyWith(
          color: context.appTextSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
