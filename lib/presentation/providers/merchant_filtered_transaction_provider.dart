import 'package:anet_merchant_app/data/models/transaction_history_request_model.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/data/services/dio_exception_handlers.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FilterType {
  RRNAPPCODE,
  DATERANGE,
}

enum SearchType {
  RRN,
  APP_CODE,
}

enum TerminalType { TID, VPA }

class MerchantFilteredTransactionProvider extends ChangeNotifier {
  MerchantServices merchantServices = MerchantServices();
  final TextEditingController searchController = TextEditingController();
  // Services
  final MerchantServices _merchantServices = MerchantServices();
  SearchType _selectedSearchType = SearchType.RRN;
  FilterType _searchFilterType = FilterType.DATERANGE;
  TerminalType _selectedTerminalType = TerminalType.TID;
  TerminalType get selectedTerminalType => _selectedTerminalType;

  set selectedTerminalType(TerminalType value) {
    _selectedTerminalType = value;
    notifyListeners();
  }

  FilterType get selectedSearchFilterType => _searchFilterType;
  // TextEditingController _tidSearchController = TextEditingController();
  // TextEditingController get tidSearchController => _tidSearchController;

  final ScrollController _allTidScrollCtrl = ScrollController();
  final ScrollController _allVpaScrollCtrl = ScrollController();
  TextEditingController _tidSearchController = TextEditingController();

  ScrollController get allTidScrollCtrl => _allTidScrollCtrl;
  ScrollController get allVpaScrollCtrl => _allVpaScrollCtrl;
  TextEditingController get tidSearchController => _tidSearchController;
  //  void setTid(param0) {

  //  }
  setTidOrVpa(tid) {
    _tidSearchController.text = tid;
    notifyListeners();
  }

  String? _selectedDateRange;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  bool isDateNotSelected() {
    return (_customStartDate == null || _customEndDate == null);
  }

  String _selectedPaymentMode = "ALL";

  List<String> dateRanges = [
    "Today - ${DateFormat('d MMM yyyy').format(DateTime.now())}",
    'Yesterday - ${DateFormat('d MMM yyyy').format(DateTime.now().subtract(Duration(days: 1)))}',
    'Last 7 Days',
    'Last 1 Month',
    'Custom Date Range'
  ];
  List<String> paymentModes = ["ALL", 'CARD', 'UPI'];

  // Getters
  SearchType get selectedSearchType => _selectedSearchType;
  // String? get selectedTid => _selectedTid;
  String? get selectedDateRange => _selectedDateRange;

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

  // Flags
  bool _isAllTidLoading = false;
  bool _isAllVpaLoading = false;
  bool isAllTidApiLoadingFistTime = true;
  bool isAllVpaApiLoadingFistTime = true;

  bool get isAllTidLoading => _isAllTidLoading;
  bool get isAllVpaLoading => _isAllVpaLoading;

  // Pagination
  int currentTidListPageNo = 0;
  int currentVpaListPageNo = 0;

  int _allTidCount = 0;
  int _allVpaCount = 0;
  List<dynamic> _allTerminalId = [];
  List<dynamic> _allVpa = [];

  List<dynamic> get allTid => _allTerminalId;
  List<dynamic> get allVpa => _allVpa;
  bool get hasMoreTid => _allTerminalId.length < _allTidCount;
  bool get hasMoreVpa => _allVpa.length < _allVpaCount;

  /// Fetch recent TIDs by Merchant ID
  Future<void> getTidByMerchantId() async {
    print("Current Page: $currentTidListPageNo");
    print("Page Size: 10");
    print("Total tid: $_allTidCount");
    print("Tid list Length: ${_allTerminalId.length}");

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_allTerminalId.length >= _allTidCount && !isAllTidApiLoadingFistTime) {
      return;
    }

    String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';
    print(merchantId);

    if (_isAllTidLoading) return;

    _isAllTidLoading = true;
    notifyListeners();

    try {
      final response = await _merchantServices.getTidByMerchantId(
        {},
        pageNumber: currentTidListPageNo,
        pageSize: 10,
        merchantId: merchantId,
      );

      if (response.statusCode == 200) {
        var decodedData = response.data;
        var newItems = response.data["content"] ?? [];
        _allTidCount = decodedData["totalElements"] ?? 0;
        print('_allTidCount is $_allTidCount');

        if (newItems.isNotEmpty) {
          currentTidListPageNo++;
          isAllTidApiLoadingFistTime = false;
          _allTerminalId.addAll(newItems);
        }
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching Tid: $e");
    } finally {
      _isAllTidLoading = false;
      notifyListeners();
    }
  }

  /// Fetch recent TIDs by Merchant ID
  Future<void> getVpaByMerchantId() async {
    print("Current Vpa Page: $currentVpaListPageNo");
    print("Vpa Page Size: 10");
    print("Total vpa count : $_allVpaCount");
    print("Vpa list Length: ${_allVpa.length}");

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_allVpa.length >= _allVpaCount && !isAllVpaApiLoadingFistTime) {
      return;
    }

    String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';
    print(merchantId);

    if (_isAllVpaLoading) return;

    _isAllVpaLoading = true;
    notifyListeners();

    try {
      final response = await _merchantServices.getVpaByMerchantId(
        {"merchantId": merchantId},
        pageNumber: currentVpaListPageNo,
        pageSize: 10,
        merchantId: merchantId,
      );

      if (response.statusCode == 200) {
        var decodedData = response.data;
        var newItems = response.data["pageData"]["content"] ?? [];
        _allVpaCount = decodedData["pageData"]["totalElements"] ?? 0;
        print('_allVpaCount is $_allVpaCount');

        if (newItems.isNotEmpty) {
          currentVpaListPageNo++;
          isAllVpaApiLoadingFistTime = false;
          _allVpa.addAll(newItems);
        }
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching Vpa list: $e");
    } finally {
      _isAllVpaLoading = false;
      notifyListeners();
    }
  }

