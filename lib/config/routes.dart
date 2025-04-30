/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : ROUTES.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:anet_merchant_app/pages/splash_screen/splash_screen.dart';

import 'package:anet_merchant_app/pages/users/merchant/merchant_help_screen.dart';
import 'package:anet_merchant_app/pages/users/merchant/merchant_home_page/merchant_home_screen.dart';
import 'package:anet_merchant_app/pages/users/merchant/merchant_login.dart';
import 'package:anet_merchant_app/pages/users/merchant/merchant_transcation_filter_screen.dart';
import 'package:anet_merchant_app/pages/users/merchant/merchat_statement_filter_screen.dart';
import 'package:anet_merchant_app/pages/users/merchant/settlement_dashboard.dart';
import 'package:anet_merchant_app/pages/users/merchant/view_all_transaction_screen.dart';
import 'package:anet_merchant_app/providers/connectivity_provider.dart';

import '../widgets/widget.dart';

// Custom route Class
class CustomRoute {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    var args = settings.arguments;

    return CupertinoPageRoute(builder: (context) {
      final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
      if (!isOnline) {
        return const NoInternetPage();
      }
      switch (settings.name) {
        // case "login":
        //   return const LoginPage();
        // case "userType":
        //   return const UserTypeSelection();
        // case "MerchantNumVerify":
        //   return const MerchantOTPVerifyScreen();
        // // case "merchantOnboarding":
        // //   return const MerchantSignup();
        // case "myApplications":
        //   return const MyApplications();
        // case "DeviceDeploymentScreen":
        //   return DeviceDeploymentScreen(
        //     deviceInfo: args as Map<String, dynamic>?,
        //   );

        // case "PaymentPage":
        //   return PaymentPage(
        //     merchantDetails: args as Map<String, dynamic>?,
        //   );

        // case "PaymentSuccessPage":
        //   return PaymentSuccessPage(
        //     payAmountAndPackage: args as Map<String, dynamic>,
        //   );
        // case "SignUpSuccessScreen":
        //   return const SignUpSuccessScreen();

        case "splash":
          return const SplashScreen();

        // Merchant Routes
        case "merchantLogin":
          return const MerchantLogin();
        case "merchantHomeScreen":
          return const MerchantHomeScreen();
        case "merchantHelpScreen":
          return const MerchantHelpScreen();
        case "merchantTransactionFilterScreen":
          return MerchantTransactionFilterScreen();
        case "merchantStatementFilterScreen":
          return MerchantStatementFilterScreen();
        case "viewAllTransaction":
          return ViewAllTransactionScreen();
        case "settlementDashboard":
          return SettlementDashboard();
      }
      return const Scaffold(
        body: Center(
            child: Text(
          "404 Page not found",
          style: TextStyle(color: Colors.red, fontSize: 22),
        )),
      );
    });
  }
}
