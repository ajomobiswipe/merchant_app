import 'package:web/web.dart' as web;

import 'session_storage_backend.dart';

SessionStorageBackend createSessionStorageBackend() =>
    WebTabSessionStorageBackend();

/// Keeps authentication state inside the current browser tab.
///
/// Non-sensitive preferences such as theme and language may continue to use
/// shared preferences/local storage. Bearer tokens and merchant identity must
/// not be shared between tabs because each tab can represent a different
/// signed-in merchant.
final class WebTabSessionStorageBackend implements SessionStorageBackend {
  static const _prefix = 'anet_merchants.session.';
  static const _legacyAuthKeys = <String>[
    'FlutterSecureStorage.login_success',
    'FlutterSecureStorage.user_info',
    'FlutterSecureStorage.active_acq_merchant_id',
    'FlutterSecureStorage.active_shop_name',
  ];
  static bool _legacyStateRemoved = false;

  WebTabSessionStorageBackend() {
    if (!web.window.isSecureContext) {
      throw StateError(
        'Web authentication requires HTTPS or localhost.',
      );
    }
    _removeLegacySharedAuthState();
  }

  web.Storage get _storage => web.window.sessionStorage;

  String _storageKey(String key) => '$_prefix$key';

  void _removeLegacySharedAuthState() {
    if (_legacyStateRemoved) return;

    for (final key in _legacyAuthKeys) {
      web.window.localStorage.removeItem(key);
    }
    _legacyStateRemoved = true;
  }

  @override
  Future<String?> read(String key) async => _storage.getItem(_storageKey(key));

  @override
  Future<void> write(String key, String value) async {
    _storage.setItem(_storageKey(key), value);
  }

  @override
  Future<void> delete(String key) async {
    _storage.removeItem(_storageKey(key));
  }
}