  /// Refresh all TIDs
  void refreshAllTidAndVpa() {
    _allTerminalId = [];
    _allVpa = [];
    currentTidListPageNo = 0;
    currentVpaListPageNo = 0;
    isAllTidApiLoadingFistTime = true;
    isAllVpaApiLoadingFistTime = true;
    _tidSearchController.clear();
    _allTidCount = 0;
    _allVpaCount = 0;

    getTidByMerchantId();
    getVpaByMerchantId();
    notifyListeners();
  }

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

    _allTranReqModel.acquirerId = "OMAIND";
    _allTranReqModel.merchantId = merchantId;
    _allTranReqModel.rrn = getRRn();
    _allTranReqModel.authCode = getAuthCode();
    _allTranReqModel.recordFrom = getRecordFrom();
    _allTranReqModel.recordTo = getRecordTo();
    _allTranReqModel.terminalId = getTid();
    _allTranReqModel.creditVpa = getVpa();
    _allTranReqModel.sendTxnReportToMail = false;
    _allTranReqModel.sourceOftxn = getPaymentMode();

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
        final decodedData = TransactionHistory.fromJson(response.data);
        var newItems = decodedData.responsePage!.content ?? [];
        _allTnxCount = decodedData.responsePage!.totalElements ?? 0;
        print('_allTnxCount is $_allTnxCount');
        _totalAmountInAllTrans = decodedData.totalAmount ?? 0.0;
        print(
            "todays transaction count: ${decodedData.responsePage!.totalElements}");
        if (newItems.isNotEmpty) {
          currentPage++;

          isAllTransLoadingFistTime = false;

          _allTransactions.addAll(newItems);
        }
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching transactions: $e");
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';
    print(merchantId);
    print(_selectedDateRange);
    print(_customStartDate);
    print("Current Page: $currentPage");
    print("Page Size: $pageSize");
    print("Total Items: $_allTnxCount");
    print("Recent Transactions Length: ${_allTransactions.length}");

    _allTranReqModel
      ..acquirerId = "OMAIND"
      ..merchantId = merchantId
      ..rrn = getRRn()
      ..authCode = getAuthCode()
      ..recordFrom = getRecordFrom()
      ..recordTo = getRecordTo()
      ..terminalId = getTid()
      ..sourceOftxn = getPaymentMode()
      ..creditVpa = getVpa()
      ..sendTxnReportToMail = true;

    _isEmailSending = true;
    notifyListeners();

    try {
      final response = await _merchantServices.fetchTransactionHistory(
        _allTranReqModel.toJson(),
        pageNumber: 0,
        pageSize: _allTnxCount,
      );

      if (response.statusCode == 200) {
        final decodedData = TransactionHistory.fromJson(response.data);
        if (decodedData.sendMailResponse!.responseCode == "00") {
          AlertService().success(
              " Transaction report has been sent to your registered email.");
        } else {
          AlertService().error("Error Sending Transaction report .");
        }
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching transactions: $e");
    } finally {
      _isEmailSending = false;
      notifyListeners();
    }
  }

  String? getRRn() => _searchFilterType == FilterType.RRNAPPCODE &&
          _selectedSearchType == SearchType.RRN
      ? searchController.text
      : '';

  String? getAuthCode() => _searchFilterType == FilterType.RRNAPPCODE &&
          _selectedSearchType == SearchType.APP_CODE
      ? searchController.text
      : '';

  getRecordFrom() {
    if (_searchFilterType == FilterType.DATERANGE && _customStartDate != null) {
      return DateFormat('dd-MM-yyyy').format(_customStartDate!);
    }
    return null;
  }

  getRecordTo() {
    if (_searchFilterType == FilterType.DATERANGE && _customEndDate != null) {
      return DateFormat('dd-MM-yyyy').format(_customEndDate!);
    } else {
      return null;
    }
  }

  getTid() {
    if (_searchFilterType == FilterType.DATERANGE &&
        _tidSearchController.text.isNotEmpty &&
        _selectedTerminalType == TerminalType.TID) {
      return _tidSearchController.text;
    } else {
      return null;
    }
  }

  getVpa() {
    if (_searchFilterType == FilterType.DATERANGE &&
        _tidSearchController.text.isNotEmpty &&
        _selectedTerminalType == TerminalType.VPA) {
      return _tidSearchController.text;
    } else {
      return null;
    }
  }

  getPaymentMode() {
    if (_searchFilterType == FilterType.DATERANGE) {
      return _selectedPaymentMode;
    } else {
      return null;
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

  void resetFilters() {
    _selectedSearchType = SearchType.RRN;
    _searchFilterType = FilterType.DATERANGE;
    _selectedTerminalType = TerminalType.TID;
    tidSearchController.clear();
    _tidSearchController.clear();
    _selectedDateRange = null;
    _customStartDate = null;
    _customEndDate = null;
    _selectedPaymentMode = 'ALL';
    refreshAllTidAndVpa();
    searchController.clear();

    notifyListeners();
  }

  // Setters
  void setSearchType(SearchType value) {
    _selectedSearchType = value;
    searchController.clear();

    notifyListeners();
  }

  void setFilterType(FilterType? value) {
    searchController.clear();
    _tidSearchController.clear();
    _selectedDateRange = null;
    _searchFilterType = value!;
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

  // void setSelectedTid(String? value) {
  //   _selectedTid = value;
  //   notifyListeners();
  // }

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
      print(_customEndDate);
    } else if (_selectedDateRange == 'All') {
      _customStartDate = null;
      _customEndDate = null;
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
