import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/widgets/app/alert_service.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../services/transaction_services.dart';
import '../../widgets/app_widget/app_bar_widget.dart';

class MPinVerification extends StatefulWidget {
  const MPinVerification({Key? key, this.payment}) : super(key: key);
  final dynamic payment;

  @override
  State<MPinVerification> createState() => _MPinVerificationState();
}

class _MPinVerificationState extends State<MPinVerification> {
  TransactionServices transactionServices = TransactionServices();
  AlertService alertService = AlertService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  cashOutFinal(request) {
    setLoading(true);

    Navigator.pushNamedAndRemoveUntil(
        context, 'receiptSuccessForDemo', (route) => false);

    // transactionServices.cashOut(request).then((response) {
    //   var jsonDecodeData = json.decode(response.body);
    //
    //  if(kDebugMode)print(response.statusCode);
    //
    //   if (response.statusCode == 200 || response.statusCode == 201) {
    //     var code = jsonDecodeData['responseCode'].toString();
    //     if (jsonDecodeData['responseCode'].toString() == "00") {
    //       setLoading(false);
    //       Navigator.pushNamedAndRemoveUntil(
    //           context,
    //           'receiptSuccess',
    //           arguments: {'receipt': jsonEncode(jsonDecodeData)},
    //           (route) => false);
    //     } else {
    //       setLoading(false);
    //       alertService.failure(context, '', jsonDecodeData['responseMessage']);
    //       if (code == "51") {
    //         Navigator.pushNamed(context, "wallet");
    //       }
    //       if (code == "01") {
    //         Navigator.pushNamed(context, "home");
    //       }
    //     }
    //   } else {
    //     setLoading(false);
    //     alertService.failure(context, '', jsonDecodeData['message']);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    var payment = jsonDecode(widget.payment);
    return Scaffold(
        appBar: const AppBarWidget(
          title: "Verify your MPIN",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                    ),
                    Image.asset(
                      'assets/screen/verify_mpin.png',
                      height: 200,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                    const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Which we require to doing online transaction in your bank account. It is a six digit secret code number.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        ]),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        "Please Enter Your mPIN",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    OtpTextField(
                      numberOfFields: 6,
                      fieldWidth: 45.0,
                      filled: true,
                      obscureText: true,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none),
                      borderColor: Theme.of(context).primaryColorDark,
                      enabledBorderColor:
                          Theme.of(context).primaryColorDark.withOpacity(0.5),
                      showFieldAsBox: true,
                      onCodeChanged: (String code) {},
                      onSubmit: (String verificationCode) async {
                        var a = payment;
                        a['mPin'] = await Validators.encrypt(verificationCode);
                        cashOutFinal(a);
                      }, // end onSubmit
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ));
  }
}
