import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class InAppUpdateScreen extends StatefulWidget {
  const InAppUpdateScreen({super.key});

  @override
  State<InAppUpdateScreen> createState() => _InAppUpdateScreenState();
}

class _InAppUpdateScreenState extends State<InAppUpdateScreen> {
  AppUpdateInfo? _updateInfo;
  bool _flexibleUpdateAvailable = false;
  StreamSubscription<InstallStatus>? _subscription;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  void showSnack(String text) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      setState(() {
        _updateInfo = info;
      });
      showSnack("Checked for updates successfully");
    } catch (e) {
      showSnack("Error: $e");

      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> performImmediateUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      showSnack("Immediate update failed: $e");
    }
  }

  Future<void> startFlexibleUpdate() async {
    try {
      await InAppUpdate.startFlexibleUpdate();

      InAppUpdate.installUpdateListener.listen((status) {
        if (status == InstallStatus.downloaded) {
          // Flexible update is ready
        }
      });

      // Listen for update status changes
      _subscription = InAppUpdate.installUpdateListener.listen((status) {
        debugPrint("Update status: $status");

        if (status == InstallStatus.downloaded) {
          setState(() {
            _flexibleUpdateAvailable = true;
          });
          showSnack("Update downloaded! Ready to install.");
        }
      });
    } catch (e) {
      showSnack("Flexible update failed: $e");
    }
  }

  Future<void> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
      showSnack("Flexible update completed. App will restart.");
    } catch (e) {
      showSnack("Complete flexible update failed: $e");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(title: const Text("In-App Update Tester")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _updateInfo == null
                    ? "No update info yet"
                    : "Update availability: ${_updateInfo?.updateAvailability}\n"
                        "Available version code: ${_updateInfo?.availableVersionCode}",
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: checkForUpdate,
                child: const Text("Check for Update"),
              ),
              ElevatedButton(
                onPressed: _updateInfo?.updateAvailability ==
                        UpdateAvailability.updateAvailable
                    ? performImmediateUpdate
                    : null,
                child: const Text("Perform Immediate Update"),
              ),
              ElevatedButton(
                onPressed: _updateInfo?.updateAvailability ==
                        UpdateAvailability.updateAvailable
                    ? startFlexibleUpdate
                    : null,
                child: const Text("Start Flexible Update"),
              ),
              ElevatedButton(
                onPressed:
                    _flexibleUpdateAvailable ? completeFlexibleUpdate : null,
                child: const Text("Complete Flexible Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
