import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/sampledata/sampledata.dart';
import 'package:flutter/material.dart';

enum HomeScreenTabItem { TransactionHistory, Settlements, Mpr }

class MerchantProvider with ChangeNotifier {
  HomeScreenTabItem _selectedTab = HomeScreenTabItem.TransactionHistory;

  double _totalTransactions = 5;
  double _totalSettlementAmount = 565647;
  double get totalTransactions => _totalTransactions;
  double get totalSettlementAmount => _totalSettlementAmount;

  List<TransactionElement> get transactions =>
      transactionFromJson(transaction).transactions ?? [];
  HomeScreenTabItem get selectedTab => _selectedTab;

  void updateSelectedTab(HomeScreenTabItem tab) {
    _selectedTab = tab;
    notifyListeners(); // Notifies the UI to rebuild
  }
}
