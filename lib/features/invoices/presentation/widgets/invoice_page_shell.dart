import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/utils/logout_helper.dart';

/// Keeps the existing mobile receipt presentation while giving browser
/// invoices a readable, print-like surface instead of stretching the receipt
/// across the entire desktop content area.
class InvoicePageShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry mobilePadding;

  const InvoicePageShell({
    super.key,
    required this.child,
    required this.mobilePadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideWebLayout = kIsWeb && constraints.maxWidth >= 720;
        final content = Padding(
          padding: isWideWebLayout
              ? const EdgeInsets.fromLTRB(42, 34, 42, 42)
              : mobilePadding,
          child: child,
        );

        return DecoratedBox(
          decoration: BoxDecoration(
            color: isWideWebLayout ? const Color(0xffFCFBFF) : null,
          ),
          child: SingleChildScrollView(
            padding: isWideWebLayout
                ? const EdgeInsets.fromLTRB(28, 32, 28, 42)
                : EdgeInsets.zero,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWideWebLayout ? 760 : double.infinity,
                ),
                child: DecoratedBox(
                  decoration: isWideWebLayout
                      ? BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xffE7E2EE)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0C171023),
                              blurRadius: 18,
                              offset: Offset(0, 6),
                            ),
                          ],
                        )
                      : const BoxDecoration(),
                  child: content,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Aligns an invoice action with the receipt on desktop while leaving the
/// mobile action bar at its current full-width size.
class InvoiceDownloadAction extends StatelessWidget {
  final Widget child;

  const InvoiceDownloadAction({super.key, required this.child});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  kIsWeb && constraints.maxWidth >= 720 ? 760 : double.infinity,
            ),
            child: child,
          ),
        ),
      );
}

/// The shared web scaffold already owns app branding, notifications, and
/// logout. Invoice screens only need their flow-specific Back action on web;
/// native receipts retain their existing standalone header.
class InvoiceNavigationHeader extends StatelessWidget {
  final VoidCallback onBack;

  const InvoiceNavigationHeader({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final backButton = IconButton(
      onPressed: onBack,
      icon: const Icon(Icons.arrow_back_rounded),
      color: context.appTextPrimary,
      iconSize: 32,
      tooltip: context.tr('back'),
    );

    if (kIsWeb) {
      return Align(alignment: Alignment.centerLeft, child: backButton);
    }

    return Row(
      children: [
        backButton,
        const Spacer(),
        Image.asset(
          AppAssets.anetLauncherIcon,
          width: 42,
          height: 36,
          fit: BoxFit.contain,
        ),
        const Spacer(),
        IconButton(
          onPressed: () => context.push(AppRoutes.notifications),
          icon: const Icon(Icons.notifications_none_rounded),
          color: context.appIconColor,
          iconSize: 32,
          tooltip: context.tr('notifications'),
        ),
        IconButton(
          onPressed: () => LogoutHelper.logout(context),
          icon: const Icon(Icons.logout_rounded),
          color: context.appIconColor,
          iconSize: 32,
          tooltip: context.tr('logout'),
        ),
      ],
    );
  }
}
