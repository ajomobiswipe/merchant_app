import 'package:permission_handler/permission_handler.dart';

class DevicePermission {
  checkPermission() async {
    var statuses = await [
      Permission.location,
      Permission.camera,
      Permission.storage,
      Permission.notification,
    ].request();
    print(statuses);
    // if (statuses[Permission.camera] == PermissionStatus.permanentlyDenied) {
    //   openAppSettings();
    // }
  }
}
