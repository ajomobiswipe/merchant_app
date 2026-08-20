import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anet_merchants/core/di/injection_container.dart';
import 'package:anet_merchants/features/auth/auth.dart';
import 'package:anet_merchants/features/home/home.dart';
import 'package:anet_merchants/features/notifications/notifications.dart';
import 'package:anet_merchants/features/settlements/settlements.dart';
import 'package:anet_merchants/features/shared/shared.dart';
import 'package:anet_merchants/features/splash/splash.dart';
import 'package:anet_merchants/features/transactions/transactions.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String splash = '/Splash';
  static const String login = '/Login';
  static const String forgotPassword = '/ForgotPassword';
  static const String resetPassword = '/ResetPassword';
  static const String otpValidation = '/OtpValidation';
  static const String home = '/Home';
  static const String notifications = '/Notifications';
  static const String profile = '/Profile';
  static const String transactionFilter = '/TransactionFilter';
  static const String transactions = '/Transactions';
  static const String transactionInvoice = '/TransactionInvoice';
  static const String vpaInvoice = '/VpaInvoice';
  static const String settlementDashboard = '/SettlementDashboard';
  static const String settlementDetail = '/SettlementDetail';
  static const String settlementInvoice = '/SettlementInvoice';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => splash,
      ),
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: resetPassword,
        builder: (context, state) {
          final extra = state.extra;

          return ResetPasswordPage(username: extra is String ? extra : '');
        },
      ),
      GoRoute(
        path: otpValidation,
        builder: (context, state) {
          final extra = state.extra;

          // OTP and reset flows depend on login payload passed through routing.
          // If that context is missing, send the user back to login instead of
          // building a partially initialized screen.
          if (extra is UserInfoModel) {
            return OtpValidationPage(userInfo: extra);
          }

          return const Login();
        },
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const HomePage(initialBottomIndex: 3),
      ),
      GoRoute(
        path: transactionFilter,
        builder: (context, state) {
          final extra = state.extra;

          if (extra is TransactionFilterData) {
            return TransactionFilterPage(
              tab: extra.tab,
              initialVpa: extra.creditVpa,
            );
          }

          return const TransactionFilterPage(tab: TransactionTab.qr);
        },
      ),
      GoRoute(
        path: transactions,
        builder: (context, state) {
          final extra = state.extra;

          // Transaction list pages spin up their own blocs so filter-driven
          // navigation can request a fresh dataset without disturbing home state.
          if (extra is TransactionFilterData) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<MerchantVpaTxnBloc>(
                  create: (_) => sl<MerchantVpaTxnBloc>(),
                ),
                BlocProvider<PosTransactionBloc>(
                  create: (_) => sl<PosTransactionBloc>(),
                ),
                BlocProvider<SettlementBloc>(
                  create: (_) => sl<SettlementBloc>(),
                ),
              ],
              child: TransactionListPage(filter: extra),
            );
          }

          return const HomePage();
        },
      ),
      GoRoute(
        path: settlementDashboard,
        builder: (context, state) {
          final extra = state.extra;

          if (extra is TransactionFilterData) {
            return BlocProvider<SettlementBloc>(
              create: (_) => sl<SettlementBloc>(),
              child: SettlementDashboardPage(filter: extra),
            );
          }

          return const HomePage();
        },
      ),
      GoRoute(
        path: settlementDetail,
        builder: (context, state) {
          final extra = state.extra;

          if (extra is SettlementDetailData) {
            return BlocProvider<SettlementBloc>(
              create: (_) => sl<SettlementBloc>(),
              child: SettlementDetailPage(data: extra),
            );
          }

          return const HomePage();
        },
      ),
      GoRoute(
        path: settlementInvoice,
        builder: (context, state) {
          final extra = state.extra;

          if (extra is SettlementItemModel) {
            return SettlementInvoicePage(transaction: extra);
          }

          return const HomePage();
        },
      ),
      GoRoute(
        path: transactionInvoice,
        builder: (context, state) {
          final extra = state.extra;

          if (extra is PosTransactionModel) {
            return TransactionInvoicePage(transaction: extra);
          }

          return const HomePage();
        },
      ),
      GoRoute(
        path: vpaInvoice,
        builder: (context, state) {
          final extra = state.extra;

          if (extra is MerchantVpaTransactionModel) {
            return VpaInvoicePage(transaction: extra);
          }

          return const HomePage();
        },
      ),
    ],
  );
}
