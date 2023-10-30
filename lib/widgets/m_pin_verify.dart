/* ===============================================================
| Project : SIFR
| Page    : MPIN_VERIFY.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:sifr_latest/widgets/app_widget/app_bar_widget.dart';
import '../config/config.dart';

// Mpin Verify Class
class MPinVerify extends StatelessWidget {
  const MPinVerify({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: "Verify MPIN",
        action: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                Constants.verifyMPIN,
                height: 200,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Which we require to doing online transaction in your bank account. It is a six digit secret code number.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
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
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none),
                fieldWidth: 45.0,
                filled: true,
                obscureText: true,
                autoFocus: true,
                borderColor: Theme.of(context).primaryColorDark,
                enabledBorderColor:
                    Theme.of(context).primaryColorDark.withOpacity(0.5),
                showFieldAsBox: true,
                onCodeChanged: (String code) {},
                onSubmit: (String verificationCode) {
                  Navigator.of(context).pop(verificationCode);
                }, // end onSubmit
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
