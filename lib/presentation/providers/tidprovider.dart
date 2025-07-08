// import 'package:anet_merchant_app/data/services/merchant_service.dart';
// import 'package:anet_merchant_app/presentation/widgets/widget.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class TidProvider extends ChangeNotifier {
//   // Services
//   final MerchantServices _merchantServices = MerchantServices();

//   // Controllers
//   final ScrollController _allTidScrollCtrl = ScrollController();
//   TextEditingController _tidSearchController = TextEditingController();

//   ScrollController get allTidScrollCtrl => _allTidScrollCtrl;
//   TextEditingController get tidSearchController => _tidSearchController;
//   set tidSearchController(TextEditingController controller) {
//     _tidSearchController = controller;
//     notifyListeners();
//   }

//   // Flags
//   bool _isAllTidLoading = false;
//   bool isAllTidApiLoadingFistTime = true;

//   bool get isAllTidLoading => _isAllTidLoading;

//   // Pagination
//   int currentTidListPageNo = 0;
//   int tidPageSize = 40;

//   int _allTidCount = 0; // Simulate total from API
//   List<dynamic> _allTerminalId = [];

//   List<dynamic> get allTid => _allTerminalId;
//   bool get hasMoreTid => _allTerminalId.length < _allTidCount;

//   // Methods

//   /// Fetch recent TIDs by Merchant ID
//   Future<void> getTidByMerchantId() async {
//     print("Current Page: $currentTidListPageNo");
//     print("Page Size: $tidPageSize");
//     print("Total tid: $_allTidCount");
//     print("Tid list Length: ${_allTerminalId.length}");

//     final SharedPreferences prefs = await SharedPreferences.getInstance();

//     if (_allTerminalId.length >= _allTidCount && !isAllTidApiLoadingFistTime) {
//       return;
//     }

//     String? merchantId = prefs.getString('acqMerchantId') ?? '65OMA0000000002';
//     print(merchantId);

//     if (_isAllTidLoading) return;

//     _isAllTidLoading = true;
//     notifyListeners();

//     try {
//       final response = await _merchantServices.getTidByMerchantId(
//         {},
//         pageNumber: tidPageSize,
//         pageSize: 40,
//         merchantId: merchantId,
//       );

//       if (response.statusCode == 200) {
//         var decodedData = response.data;
//         var newItems = response.data["content"] ?? [];
//         _allTidCount = decodedData["totalElements"] ?? 0;
//         print('_allTidCount is $_allTidCount');

//         if (newItems.isNotEmpty) {
//           tidPageSize++;
//           isAllTidApiLoadingFistTime = false;
//           _allTerminalId.addAll(newItems);
//         }
//       }
//     } on DioException catch (dioError) {
//       _handleDioError(dioError);
//     } catch (e) {
//       print("Error fetching Tid: $e");
//     } finally {
//       _isAllTidLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Refresh all TIDs
//   void refreshAllTid() {
//     _allTerminalId = [];
//     tidPageSize = 0;
//     isAllTidApiLoadingFistTime = true;
//     _allTidCount = 0;
//     notifyListeners();
//     getTidByMerchantId();
//   }

//   /// Handle Dio errors
//   void _handleDioError(DioException dioError) {
//     if (dioError.type == DioExceptionType.connectionTimeout) {
//       AlertService().error(
//           "Connection timeout while fetching Tid. Please try again later.");
//       print("Connection timeout while fetching Tid.");
//     } else if (dioError.type == DioExceptionType.receiveTimeout) {
//       AlertService()
//           .error("Receive timeout while fetching Tid. Please try again later.");
//       print("Receive timeout while fetching Tid.");
//     } else if (dioError.type == DioExceptionType.sendTimeout) {
//       AlertService()
//           .error("Send timeout while fetching Tid. Please try again later.");
//       print("Send timeout while fetching Tid.");
//     } else if (dioError.type == DioExceptionType.badResponse) {
//       AlertService().error(
//           "Bad response while fetching Tid: ${dioError.response?.statusCode}");
//       print(
//           "Bad response while fetching Tid: ${dioError.response?.statusCode}");
//     } else {
//       AlertService().error(
//           "An error occurred while fetching Tid. Please try again later.");
//       print("DioError fetching Tid: ${dioError.message}");
//       if (dioError.response != null) {
//         print("DioError response data: ${dioError.response?.data}");
//         print("DioError response status: ${dioError.response?.statusCode}");
//       }
//     }
//   }
// }
