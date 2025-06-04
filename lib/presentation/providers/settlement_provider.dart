import 'package:anet_merchant_app/data/models/get_settlement_dashboard_data.dart';
import 'package:anet_merchant_app/data/models/get_settlement_history_model.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/sampledata/sampledata.dart';
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

  bool _isoading = false;
  bool _isEmailSending = false;
  bool get isEmailSending => _isEmailSending;

  bool get isLoading => _isoading;
  double get totalSettlementAmount => _totalSettlementAmount;
  double get deductionsAmount => _deductions;

  int get totalTransactions => _totalTransactions;
  int get totalSettlement => _totalSettlement;

  AlertService _alertService = AlertService();

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

  // Flags
  bool _isAllTransactionsLoading = false;
  bool isAllTransLoadingFistTime = true;

  // Pagination
  int currentPage = 0;
  final int pageSize = 10;

  // Transaction Data
  int _allTnxCount = 0; // Simulate total from API
  int _transactionsInSettlementCount = 0; // Simulate total from API
  int get transactionsInSettlementCount => _transactionsInSettlementCount;
  List<SettledTransaction> _allTransactions = [];
  List<SettledTransaction> get allTransactions => _allTransactions;
  // Getters

  bool get hasMoreTransactions =>
      _allTransactions.length < _transactionsInSettlementCount;

  bool get isAllTransactionsLoading => _isAllTransactionsLoading;

  List<SettlementAggregate> _utrWiseSettlements = [];
  List<SettlementAggregate> get utrWiseSettlements => _utrWiseSettlements;
  SettlementAggregate? _selectedSettlementAggregate;
  void setSelectedSettlementAggregate(SettlementAggregate? settlement) {
    _selectedSettlementAggregate = settlement;
  }

  SettlementAggregate? get selectedSettlementAggregate =>
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
        final decodedData = getSettlementHistoryDataFromJson(response.body);
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

  clearTransactionList() {
    currentPage = 0;
    _allTransactions = [];
    isAllTransLoadingFistTime = true;
    _transactionsInSettlementCount = 0;
    notifyListeners();
  }

  // Fetch recent transactions
  Future<void> getSettlementDashboardReport() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId') ?? '651010000022371';
    _isoading = true;
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
      "sendSettlementReportToMail": false
    };

    try {
      final response = await _merchantServices.getSettlementDashboardReport(
        reqBody,
        pageNumber: 0,
        pageSize: 100,
      );

      if (response.statusCode == 200) {
        final decodedData = getSettlementDashboardDataFromJson(response.body);
        _totalSettlementAmount =
            decodedData.settlementTotal?.totalAmount ?? 0.00;
        _totalSettlement = decodedData.settlementTotal?.settlementCount ?? 0;
        _totalTransactions = decodedData.settlementTotal?.transactionCount ?? 0;

        _utrWiseSettlements = decodedData.settlementAggregates ?? [];
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      _isoading = false;
      notifyListeners();
    }
  }

  Future<void> sendSettlementDashboardReportTOEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';
    _isEmailSending = true;
    notifyListeners();
    var reqBody = {
      "merchantId": merchantId,
      "fromDate": DateFormat('yyyy-MM-dd').format(_customStartDate!),
      "toDate": DateFormat('yyyy-MM-dd').format(_customEndDate!),
      "reconsiled": true,
      "merPayDone": true,
      "misDone": true,
      "pageDataRequired": true,
      "settlementAggregatesRequired": true,
      "sendSettlementReportToMail": true
    };

    try {
      final response = await _merchantServices.getSettlementDashboardReport(
        reqBody,
        pageNumber: 0,
        pageSize: 100,
      );

      if (response.statusCode == 200) {
        final decodedData = getSettlementDashboardDataFromJson(response.body);
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

  // Refresh recent transactions
  void refreshDasBoard() {
    _allTransactions = [];
    currentPage = 0;
    isAllTransLoadingFistTime = true;
    _allTnxCount = 0;
    notifyListeners();
    getSettlementDashboardReport();
    notifyListeners();
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
