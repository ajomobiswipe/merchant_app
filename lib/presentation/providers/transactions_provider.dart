import 'dart:convert';

import 'package:anet_merchant_app/data/models/transaction_history_request_model.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/sampledata/sampledata.dart';
import 'package:flutter/material.dart';

// Enums
enum HomeScreenTabItem {
  TransactionHistory,
  Settlements,
}

class TransactionProvider with ChangeNotifier {
  // Enums
  HomeScreenTabItem _selectedTab = HomeScreenTabItem.TransactionHistory;

  // Services
  final MerchantServices _merchantServices = MerchantServices();

  // Controllers
  final ScrollController _recentTransScrollCtrl = ScrollController();
  ScrollController get recentTransScrollCtrl => _recentTransScrollCtrl;

  // Models
  final TransactionHistoryRequestModel _recentTranReqModel =
      TransactionHistoryRequestModel();

  // Flags
  bool _isDailyTransactionsLoading = false;
  bool isRecentTransLoadingFistTime = true;

  // Pagination
  int currentPage = 0;
  final int pageSize = 10;

  // Transaction Data
  int _todaysTnxCount = 0; // Simulate total from API
  List<TransactionElement> recentTransactions = [];

  // Getters

  bool get hasMoreTransactions => recentTransactions.length < _todaysTnxCount;
  bool get isDailyTransactionsLoading => _isDailyTransactionsLoading;
  int get todaysTnxCount => _todaysTnxCount;

  List<TransactionElement> get transactions => recentTransactions;
  HomeScreenTabItem get selectedTab => _selectedTab;
// Getters for settlement data
  String get storeName => "Toy Store"; // Simulated store name
  double _totalSettlementAmount = 0;
  int _totalSettlements = 20;
  int _totalTransactions = 20;
  double _deductions = 0;
  double _pendingSettlement = 0;

  double get totalSettlementAmount => _totalSettlementAmount;
  int get totalSettlements => _totalSettlements;
  double get deductionsAmount => _deductions;
  double get pendingSettlementAmount => _pendingSettlement;
  int get totalTransactions => _totalTransactions;
  // Methods

  // Fetch recent transactions
  Future<void> getRecentTransactions() async {
    print("Current Page: $currentPage");
    print("Page Size: $pageSize");
    print("Total Items: $_todaysTnxCount");
    print("Recent Transactions Length: ${recentTransactions.length}");
    if (recentTransactions.length >= _todaysTnxCount &&
        !isRecentTransLoadingFistTime) return;

    print("Inside fetchItems");
    _recentTranReqModel
      ..acquirerId = "OMAIND"
      ..merchantId = "65OMA0000000002"
      ..recordFrom = "22-08-2024"
      ..recordTo = "09-09-2024"
      //      ..recordFrom = "${DateTime.now().toLocal().toString().split(' ')[0]}"
      // ..recordTo = "${DateTime.now().toLocal().toString().split(' ')[0]}"
      ..rrn = ""
      ..terminalId = null;

    if (_isDailyTransactionsLoading) return;

    _isDailyTransactionsLoading = true;
    notifyListeners();

    try {
      final response = await _merchantServices.fetchTransactionHistory(
        _recentTranReqModel.toJson(),
        pageNumber: currentPage,
        pageSize: pageSize,
      );

      if (response.statusCode == 200) {
        final decodedData = transactionHistoryFromJson(response.body);
        final newItems = decodedData.content ?? [];
        _todaysTnxCount = decodedData.totalElements ?? 0;
        print("todays transaction count: ${decodedData.totalElements}");
        if (newItems.isNotEmpty) {
          isRecentTransLoadingFistTime = false;
          currentPage++;
          recentTransactions.addAll(newItems);
        }
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      _isDailyTransactionsLoading = false;
      notifyListeners();
    }
  }

  void clearTransactions() {
    recentTransactions = [];

    notifyListeners();
  }

  // Refresh recent transactions
  void refreshRecentTransactions() {
    recentTransactions = [];
    currentPage = 0;
    isRecentTransLoadingFistTime = true;
    _todaysTnxCount = 0;
    notifyListeners();
    getRecentTransactions();
    fetchDailyMerchantTxnSummary();
    notifyListeners();
  }

  // Fetch daily settlement transaction summary
  Future<void> fetchDailySettlementTxnSummary() async {
    var reqbody = {
      "merchantId": "65OMA0000000002",
      "isReconsiled": true,
      "isSettled": true
    };
    var response =
        await _merchantServices.fetchDailySettlementTxnSummary(reqbody);

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body)['responseData'];
      _totalSettlementAmount = decodedData['txnAmount'] ?? 0.0;
      _deductions = decodedData['deductionAmount'] ?? 0.0;
      _pendingSettlement = decodedData['pendingSettlementAmount'] ?? 0.0;
      notifyListeners();
    }
  }

  Future<void> fetchDailyMerchantTxnSummary() async {
    var reqbody = {
      "merchantId": "65OMA0000000002",
    };
    var response =
        await _merchantServices.fetchDailyMerchantTxnSummary(reqbody);

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body)['responseData'];
      _totalSettlementAmount = decodedData['txnAmount'] ?? 0.0;
      // _totalSettlementAmount = decodedData['txnAmount'] ?? 0.0;
      // _deductions = decodedData['deductionAmount'] ?? 0.0;
      // _pendingSettlement = decodedData['pendingSettlementAmount'] ?? 0.0;
      notifyListeners();
    }
  }

  // Update selected tab
  void updateSelectedTab(HomeScreenTabItem tab) {
    _selectedTab = tab;
    notifyListeners();
  }
}
