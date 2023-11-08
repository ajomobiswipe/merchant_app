import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:custom_timer/custom_timer.dart';
import 'package:flutter/material.dart';
import 'package:sifr_latest/storage/secure_storage.dart';
import 'package:sifr_latest/widgets/app/alert_service.dart';
import 'package:sifr_latest/widgets/app_widget/app_bar_widget.dart';

import '../../config/config.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/loading.dart';
import '../../widgets/qr_code_widget.dart';

class MerchantQRCode extends StatefulWidget {
  final dynamic params;

  const MerchantQRCode({Key? key, this.params}) : super(key: key);

  @override
  State<MerchantQRCode> createState() => _MerchantQRCodeState();
}

class _MerchantQRCodeState extends State<MerchantQRCode>
    with SingleTickerProviderStateMixin {
  GenerateQRCodeRequest requestModel = GenerateQRCodeRequest();

  TransactionServices transactionServices = TransactionServices();
  AlertService alertService = AlertService();
  late final CustomTimerController _controller = CustomTimerController(
      vsync: this,
      begin: const Duration(minutes: 5),
      end: const Duration(seconds: 0),
      initialState: CustomTimerState.reset,
      interval: CustomTimerInterval.seconds);
  late bool _isLoading = false;
  late bool showQRCode = false;
  late String verifiedQrData = '';
  late String traceNo = '';

  String qrCodeId='';
  String qrCodeTransactionId='';

  Timer? timer;
  AlertService alertWidget = AlertService();

  UserServices userServices = UserServices();

  @override
  void initState() {
    // getTrace();

    generateQr();

    super.initState();
  }

  getTrace() {
    setLoading(true);
    transactionServices.getTraceNumber().then((result) {
      var response = jsonDecode(result.body);
      if (result.statusCode == 200 || result.statusCode == 201) {
        setLoading(false);
        setState(() {
          requestModel.traceNumber = response['sequence'];
        });
        generateQr();
      } else {
        setLoading(false);
        setState(() {
          requestModel.traceNumber = "000000";
          // requestModel.traceNumber = Global.getRandom(6);
        });
        generateQr();
      }
    });
  }

  Future _checkQrStatus(String? qrCodeId) async {
    var getQrCodeStatusResponse = await userServices.getQrCodeStatus(qrCodeId!);
    var getQrCodeStatusResponseValue = jsonDecode(getQrCodeStatusResponse.body);

    print(getQrCodeStatusResponseValue['qrCodeRequestStatus']);
    if (getQrCodeStatusResponseValue['qrCodeRequestStatus'] == 'ATT') return;

    Future.delayed(const Duration(seconds: 1), () {
      if (getQrCodeStatusResponseValue['qrCodeRequestStatus'] == 'EFF' || getQrCodeStatusResponseValue['qrCodeRequestStatus'] == 'EXECUTED') {
        // alertWidget.failure(context, "Error", 'Request paid by the buyer');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request paid by the buyer'),
          ),
        );
        Navigator.pushReplacementNamed(context, 'home');
      }

      if (getQrCodeStatusResponseValue['qrCodeRequestStatus'] == 'EXP') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request Expired'),
          ),
        );
        // alertWidget.failure(context, "Error", 'Request Expired');
        Navigator.pushReplacementNamed(context, 'home');
      }

      if (getQrCodeStatusResponseValue['qrCodeRequestStatus'] == 'ANN' || getQrCodeStatusResponseValue['qrCodeRequestStatus'] == 'CANCELLED') {
        alertWidget.failure(context, "Error", 'QR code canceled by merchant');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Request Expired'),
        //   ),
        // );
        Navigator.pushReplacementNamed(context, 'home');
      }
    });
  }

  generateQr() async {
    setLoading(true);
    BoxStorage boxStorage = BoxStorage();
    String merchantId = boxStorage.getMerchantId();
    String terminalId = boxStorage.getTerminalId();

    requestModel.instId = Constants.instId;
    requestModel.transaction = 'CASH_AT_POS';
    requestModel.terminalId = await Validators.encrypt(terminalId.toString());
    requestModel.merchantId = await Validators.encrypt(merchantId.toString());
    requestModel.amount = widget.params;
    requestModel.qrData = '';

    Random random = Random();

    // Generate a random 7-digit number.
    int min = 1000000; // Smallest 7-digit number (1,000,000).
    int max = 9999999; // Largest 7-digit number (9,999,999).
    int randomSevenDigitNumber = min + random.nextInt(max - min + 1);

    // print("Random 7-digit number: $randomSevenDigitNumber");

    Map<String,dynamic> objectBody = {
      "payment": {
        "amount": "${widget.params}",
        "currency": "AED",
        "reason": "Coffee x4",
        "shopId": "10001",
        "cashDeskId": "10000001",
        "categoryPurpose": "CCP"
      },
      "paymentCategory": "01",
      "paymentType": "PAG",
      "qrCodeTransactionId": "qr$randomSevenDigitNumber"
    };




    transactionServices.generateQRCode(objectBody).then((response) {
      var decodeData = jsonDecode(response.body);

      print(decodeData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        String inputString = decodeData['link'];

        // Split the input string using 'data=' as the delimiter.
        List<String> parts = inputString.split('data=');

        // Check if the split resulted in two parts (before and after 'data=').
        if (parts.length == 2) {
          // The substring you want is in the second part (index 1).
          String desiredSubstring = parts[1];

          // Trim any leading or trailing spaces if needed.
          desiredSubstring = desiredSubstring.trim();

          setState(() {
            requestModel.qrData = desiredSubstring;
            verifiedQrData = desiredSubstring;

            qrCodeTransactionId=objectBody['qrCodeTransactionId']!;
            qrCodeId=decodeData['qrCodeId'];
            // print(verifiedQrData);
            timer = Timer.periodic(const Duration(seconds: 20), (Timer t) {
              _checkQrStatus(decodeData['qrCodeId']);
            });

            _controller.start();
            _isLoading = false;
          });
        }

        // if (decodeData['responseCode'].toString() == "00") {
        //   setState(() {
        //     requestModel.qrData = decodeData['qrData'].toString();
        //     verifiedQrData = jsonEncode(requestModel);
        //     _controller.start();
        //     _isLoading = false;
        //   });
        // } else {
        //   setLoading(false);
        //   alertService.failure(context, '', Constants.somethingWrong);
        // }
      } else {
        setLoading(false);
        alertService.failure(context, '', Constants.somethingWrong);
      }
    });
  }

  Future _deleteQr() async {

    /// Calling deleteQR API - First
    /// After calling First API - we will call verify reversal API
    /// We will call confirm reversal API

    try {
      var deleteQrResponse = await transactionServices.deleteQr(qrCodeId,qrCodeTransactionId);


      if (deleteQrResponse.statusCode != 200) return;

      var deleteQrResponseValue = jsonDecode(deleteQrResponse.body);

      if(deleteQrResponseValue['responseCode']=='01'){
        alertService.failure(context, '', deleteQrResponseValue['responseMessage']);
        Navigator.pushReplacementNamed(context, 'home');
        return;
      }

      /// Checking QR code is paid by customer
      /// calling verify reversal API if only the buyer is paid for QR code
      var getQrCodeStatusResponse = await userServices.getQrCodeStatus(qrCodeId!);
      var getQrCodeStatusResponseValue = jsonDecode(getQrCodeStatusResponse.body);


      print(getQrCodeStatusResponseValue['qrCodeRequestStatus']);

      // print(getQrCodeStatusResponseValue['qrCodeRequestStatus']);
      if (getQrCodeStatusResponseValue['qrCodeRequestStatus'] != 'EXECUTED' && getQrCodeStatusResponseValue['qrCodeRequestStatus'] != 'EFF') {
        Future.delayed(const Duration(seconds: 1),(){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Qr code is deleted'),
            ),
          );
          Navigator.pushReplacementNamed(context, 'home');
        });

        return;
        // alertWidget.failure(context, "Error", 'Request paid by the buyer');
      }

      if (deleteQrResponseValue != null) {

        Random random7 = Random();

        // Generate a random 7-digit number.
        int min7 = 1000000; // Smallest 7-digit number (1,000,000).
        int max7 = 9999999; // Largest 7-digit number (9,999,999).
        int merchantTxnId = min7 + random7.nextInt(max7 - min7 + 1);


        Random random6 = Random();

        // Generate a random 7-digit number.
        int min6 = 100000; // Smallest 7-digit number (1,000,000).
        int max6 = 999999; // Largest 7-digit number (9,999,999).
        int merchantTxnRefId = min6 + random6.nextInt(max6 - min6 + 1);


        Random random8 = Random();
        // Generate a random 7-digit number.
        int min8 = 10000000; // Smallest 7-digit number (1,000,000).
        int max8 = 99999999; // Largest 7-digit number (9,999,999).
        int paymentRefId = min8 + random8.nextInt(max8 - min8 + 1);


        var paymentObject = {
          "payment": {
            "amount": "${widget.params}",
            "currency": "AED",
            "reason": "Coffee x4",
            "paymentRefId ": "QRP$paymentRefId",
            "shopId": "10001",
            "cashDeskId": "10000001"
          },
          "merchantTrxId": "$merchantTxnId",
          "merchantTrxRefId": "$merchantTxnRefId"
        };

        print(paymentObject);


        // return;

        var verifyReversalResponse =
            await transactionServices.verifyReversal(paymentObject);


        if (verifyReversalResponse.statusCode != 200) return;

        var verifyReversalResponseValue =
            jsonDecode(verifyReversalResponse.body);

        print('verifyReversalResponseValue$verifyReversalResponseValue');

        if(verifyReversalResponseValue['status']=="Failed"){
            Navigator.pushReplacementNamed(context, 'home');
          return;
        }

        if (verifyReversalResponseValue != null) {

          var requestBody = {
            "merchantTrxId": "$merchantTxnId",
            "merchantTrxRefId": "$merchantTxnRefId",
            "payment": {
              "paymentId": "${getQrCodeStatusResponseValue['paymentId']}",
              "amount": "${widget.params}",
              "currency": "AED",
              "reason": "Coffee x4 ",
              "paymentRefId ": "QRP$paymentRefId",
              "shopId": "10001",
              "cashDeskId": "10000001"
            }
          };



          print(requestBody);

          // return;

          var confirmReversalResponse =
              await transactionServices.confirmReversal(requestBody);

          print('confirmReversalResponse${jsonDecode(confirmReversalResponse.body)}');

          if (confirmReversalResponse.statusCode != 200) {
            Navigator.pushReplacementNamed(context, 'home');
            return;
          }

          var confirmReversalResponseValue =
              jsonDecode(confirmReversalResponse.body);

          Future.delayed(Duration(seconds: 1),(){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reversal confirmed for this QR'),
              ),
            );
            Navigator.pushReplacementNamed(context, 'home');
          });



        }

      }


    } catch (_) {
      print('Error Logs$_');
    }
  }

  @override
  void dispose() {
    _controller.reset();
    _controller.finish();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Scan QR',
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading ? const LoadingWidget() : mainContent(),
    );
  }

  mainContent() {
    return SingleChildScrollView(
        child: Column(children: [
      const SizedBox(
        height: 16.0,
      ),
      Center(
        child: Image.asset(
          Constants.sifrLogo,
          height: 100,
          fit: BoxFit.fill,
        ),
      ),
      const SizedBox(
        height: 16.0,
      ),
      Center(
        child: QRCode(
          qrSize: 250,
          qrBackgroundColor: Colors.white,
          qrPadding: 13,
          qrBorderRadius: 10,
          qrForegroundColor: Theme.of(context).primaryColor,
          qrData: verifiedQrData,
          gapLess: false,
          // embeddedImage: AssetImage("assets/logo.jpg"),
        ),
      ),
      const SizedBox(
        height: 16.0,
      ),
      Center(
        child: Text(
          "Scan to Pay",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontSize: 18, fontWeight: FontWeight.w400),
        ),
      ),
      const SizedBox(
        height: 16.0,
      ),
      CustomTimer(
          controller: _controller,
          builder: (state, time) {
            return RichText(
                text: TextSpan(
                    text: 'QR Code will expired in ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 14),
                    children: [
                  TextSpan(
                    text: "${time.minutes}:${time.seconds}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                        fontSize: 14,
                        decoration: TextDecoration.none),
                  ),
                ]));
          }),
      const SizedBox(
        height: 16.0,
      ),
      // OutlinedButton(
      //     onPressed: () {
      //       Navigator.pushNamed(context, 'merchantPay');
      //       _controller.reset();
      //       _controller.finish();
      //     },
      //     style: OutlinedButton.styleFrom(
      //       side: const BorderSide(color: Colors.red, width: 1),
      //     ),
      //     child: Text(
      //       "Cancel",
      //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
      //             color: Colors.red,
      //           ),
      //     ))

      OutlinedButton(
          onPressed: () {
            // Navigator.pushNamed(context, 'merchantPay');
            // _controller.reset();
            // _controller.finish();
            _deleteQr();
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red, width: 1),
          ),
          child: Text(
            "Delete",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                ),
          ))
    ]));
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }
}
