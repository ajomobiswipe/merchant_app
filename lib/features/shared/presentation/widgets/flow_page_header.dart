import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/utils/logout_helper.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';

/// Native pages keep logo, notifications, and logout. Web already has those
/// in [WebMerchantAppBar], so only Back is shown there.
class FlowPageHeader extends StatelessWidget {
  const FlowPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final backButton = IconButton(
      onPressed: () => NavigationHelper.backOrGo(
        context,
        AppRoutes.home,
      ),
      icon:  Icon(defaultTargetPlatform == TargetPlatform.iOS
          ? Icons.arrow_back_ios
          : Icons.arrow_back_rounded,),
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
