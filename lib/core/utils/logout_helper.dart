import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/config/end_points.dart';
import 'package:anet_merchants/core/di/injection_container.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/browser_history.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';

class LogoutHelper {
  const LogoutHelper._();

  static Future<void> logout(
    BuildContext context, {
    bool showConfirmation = true,
  }) async {
    if (showConfirmation) {
      final shouldLogout = await _confirmLogout(context);
      if (shouldLogout != true) {
        return;
      }
    }

    final sessionStorage = SessionStorage();
    final bearerToken = await sessionStorage.bearerToken;
    final userName = await sessionStorage.userName;

    if (bearerToken.isNotEmpty) {
      try {
        await sl<Dio>().post<Map<String, dynamic>>(
          '${EndPoints.baseApiPublicNanoUMS}logout',
          data: {'userName': userName},
          options: Options(
            headers: {
              'Authorization': bearerToken.startsWith('Bearer ')
                  ? bearerToken
                  : 'Bearer $bearerToken',
              'Content-Type': 'application/json',
            },
          ),
        );
      } on DioException {
        // Local session must still be cleared when the server token is stale.
      }
    }

    await sessionStorage.clearSession();
    await appLanguageController.resetLanguagePreference();
    setAuthenticatedHistoryGuard(false);

    if (!context.mounted) return;
    NavigationHelper.goToRoot(context, AppRoutes.login);
  }

  static Future<bool?> _confirmLogout(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .52),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: dialogContext.appSurface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: dialogContext.appBorder),
              boxShadow: [
                BoxShadow(
                  color: dialogContext.appShadow,
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.brandRed.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.brandRed,
                      size: 27,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    dialogContext.tr('logout_confirm_title'),
                    style: AppTextStyle.h2.copyWith(
                      color: dialogContext.appTextPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dialogContext.tr('logout_confirm_message'),
                    style: AppTextStyle.h4.copyWith(
                      color: dialogContext.appTextSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: dialogContext.appTextSecondary,
                          minimumSize: const Size(80, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          dialogContext.tr('cancel'),
                          style: AppTextStyle.h4.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandRed,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(112, 46),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: Text(
                          dialogContext.tr('logout'),
                          style: AppTextStyle.h4WhiteColor.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
