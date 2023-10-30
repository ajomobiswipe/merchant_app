/* ===============================================================
| Project : SIFR
| Page    : CHECK_YOUR_EMAIL.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:sifr_latest/widgets/app_widget/app_button.dart';

// STATEFUL WIDGET
class CheckYourMail extends StatefulWidget {
  const CheckYourMail({Key? key}) : super(key: key);

  @override
  State<CheckYourMail> createState() => _CheckYourMailState();
}

// Check Your Mail State Class
class _CheckYourMailState extends State<CheckYourMail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Lottie.asset('assets/lottie/lottieEmail.json', height: 150),
                Text(
                  "Check your mail",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 32,
                      ),
                ),
                Center(
                  child: Text(
                    "We have sent a Username recovery mail to your registered email ID.",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                  ),
                ),
                const SizedBox(
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: AppButton(
                    title: "Open email app",
                    onPressed: () async {
                      var result = await OpenMailApp.openMailApp();
                      if (!result.didOpen && !result.canOpen) {
                      } else if (!result.didOpen && result.canOpen) {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return MailAppPickerDialog(
                              mailApps: result.options,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pushNamedAndRemoveUntil(
                          context, 'login', (route) => false);
                    },
                    child: Text(
                      "Skip",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
