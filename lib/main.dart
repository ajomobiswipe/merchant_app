/* ===============================================================
| Project : SIFR
| Page    : MAIN.DART
| Date    : 21-MAR-2023
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sifr_latest/theme/hive_storage_services.dart';
import 'package:sifr_latest/theme/theme_provider.dart';

import 'config/config.dart';
import 'config/state_key.dart';
import 'providers/providers.dart';
import 'widgets/widget.dart';

// Global Key - unauthorized login
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
CustomAlert customAlert = CustomAlert();
AlertService alertService = AlertService();

// main function - flutter startup function
void main() {
  runZonedGuarded<Future<void>>(() async {
    setUpServiceLocator();
    final StorageService storageService = getIt<StorageService>();
    await storageService.init();
    await Hive.initFlutter(); // THIS IS FOR THEME STORAGE
    await Hive.openBox('SIFR_USER_CONTROLS'); // THIS IS FOR USER STORAGE

    // await getDataFromScanData("00020101021226080004345652049995303978540415.05802IT5907Druidia6005MILAN62250121AZ115WL#UB776WH#z4E0k#10001");

    ByteData data = await PlatformAssetBundle()
        .load('assets/ca/omaemirates_root_certificate.cer');
    SecurityContext.defaultContext
        .setTrustedCertificatesBytes(data.buffer.asUint8List());

    // --- Root
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    runApp(MainPage(
      storageService: storageService,
    ));
  }, (e, _) => throw e);
}

// FCM - Background Services
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

// Stateless Widget for main page
class MainPage extends StatelessWidget {
  // local variable declaration
  final StorageService storageService;
  MainPage({Key? key, required this.storageService}) : super(key: key);

  /*
  * This is the main page of project. we are using multiple provider.
  * ThemeProvider - for theme mode & theme color option
  * ConnectivityProvider - for internet check
  */
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (context) => ConnectivityProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (c, themeProvider, home) => MaterialApp(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: StateKey.snackBarKey,
          initialRoute: 'splash',
          onGenerateRoute: CustomRoute.allRoutes,
          navigatorKey: navigatorKey,
          locale: Locale(themeProvider.currentLanguage),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            fontFamily: "Mont",
          ),
          // theme: AppThemes.main(
          //   primaryColor: themeProvider.selectedPrimaryColor,
          // ),
          // // Dark mode design
          // darkTheme: AppThemes.main(f
          //   isDark: true,
          //   primaryColor: themeProvider.selectedPrimaryColor,
          // ),
          // this is Theme Mode Selection
          themeMode: themeProvider.selectedThemeMode,
        ),
      ),
    );
  }
}
