import 'dart:convert';

import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupportActionProvider with ChangeNotifier {
  String? _selectedSupportAction;

  String? selectedQuickAction;

  bool isSupportActionsIsTaped = false;
  bool get isSupportActionsTaped => isSupportActionsIsTaped;
  set isSupportActionsTaped(bool value) {
    isSupportActionsIsTaped = value;
    notifyListeners();
  }

  String? get selectedSupportAction => _selectedSupportAction;
  set selectedSupportAction(dynamic value) {
    _selectedSupportAction = value;
    notifyListeners();
  }

  List<dynamic> _supportActionList = [];
  List<dynamic> get supportActionList => _supportActionList;
  MerchantServices _merchantServices = MerchantServices();

  Future<void> getSupportActionData() async {
    var response = await _merchantServices.getSupportActionData();
    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      _supportActionList = decodedData['data'] ?? [];

      notifyListeners();
    }
  }

  // Fetch recent transactions
  Future<void> raiseSupportRequest() async {
    isSupportActionsIsTaped = true;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId') ?? '651010000022371';

    if (_selectedSupportAction == null || _selectedSupportAction!.isEmpty) {
      AlertService().errorToast("Please select a support action");
      return;
    }
    var reqBody = {
      "merchantId": merchantId,
      "quickActionMessage": _selectedSupportAction,
    };

    try {
      final response = await _merchantServices.raiseSupportRequest(
        reqBody,
      );

      if (response.statusCode == 200) {
        AlertService().success("Support request raised successfully");
      } else {
        AlertService().errorToast("Failed to raise support request");
      }
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      _selectedSupportAction = null;
      selectedQuickAction = null;
      isSupportActionsIsTaped = false;
      notifyListeners();
    }
  }
}
