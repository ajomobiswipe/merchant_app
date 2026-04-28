import 'dart:convert';

import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/data/models/transaction_history_request_model.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/data/models/transaction_models.dart';
import 'package:anet_merchant_app/data/services/dio_exception_handlers.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:anet_merchant_app/presentation/widgets/common_widgets/custom_app_button.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Period { today, week, month, custom }

class TransactionProvider extends ChangeNotifier {
  // Period selectedPeriod = Period.today;
  Period selectedPeriod = Period.month;
  String selectedScheme = "All";
  bool isLoading = false;
  bool get isLoadingData => isLoading;

  double get maxY {
    if (chartData.isEmpty) return 10; // default fallback height
    final values = chartData
        .expand((e) => [e.posSuccess, e.upiSuccess, e.emiMdrAmount ?? 0])
        .toList();

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    // add 20% headroom + ensure minimum visible height
    return (maxValue * 1.2).clamp(10, double.infinity);
  }

  void changeScheme(String scheme) {
    selectedScheme = scheme;
    notifyListeners();
  }

  List<HourlyTransaction> _chartData = [];

  List<HourlyTransaction> get chartData => _chartData;

  Future<void> showCustomDateDialog(BuildContext context) async {
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const CustomTextWidget(
                color: Colors.black87,
                text: "Select Report period",
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: CustomTextWidget(
                      color: Colors.black54,
                      text: startDate == null
                          ? "Start Date"
                          : startDate.toString().split(" ")[0],
                    ),
                    trailing: const Icon(
                      Icons.calendar_today,
                      color: AppColors.kPrimaryColor,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDate: startDate ?? DateTime.now(),
                      );

                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: CustomTextWidget(
                      color: Colors.black54,
                      text: endDate == null
                          ? "End Date"
                          : endDate.toString().split(" ")[0],
                    ),
                    trailing: const Icon(
                      Icons.calendar_today,
                      color: AppColors.kPrimaryColor,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: startDate ?? DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDate: endDate ?? DateTime.now(),
                      );

                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomAppButton(
                        backgroundColor: Colors.redAccent,
                        width: .25,
                        fontSize: 12,
                        title: "Cancel",
                        onPressed: () => Navigator.pop(context),
                      ),
                      CustomAppButton(
                        fontSize: 12,
                        width: 0.25,
                        title: "Apply",
                        onPressed: () {
                          if (startDate != null && endDate != null) {
                            final diff = endDate!.difference(startDate!).inDays;

                            if (diff > 90) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Range must be within 90 days"),
                                ),
                              );
                              return;
                            }
                            print(startDate);
                            print(endDate);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  final TransactionHistoryRequestModel _recentTranReqModel =
      TransactionHistoryRequestModel();

  final MerchantServices _merchantServices = MerchantServices();

  Future<void> setMonthRange({DateTime? startDate, DateTime? endDate}) async {
    _chartData = [];

    if (startDate == null || endDate == null) {
      DateTime now = DateTime.now();
      // 2 months back - first day
      startDate = fromMonth = DateTime(now.year, now.month - 2, 1);
      // DateTime middleDate = DateTime(now.year, now.month - 1);
      // current month - last day
      endDate = toMonth = DateTime(now.year, now.month + 1, 0);

      notifyListeners();
    }

    var monthlyPosValues = await getPosTxnMonthlyValues(
        DateFormat('dd-MM-yyyy').format(startDate),
        DateFormat('dd-MM-yyyy').format(endDate));

    var monthlyUpiValues = await getUpiTxnMonthlyValues(
        DateFormat('dd-MM-yyyy').format(startDate),
        DateFormat('dd-MM-yyyy').format(endDate));

    if (monthlyPosValues != null) {
      if (monthlyPosValues['monthlyValues'] != null) {
        monthlyPosValues['monthlyValues'].entries.forEach((entry) {
          _chartData.add(HourlyTransaction(
              label: entry.key,
              posSuccess: double.parse(entry.value.toStringAsFixed(2)),
              upiSuccess: 0));
        });
      }
      if (monthlyPosValues['monthlyEmiMdrAmount'] != null) {
        monthlyPosValues['monthlyEmiMdrAmount'].entries.forEach((entry) {
          bool isExisting = _chartData.any((e) => e.label == entry.key);
          if (isExisting) {
            _chartData[_chartData.indexWhere((e) => e.label == entry.key)]
                .emiMdrAmount = double.parse(entry.value.toStringAsFixed(2));
          }
        });
      }
    }

    if (monthlyUpiValues != null) {
      // monthlyUpiValues.entries.forEach((entry) {
      for (var entry in monthlyUpiValues.entries) {
        bool isExisting = _chartData.any((e) => e.label == entry.key);
        if (isExisting) {
          _chartData[_chartData.indexWhere((e) => e.label == entry.key)]
              .upiSuccess = double.parse(entry.value.toStringAsFixed(2));
        }
      }
    }

    notifyListeners();
  }

  /// Pos Txn monthlyrange
  Future<Map<String, dynamic>?> getPosTxnMonthlyValues(
      String recordFromData, String recordToData) async {
    final prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('acqMerchantId');
    _recentTranReqModel
      ..acquirerId = "OMAIND"
      ..merchantId = merchantId
      ..recordFrom = recordFromData
      ..recordTo = recordToData
      ..rrn = null
      ..terminalId = null
      ..sendTxnReportToMail = false;

    try {
      // var dummydata = {
      //   "responsePage": {
      //     "content": [],
      //     "pageable": {
      //       "sort": {"unsorted": false, "sorted": true, "empty": false},
      //       "offset": 0,
      //       "pageSize": 1,
      //       "pageNumber": 0,
      //       "paged": true,
      //       "unpaged": false
      //     },
      //     "last": false,
      //     "totalElements": 1816,
      //     "totalPages": 1816,
      //     "size": 1,
      //     "number": 0,
      //     "sort": {"unsorted": false, "sorted": true, "empty": false},
      //     "first": true,
      //     "numberOfElements": 1,
      //     "empty": false
      //   },
      //   "totalAmount": 8368267.33,
      //   "count": 650,
      //   "monthlyValues": {
      //     "February": 564567.000000,
      //     "March": 658267.330000,
      //     "April": 465571.000000
      //   },
      //   "sumEmiMdrValues": {
      //     "February": 548874.00,
      //     "March": 488746.00,
      //     "April": 887458.00
      //   },
      //   "sendMailResponse": {
      //     "responseCode": null,
      //     "responseMessage": null,
      //     "userName": null,
      //     "mailId": null,
      //     "twoFAOTPTimer": 0
      //   }
      // };

      // Response response = Response(
      //     requestOptions: RequestOptions(path: ''),
      //     data: dummydata,
      //     statusCode: 200);
      isLoading = true;
      notifyListeners();
      final response = await _merchantServices.fetchTransactionHistory(
        _recentTranReqModel.toJson(),
        pageNumber: 0,
        pageSize: 1,
      );

      if (response.statusCode == 200) {
        final decodedData = TransactionHistory.fromJson(response.data);
        return {
          "monthlyValues": decodedData.monthlyValues,
          "monthlyEmiMdrAmount": decodedData.sumEmiMdrValues
        };
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching transactions: $e");

      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// UPI Txn monthlyrange
  Future<Map<String, dynamic>?> getUpiTxnMonthlyValues(
      String recordFrom, String recordTo) async {
    final prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('merchantId');

    try {
      // Map<String, dynamic> decodedData = {
      //   "successMessage": "Success",
      //   "statusCode": 200,
      //   "pageData": {
      //     "content": [],
      //     "pageable": {
      //       "sort": {"unsorted": false, "sorted": true, "empty": false},
      //       "offset": 0,
      //       "pageSize": 1,
      //       "pageNumber": 0,
      //       "paged": true,
      //       "unpaged": false
      //     },
      //     "last": false,
      //     "totalElements": 2,
      //     "totalPages": 2,
      //     "size": 1,
      //     "number": 0,
      //     "sort": {"unsorted": false, "sorted": true, "empty": false},
      //     "first": true,
      //     "numberOfElements": 1,
      //     "empty": false
      //   },
      //   "monthlyupiTxnAmount": {
      //     "February": 564567.000000,
      //     "March": 658267.330000,
      //     "April": 465571.000000
      //   },
      //   "totalAmount": 2.22
      // };
      //   Response response = Response(
      // requestOptions: RequestOptions(path: ''),
      // data: decodedData,
      // statusCode: 200);
      final response = await _merchantServices.fetchVpaTransactionHistory({
        "from": recordFrom,
        "to": recordTo,
        // "creditVpa": selectedVpa,
          // "gatewayResponseCode":"00"
      },
          pageNumber: 0,
          pageSize: 1,
          forMonthyValues: true,
          merchantId: merchantId);
      var decodedData = response.data;

      if (response.statusCode == 200 && decodedData["statusCode"] == 200) {
        return Map<String, dynamic>.from(
            decodedData['monthlyupiTxnAmount'] ?? {});
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching transactions: $e");
      return null;
    } finally {}

    return null;
  }

  DateTime? fromMonth;
  DateTime? toMonth;

  String formatMonth(DateTime? date) {
    if (date == null) return "Select Month";
    return DateFormat('MMMM yyyy').format(date);
  }

  Future<void> pickMonth(bool isFrom, context) async {
    final picked = await showMonthYearPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5, DateTime.now().month),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      if (isFrom) {
        fromMonth = DateTime(picked.year, picked.month, 1);
        final tempTo = DateTime(picked.year, picked.month + 3, 0);
        toMonth = tempTo;
      } else {
        toMonth = DateTime(picked.year, picked.month + 1, 0);
        final tempFrom = DateTime(picked.year, picked.month - 2, 1);
        fromMonth = tempFrom;
      }
    }

    setMonthRange(startDate: fromMonth, endDate: toMonth);
    notifyListeners();
  }
}
