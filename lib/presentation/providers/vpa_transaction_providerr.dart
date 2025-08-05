import 'package:anet_merchant_app/data/models/transaction_history_request_model.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/data/services/dio_exception_handlers.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class VpaTransactionProvider with ChangeNotifier {
  // Enums

  // Services
  final MerchantServices _merchantServices = MerchantServices();

  // Controllers
  final ScrollController _recentTransScrollCtrl = ScrollController();
  ScrollController get recentTransScrollCtrl => _recentTransScrollCtrl;

  // Models

  // Flags
  bool _isDailyTransactionsLoading = false;
  bool isRecentTransLoadingFistTime = true;

  // Pagination
  int currentPage = 0;
  final int pageSize = 10;

  // Transaction Data
  int _todaysTnxCount = 0; // Simulate total from API
  List<dynamic> recentTransactions = [];
  double _totalTransactionAmount = 0.0;

  double get getTotalTransactionAmount => _totalTransactionAmount;

  // Getters

  bool get hasMoreTransactions => recentTransactions.length < _todaysTnxCount;
  bool get isDailyTransactionsLoading => _isDailyTransactionsLoading;
  int get todaysTnxCount => _todaysTnxCount;

  List<dynamic> get transactions => recentTransactions;

// Getters for settlement data
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
    String? merchantId = prefs.getString('acqMerchantId');
    print(merchantId);
    print("Inside fetchItems");
    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // _recentTranReqModel
    //   ..acquirerId = "OMAIND"
    //   ..merchantId = merchantId
    //   // ..recordFrom = today
    //   // ..recordTo = today
    //   ..recordFrom = "20-05-2025"
    //   ..recordTo = "20-07-2025"
    //   ..rrn = null
    //   ..terminalId = null
    //   ..sendTxnReportToMail = false;

    if (_isDailyTransactionsLoading) return;

    _isDailyTransactionsLoading = true;
    notifyListeners();

    try {
      final response = await _merchantServices.fetchVpaTransactionHistory(
        {"from": null, "to": null, "creditVpa": "Hardwarisweets.anet@axisbank"},
        pageNumber: currentPage,
        pageSize: pageSize,
      );
      var decodedData = response.data;
      print(decodedData["pageData"]["totalElements"]);
      if (response.statusCode == 200) {
        // final decodedData = transactionHistoryFromJson(
        //   jsonEncode(response.data),
        // );// for http

        final newItems = decodedData["pageData"]["content"] ?? [];
        _todaysTnxCount = decodedData["pageData"]["totalElements"] ?? 0;
        print(decodedData["pageData"]["totalElements"]);
        // _totalTransactionAmount = decodedData.totalAmount ?? 0.0;

        // print(
        //     "todays transaction count: ${decodedData.responsePage!.totalElements}");

        if (newItems.isNotEmpty) {
          isRecentTransLoadingFistTime = false;
          currentPage++;
          recentTransactions.addAll(newItems);
        }
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching transactions: $e");
    } finally {
      _isDailyTransactionsLoading = false;
      notifyListeners();
    }
  }

  void clearTransactions() {
    currentPage = 0;
    isRecentTransLoadingFistTime = true;
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

    notifyListeners();
  }
}
