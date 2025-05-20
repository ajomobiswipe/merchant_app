import 'dart:convert';

import 'package:anet_merchant_app/data/models/transaction_history_request_model.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/sampledata/sampledata.dart';
import 'package:flutter/material.dart';

enum HomeScreenTabItem {
  TransactionHistory,
  Settlements,
}

class TransactionProvider with ChangeNotifier {
  HomeScreenTabItem _selectedTab = HomeScreenTabItem.TransactionHistory;
  MerchantServices _merchantServices = MerchantServices();
  final ScrollController _recentTransScrollCtrl = ScrollController();
  ScrollController get recentTransScrollCtrl => _recentTransScrollCtrl;
  TransactionHistoryRequestModel _recentTranReqModel =
      TransactionHistoryRequestModel();
  bool _isTransactionsLoading = false;
  bool get isTransactionsLoading => _isTransactionsLoading;

  int currentPage = 0;
  final int pageSize = 10;
  final int totalItems = 50; // simulate total from API
  List<TransactionElement> recentTransactions = [];
  bool get hasMoreTransactions => recentTransactions.length < totalItems;

  int _totalTransactions = 0;
  double _totalSettlementAmount = 0;
  int get totalTransactions => _totalTransactions;
  double get totalSettlementAmount => _totalSettlementAmount;

  List<TransactionElement> get transactions => recentTransactions;
  HomeScreenTabItem get selectedTab => _selectedTab;

  Future<void> fetchItems() async {
    print("Current Page: $currentPage");
    print("Page Size: $pageSize");
    print("Total Items: $totalItems");
    print("Recent Transactions Length: ${recentTransactions.length}");
    if (recentTransactions.length >= totalItems) return;
    print("Inside fetchItems");
    _isTransactionsLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 2));

    var newItems = transactionHistoryFromJson(transaction).content ?? [];

    currentPage++;
    recentTransactions.addAll(newItems);
    _isTransactionsLoading = false;
    notifyListeners();
  }

  geRecentTransactions() async {
    _recentTranReqModel.acquirerId = "OMAIND";
    _recentTranReqModel.merchantId = "65OMA0000000002";
    _recentTranReqModel.recordFrom = "22-08-2024";
    _recentTranReqModel.recordTo = "22-08-2024";
    _recentTranReqModel.rrn = "000017088748";
    _recentTranReqModel.terminalId = null;
    var response = await _merchantServices.fetchTransactionHistory(
        _recentTranReqModel.toJson(),
        pageNumber: 0,
        pageSize: 10);
    if (response.statusCode == 200) {
      recentTransactions = transactionHistoryFromJson(response.body).content ?? [];
      notifyListeners();
    }
  }

  fetchDailySettlementTxnSummary() async {
    var reqbody = {
      "merchantId": "65OMA0000000002",
      "isReconsiled": true,
      "isSettled": true
    };
    var response =
        await _merchantServices.fetchDailySettlementTxnSummary(reqbody);

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body)['responseData'];
      _totalTransactions = decodedData['txnCount'] ?? 0;
      _totalSettlementAmount = decodedData['txnAmount'] ?? 0.0;
      notifyListeners();
    }
  }

  refreshRecentTransactions() {
    recentTransactions = [];

    notifyListeners();
    Future.delayed(Duration(seconds: 2), () {
      recentTransactions =
          transactionHistoryFromJson(transaction).content ?? [];

      _totalSettlementAmount = recentTransactions.fold(
          0.0,
          (sum, transaction) =>
              sum + double.parse((transaction.amount ?? '0.0').toString()));
      _totalTransactions = recentTransactions.length;
      notifyListeners();
    });
  }

  void updateSelectedTab(HomeScreenTabItem tab) {
    _selectedTab = tab;
    notifyListeners();
  }
}
