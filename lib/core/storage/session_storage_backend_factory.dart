import 'session_storage_backend.dart';
import 'session_storage_backend_native.dart'
    if (dart.library.js_interop) 'session_storage_backend_web.dart' as platform;

SessionStorageBackend createSessionStorageBackend() =>
    platform.createSessionStorageBackend();
