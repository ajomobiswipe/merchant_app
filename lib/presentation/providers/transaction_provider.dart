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

  // void changePeriod(Period period) {
  //   selectedPeriod = period;
  //   notifyListeners();
  // }

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

  // List<HourlyTransaction> weekData = [
  //   HourlyTransaction(label: "Mon", success: 120, failed: 30),
  //   HourlyTransaction(label: "Tue", success: 150, failed: 20),
  //   HourlyTransaction(label: "Wed", success: 180, failed: 25),
  //   HourlyTransaction(label: "Thu", success: 200, failed: 35),
  //   HourlyTransaction(label: "Fri", success: 170, failed: 40),
  //   HourlyTransaction(label: "Sat", success: 190, failed: 30),
  //   HourlyTransaction(label: "Sun", success: 210, failed: 50),
  // ];

  // List<HourlyTransaction> _monthData = [
  //   HourlyTransaction(label: "NOV", success: 50, failed: 10),
  //   HourlyTransaction(label: "DEC", success: 70, failed: 15),
  //   HourlyTransaction(label: "JAN", success: 90, failed: 20),
  //   HourlyTransaction(label: "FEB", success: 120, failed: 30),
  // ];

  // List<HourlyTransaction> customData = [
  //   HourlyTransaction(label: "Custom 1", success: 50, failed: 10),
  //   HourlyTransaction(label: "Custom 2", success: 70, failed: 15),
  //   HourlyTransaction(label: "Custom 3", success: 90, failed: 20),
  //   HourlyTransaction(label: "Custom 4", success: 120, failed: 30),
  // ];

  List<HourlyTransaction> _chartData = [];

  List<HourlyTransaction> get chartData => _chartData;

  // void changePeriod(Period period, BuildContext context) {
  //   selectedPeriod = period;
  //   switch (period) {
  //     case Period.today:
  //       _chartData = [
  //         HourlyTransaction(label: "5AM", success: 3, failed: 1),
  //         HourlyTransaction(label: "8AM", success: 8, failed: 2),
  //         HourlyTransaction(label: "11AM", success: 16, failed: 4),
  //         HourlyTransaction(label: "1PM", success: 24, failed: 6),
  //         HourlyTransaction(label: "3PM", success: 35, failed: 8),
  //         HourlyTransaction(label: "6PM", success: 28, failed: 5),
  //         HourlyTransaction(label: "9PM", success: 18, failed: 4),
  //       ];
  //       break;
  //     case Period.week:
  //       _chartData = weekData;
  //       break;
  //     case Period.month:
  //       _chartData = _monthData;
  //       break;
  //     case Period.custom:
  //       showCustomDateDialog(context);
  //       break;
  //   }
  //   notifyListeners();
  // }

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

    if (monthlyPosValues == null || monthlyPosValues['monthlyValues'] == null)
      return;
    if (monthlyUpiValues == null) return;

    monthlyPosValues['monthlyValues'].entries.forEach((entry) {
      _chartData.add(HourlyTransaction(
          label: entry.key,
          posSuccess: double.parse(entry.value.toStringAsFixed(2)),
          upiSuccess: 0));
    });

    if (monthlyPosValues['monthlyEmiMdrAmount'] != null) {
      monthlyPosValues['monthlyEmiMdrAmount'].entries.forEach((entry) {
        bool isExisting = _chartData.any((e) => e.label == entry.key);
        if (isExisting) {
          _chartData[_chartData.indexWhere((e) => e.label == entry.key)]
              .emiMdrAmount = double.parse(entry.value.toStringAsFixed(2));
        }
      });
    }

    monthlyUpiValues.entries.forEach((entry) {
      bool isExisting = _chartData.any((e) => e.label == entry.key);
      if (isExisting) {
        _chartData[_chartData.indexWhere((e) => e.label == entry.key)]
            .upiSuccess = double.parse(entry.value.toStringAsFixed(2));
      }
    });

    print(' Chart Data: $_chartData');
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
      var dummydata = {
        "responsePage": {
          "content": [
            {
              "merchantId": "65OMA0000000002",
              "acquirerId": "OMAIND",
              "terminalId": "OM000002",
              "transactionDate": "05/09/2026",
              "transactionTime": "19:23:37",
              "stan": "000185",
              "rrn": "424919510280",
              "amount": "385.00",
              "authCode": "192343",
              "responseCode": "000",
              "responseDesc": null,
              "transactionType": "OSAL001",
              "mcc": null,
              "cardNo": "608326******0066",
              "merReceiptLink": null,
              "custReceiptLink": null,
              "acquirerName": null,
              "mti": "1210",
              "currency": "356",
              "terminalGuid": 0,
              "txnGuid": 0,
              "insertDateTime": "25/03/2026 13:45:00",
              "batchNo": "001",
              "traceNumber": "000185",
              "terminalLocation": "TEST MERCHANT         SHARJAH      SHJAE",
              "de_7": "0905152329",
              "acquiringBIN": "OMAIND",
              "schemeName": null,
              "processCode": "000000",
              "p2pRequestId": null,
              "posEntryMode": "071",
              "deviceType": null,
              "txnSource": null,
              "nameOnCard": null,
              "batchClosedOn": null,
              "settledOn": null,
              "processAck": false,
              "txnResponse": null,
              "txnAckResponse": null,
              "terminalAddress": "TEST MERCHANT         SHARJAH      SHJAE",
              "batchClosed": false,
              "reverse": false,
              "settled": false,
              "voided": false
            }
          ],
          "pageable": {
            "sort": {"unsorted": false, "sorted": true, "empty": false},
            "offset": 0,
            "pageNumber": 0,
            "pageSize": 1,
            "paged": true,
            "unpaged": false
          },
          "last": false,
          "totalElements": 1816,
          "totalPages": 1816,
          "size": 1,
          "number": 0,
          "sort": {"unsorted": false, "sorted": true, "empty": false},
          "first": true,
          "numberOfElements": 1,
          "empty": false
        },
        "totalAmount": 8368267.33,
        "count": 650,
        "monthlyValues": {
          "February": 0.000000,
          "March": 8368267.330000,
          "April": 0.000000
        },
        "sumEmiMdrValues": {},
        "sendMailResponse": {
          "responseCode": null,
          "responseMessage": null,
          "userName": null,
          "mailId": null,
          "twoFAOTPTimer": 0
        }
      };
      //  final res = jsonEncode(dummydata);
      Response response = Response(
          requestOptions: RequestOptions(path: ''),
          data: dummydata,
          statusCode: 200);
      // final response = await _merchantServices.fetchTransactionHistory(
      //   _recentTranReqModel.toJson(),
      //   pageNumber: 0,
      //   pageSize: 1,
      // );

      if (response.statusCode == 200) {
        final decodedData = TransactionHistory.fromJson(response.data);
        return {
          "monthlyValues": decodedData.monthlyValues,
          "monthlyEmiMdrAmount": decodedData.monthlyEmiMdrAmount
        };
      }
    } on DioException catch (e) {
      handleDioError(e);
    } catch (e) {
      AlertService().error("Error fetching transactions: $e");

      return null;
    } finally {}
    return null;
  }

  /// UPI Txn monthlyrange
  Future<Map<String, dynamic>?> getUpiTxnMonthlyValues(
      String recordFrom, String recordTo) async {
    final prefs = await SharedPreferences.getInstance();
    String? merchantId = prefs.getString('merchantId');

    try {
      Map<String, dynamic> decodedData = {
        "successMessage": "Success",
        "statusCode": 200,
        "pageData": {
          "content": [
            {
              "refId": "OMAAXIS10030",
              "transactionInfoType": "UPI",
              "accountDetailsType": "SAVINGS",
              "payerDetailsType": "PAYER",
              "accountDetailsAccType": "SAVINGS",
              "payerDetailsAccType": "SAVINGS",
              "name": "Amit Sharma",
              "payerVPA": null,
              "mobileNumber": "9867093454",
              "acNum": "2201201144299621",
              "addr": "1234, Main Street, City",
              "code": "220",
              "orgAmount": "1000",
              "regName": "Amit Sharma",
              "seqNum": "001",
              "setAmount": "0",
              "transactionInfoNote": null,
              "txnConfirmationNote": null,
              "orgStatus": "SUCCESS",
              "custRef": "CUST12345",
              "orgId": "AXIS-BANK",
              "initiationMode": "UPI",
              "orgTxnId": "AXIS1234567890",
              "purpose": "UPI Transaction",
              "refUrl": "https://www.axisbank.com",
              "ts": "2023-09-06T11:42:52+05:30",
              "msgId": "MSG123456",
              "version": "1.0",
              "addedOn": "2025-10-15T18:57:31.687",
              "updatedOn": "2025-10-15T18:57:31.687",
              "addedBy": "AXIS-BANK",
              "updatedBy": "AXIS-BANK",
              "status": "SUCCESS",
              "deviceId": "9222105983",
              "requestData": null,
              "customerVpa": null,
              "merchantId": "merchant123",
              "merchantChannelId": "collect123",
              "merchantTransactionId": "734613572371",
              "transactionTimestamp": 20260316114100,
              "transactionAmount": "1.11",
              "gatewayTransactionId": "AXI0367c9065cb94106868287161a7d8201",
              "gatewayResponseCode": "00",
              "gatewayResponseMessage": "SUCCESS",
              "rrn": "OMAAXIS10030",
              "creditVpa": "zxpay@anet",
              "checksum": "",
              "channelType": "POS",
              "dqrRequestId": "OMAAXIS10030",
              "qrCodeTransactionId": "vpa0000102",
              "reconciledTime": null,
              "ifsc": "IUBL0002012",
              "hts": "2023-09-06T11:42:52+05:30",
              "horgId": "AXIS-BANK"
            }
          ],
          "pageable": {
            "sort": {"unsorted": false, "sorted": true, "empty": false},
            "offset": 0,
            "pageSize": 1,
            "pageNumber": 0,
            "paged": true,
            "unpaged": false
          },
          "last": false,
          "totalElements": 2,
          "totalPages": 2,
          "size": 1,
          "number": 0,
          "sort": {"unsorted": false, "sorted": true, "empty": false},
          "first": true,
          "numberOfElements": 1,
          "empty": false
        },
        "monthlyupiTxnAmount": {
          "January": 0.00,
          "February": 0.00,
          "March": 2.22
        },
        "totalAmount": 2.22
      };
      // final response = await _merchantServices.fetchVpaTransactionHistory({
      //   "from": recordFrom,
      //   "to": recordTo,
      //   // "creditVpa": selectedVpa,
      // },
      //     pageNumber: 0,
      //     pageSize: 1,
      //     forMonthyValues: true,
      //     merchantId: merchantId);
      // var decodedData = response.data;
      Response response = Response(
          requestOptions: RequestOptions(path: ''),
          data: decodedData,
          statusCode: 200);
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
