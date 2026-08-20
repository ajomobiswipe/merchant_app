import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateInfo {
  final bool updateAvailable;
  final bool forceUpdate;
  final String currentVersion;
  final String latestVersion;
  final String updateUrl;
  final String message;

  const AppUpdateInfo({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.updateUrl,
    required this.message,
  });

  bool get canLaunchUpdate => updateUrl.trim().isNotEmpty;
}

class AppUpdateService {
  const AppUpdateService();

  Future<AppUpdateInfo> checkForUpdate() async {
    // Store update checks are native-only; browsers receive updates when the
    // site is deployed and must not access `dart:io` platform properties.
    if (kIsWeb) {
      return const AppUpdateInfo(
        updateAvailable: false,
        forceUpdate: false,
        currentVersion: 'web',
        latestVersion: 'web',
        updateUrl: '',
        message: 'Your app is up to date.',
      );
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final latestVersion = _platformValue(
      androidKey: 'ANDROID_LATEST_VERSION',
      iosKey: 'IOS_LATEST_VERSION',
    );
    final minimumVersion = _platformValue(
      androidKey: 'ANDROID_MIN_SUPPORTED_VERSION',
      iosKey: 'IOS_MIN_SUPPORTED_VERSION',
    );
    final updateUrl = _platformValue(
      androidKey: 'ANDROID_UPDATE_URL',
      iosKey: 'IOS_UPDATE_URL',
    );

    if (latestVersion.trim().isEmpty) {
      return AppUpdateInfo(
        updateAvailable: false,
        forceUpdate: false,
        currentVersion: currentVersion,
        latestVersion: currentVersion,
        updateUrl: updateUrl,
        message: 'Your app is up to date.',
      );
    }

    final updateAvailable = _compareVersions(currentVersion, latestVersion) < 0;
    final forceUpdate = minimumVersion.trim().isNotEmpty &&
        _compareVersions(currentVersion, minimumVersion) < 0;

    return AppUpdateInfo(
      updateAvailable: updateAvailable,
      forceUpdate: forceUpdate,
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      updateUrl: updateUrl,
      message: updateAvailable
          ? 'A new version is available. Please update the application.'
          : 'Your app is up to date.',
    );
  }

  Future<bool> openUpdate(AppUpdateInfo updateInfo) async {
    if (!updateInfo.canLaunchUpdate) {
      return false;
    }

    final uri = Uri.tryParse(updateInfo.updateUrl);
    if (uri == null) {
      return false;
    }

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _platformValue({
    required String androidKey,
    required String iosKey,
  }) {
    if (Platform.isIOS) {
      return dotenv.maybeGet(iosKey) ?? '';
    }

    return dotenv.maybeGet(androidKey) ?? '';
  }

  int _compareVersions(String current, String latest) {
    final currentParts = _versionParts(current);
    final latestParts = _versionParts(latest);
    final maxLength = currentParts.length > latestParts.length
        ? currentParts.length
        : latestParts.length;

    for (var index = 0; index < maxLength; index++) {
      final currentValue =
          index < currentParts.length ? currentParts[index] : 0;
      final latestValue = index < latestParts.length ? latestParts[index] : 0;

      if (currentValue != latestValue) {
        return currentValue.compareTo(latestValue);
      }
    }

    return 0;
  }

  List<int> _versionParts(String version) {
    return version
        .split('+')
        .first
        .split('.')
        .map((part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')))
        .map((part) => part ?? 0)
        .toList();
  }
}
