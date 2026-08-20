import 'package:flutter/material.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/services/app_update_service.dart';

class AppUpdateGate extends StatefulWidget {
  final Widget child;

  const AppUpdateGate({
    super.key,
    required this.child,
  });

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate> {
  final AppUpdateService _updateService = const AppUpdateService();
  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_checked) {
      return;
    }

    _checked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    if (!mounted) return;

    final updateInfo = await _updateService.checkForUpdate();
    if (!mounted || !updateInfo.updateAvailable) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: !updateInfo.forceUpdate,
      builder: (context) {
        return PopScope(
          canPop: !updateInfo.forceUpdate,
          child: AlertDialog(
            title: Text(
              updateInfo.forceUpdate
                  ? context.tr('update_required')
                  : context.tr('update_available'),
            ),
            content: Text(
              '${context.tr('app_update_message')}\n\n'
              '${context.tr('current_version')}: ${updateInfo.currentVersion}\n'
              '${context.tr('latest_version')}: ${updateInfo.latestVersion}',
            ),
            actions: [
              if (!updateInfo.forceUpdate)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.tr('later')),
                ),
              ElevatedButton(
                onPressed: () async {
                  final opened = await _updateService.openUpdate(updateInfo);
                  if (!context.mounted) return;
                  if (!opened) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('could_not_open_update_link')),
                      ),
                    );
                    return;
                  }
                  if (!updateInfo.forceUpdate) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                ),
                child: Text(context.tr('update')),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
