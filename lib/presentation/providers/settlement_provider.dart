import 'package:anet_merchant_app/data/models/get_settlement_dashboard_data.dart';
import 'package:anet_merchant_app/data/models/get_settlement_history_model.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/sampledata/sampledata.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SettlementProvider extends ChangeNotifier {
  final String _storeName = "Toy Store";
  String get storeName => _storeName;

  double _totalSettlementAmount = 0.0;

  int _totalTransactions = 0;
  int _totalSettlement = 0;
  double _deductions = 0;
  bool _isoading = false;

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

  // Getters

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
  List<SettledTransaction> _allTransactions = [];
  List<SettledTransaction> get allTransactions => _allTransactions;
  // Getters

  bool get hasMoreTransactions => _allTransactions.length < _allTnxCount;
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
    _allTransactions = [];
    notifyListeners();
    var reqBody = {
      "merchantId": "651076000006945",
      "fromDate": getFormattedDate(_selectedSettlementAggregate!.tranDate!),
      "toDate": getFormattedDate(_selectedSettlementAggregate!.tranDate!),
      "reconsiled": true,
      "merPayDone": true,
      "misDone": true,
      "pageDataRequired": true,
      "settlementAggregatesRequired": true
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
        _allTnxCount = decodedData.settledSummaryPage?.totalElements ?? 0;

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

  // Fetch recent transactions
  Future<void> getSettlementDashboardReport() async {
    _isoading = true;
    notifyListeners();
    var reqBody = {
      "merchantId": "651076000006945",
      "fromDate": "2024-05-01",
      "toDate": "2025-05-22",
      "reconsiled": true,
      "merPayDone": true,
      "misDone": true,
      "pageDataRequired": false,
      "settlementAggregatesRequired": true
    };

    try {
      final response = await _merchantServices.getSettlementDashboardReport(
        reqBody,
        pageNumber: currentPage,
        pageSize: pageSize,
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
    } else if (_selectedDateRange == 'Custom Date Range') {}
    print(_customEndDate);
    print(_customStartDate);
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
