/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : SPLASH_SCREEN.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:async';

import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:freerasp/freerasp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/widget.dart';

// SPLASH SCREEN STATEFUL WIDGET
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// SPLASH SCREEN - State Class
class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false; // DECLARE LOGIN VARIABLE
  CustomAlert customAlert = CustomAlert();
  AlertService alertService = AlertService();

  // Init function for page Initialization
  @override
  void initState() {
    // isRooted();
    Future.delayed(const Duration(seconds: 1), () {
      getValidationData();
    });
    super.initState();
  }

  Future<void> getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final bool isLogged = sharedPreferences.getBool('isLogged') ?? false;

    if (isLogged) {
      var tokenResponse = await MerchantServices().refreshToken();

      if (tokenResponse == null) return;

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'merchantHomeScreen');
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'merchantLogin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset('assets/screen/anet.png'),
      logoWidth: 150,
      title: Text(
        "Anet Merchant App",
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showLoader: false,
      // navigator: isLoggedIn == false ? const LoginPage() : const HomePage(),
      // navigator: dynamicNavigation(),
      durationInSeconds: 5,
    );
  }
}
