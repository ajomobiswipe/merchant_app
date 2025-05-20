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
  TransactionHistoryRequestModel _recentTranReqModel =
      TransactionHistoryRequestModel();
  List<TransactionElement> recentTransactions = [];
  double _totalTransactions = 0;
  double _totalSettlementAmount = 0;
  double get totalTransactions => _totalTransactions;
  double get totalSettlementAmount => _totalSettlementAmount;

  List<TransactionElement> get transactions => recentTransactions;
  HomeScreenTabItem get selectedTab => _selectedTab;
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
      recentTransactions = transactionHistoryFromJson(response).content ?? [];
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
      _totalTransactions = recentTransactions.length.toDouble();
      notifyListeners();
    });
  }

  void updateSelectedTab(HomeScreenTabItem tab) {
    _selectedTab = tab;
    notifyListeners();
  }
}
