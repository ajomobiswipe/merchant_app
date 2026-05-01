import 'dart:async';

import 'package:anet_merchant_app/core/utils/pageing_element.dart';
import 'package:anet_merchant_app/data/models/all_transaction_list.dart';
import 'package:anet_merchant_app/data/models/transaction_history_request_model.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/data/services/dio_exception_handlers.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Enums
enum HomeScreenTabItem {
  TransactionHistory,
  VpaTransactions,
  Settlements,
}

class HomeScreenProvider with ChangeNotifier {
  final MerchantServices _merchantServices = MerchantServices();

  // Controllers
  final ScrollController _recentTransScrollCtrl = ScrollController();
  ScrollController get recentTransScrollCtrl => _recentTransScrollCtrl;
  final ScrollController _recentVPATransScrollCtrl = ScrollController();
  ScrollController get recentVPATransScrollCtrl => _recentVPATransScrollCtrl;

  // Models
  final TransactionHistoryRequestModel _recentTranReqModel =
      TransactionHistoryRequestModel();

  // Enums
  HomeScreenTabItem _selectedTab = HomeScreenTabItem.TransactionHistory;
  HomeScreenTabItem get selectedTab => _selectedTab;

  // Pagination handlers
  final PaginationHandler<TransactionElement> recentTransactionsPagination =
      PaginationHandler<TransactionElement>(pageSize: 10);
  final PaginationHandler<dynamic> recentVpaTransactionsPagination =
      PaginationHandler<dynamic>(pageSize: 10);
  final PaginationHandler<dynamic> allVpalistPagination =
      PaginationHandler<dynamic>(pageSize: 10);
  String? _selectedVpa;
  String? get selectedVpa => _selectedVpa;

  // Settlement summary
  double _totalSettlementAmount = 0;
  double _deductions = 0;
  double _pendingSettlement = 0;
  int _totalTransactions = 0;

  double get totalSettlementAmount => _totalSettlementAmount;
  double get deductionsAmount => _deductions;
  double get pendingSettlementAmount => _pendingSettlement;
  int get totalTransactions => _totalTransactions;
  int get totalVPATransactions => _totalTransactions;

  double get totalTransactionAmount => _totalTransactionAmount;
  double _totalTransactionAmount = 0.0;
  double get totalVPATransactionAmount => _totalVPATransactionAmount;
  double _totalVPATransactionAmount = 0.0;

  String _selectedAcquirerMerchantId = "0";
  String get selectedAcquirerMerchantId => _selectedAcquirerMerchantId;

  List<AllTerminalsTxn> _allTerminalsTxn = [];
  List<AllTerminalsTxn> get allTerminalsTxn => _allTerminalsTxn;
   

  // Store name
  void changeSelectedVpa(String? vpa) {
    if (vpa == _selectedVpa) return;
    _selectedVpa = vpa;
    notifyListeners();
    recentVpaTransactionsPagination.reset();
    getRecentVPATransactions();
  }

  void setSelectedAcquirerMerchantId(String merchantId) {
    _selectedAcquirerMerchantId = merchantId;
    notifyListeners();
  }

  Future<void> refreshVpaTransactions() async {
    if (recentVpaTransactionsPagination.isLoading) return;
    _totalVPATransactionAmount = 0.0;
    recentVpaTransactionsPagination.reset();
    recentVpaTransactionsPagination.items = [];
    getRecentVPATransactions();
  }

  Future<void> getRecentVPATransactions() async {
    if (!recentVpaTransactionsPagination.hasMore &&
        !recentVpaTransactionsPagination.isFirstLoad) return;

    // final prefs = await SharedPreferences.getInstance();
    // String? merchantId = prefs.getString('acqMerchantId');

    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());

    if (recentVpaTransactionsPagination.isLoading) return;
    if (_selectedVpa == null || _selectedVpa!.isEmpty) return;

    recentVpaTransactionsPagination.isLoading = true;
    notifyListeners();

