import 'package:anet_merchant_app/core/utils/pageing_element.dart';
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
  final MerchantServices _merchantServices = MerchantServices();

  // Controllers
  final ScrollController _recentTransScrollCtrl = ScrollController();
  ScrollController get recentTransScrollCtrl => _recentTransScrollCtrl;

  // Models
  final TransactionHistoryRequestModel _recentTranReqModel =
      TransactionHistoryRequestModel();

  // Enums
  HomeScreenTabItem _selectedTab = HomeScreenTabItem.TransactionHistory;
  HomeScreenTabItem get selectedTab => _selectedTab;

  // Pagination handlers
  final PaginationHandler<TransactionElement> recentTransactionsPagination =
      PaginationHandler<TransactionElement>(pageSize: 10);

  // Settlement summary
  double _totalSettlementAmount = 0;
  double _deductions = 0;
  double _pendingSettlement = 0;
  int _totalTransactions = 0;

  double get totalSettlementAmount => _totalSettlementAmount;
  double get deductionsAmount => _deductions;
  double get pendingSettlementAmount => _pendingSettlement;
  int get totalTransactions => _totalTransactions;

  double get totalTransactionAmount => _totalTransactionAmount;
  double _totalTransactionAmount = 0.0;

  // Store name

  Future<void> getRecentTransactions() async {
    if (!recentTransactionsPagination.hasMore &&
        !recentTransactionsPagination.isFirstLoad) return;

    final prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId');

    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _recentTranReqModel
      ..acquirerId = "OMAIND"
      ..merchantId = merchantId
      ..recordFrom = today
      ..recordTo = today
      ..rrn = null
      ..terminalId = null
      ..sendTxnReportToMail = false;

    if (recentTransactionsPagination.isLoading) return;

    recentTransactionsPagination.isLoading = true;
    notifyListeners();

    try {
      final response = await _merchantServices.fetchTransactionHistory(
        _recentTranReqModel.toJson(),
        pageNumber: recentTransactionsPagination.currentPage,
        pageSize: recentTransactionsPagination.pageSize,
      );

      if (response.statusCode == 200) {
        final decodedData = TransactionHistory.fromJson(response.data);
        final newItems = decodedData.responsePage?.content ?? [];

        _totalTransactionAmount = decodedData.totalAmount ?? 0.0;

        recentTransactionsPagination.addItems(
          newItems,
          decodedData.responsePage?.totalElements ?? 0,
        );
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching transactions: $e");
    } finally {
      recentTransactionsPagination.isLoading = false;
      notifyListeners();
    }
  }

  void refreshRecentTransactions() {
    recentTransactionsPagination.reset();
    _totalTransactionAmount = 0.0;
    getRecentTransactions();
  }

  Future<void> fetchDailySettlementTxnSummary() async {
    final prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';

    final reqbody = {
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

  void updateSelectedTab(HomeScreenTabItem tab) {
    _selectedTab = tab;
    notifyListeners();
  }
}
