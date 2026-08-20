import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/config/theme/app_theme_controller.dart';
import 'package:anet_merchants/config/theme/app_themes.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/services/connectivity_controller.dart';
import 'package:anet_merchants/core/utils/browser_history.dart';
import 'package:anet_merchants/core/utils/unauthorized_session_handler.dart';
import 'package:anet_merchants/core/widgets/app_update_gate.dart';
import 'package:anet_merchants/core/widgets/connectivity_blocker.dart';
import 'package:anet_merchants/features/auth/auth.dart';
import 'package:anet_merchants/features/devices/devices.dart';
import 'package:anet_merchants/features/settlements/settlements.dart';
import 'package:anet_merchants/features/support/support.dart';
import 'package:anet_merchants/features/transactions/transactions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await dotenv.load(fileName: '.env');
  await appThemeController.loadThemePreference();
  await appColorPaletteController.loadPreference();
  await appLanguageController.loadLanguagePreference();
  await connectivityController.start();
  await initializeDependencies();
  UnauthorizedSessionHandler.configure(
    onUnauthorized: () => AppRoutes.router.go(AppRoutes.login),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    // The connectivity controller is process-scoped, so stop its stream when
    // the root widget is removed. It remains restartable for widget tests and
    // app reattachment instead of disposing the global singleton itself.
    unawaited(connectivityController.stop());
    disposeBrowserHistoryGuard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl(),
        ),
        BlocProvider<SoundBoxBloc>(
          create: (context) => sl(),
        ),
        BlocProvider<MerchantVpaTxnBloc>(
          create: (context) => sl(),
        ),
        BlocProvider<PosTransactionBloc>(
          create: (context) => sl(),
        ),
        BlocProvider<SettlementBloc>(
          create: (context) => sl(),
        ),
        BlocProvider<SupportActionBloc>(
          create: (context) => sl(),
        ),
      ],
      child: AppLanguageScope(
        controller: appLanguageController,
        child: ListenableBuilder(
          listenable: Listenable.merge([
            appThemeController,
            appColorPaletteController,
            appLanguageController,
          ]),
          builder: (context, _) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              scrollBehavior: const _AppScrollBehavior(),
              theme: theme(),
              darkTheme: darkTheme(),
              themeMode: appThemeController.themeMode,
              locale: appLanguageController.locale,
              title: 'ANET Merchants',
              routerConfig: AppRoutes.router,
              builder: (context, child) {
                return AppUpdateGate(
                  child: ConnectivityBlocker(
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Enables the same direct scrolling gestures on web and native platforms.
/// Individual pages keep ownership of their existing scroll views.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
