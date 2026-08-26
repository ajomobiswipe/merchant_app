import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session_storage_backend.dart';

SessionStorageBackend createSessionStorageBackend() =>
    const NativeSessionStorageBackend();

final class NativeSessionStorageBackend implements SessionStorageBackend {
  static const _storage = FlutterSecureStorage();

  const NativeSessionStorageBackend();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
