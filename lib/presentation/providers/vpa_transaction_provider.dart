import 'package:anet_merchant_app/data/services/dio_exception_handlers.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/providers/merchant_filtered_transaction_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

class DummyMerchantProvider extends MerchantFilteredTransactionProvider {}

class VpaTransactionProvider with ChangeNotifier {
  final MerchantFilteredTransactionProvider transactionProvider;

  VpaTransactionProvider(this.transactionProvider) {
    // Access fromDate and toDate
    print("FROM: ${transactionProvider.customStartDate}");
    print("TO: ${transactionProvider.customEndDate}");
  }
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
  int _TnxCount = 0; // Simulate total from API
  List<dynamic> recentTransactions = [];

  double _totalTransactionAmount = 0.0;

  double getSumOfTransactions() {
    return recentTransactions.fold(0.0, (sum, transaction) {
      final rawAmount = transaction['transactionAmount'];
      final parsedAmount = double.tryParse(rawAmount?.toString() ?? '');
      return sum + (parsedAmount ?? 0.0);
    });
  }

  double get getTotalTransactionAmount => _totalTransactionAmount;

  // Getters

  bool get hasMoreTransactions => recentTransactions.length < _TnxCount;
  bool get isDailyTransactionsLoading => _isDailyTransactionsLoading;
  int get TnxCount => _TnxCount;

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
  String? formatDateOrNull(DateTime? date) {
    return date != null ? DateFormat('dd-MM-yyyy').format(date) : null;
  }

  Future<void> getRecentTransactions() async {
    print("Current Page: $currentPage");
    print("Page Size: $pageSize");
    print("Total Items: $_TnxCount");
    print("Recent Transactions Length: ${recentTransactions.length}");

    if (recentTransactions.length >= _TnxCount && !isRecentTransLoadingFistTime)
      return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId');
    print(merchantId);
    print("Inside fetchItems");
    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final startDate = formatDateOrNull(transactionProvider.customStartDate);
    final endDate = formatDateOrNull(transactionProvider.customEndDate);
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
        {
          "from": startDate,
          "to": endDate,
          "creditVpa": transactionProvider.tidSearchController.text.trim(),
        },
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
        _TnxCount = decodedData["pageData"]["totalElements"] ?? 0;
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
    _TnxCount = 0;
    notifyListeners();
    getRecentTransactions();

    notifyListeners();
  }
}
