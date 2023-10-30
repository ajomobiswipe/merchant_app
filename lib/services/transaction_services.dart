/* ===============================================================
| Project : SIFR
| Page    : TRANSACTION_SERVICE.DART
| Date    : 23-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:sifr_latest/config/constants.dart';
import 'package:sifr_latest/models/TransactionRequest.dart';
import '../config/endpoints.dart';
import '../models/notification_model.dart';
import 'connection.dart';

class TransactionServices {
  /*
  * SERVICE NAME: generateQRCode
  * DESC: Generate QR Code API
  * METHOD: POST
  * Params: QrCodeGenerationRequest
  * to pass token in Headers
  */
  generateQRCode(requestModel) async {
    Connection connection = Connection();
    // var url = EndPoints.baseApi9502 + EndPoints.generateQrCode;
    var url = "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/registerQRCode/12345/AA1234567890/UB776WH";
    var response = await connection.post(url, requestModel);

    // print('response$response');
    return response;
  }

  checkQrStatus(String? qrCodeId)async{
    Connection connection = Connection();
    // var url = EndPoints.baseApi9502 + EndPoints.generateQrCode;
    var url = "http://10.0.38.60:8080/NanoSmartBanking/v1/qrPayment/registerQRCode/12345/AA1234567890/UB776WH";
    var response = await connection.get(url);

    // print('response$response');
    return response;
  }

  /*
  * SERVICE NAME: loadAllTransaction
  * DESC: Fetch All Transaction Details Based on Size
  * METHOD: POST
  * Params: TransactionRequest and size1
  * to pass token in Headers
  */
  loadAllTransaction(TransactionRequest requestModel, size1) async {
    Connection connection = Connection();
    var size = '?size=$size1';
    var url = EndPoints.baseApi9503 + EndPoints.transactionListing + size;
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: getAllTransaction
  * DESC: Fetch All Transaction Details Based on Page
  * METHOD: POST
  * Params: TransactionRequest and page
  * to pass token in Headers
  */
  getAllTransaction(requestModel, page) async {
    Connection connection = Connection();
    var url =
        '${EndPoints.baseApi9503}${EndPoints.transactionListing}?size=15&page=$page';
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: getStatements
  * DESC: Fetch All Transaction Details Based on Page And Size
  * METHOD: POST
  * Params: TransactionRequest , page and size
  * to pass token in Headers
  */
  getStatements(requestModel, page, size) async {
    Connection connection = Connection();
    var url =
        '${EndPoints.baseApi9503}${EndPoints.transactionListing}?size=$size&page=$page';
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: loadAllNotification
  * DESC: Fetch All Notification Details Based Customer Id
  * METHOD: POST
  * Params: Customer Id and size
  * to pass token in Headers
  */
  loadAllNotification(size1, String custId) async {
    Connection connection = Connection();
    var size = '?size=$size1';
    var url =
        '${EndPoints.baseApi9503}${EndPoints.notificationListing}${Constants.instId}/$custId$size';
    var response = await connection.get(url);
    return response;
  }

  /*
  * SERVICE NAME: notificationRead
  * DESC: Notification Read Status Update
  * METHOD: POST
  * Params: NotificationRequest
  * to pass token in Headers
  */
  notificationRead(NotificationRequest notificationRequest) async {
    Connection connection = Connection();
    var url = EndPoints.baseApi9503 + EndPoints.notificationStatus;
    var response = await connection.post(url, notificationRequest);
    return response;
  }

  /*
  * SERVICE NAME: cashOut
  * DESC: Notification Read Status Update
  * METHOD: POST
  * Params: List
  * to pass token in Headers
  */
  cashOut(requestModel) async {

    // print(requestModel);

    Connection connection = Connection();
    var url = EndPoints.baseApi9503 + EndPoints.cashOut;
    var response = await connection.post(url, requestModel);
    return response;
  }

  /*
  * SERVICE NAME: getTraceNumber
  * DESC: Fetch Trace Number for Transaction
  * METHOD: GET
  * Params: NA
  */
  getTraceNumber() async {
    Connection connection = Connection();
    var url = '${EndPoints.serviceUrl}/getTraceNo';
    var response = await connection.getWithOutToken(url);
    return response;
  }
}
