import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/sampledata/sampledata.dart';
import 'package:flutter/material.dart';

class SettlementProvider with ChangeNotifier {
  final String _storeName = "Toy Store";
  String get storeName => _storeName;

  double _totalTransactions = 500;
  double _totalSettlementAmount = 3455265;
  int _totalSettlements = 20;

  double get totalTransactions => _totalTransactions;
  double get totalSettlementAmount => _totalSettlementAmount;
  int get totalSettlements => _totalSettlements;

  List<TransactionElement> get transactions =>
      transactionFromJson(transaction).transactions ?? [];

  List<Map<String, dynamic>> _utrWiseSettlements = [
    {
      "amount": 3455265,
      "settlements": 20,
      "transactions": 500,
      "utr": "1234567890",
      "settledOn": "12/12/2023"
    },
    // Add more entries as needed
  ];

  List<Map<String, dynamic>> get utrWiseSettlements => _utrWiseSettlements;
}
