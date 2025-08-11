import 'package:anet_merchant_app/data/models/transaction_history_request_model.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/data/services/dio_exception_handlers.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Enums
enum HomeScreenTabItem {
  TransactionHistory,
  Settlements,
}

class HomeScreenProvider with ChangeNotifier {
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

  /// Fetches recent transactions from the server and updates the transaction list.
  ///
  /// This method retrieves the recent transactions based on the current page
  /// and page size. It checks if the recent transactions list has reached the
  /// total number of transactions and if it is not loading for the first time,
  /// then it returns early. If the transactions are still loading, it sets the
  /// loading flag and notifies listeners. The method fetches transaction history
  /// from the merchant services using the request model and updates the
  /// transaction list and total transaction amount if the response is successful.
  /// The page is incremented, and transactions are added if new items are
  /// retrieved. Handles exceptions using DioException and alerts the user on
  /// failure.

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
    _recentTranReqModel
      ..acquirerId = "OMAIND"
      ..merchantId = merchantId
      ..recordFrom = today
      ..recordTo = today
      // ..recordFrom = "20-05-2025"
      // ..recordTo = "20-07-2025"
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
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching transactions: $e");
    } finally {
      _isDailyTransactionsLoading = false;
      notifyListeners();
    }
  }

  /// Resets the recent transactions data, including the current page, transaction
  /// list, loading flag, total count, and total transaction amount. Also notifies
  /// the listeners of the changes.
  void clearTransactions() {
    currentPage = 0;
    recentTransactions = [];
    isRecentTransLoadingFistTime = true;
    _todaysTnxCount = 0;
    _totalTransactionAmount = 0.0;
    notifyListeners();
  }

  // Refresh recent transactions
  /// Refreshes the list of recent transactions by clearing the current transactions,
  /// resetting the associated state, and fetching the list of recent transactions again.

  void refreshRecentTransactions() {
    clearTransactions();

    getRecentTransactions();
    // fetchDailyMerchantTxnSummary();
    // notifyListeners();
  }

  /// Fetches the daily settlement transaction summary for the merchant.
  ///
  /// Retrieves the merchant ID from shared preferences and sends a request
  /// with necessary parameters to fetch the daily settlement transaction summary.
  /// Updates the total settlement amount, deductions, and pending settlement
  /// amounts based on the response data. Notifies listeners upon successful
  /// data retrieval.

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

  // Future<void> fetchDailyMerchantTxnSummary() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';

  //   var reqbody = {
  //     "merchantId": merchantId,
  //   };

  //   final response =
  //       await _merchantServices.fetchDailyMerchantTxnSummary(reqbody);

  //   if (response.statusCode == 200) {
  //     final decodedData = response.data['responseData'];
  //     _totalSettlementAmount = decodedData['txnAmount'] ?? 0.0;
  //     notifyListeners();
  //   }
  // }

  // Update selected tab
  /// Updates the selected tab on the home screen.
  ///
  /// This method changes the current selected tab to the given [tab] and
  /// notifies listeners about the change.

  void updateSelectedTab(HomeScreenTabItem tab) {
    _selectedTab = tab;
    notifyListeners();
  }
}
