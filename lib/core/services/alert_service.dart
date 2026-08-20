import 'package:flutter/material.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';

enum AppAlertType { success, warning, error, info }

class AlertService {
  const AlertService._();

  static Future<void> show(
    BuildContext context, {
    required AppAlertType type,
    required String title,
    required String message,
    String? buttonText,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => _AppAlertDialog(
        type: type,
        title: title,
        message: message,
        primaryText: buttonText ?? context.tr('ok'),
      ),
    );
  }

  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return show(
      context,
      type: AppAlertType.success,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  static Future<void> warning(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return show(
      context,
      type: AppAlertType.warning,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return show(
      context,
      type: AppAlertType.error,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  static Future<bool> confirm(
    BuildContext context, {
    AppAlertType type = AppAlertType.warning,
    required String title,
    required String message,
    String? cancelText,
    String? confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _AppAlertDialog(
        type: type,
        title: title,
        message: message,
        secondaryText: cancelText ?? context.tr('cancel'),
        primaryText: confirmText ?? context.tr('continue'),
      ),
    );

    return result ?? false;
  }
}

class _AppAlertDialog extends StatelessWidget {
  final AppAlertType type;
  final String title;
  final String message;
  final String primaryText;
  final String? secondaryText;

  const _AppAlertDialog({
    required this.type,
    required this.title,
    required this.message,
    required this.primaryText,
    this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalInset = screenWidth < 600 ? 16.0 : 40.0;
    final availableWidth = screenWidth - (horizontalInset * 2);
    final dialogWidth = availableWidth > 520.0 ? 520.0 : availableWidth;

    return AlertDialog(
      backgroundColor: context.appSurface,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalInset,
        vertical: 24,
      ),
      constraints: BoxConstraints.tightFor(width: dialogWidth),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: .14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _icon,
              color: accentColor,
              size: 46,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyle.h2.copyWith(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.h4.copyWith(
              color: context.appTextSecondary,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 26),
          Divider(color: context.appBorder),
          const SizedBox(height: 10),
          Row(
            children: [
              if (secondaryText != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.appTextPrimary,
                      side: BorderSide(color: context.appBorder),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      secondaryText!,
                      style: AppTextStyle.h4.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    primaryText,
                    style: AppTextStyle.h4WhiteColor.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _accentColor {
    switch (type) {
      case AppAlertType.success:
        return AppColors.successGreen;
      case AppAlertType.warning:
        return AppColors.brandRed;
      case AppAlertType.error:
        return AppColors.brandRed;
      case AppAlertType.info:
        return AppColors.primaryPurple;
    }
  }

  IconData get _icon {
    switch (type) {
      case AppAlertType.success:
        return Icons.check_circle_outline_rounded;
      case AppAlertType.warning:
        return Icons.warning_amber_rounded;
      case AppAlertType.error:
        return Icons.error_outline_rounded;
      case AppAlertType.info:
        return Icons.info_outline_rounded;
    }
  }
}
