import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class DevicePermission {
  Future<void> checkPermission() async {
    final permissions = <Permission>[
      Permission.location,
      Permission.camera,
      Permission.notification,
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        Permission.storage,
    ];

    final statuses = await permissions.request();
    if (kDebugMode) debugPrint('$statuses');
    if (statuses[Permission.camera] == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
  }
}
