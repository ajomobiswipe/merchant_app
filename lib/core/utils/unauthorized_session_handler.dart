import 'dart:async';

import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/browser_history.dart';

class UnauthorizedSessionHandler {
  const UnauthorizedSessionHandler._();

  static FutureOr<void> Function()? _onUnauthorized;
  static bool _isHandling = false;

  static void configure({
    required FutureOr<void> Function() onUnauthorized,
  }) {
    _onUnauthorized = onUnauthorized;
  }

  static Future<void> handleUnauthorized() async {
    if (_isHandling) {
      return;
    }

    _isHandling = true;
    try {
      await SessionStorage().clearSession();
      await appLanguageController.resetLanguagePreference();
      setAuthenticatedHistoryGuard(false);
      await _onUnauthorized?.call();
    } finally {
      _isHandling = false;
    }
  }
}
