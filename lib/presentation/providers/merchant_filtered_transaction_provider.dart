import 'package:anet_merchant_app/data/models/transaction_history_request_model.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantFilteredTransactionProvider extends ChangeNotifier {
  MerchantServices merchantServices = MerchantServices();
  final TextEditingController searchController = TextEditingController();
  // Services
  final MerchantServices _merchantServices = MerchantServices();
  String _searchType = 'RRN';
  String? _selectedTid = "ALL";
  String? _selectedDateRange;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  String _selectedPaymentMode = 'ALL';

  List<String> tidOptions = ["ALL", 'TID001', 'TID002', 'TID003'];
  List<String> dateRanges = [
    "Today - ${DateFormat('d MMM yyyy').format(DateTime.now())}",
    'Yesterday - ${DateFormat('d MMM yyyy').format(DateTime.now().subtract(Duration(days: 1)))}',
    'Last 7 Days',
    'Last 1 Month',
    'Custom Date Range'
  ];
  List<String> paymentModes = ['ALL', 'Card', 'UPI'];

  // Getters
  String get searchType => _searchType;
  String? get selectedTid => _selectedTid;
  String? get selectedDateRange => _selectedDateRange;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  String getFormattedDateRange() {
    if (_selectedDateRange == 'Custom Date Range' &&
        _customStartDate != null &&
        _customEndDate != null) {
      return '${DateFormat('dd-MM-yyyy').format(_customStartDate!)} to ${DateFormat('dd-MM-yyyy').format(_customEndDate!)}';
    }
    return _selectedDateRange ?? '';
  }

  String get selectedPaymentMode => _selectedPaymentMode;

  // Controllers
  final ScrollController _allTransScrollCtrl = ScrollController();
  ScrollController get allTransScrollCtrl => _allTransScrollCtrl;

  // Models
  final TransactionHistoryRequestModel _allTranReqModel =
      TransactionHistoryRequestModel();

  // Flags
  bool _isAllTransactionsLoading = false;
  bool isAllTransLoadingFistTime = true;
  bool _isEmailSending = false;

  // Pagination
  int currentPage = 0;
  final int pageSize = 10;

  // Transaction Data
  int _allTnxCount = 0; // Simulate total from API
  List<TransactionElement> _allTransactions = [];
  double _totalAmountInAllTrans = 0;

  double get getTotalTransactionAmount => _totalAmountInAllTrans;
  // Getters

  bool get hasMoreTransactions => _allTransactions.length < _allTnxCount;
  bool get isAllTransactionsLoading => _isAllTransactionsLoading;
  int get todaysTnxCount => _allTnxCount;
  List<TransactionElement> get allTransactions => _allTransactions;
  bool get isEmailSending => _isEmailSending;

  // Methods

  // Fetch recent transactions
  Future<void> getAllTransactions() async {
    print(_selectedDateRange);
    print(_customStartDate);
    print("Current Page: $currentPage");
    print("Page Size: $pageSize");
    print("Total Items: $_allTnxCount");
    print("Recent Transactions Length: ${_allTransactions.length}");

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_allTransactions.length >= _allTnxCount && !isAllTransLoadingFistTime)
      return;

    String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';
    print(merchantId);
    _allTranReqModel
      ..acquirerId = "OMAIND"
      ..merchantId = merchantId
      ..rrn = _searchType == "RRN" ? searchController.text : ''
      ..recordFrom = "22-01-2023"

      //  _customStartDate != null
      //     ? DateFormat('dd-MM-yyyy').format(_customStartDate!)
      //     : _selectedDateRange
      ..recordTo = "27-05-2025"
      // _customEndDate != null
      //     ? DateFormat('dd-MM-yyyy').format(_customEndDate!)
      //     : _selectedDateRange
      ..terminalId = null;

    // "merchantId": "651010000022371",
    // "recordFrom": "22-01-2023",
    // "recordTo": "27-05-2025",
    // "acquirerId": "OMAIND",
    // "rrn": null,
    // "terminalId": null,
    // "sendTxnReportToMail": true
    if (_isAllTransactionsLoading) return;

    _isAllTransactionsLoading = true;
    notifyListeners();

    try {
      final response = await _merchantServices.fetchTransactionHistory(
        _allTranReqModel.toJson(),
        pageNumber: currentPage,
        pageSize: pageSize,
      );

      if (response.statusCode == 200) {
        final decodedData = transactionHistoryFromJson(response.body);
        final newItems = decodedData.responsePage!.content ?? [];
        _allTnxCount = decodedData.responsePage!.totalElements ?? 0;
        _totalAmountInAllTrans = decodedData.totalAmount ?? 0.0;
        print(
            "todays transaction count: ${decodedData.responsePage!.totalElements}");
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
  Future<void> sendAllTransactionsToEmail() async {
    if (_allTransactions.isEmpty) {
      AlertService().error("No transactions available to send.");
      return;
    }
    print(_selectedDateRange);
    print(_customStartDate);
    print("Current Page: $currentPage");
    print("Page Size: $pageSize");
    print("Total Items: $_allTnxCount");
    print("Recent Transactions Length: ${_allTransactions.length}");

    _allTranReqModel
      ..acquirerId = "OMAIND"
      ..merchantId = "65OMA0000000002"
      ..rrn = _searchType == "RRN" ? searchController.text : ''
      ..recordFrom = _customStartDate != null
          ? DateFormat('dd-MM-yyyy').format(_customStartDate!)
          : _selectedDateRange
      ..recordTo = _customEndDate != null
          ? DateFormat('dd-MM-yyyy').format(_customEndDate!)
          : _selectedDateRange
      ..terminalId = null
      ..sendTxnReportToMail = true;

    _isEmailSending = true;
    notifyListeners();

    try {
      final response = await _merchantServices.fetchTransactionHistory(
        _allTranReqModel.toJson(),
        pageNumber: 0,
        pageSize: 100,
      );

      if (response.statusCode == 200) {
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
  void refreshAllTransactions() {
    _allTransactions = [];
    currentPage = 0;
    isAllTransLoadingFistTime = true;
    _allTnxCount = 0;
    notifyListeners();
    getAllTransactions();
    notifyListeners();
  }

  // Setters
  void setSearchType(String? value) {
    _searchType = value!;
    searchController.clear();
    notifyListeners();
  }

  // fetchTransactionHistory() {
  //   var res = merchantServices.fetchTransactionHistory({
  //     "merchantId": "65OMA0000000002",
  //     "recordFrom": _selectedDateRange,
  //     "recordTo": _se,
  //     "acquirerId": "OMAIND",
  //     "rrn": "000017088748",
  //     "terminalId": null
  //   }, pageNumber: 0, pageSize: 10);
  // }

  void setSelectedTid(String? value) {
    _selectedTid = value;
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
      // Custom date range is already set via setCustomStartDate and setCustomEndDate
    }
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

  void setSelectedPaymentMode(String? value) {
    _selectedPaymentMode = value!;
    notifyListeners();
  }
}
