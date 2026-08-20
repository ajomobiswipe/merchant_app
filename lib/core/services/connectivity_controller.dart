import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityController extends ChangeNotifier {
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _hasInternet = true;
  bool _isStarted = false;

  ConnectivityController({
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  bool get hasInternet => _hasInternet;

  Future<void> start() async {
    if (_isStarted) return;

    _isStarted = true;
    final results = await _connectivity.checkConnectivity();
    if (!_isStarted) return;

    await _updateStatus(results);
    if (!_isStarted) return;

    _subscription ??= _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  Future<void> stop() async {
    _isStarted = false;
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();
  }

  Future<void> _updateStatus(List<ConnectivityResult> results) async {
    if (!_isStarted) return;

    final hasNetwork =
        results.any((result) => result != ConnectivityResult.none);
    final hasInternet = hasNetwork && await _canReachInternet();

    // A DNS/network check may finish after the app has already stopped this
    // controller. Do not notify listeners after that lifecycle boundary.
    if (!_isStarted || _hasInternet == hasInternet) {
      return;
    }

    _hasInternet = hasInternet;
    notifyListeners();
  }

  Future<bool> _canReachInternet() async {
    // Browsers do not support DNS lookups through `InternetAddress`. Their
    // network stack performs that work for each HTTP request instead.
    if (kIsWeb) return true;

    try {
      final lookup = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 4));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } on Object {
      return false;
    }
  }

  @override
  void dispose() {
    unawaited(stop());
    super.dispose();
  }
}

final connectivityController = ConnectivityController();
