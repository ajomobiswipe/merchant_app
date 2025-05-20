import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MerchantTransactionFilterProvider extends ChangeNotifier {
  MerchantServices merchantServices = MerchantServices();
  final TextEditingController searchController = TextEditingController();
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
  String get selectedPaymentMode => _selectedPaymentMode;

  // Setters
  void setSearchType(String? value) {
    _searchType = value!;
    notifyListeners();
  }

  fetchTransactionHistory() {
    var res = merchantServices.fetchTransactionHistory({
      "merchantId": "65OMA0000000002",
      "recordFrom": "22-08-2024",
      "recordTo": "22-08-2024",
      "acquirerId": "OMAIND",
      "rrn": "000017088748",
      "terminalId": null
    }, pageNumber: 0, pageSize: 10);
  }

  void setSelectedTid(String? value) {
    _selectedTid = value;
    notifyListeners();
  }

  void setSelectedDateRange(String? value) {
    _selectedDateRange = value;
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
