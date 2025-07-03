/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : MAIN.DART
| Date    : 04-OCT-2024
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:async';
import 'dart:io';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/core/endpoints.dart';
import 'package:anet_merchant_app/core/routes.dart';
import 'package:anet_merchant_app/core/state_key.dart';
import 'package:anet_merchant_app/data/services/connectivity_service.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/providers/connectivity_provider.dart';
import 'package:anet_merchant_app/presentation/providers/support_action_provider.dart';
import 'package:anet_merchant_app/presentation/providers/transactions_provider.dart';
import 'package:anet_merchant_app/presentation/providers/merchant_filtered_transaction_provider.dart';
import 'package:anet_merchant_app/presentation/providers/settlement_provider.dart';
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

bool isDevWithoutOtp = false;

///setting true for demo purpose or else set to false

// main function - flutter startup function
void main() {
  runZonedGuarded<Future<void>>(() async {
    // setUpServiceLocator();
    // final StorageService storageService = getIt<StorageService>();
    // await storageService.init();
    await dotenv.load();
    await Hive.initFlutter(); // THIS IS FOR THEME STORAGE
    await Hive.openBox(Constants.hiveName); // THIS IS FOR USER STORAGE
    ByteData data = await PlatformAssetBundle()
        .load('assets/ca/omaemirates_root_certificate.cer');
    SecurityContext.defaultContext
        .setTrustedCertificatesBytes(data.buffer.asUint8List());

    // --- Root
    WidgetsFlutterBinding.ensureInitialized();
    ConnectivityService().initialize();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      // ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
      ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ChangeNotifierProvider(create: (_) => SettlementProvider()),
      ChangeNotifierProvider(create: (_) => SupportActionProvider()),
      ChangeNotifierProvider(
          create: (_) => MerchantFilteredTransactionProvider()),
      // ], child: MainPage()));
    ], child: MainPage()));
  }, (e, _) => throw e);
}

// // FCM - Background Services
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

// Stateless Widget for main page
class MainPage extends StatelessWidget {
  // local variable declaration
  // final StorageService storageService;

  const MainPage({
    super.key,
  });

  /*
  * This is the main page of project. we are using multiple provider.
  * ThemeProvider - for theme mode & theme color option
  * ConnectivityProvider - for internet check
  */
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

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();

  factory TokenManager() {
    return _instance;
  }

  TokenManager._internal(); // private constructor

  Timer? _timer;
  MerchantServices merchantServices = MerchantServices();

  void start(BuildContext context) {
    print("token manager started at ${DateTime.now()}");
    _timer ??= Timer.periodic(Duration(seconds: 100), (_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isLoggedIn) {
        try {
          _refreshToken();
        } catch (e) {
          print("Error occurred while refreshing token: $e");
          stop();
        }
      }
    });
  }

  void stop() {
    Provider.of<AuthProvider>(
            NavigationService.navigatorKey.currentState!.context,
            listen: false)
        .isLoggedIn = false;
    _timer?.cancel();
    _timer = null;
  }

  void _refreshToken() {
    merchantServices.refreshToken();
    print("Token refreshed at ${DateTime.now()}");
    // Add actual logic here
  }
}
