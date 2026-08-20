import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceAppInfo {
  final String appVersion;
  final String osVersion;
  final String platform;
  final String deviceModel;

  const DeviceAppInfo({
    required this.appVersion,
    required this.osVersion,
    required this.platform,
    required this.deviceModel,
  });
}

class DeviceAppInfoService {
  final DeviceInfoPlugin _deviceInfoPlugin;

  DeviceAppInfoService({
    DeviceInfoPlugin? deviceInfoPlugin,
  }) : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  Future<DeviceAppInfo> getInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();

    // The browser does not expose a native device model or operating-system
    // service. Query the web plugin before touching [Platform], which is not
    // supported by Flutter web and previously left the Profile card loading.
    if (kIsWeb) {
      final webInfo = await _deviceInfoPlugin.webBrowserInfo;
      return DeviceAppInfo(
        appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
        osVersion: webInfo.platform ?? '',
        platform: webInfo.appName ?? '',
        deviceModel: webInfo.userAgent ?? '',
      );
    }

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      return DeviceAppInfo(
        appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
        osVersion: 'Android ${androidInfo.version.release}',
        platform: 'Android',
        deviceModel: '${androidInfo.manufacturer} ${androidInfo.model}'.trim(),
      );
    }

    if (Platform.isIOS) {
      final iosInfo = await _deviceInfoPlugin.iosInfo;
      return DeviceAppInfo(
        appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
        osVersion: 'iOS ${iosInfo.systemVersion}',
        platform: 'iOS',
        deviceModel: iosInfo.utsname.machine,
      );
    }

    return DeviceAppInfo(
      appVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
      osVersion: Platform.operatingSystemVersion,
      platform: Platform.operatingSystem,
      deviceModel: Platform.localHostname,
    );
  }
}
