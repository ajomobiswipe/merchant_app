import 'package:flutter/material.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/browser_history.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SessionStorage _sessionStorage = SessionStorage();

  @override
  void initState() {
    super.initState();
    _checkLoginSession();
  }

  Future<void> _checkLoginSession() async {
    final isLoggedIn = await _sessionStorage.isLoginSuccess;

    if (!mounted) return;

    setAuthenticatedHistoryGuard(isLoggedIn);

    // Splash is only a transient session check. Replacing it prevents browser
    // Back from reopening Splash and immediately redirecting to another Home.
    NavigationHelper.goToRoot(
      context,
      isLoggedIn ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssets.anetIcon,
              width: 110,
              height: 110,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(color: AppColors.primaryPurple),
            const SizedBox(height: 16),
            Text(
              context.tr('loading'),
              style: AppTextStyle.h4.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
