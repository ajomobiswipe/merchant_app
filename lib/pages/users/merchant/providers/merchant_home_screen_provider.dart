import 'package:flutter/material.dart';
import 'package:anet_merchant_app/pages/users/merchant/sampledata/sampledata.dart';
import 'package:anet_merchant_app/pages/users/merchant/models/transaction_model.dart';

enum HomeScreenTabItem { TransactionHistory, Settlements, Mpr }

class MerchantProvider with ChangeNotifier {
  HomeScreenTabItem _selectedTab = HomeScreenTabItem.TransactionHistory;
  final String _storeName = "Toy Store";
  double _totalTransactions = 5;
  double _totalSettlementAmount = 565647;
  double get totalTransactions => _totalTransactions;
  double get totalSettlementAmount => _totalSettlementAmount;
  String get storeName => _storeName;
  List<TransactionElement> get transactions =>
      transactionFromJson(transaction).transactions ?? [];
  HomeScreenTabItem get selectedTab => _selectedTab;

  void updateSelectedTab(HomeScreenTabItem tab) {
    _selectedTab = tab;
    notifyListeners(); // Notifies the UI to rebuild
  }
}
