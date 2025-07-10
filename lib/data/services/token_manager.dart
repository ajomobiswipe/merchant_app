import 'dart:async';

import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/main.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
