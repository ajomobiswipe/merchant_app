import 'package:anet_merchant_app/data/models/get_settlement_dashboard_data.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettlementProvider extends ChangeNotifier {
  final String _storeName = "Toy Store";
  String get storeName => _storeName;

  double _totalSettlementAmount = 0.0;

  int _totalTransactions = 0;
  int _totalSettlement = 0;
  double _deductions = 0;

  bool _isEmailSending = false;
  bool get isEmailSending => _isEmailSending;

  double get totalSettlementAmount => _totalSettlementAmount;
  double get deductionsAmount => _deductions;

  int get totalTransactions => _totalTransactions;
  int get totalSettlement => _totalSettlement;

  AlertService _alertService = AlertService();
  bool _showDeductions = false;
  bool get showDeductions => _showDeductions;
  void toggleDeductions() {
    _showDeductions = !_showDeductions;
    notifyListeners();
  }

  // Services
  final MerchantServices _merchantServices = MerchantServices();

  String? _selectedDateRange;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  List<String> dateRanges = [
    "Today - ${DateFormat('d MMM yyyy').format(DateTime.now())}",
    'Yesterday - ${DateFormat('d MMM yyyy').format(DateTime.now().subtract(Duration(days: 1)))}',
    'Last 7 Days',
    'Last 1 Month',
    'Custom Date Range'
  ];
  String getFormattedDateRange() {
    if (_selectedDateRange == 'Custom Date Range' &&
        _customStartDate != null &&
        _customEndDate != null) {
      return 'From ${DateFormat('dd-MM-yyyy').format(_customStartDate!)} to ${DateFormat('dd-MM-yyyy').format(_customEndDate!)}';
    }
    return _selectedDateRange ?? '';
  }

  // Getters
  bool isDateNotSelected() {
    return _customStartDate == null || _customEndDate == null;
  }

  String? get selectedDateRange => _selectedDateRange;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;

  // Controllers
  final ScrollController _allSettlementScrollCtrl = ScrollController();
  ScrollController get allSettlementScrollCtrl => _allSettlementScrollCtrl;
  // Controllers
  final ScrollController _allUtrWiseSettlementScrollCtrl = ScrollController();
  ScrollController get allUtrWiseSettlementScrollCtrl =>
      _allUtrWiseSettlementScrollCtrl;

  // Flags
  bool _isAllTransactionsLoading = false;
  bool isAllTransLoadingFistTime = true;
  bool _isAllUtrWiseSettlementLoading = false;
  bool isAllUtrWiseSettlementFistTime = true;

  // Pagination
  int currentPage = 0;
  final int pageSize = 10;
  int utrCurrentPage = 0;
  final int utrPageSize = 10;

  // Transaction Data
  int _allTnxCount = 0; // Simulate total from API
  int _transactionsInSettlementCount = 0; // Simulate total from API
  int _utrWiseSettlementCount = 0; // Simulate total from API
  int get transactionsInSettlementCount => _transactionsInSettlementCount;
  List<SettledSummaryPageContent> _allTransactions = [];
  List<SettledSummaryPageContent> get allTransactions => _allTransactions;
  // Getters

  bool get hasMoreTransactions =>
      _allTransactions.length < _transactionsInSettlementCount;
  bool get hasMoreUtrSettlements =>
      _utrWiseSettlements.length < _utrWiseSettlementCount;

  bool get isAllTransactionsLoading => _isAllTransactionsLoading;
  bool get isAllUtrWiseSettlementLoading => _isAllUtrWiseSettlementLoading;

  List<SettlementAggregatePageContent> _utrWiseSettlements = [];
  List<SettlementAggregatePageContent> get utrWiseSettlements =>
      _utrWiseSettlements;
  SettlementAggregatePageContent? _selectedSettlementAggregate;
  void setSelectedSettlementAggregate(
      SettlementAggregatePageContent? settlement) {
    _selectedSettlementAggregate = settlement;
  }

  SettlementAggregatePageContent? get selectedSettlementAggregate =>
      _selectedSettlementAggregate;

  // Methods
  getFormattedDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Fetch recent transactions
  Future<void> getTransactionsInSettlement() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';
    if (_allTransactions.length >= _transactionsInSettlementCount &&
        !isAllTransLoadingFistTime) return;

    notifyListeners();
    var reqBody = {
      "merchantId": merchantId,
      "fromDate": getFormattedDate(_selectedSettlementAggregate!.tranDate!),
      "toDate": getFormattedDate(_selectedSettlementAggregate!.tranDate!),
      "reconciled": true,
      "merPayDone": true,
      "misDone": true,
      "pageDataRequired": true,
      "settlementAggregatesRequired": true,
      "sendSettlementReportToMail": false
    };
    if (_isAllTransactionsLoading) return;

    _isAllTransactionsLoading = true;
    notifyListeners();

    try {
      final response = await _merchantServices.getSettlementDashboardReport(
        reqBody,
        pageNumber: currentPage,
        pageSize: pageSize,
      );

      if (response.statusCode == 200) {
        final decodedData = GetSettlementDashboardData.fromJson(response.data);
        final newItems = decodedData.settledSummaryPage?.content ?? [];
        _transactionsInSettlementCount =
            decodedData.settledSummaryPage?.totalElements ?? 0;

        if (newItems.isNotEmpty) {
          currentPage++;

          isAllTransLoadingFistTime = false;

          _allTransactions.addAll(newItems);
        }
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      _isAllTransactionsLoading = false;
      notifyListeners();
    }
  }

  resetFilters() {
    _selectedDateRange = null;
    notifyListeners();
  }

  resetDashBoard() {
    _utrWiseSettlements = [];
    _utrWiseSettlementCount = 0;
    utrCurrentPage = 0;
    isAllUtrWiseSettlementFistTime = true;
    _isAllUtrWiseSettlementLoading = false;
    notifyListeners();
  }

  clearTransactionList() {
    currentPage = 0;
    _allTransactions = [];
    _showDeductions = false;
    isAllTransLoadingFistTime = true;
    _transactionsInSettlementCount = 0;
    notifyListeners();
  }

  // Fetch recent transactions
  Future<void> getSettlementDashboardReport() async {
    print("utrWiseSettlements length: ${_utrWiseSettlements.length}");
    print("utrWiseSettlementCount: $_utrWiseSettlementCount");
    print("isAllUtrWiseSettlementFistTime: $isAllUtrWiseSettlementFistTime");
    if (_utrWiseSettlements.length >= _utrWiseSettlementCount &&
        !isAllUtrWiseSettlementFistTime) {
      return;
    }
    if (_isAllUtrWiseSettlementLoading) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId') ?? '651010000022371';
    _isAllUtrWiseSettlementLoading = true;
    notifyListeners();
    print("selected DateRange ${_selectedDateRange}");
    var reqBody = {
      "merchantId": merchantId,
      "fromDate": DateFormat('yyyy-MM-dd').format(_customStartDate!),
      "toDate": DateFormat('yyyy-MM-dd').format(_customEndDate!),
      // "fromDate": "2024-05-01",
      // "toDate": "2025-05-28",
      // "fromDate": getFormattedDate(_selectedSettlementAggregate!.tranDate!),
      // "toDate": getFormattedDate(_selectedSettlementAggregate!.tranDate!),
      "reconciled": true,
      "merPayDone": true,
      "misDone": true,
      "pageDataRequired": true,
      "settlementAggregatesRequired": true,
      "settlementTotalRequired": true,
      "sendSettlementReportToMail": false
    };

    try {
      final response = await _merchantServices.getSettlementDashboardReport(
        reqBody,
        pageNumber: utrCurrentPage,
        pageSize: utrPageSize,
      );

      if (response.statusCode == 200) {
        final decodedData = GetSettlementDashboardData.fromJson(response.data);
        _totalSettlementAmount =
            decodedData.settlementTotal?.totalAmount ?? 0.00;
        _totalSettlement = decodedData.settlementTotal?.settlementCount ?? 0;
        _totalTransactions = decodedData.settlementTotal?.transactionCount ?? 0;
        _utrWiseSettlementCount =
            decodedData.settlementTotal?.settlementCount ?? 0;
        final newItems = decodedData.settlementAggregatePage?.content ?? [];
        if (decodedData.settlementAggregatePage?.content != null) {
          isAllUtrWiseSettlementFistTime = false;
          utrCurrentPage++;
          _utrWiseSettlements.addAll(newItems);
        } else {}
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      _isAllUtrWiseSettlementLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendSettlementDashboardReportTOEmail() async {
    if (_selectedSettlementAggregate == null) {
      AlertService().error("Please select a settlement date first.");
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';
    _isEmailSending = true;
    notifyListeners();
    var reqBody = {
      "merchantId": merchantId,
      "fromDate": DateFormat('yyyy-MM-dd')
          .format(_selectedSettlementAggregate!.tranDate!),
      "toDate": DateFormat('yyyy-MM-dd')
          .format(_selectedSettlementAggregate!.tranDate!),
      "reconciled": true,
      "merPayDone": true,
      "misDone": true,
      "pageDataRequired": true,
      "settlementAggregatesRequired": true,
      "settlementTotalRequired": true,
      "sendSettlementReportToMail": true
    };

    try {
      final response = await _merchantServices.getSettlementDashboardReport(
        reqBody,
        pageNumber: 0,
        pageSize: selectedSettlementAggregate!.transactionCount ?? 20,
      );

      if (response.statusCode == 200) {
        final decodedData = GetSettlementDashboardData.fromJson(response.data);

        AlertService().success(
            " Settlement report has been sent to your registered email.");
      } else {
        AlertService().error("Failed to send settlement report to email.");
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      _isEmailSending = false;
      notifyListeners();
    }
  }

  void setSelectedDateRange(String? value) {
    _selectedDateRange = value;
    applyDateToModel();
    notifyListeners();
  }

  applyDateToModel() {
    if (_selectedDateRange ==
        "Today - ${DateFormat('d MMM yyyy').format(DateTime.now())}") {
      _customStartDate = DateTime.now();
      _customEndDate = DateTime.now();
    } else if (_selectedDateRange ==
        'Yesterday - ${DateFormat('d MMM yyyy').format(DateTime.now().subtract(Duration(days: 1)))}') {
      _customStartDate = DateTime.now().subtract(Duration(days: 1));
      _customEndDate = DateTime.now().subtract(Duration(days: 1));
    } else if (_selectedDateRange == 'Last 7 Days') {
      _customStartDate = DateTime.now().subtract(Duration(days: 7));
      _customEndDate = DateTime.now();
    } else if (_selectedDateRange == 'Last 1 Month') {
      _customStartDate = DateTime.now().subtract(Duration(days: 30));
      _customEndDate = DateTime.now();
    } else if (_selectedDateRange == 'Custom Date Range') {
      _customStartDate = DateTime.now().subtract(Duration(days: 30));
      _customEndDate = DateTime.now();
    }
    notifyListeners();
  }

  void setCustomStartDate(DateTime? date) {
    _customStartDate = date;
    notifyListeners();
  }

  void setCustomEndDate(DateTime? date) {
    _customEndDate = date;
    notifyListeners();
  }

  // List<SettledTransaction> get transactions =>
  //     transactionHistoryFromJson(
  //             getDummyPosTxnHistoryReport(pageNumber: 0, pageSize: 20))
  //         .content ??
  //     [];
}
