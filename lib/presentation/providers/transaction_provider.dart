import 'package:anet_merchant_app/data/models/transaction_models.dart';
import 'package:flutter/material.dart';

enum Period { today, week, month, custom }

class TransactionProvider extends ChangeNotifier {
  Period selectedPeriod = Period.today;
  String selectedScheme = "All";

  // void changePeriod(Period period) {
  //   selectedPeriod = period;
  //   notifyListeners();
  // }

  double get maxY {
    if (chartData.isEmpty) return 10; // default fallback height

    final values = chartData.expand((e) => [e.success, e.failed]).toList();

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    // add 20% headroom + ensure minimum visible height
    return (maxValue * 1.2).clamp(10, double.infinity);
  }

  void changeScheme(String scheme) {
    selectedScheme = scheme;
    notifyListeners();
  }

  // List<HourlyTransaction> get chartData => [
  //       HourlyTransaction(label: "5AM", success: 3, failed: 1),
  //       HourlyTransaction(label: "8AM", success: 8, failed: 2),
  //       HourlyTransaction(label: "11AM", success: 16, failed: 4),
  //       HourlyTransaction(label: "1PM", success: 24, failed: 6),
  //       HourlyTransaction(label: "3PM", success: 35, failed: 8),
  //       HourlyTransaction(label: "6PM", success: 28, failed: 5),
  //       HourlyTransaction(label: "9PM", success: 18, failed: 4),
  //     ];

  List<SchemeReport> allSchemes = [
    SchemeReport(
      name: "Visa",
      totalTxns: 405,
      success: 385,
      failed: 20,
      successAmount: 138480,
      failedAmount: 9520,
    ),
    SchemeReport(
      name: "Mastercard",
      totalTxns: 197,
      success: 191,
      failed: 6,
      successAmount: 62300,
      failedAmount: 3000,
    ),
    SchemeReport(
      name: "UPI",
      totalTxns: 226,
      success: 214,
      failed: 12,
      successAmount: 47540,
      failedAmount: 2320,
    ),
  ];

  List<SchemeReport> get filteredSchemes {
    if (selectedScheme == "All") return allSchemes;
    return allSchemes.where((e) => e.name == selectedScheme).toList();
  }

  int get totalSuccess => filteredSchemes.fold(0, (s, e) => s + e.success);

  int get totalFailed => filteredSchemes.fold(0, (s, e) => s + e.failed);

  double get totalAmount =>
      filteredSchemes.fold(0, (s, e) => s + e.successAmount);

  List<HourlyTransaction> weekData = [
    HourlyTransaction(label: "Mon", success: 120, failed: 30),
    HourlyTransaction(label: "Tue", success: 150, failed: 20),
    HourlyTransaction(label: "Wed", success: 180, failed: 25),
    HourlyTransaction(label: "Thu", success: 200, failed: 35),
    HourlyTransaction(label: "Fri", success: 170, failed: 40),
    HourlyTransaction(label: "Sat", success: 190, failed: 30),
    HourlyTransaction(label: "Sun", success: 210, failed: 50),
  ];

  List<HourlyTransaction> monthData = [
    HourlyTransaction(label: "NOV", success: 50, failed: 10),
    HourlyTransaction(label: "DEC", success: 70, failed: 15),
    HourlyTransaction(label: "JAN", success: 90, failed: 20),
    HourlyTransaction(label: "FEB", success: 120, failed: 30),
  ];

  List<HourlyTransaction> customData = [
    HourlyTransaction(label: "Custom 1", success: 50, failed: 10),
    HourlyTransaction(label: "Custom 2", success: 70, failed: 15),
    HourlyTransaction(label: "Custom 3", success: 90, failed: 20),
    HourlyTransaction(label: "Custom 4", success: 120, failed: 30),
  ];

  List<HourlyTransaction> _chartData = [];

  List<HourlyTransaction> get chartData => _chartData;

  void changePeriod(Period period) {
    selectedPeriod = period;
    switch (period) {
      case Period.today:
        _chartData = [
          HourlyTransaction(label: "5AM", success: 3, failed: 1),
          HourlyTransaction(label: "8AM", success: 8, failed: 2),
          HourlyTransaction(label: "11AM", success: 16, failed: 4),
          HourlyTransaction(label: "1PM", success: 24, failed: 6),
          HourlyTransaction(label: "3PM", success: 35, failed: 8),
          HourlyTransaction(label: "6PM", success: 28, failed: 5),
          HourlyTransaction(label: "9PM", success: 18, failed: 4),
        ];
        break;
      case Period.week:
        _chartData = weekData;
        break;
      case Period.month:
        _chartData = monthData;
        break;
      case Period.custom:
        _chartData = customData;
        break;
    }
    notifyListeners();
  }
}
