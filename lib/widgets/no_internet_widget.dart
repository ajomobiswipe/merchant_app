/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : NO_INTERNET_PAGE.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/config.dart';

// No Internet Page
class NoInternetPage extends StatelessWidget {
  static const String routeName = 'noInternet';
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          SystemNavigator.pop();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(Constants.noInternetImage,
                    height: 250, fit: BoxFit.fill),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "No internet connection",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "This network is not connected to the Internet",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ));
  }
}
