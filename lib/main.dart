/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : MAIN.DART
| Date    : 04-OCT-2024
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:async';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/core/endpoints.dart';
import 'package:anet_merchant_app/core/routes.dart';
import 'package:anet_merchant_app/core/state_key.dart';
import 'package:anet_merchant_app/data/services/connectivity_service.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/providers/support_action_provider.dart';
import 'package:anet_merchant_app/presentation/providers/home_screen_provider.dart';
import 'package:anet_merchant_app/presentation/providers/merchant_filtered_transaction_provider.dart';
import 'package:anet_merchant_app/presentation/providers/settlement_provider.dart';
import 'package:anet_merchant_app/presentation/providers/vpa_transaction_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:anet_merchant_app/presentation/widgets/app/custom_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Global Key - unauthorized login

CustomAlert customAlert = CustomAlert();
AlertService alertService = AlertService();

/// The main entry point of the application.

void main() {
  runZonedGuarded<Future<void>>(() async {
    await dotenv.load();
    await Hive.initFlutter(); // THIS IS FOR THEME STORAGE
    await Hive.openBox(Constants.hiveName); // THIS IS FOR USER STORAGE

    // --- Root
    WidgetsFlutterBinding.ensureInitialized();
    ConnectivityService().initialize();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Background color
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
        systemNavigationBarColor: Colors.white, // Navigation bar color
        systemNavigationBarIconBrightness: Brightness.dark, // For Android
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      // ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
      ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
      // ChangeNotifierProvider(create: (_) => TidProvider()),
      ChangeNotifierProvider(create: (_) => SettlementProvider()),
      ChangeNotifierProvider(create: (_) => SupportActionProvider()),
      ChangeNotifierProvider(
          create: (_) => MerchantFilteredTransactionProvider()),
      ChangeNotifierProxyProvider<MerchantFilteredTransactionProvider,
          VpaTransactionProvider>(
        create: (_) =>
            VpaTransactionProvider(DummyMerchantProvider()), // required dummy
        update: (_, merchantProvider, __) =>
            VpaTransactionProvider(merchantProvider),
      ),

      // ], child: MainPage()));
    ], child: MainPage()));
  }, (e, _) => throw e);
}

// Stateless Widget for main page
class MainPage extends StatelessWidget {
  const MainPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isUAT = EndPoints.baseApiPublic.contains("omasoftposqc");
    return isUAT
        ? Directionality(
            textDirection: TextDirection.ltr, // Left-to-right direction
            child: Banner(
              message: "UAT",
              location: BannerLocation.topEnd,
              color: Colors.red,
              child: _buildMaterialApp(),
            ),
          )
        : _buildMaterialApp();
  }

  Widget _buildMaterialApp() {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: StateKey.snackBarKey,
        initialRoute: 'splash',
        // initialRoute: 'merchantHomeScreen',
        onGenerateRoute: CustomRoute.allRoutes,
        navigatorKey: NavigationService.navigatorKey,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          fontFamily: "Mont-regular",
        ),
      ),
    );
  }
}

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  static void goBack() {
    navigatorKey.currentState!.pop();
  }
}
