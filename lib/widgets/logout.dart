/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : LOGOUT.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anet_merchant_app/config/app_color.dart';
import 'package:anet_merchant_app/config/constants.dart';
import 'package:anet_merchant_app/main.dart';
import 'package:anet_merchant_app/widgets/alert_popup.dart';
import 'package:anet_merchant_app/widgets/custom_text_widget.dart';

// Global Logout Class
class Logout {
  // Logout widget

  Future<void> logoutWarningDialog({
    required BuildContext context,
    required String title,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            var screenWidth = MediaQuery.of(context).size.width;
            return Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              shadowColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Container(
                width: screenWidth * 0.9,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                      text: title,
                      size: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.kPrimaryColor,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Are you sure you want to logout?\n\n"
                      "Logging out will require you to sign in again to access your account. "
                      "Make sure you’ve saved any important changes.",
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        PopupButton(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          title: "Cancel",
                          width: screenWidth * 0.35,
                          color: AppColors.kLightGreen,
                        ),
                        PopupButton(
                          title: "Logout",
                          width: screenWidth * 0.35,
                          color: AppColors.kPrimaryColor,
                          onTap: () {
                            TokenManager().stop();
                            logOutUser(context);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> logOutUser(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userName = prefs.getString('userName');

      await Future.wait(
          [navigateToUserType(context), Hive.box(Constants.hiveName).clear()]);
    } catch (e) {
      clearSharedPref();
      await Hive.box(Constants.hiveName).clear();
    }
  }

  Future<void> clearSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (!rememberMe) {
      await prefs.clear();
    } else {
      await prefs.remove('isLogged');
      await prefs.remove('lastLogin');
      await prefs.remove('loggedUserType');
      await prefs.remove('merchantOnboardingValues');
      await prefs.remove('OnboardingValuesRefreshedtime');
    }
  }

  void handleLogoutError(response) {
    var res = jsonDecode(response.body);
    alertService.error(res["description"]);
  }

  Future<void> navigateToUserType(BuildContext context) async {
    clearSharedPref();
    Navigator.pushNamedAndRemoveUntil(
        context, 'merchantLogin', (route) => false);
  }
}
