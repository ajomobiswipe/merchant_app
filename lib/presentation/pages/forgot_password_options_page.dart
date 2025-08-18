/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : FORGOT.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/presentation/widgets/app_widget/app_button.dart';
import 'package:flutter/material.dart';

import '../widgets/loading.dart';

// STATEFUL WIDGET
class Forgot extends StatefulWidget {
  const Forgot({super.key, this.type});
  final String? type;

  @override
  State<Forgot> createState() => _ForgotState();
}

// Forgot State Class
class _ForgotState extends State<Forgot> {
  // LOCAL VARIABLE DECLARATION
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingWidget()
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: childData());
  }

  // Body widget
  Widget childData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 30,
        ),
        Image.asset(
          Constants.forgotPasswordImage,
          height: 300,
          fit: BoxFit.fill,
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          "Forgot Password?",
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Do not worry we will help you recover your password.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
        ),
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: AppButton(
            title: "OTP Verification",
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'userCheckPage',
                  arguments: {'type': widget.type, 'page': 'OTPVerification'});
            },
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: AppButton(
            title: "Security Questions",
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'userCheckPage',
                  arguments: {'type': widget.type, 'page': 'Security'});
            },
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "DON'T HAVE ACCOUNT? ",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                ),
                InkWell(
                  child: Text(
                    "SIGN UP",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                        ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, 'role');
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }
}
