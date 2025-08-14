/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : ROUTES.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:anet_merchant_app/presentation/pages/reset_password.dart';
import 'package:anet_merchant_app/presentation/pages/splash_screen/splash_screen.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_help_screen.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_home_page/merchant_home_screen.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_login.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_transcation_filter_screen.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_settlements_filter_screen.dart';
import 'package:anet_merchant_app/presentation/pages/settlement_dashboard.dart';
import 'package:anet_merchant_app/presentation/pages/view_all_transaction_screen.dart';
import 'package:anet_merchant_app/presentation/pages/view_settlement_info.dart';
import 'package:anet_merchant_app/presentation/pages/vpa_transactions_screen.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Custom route Class
class CustomRoute {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    //var args = settings.arguments;

    return CupertinoPageRoute(builder: (context) {
      // final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
      // if (!isOnline) {
      //   return const NoInternetPage();
      // }
      switch (settings.name) {
        case "splash":
          return const SplashScreen();

        // Merchant Routes
        case "merchantLogin":
          return const MerchantLogin();
        case "login":
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
        case "viewSettlementInfo":
          return ViewSettlementInfo();
        case "vpaTransactionsScreen":
          return VpaTransactionsScreen();
        case "resetPassword":
          String userName = settings.arguments as String;
          return ResetPassword(
            userName: userName,
          );
      }
      return const Scaffold(
        body: Center(
            child: CustomTextWidget(
                text: "404 Page not found", color: Colors.red, size: 22)),
      );
    });
  }
}
