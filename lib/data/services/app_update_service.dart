import 'package:anet_merchant_app/data/services/pref_service%20.dart';
import 'package:anet_merchant_app/main.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shimmer/shimmer.dart';

class InAppUpdateService {
  static final InAppUpdateService _instance = InAppUpdateService._internal();
  factory InAppUpdateService() => _instance;
  InAppUpdateService._internal();

  bool _isDialogShown = false;

  /// --------------------------------------------------------------
  /// PUBLIC FUNCTION — CALL THIS AFTER LOGIN OR APP STARTUP
  /// --------------------------------------------------------------
  Future<void> checkForUpdate({bool showNoUpdateDialog = false}) async {
    // in_app_update wraps Google Play's update API and is Android-only.
    // Calling its method channel on iOS or web throws MissingPluginException.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    debugPrint("Checking for app update...");
    final enableUpdate = await PrefService.instance.isUpdateCheckEnabled();
    debugPrint("Update check enabled: $enableUpdate");
    if (!enableUpdate) return;

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (!_isDialogShown) {
          _isDialogShown = true;
          _showUpdateDialog();
        }
      } else {
        if (showNoUpdateDialog) {
          AlertService().success("App is up to date");
        }
      }
    } catch (e) {
      // Optional: Add logging for debugging
      debugPrint("Update check failed: $e");
    }
  }

  /// --------------------------------------------------------------
  /// PERFORM IMMEDIATE UPDATE
  /// --------------------------------------------------------------
  Future<void> _performImmediateUpdate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      debugPrint("Immediate update failed: $e");
    }
  }

  /// --------------------------------------------------------------
  /// SAME UI DESIGN AS NO-INTERNET DIALOG
  /// --------------------------------------------------------------
  void _showUpdateDialog() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.blue.shade300,
                highlightColor: Colors.blue.shade100,
                child: const Icon(
                  Icons.system_update_rounded,
                  size: 60,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              const CustomTextWidget(
                text: 'Update Available',
                fontWeight: FontWeight.w600,
                size: 20,
                color: Colors.black87,
              ),
              const SizedBox(height: 12),
              CustomTextWidget(
                text: 'A new version is available.\nPlease update to continue.',
                textAlign: TextAlign.center,
                size: 16,
                color: Colors.grey.shade700,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  /// CANCEL BUTTON
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        PrefService.instance.disableUpdateCheck();
                        Navigator.pop(context);
                        _isDialogShown = false;
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// UPDATE BUTTON
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _isDialogShown = false;
                        _performImmediateUpdate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Update"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