    try {
      final response = await _merchantServices.fetchVpaTransactionHistory(
        {
          "from": today,
          "to": today,
          "creditVpa": selectedVpa,
          "gatewayResponseCode": "00"
        },
        pageNumber: recentVpaTransactionsPagination.currentPage,
        pageSize: recentVpaTransactionsPagination.pageSize,
      );
      var decodedData = response.data;
      if (response.statusCode == 200 && decodedData["statusCode"] == 200) {
        final newItems = decodedData["pageData"]["content"] ?? [];

        if (newItems.isNotEmpty) {
          recentVpaTransactionsPagination.addItems(
            newItems,
            decodedData["pageData"]["totalElements"] ?? 0,
          );
          _totalVPATransactionAmount = decodedData["totalAmount"] ?? 0.0;
        }
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching transactions: $e");
    } finally {
      recentVpaTransactionsPagination.isLoading = false;
      notifyListeners();
    }
  }

  clearallVpalistPagination() {
    allVpalistPagination.reset();
    _totalVPATransactionAmount = 0.0;
    recentVpaTransactionsPagination.reset();
  }

  Future<void> getVpaByMerchantId() async {
    if (!allVpalistPagination.hasMore && !allVpalistPagination.isFirstLoad)
      return;

    if (allVpalistPagination.isFirstLoad) {
      allVpalistPagination.currentPage = 0;
      allVpalistPagination.items.clear();
    }

    final prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId') ?? '';

    if (allVpalistPagination.isLoading) return;

    allVpalistPagination.isLoading = true;
    notifyListeners();

    try {
      final response = await _merchantServices.getVpaByMerchantId(
        {"merchantId": merchantId},
        pageNumber: allVpalistPagination.currentPage,
        pageSize: allVpalistPagination.pageSize,
        merchantId: merchantId,
      );

      if (response.statusCode == 200) {
        var decodedData = response.data;
        var newItems = decodedData["pageData"]["content"] ?? [];
        // var newItems = [];
        // var newItems = [
        //   "Hardwarisweets.anet@axisbank",
        //   "vikastraders3.anet@axisbank",
        //   "shapeshifters.anet@axisbank",
        // ];

        if (newItems.isNotEmpty) {
          allVpalistPagination.addItems(
            newItems,
            decodedData["pageData"]["totalElements"] ?? 0,
          );
          _selectedVpa = newItems[0];
          getRecentVPATransactions();
        }
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching VPA list: $e");
    } finally {
      allVpalistPagination.isLoading = false;
      notifyListeners();
    }
  }

  void setAllTerminalTxnEmpty() {
    _allTerminalsTxn = [];
    notifyListeners();
  }

  Future getAllTxnsTotalAndCount() async {
    _allTerminalsTxn = [];
    final prefs = await SharedPreferences.getInstance();
    String? axisMerchantId = prefs.getString('merchantId') ?? '';
    _totalTransactions = 0;
    _totalTransactionAmount = 0;

    try {
      final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      _recentTranReqModel
        ..acquirerId = "OMAIND"
        ..merchantId = ""
        ..mid = axisMerchantId
        ..recordFrom = today
        ..recordTo = today
        ..rrn = null
        ..terminalId = null
        ..sendTxnReportToMail = false;

      recentTransactionsPagination.isLoading = true;
      notifyListeners();

      final response = await _merchantServices
          .fetchTransactionHistoryGetPosTxnHistoryReportbyMid(
        _recentTranReqModel.toJson(),
        pageNumber: 0,
        pageSize: 1,
      );

      if (response.statusCode == 200) {
        var decodedData = response.data;

        if (decodedData is List) {
          for (var item in decodedData) {
            _totalTransactions += (item["count"] as num).toInt();
            _totalTransactionAmount += item["totalAmount"] ?? 0.0;
          }

          _allTerminalsTxn = decodedData
              .map<AllTerminalsTxn>((item) => AllTerminalsTxn.fromJson(item))
              .toList();
        }

        recentTransactionsPagination.addItems(
          [],
          _totalTransactions,
        );
      }

      notifyListeners();
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching transaction summary: $e");
    } finally {
      recentTransactionsPagination.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getRecentTransactions() async {
    if (!recentTransactionsPagination.hasMore &&
        !recentTransactionsPagination.isFirstLoad) return;

    final prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId');
    bool isTerminalUser = prefs.getString('role') == "TERMINAL USER";

    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    _recentTranReqModel
      ..acquirerId = "OMAIND"
      ..merchantId = merchantId
      ..recordFrom = today
      ..recordTo = today
      ..rrn = null
      ..terminalId = isTerminalUser ? prefs.getString('terminalId') : null
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

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
