/* ===============================================================
| Project : SIFR
| Page    : SPLASH_SCREEN.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:async';

import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:freerasp/freerasp.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/pages/user_types/user_type_selection.dart';
import 'package:sifr_latest/storage/secure_storage.dart';

import '../../config/config.dart';
import '../../widgets/widget.dart';
import '../home/home_page.dart';
import '../users/users.dart';

// SPLASH SCREEN STATEFUL WIDGET
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// SPLASH SCREEN - State Class
class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false; // DECLARE LOGIN VARIABLE
  LocalAuthentication auth = LocalAuthentication();
  final bool _result = true;
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

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> isRooted() async {
  //   final callback = ThreatCallback(
  //     onPrivilegedAccess: () {
  //       print("Root access");
  //       alertService.errorToast("Debug access");
  //       if (Platform.isAndroid) {
  //         // SystemNavigator.pop();
  //         Navigator.pushNamedAndRemoveUntil(context, "login", (route) => false);
  //         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //       } else if (Platform.isIOS) {
  //         exit(0);
  //       }
  //     },
  //     onHooks: () {
  //       print("Hook access");
  //       // customAlert.rootExits(context);
  //       alertService.errorToast("Debug access");
  //       if (Platform.isAndroid) {
  //         // SystemNavigator.pop();
  //         Navigator.pushNamedAndRemoveUntil(context, "login", (route) => false);
  //         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //       } else if (Platform.isIOS) {
  //         exit(0);
  //       }
  //     },
  //     onDebug: () {
  //       print("Debug access");
  //       // customAlert.rootExits(context);
  //       alertService.errorToast("Debug access");
  //       if (Platform.isAndroid) {
  //         // SystemNavigator.pop();
  //         Navigator.pushNamedAndRemoveUntil(context, "login", (route) => false);
  //         SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  //       } else if (Platform.isIOS) {
  //         exit(0);
  //       }
  //     },
  //   );
  //   // Attaching listener
  //   Talsec.instance.attachListener(callback);
  // }

  Future getValidationData() async {
    debugPrint('--- Splash Screen ---');
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    bool? isLogged = sharedPreferences.getBool('isLogged') ?? false;
    String lastLogin = sharedPreferences.getString('lastLogin').toString();
    isLoggedIn = isLogged;
    if (sharedPreferences.getString('lastLogin') != null) {
      DateTime dt1 = DateTime.parse(lastLogin);
      DateTime now = DateTime.now();
      DateTime dt2 =
          DateTime.parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(now));
      Duration diff = dt2.difference(dt1);

      BoxStorage boxStorage = BoxStorage();
      // boxStorage.save('isEnableBioMetric', false);
      List check = await Global.availableBiometrics();
      if (check.isEmpty) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, 'MerchantNumVerify');
      } else {
        bool isEnableBioMetric = boxStorage.get('isEnableBioMetric') ?? false;
        if (isEnableBioMetric) {
          var authentication = await Global.authenticate();
          if (authentication && authentication != null) {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, 'MerchantNumVerify');
          } else if (authentication == false) {
            SystemNavigator.pop();
          } else {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, 'userType');
          }
        } else {
          if (diff.inHours >= 4) {
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, 'loginWithPin', (route) => false);
          } else if (isLoggedIn) {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, 'MerchantNumVerify');
          } else {
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, 'userType');
          }
        }
      }
    } else {
      if (isLoggedIn == false) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, 'userType');
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, 'MerchantNumVerify');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset('assets/logo/oma_emirates_logo.png'),
      logoWidth: 150,
      title: Text(
        "Merchant Onboarding",
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showLoader: false,
      // navigator: isLoggedIn == false ? const LoginPage() : const HomePage(),
      navigator: dynamicNavigation(),
      durationInSeconds: 5,
    );
  }

  dynamicNavigation() async {
    debugPrint("--- Dynamic Navigation ---");
    return isLoggedIn == false ? const UserTypeSelection() : const HomePage();
  }
}
