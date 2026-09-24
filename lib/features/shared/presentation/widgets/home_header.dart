import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/utils/logout_helper.dart';

class HomeHeader extends StatelessWidget {
  final ValueChanged<int> onNavigationSelected;
  final bool showDashboard;

  const HomeHeader({
    super.key,
    required this.onNavigationSelected,
    this.showDashboard = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupMenuButton<int>(
          onSelected: onNavigationSelected,
          offset: const Offset(0, 42),
          itemBuilder: (context) => [
            PopupMenuItem(value: 0, child: Text(context.tr('home'))),
            PopupMenuItem(value: 1, child: Text(context.tr('support'))),
            if (showDashboard)
              PopupMenuItem(value: 2, child: Text(context.tr('dashboard'))),
            PopupMenuItem(value: 3, child: Text(context.tr('profile'))),
          ],
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.appSurface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: context.appShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(color: context.appBorder),
            ),
            child: Icon(
              Icons.menu_rounded,
              color: context.appIconColor,
              size: 24,
            ),
          ),
        ),
        const Spacer(),
        const _AntenLogo(),
        const Spacer(),
        IconButton(
          onPressed: () => context.push(AppRoutes.notifications),
          icon: const Icon(Icons.notifications_none_rounded),
          color: context.appIconColor,
          iconSize: 28,
          tooltip: context.tr('notifications'),
        ),
        IconButton(
          onPressed: () => LogoutHelper.logout(context),
          icon: const Icon(Icons.logout_rounded),
          color: context.appIconColor,
          iconSize: 28,
          tooltip: context.tr('logout'),
        ),
      ],
    );
  }
}

class _AntenLogo extends StatelessWidget {
  const _AntenLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.anetLauncherIcon,
      width: 46,
      height: 40,
      fit: BoxFit.contain,
    );
  }
}
