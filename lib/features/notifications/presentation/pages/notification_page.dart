import 'package:flutter/material.dart';

import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/utils/logout_helper.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => NavigationHelper.backOrGo(
                      context,
                      AppRoutes.home,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: context.appIconColor,
                    iconSize: 32,
                    tooltip: context.tr('back'),
                  ),
                  const Spacer(),
                  Image.asset(
                    AppAssets.anetLauncherIcon,
                    width: 52,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => LogoutHelper.logout(context),
                    icon: const Icon(Icons.logout_rounded),
                    color: context.appIconColor,
                    iconSize: 32,
                    tooltip: context.tr('logout'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                context.tr('notifications'),
                style: AppTextStyle.h2.copyWith(
                  color: context.appTextPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: context.appSurfaceAlt,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.appBorder),
                        ),
                        child: Icon(
                          Icons.notifications_off_outlined,
                          size: 42,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.tr('no_notifications'),
                        style: AppTextStyle.h3.copyWith(
                          color: context.appTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('no_notifications_message'),
                        style: AppTextStyle.h4.copyWith(
                          color: context.appTextSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
