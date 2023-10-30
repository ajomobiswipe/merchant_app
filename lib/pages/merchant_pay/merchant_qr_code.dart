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

  Timer? timer;

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


  Future _checkQrStatus(String? qrCodeId)async{
    transactionServices.checkQrStatus(qrCodeId).then((response) {

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



    var objectBody = {
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

            // print(verifiedQrData);

            // timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
            //   print('30 seconds');
            //   _checkQrStatus(decodeData['qrCodeId']);
            // });

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
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
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
              qrForegroundColor: Theme
                  .of(context)
                  .primaryColor,
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
              style: Theme
                  .of(context)
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
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 14),
                        children: [
                          TextSpan(
                            text: "${time.minutes}:${time.seconds}",
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                color: Colors.red,
                                fontSize: 14,
                                decoration: TextDecoration.none),
                          ),
                        ]));
              }),

          const SizedBox(
            height: 16.0,
          ),
          OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'merchantPay');
                _controller.reset();
                _controller.finish();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1),
              ),
              child: Text(
                "Cancel",
                style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
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
