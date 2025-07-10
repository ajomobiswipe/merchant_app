import 'dart:convert';

import 'package:anet_merchant_app/data/models/transaction_history_request_model.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
  double _totalTransactionAmount = 0.0;

  double get getTotalTransactionAmount => _totalTransactionAmount;

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

  Future<void> getRecentTransactions() async {
    print("Current Page: $currentPage");
    print("Page Size: $pageSize");
    print("Total Items: $_todaysTnxCount");
    print("Recent Transactions Length: ${recentTransactions.length}");

    if (recentTransactions.length >= _todaysTnxCount &&
        !isRecentTransLoadingFistTime) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId') ?? "651010000022371";
    print(merchantId);

    print("Inside fetchItems");

    _recentTranReqModel
      ..acquirerId = "OMAIND"
      ..merchantId = merchantId
      ..recordFrom = DateTime.now().toLocal().toString().split(' ')[0]
      ..recordTo = DateTime.now().toLocal().toString().split(' ')[0]
      // ..recordFrom = "06-05-2025"
      // ..recordTo = "03-06-2025"
      // ..recordFrom = "22-01-2023"
      // ..recordTo = "27-05-2025"
      ..rrn = null
      ..terminalId = null
      ..sendTxnReportToMail = false;

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
        final decodedData = TransactionHistory.fromJson(
          response.data,
        ); //for dio
        // final decodedData = transactionHistoryFromJson(
        //   jsonEncode(response.data),
        // );// for http

        final newItems = decodedData.responsePage?.content ?? [];
        _todaysTnxCount = decodedData.responsePage?.totalElements ?? 0;
        _totalTransactionAmount = decodedData.totalAmount ?? 0.0;

        // print(
        //     "todays transaction count: ${decodedData.responsePage!.totalElements}");

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

  Future<void> fetchDailySettlementTxnSummary() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';

    var reqbody = {
      "merchantId": merchantId,
      "isReconsiled": true,
      "isSettled": true
    };

    final response =
        await _merchantServices.fetchDailySettlementTxnSummary(reqbody);

    if (response.statusCode == 200) {
      final decodedData = response.data['responseData'];
      _totalSettlementAmount = decodedData['txnAmount'] ?? 0.0;
      _deductions = decodedData['deductionAmount'] ?? 0.0;
      _pendingSettlement = decodedData['pendingSettlementAmount'] ?? 0.0;
      notifyListeners();
    }
  }

  Future<void> fetchDailyMerchantTxnSummary() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';

    var reqbody = {
      "merchantId": merchantId,
    };

    final response =
        await _merchantServices.fetchDailyMerchantTxnSummary(reqbody);

    if (response.statusCode == 200) {
      final decodedData = response.data['responseData'];
      _totalSettlementAmount = decodedData['txnAmount'] ?? 0.0;
      notifyListeners();
    }
  }

  // Update selected tab
  void updateSelectedTab(HomeScreenTabItem tab) {
    _selectedTab = tab;
    notifyListeners();
  }
}
