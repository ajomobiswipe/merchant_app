import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/common/responsive_layout.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/logout_helper.dart';

class CommonScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onBottomNavItemSelected;
  final Widget? bottomAction;
  final bool showDashboard;

  const CommonScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onBottomNavItemSelected,
    this.bottomAction,
    this.showDashboard = true,
  });

  @override
  Widget build(BuildContext context) {
    final isNativeDesktop = AppBreakpoints.isDesktop(context);
    // Browser pages already have a shared app-bar menu. Reserve the side rail
    // for genuinely wide screens so the web content does not fall back to the
    // mobile bottom navigation at intermediate browser widths.
    final useWebSideRail = kIsWeb && MediaQuery.sizeOf(context).width >= 1280;
    final useWebBottomNavigation =
        kIsWeb && MediaQuery.sizeOf(context).width < AppBreakpoints.tablet;
    final useDesktopNavigation = kIsWeb ? useWebSideRail : isNativeDesktop;
    final desktopBody = Row(
      children: [
        _DesktopNavigation(
          selectedIndex: selectedIndex,
          onItemSelected: onBottomNavItemSelected,
          showDashboard: showDashboard,
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMaxWidth,
              ),
              child: Column(
                children: [
                  Expanded(child: body),
                  if (bottomAction != null) bottomAction!,
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: kIsWeb
            ? Column(
                children: [
                  WebMerchantAppBar(
                    onNavigationSelected: onBottomNavItemSelected,
                    showDashboard: showDashboard,
                  ),
                  Expanded(
                    child: useDesktopNavigation ? desktopBody : body,
                  ),
                  if (!useDesktopNavigation && bottomAction != null)
                    bottomAction!,
                  if (useWebBottomNavigation)
                    _CommonBottomNavigation(
                      selectedIndex: selectedIndex,
                      onItemSelected: onBottomNavItemSelected,
                      showDashboard: showDashboard,
                    ),
                ],
              )
            : isNativeDesktop
                ? desktopBody
                : Column(
                    children: [
                      Expanded(child: body),
                      if (bottomAction != null) bottomAction!,
                      _CommonBottomNavigation(
                        selectedIndex: selectedIndex,
                        onItemSelected: onBottomNavItemSelected,
                        showDashboard: showDashboard,
                      ),
                    ],
                  ),
      ),
    );
  }
}

/// Shared browser header for every desktop web tab.
///
/// Merchant and profile information is read from the active authenticated
/// session; no sample account name or notification count is displayed.
class WebMerchantAppBar extends StatefulWidget {
  final ValueChanged<int> onNavigationSelected;
  final bool showDashboard;

  const WebMerchantAppBar({
    super.key,
    required this.onNavigationSelected,
    required this.showDashboard,
  });

  @override
  State<WebMerchantAppBar> createState() => _WebMerchantAppBarState();
}

class _WebMerchantAppBarState extends State<WebMerchantAppBar> {
  String _merchantId = '';
  String _shopName = '';
  String _firstName = '';
  String _lastName = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadSessionIdentity();
  }

  Future<void> _loadSessionIdentity() async {
    final storage = SessionStorage();
    final merchantId = await storage.merchantId;
    final activeMerchantId = await storage.activeAcqMerchantId;
    final shopName = await storage.activeShopName;
    final firstName = await storage.firstName;
    final lastName = await storage.lastName;
    final userName = await storage.userName;

    if (!mounted) return;
    setState(() {
      _merchantId = activeMerchantId.isEmpty || activeMerchantId == '0'
          ? merchantId
          : activeMerchantId;
      _shopName = shopName;
      _firstName = firstName;
      _lastName = lastName;
      _userName = userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        return Container(
          height: compact ? 64 : 72,
          padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 22),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xffE7E2EE))),
          ),
          child: Row(
            children: [
              PopupMenuButton<int>(
                onSelected: widget.onNavigationSelected,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text(context.tr('home')),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Text(context.tr('support')),
                  ),
                  if (widget.showDashboard)
                    PopupMenuItem(
                      value: 2,
                      child: Text(context.tr('dashboard')),
                    ),
                  PopupMenuItem(
                    value: 3,
                    child: Text(context.tr('profile')),
                  ),
                ],
                icon: const Icon(Icons.menu_rounded, size: 27),
              ),
              const SizedBox(width: 14),
              Image.asset(AppAssets.anetLauncherIcon, width: 38, height: 38),
              if (compact) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _MerchantIdentity(
                    shopName: _shopName,
                    merchantId: _merchantId,
                    compact: true,
                  ),
                ),
              ] else ...[
                const SizedBox(width: 9),
                Text(
                  'ANET Merchants',
                  style: AppTextStyle.h3.copyWith(
                    color: const Color(0xff201D27),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                _MerchantIdentity(
                  shopName: _shopName,
                  merchantId: _merchantId,
                ),
                const Spacer(),
              ],
              IconButton(
                onPressed: () => context.push(AppRoutes.notifications),
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: context.tr('notifications'),
              ),
              IconButton(
                onPressed: () => LogoutHelper.logout(context),
                icon: const Icon(Icons.logout_rounded),
                tooltip: context.tr('logout'),
              ),
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xffF0E8FF),
                child: _initials().isEmpty
                    ? Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primaryPurple,
                      )
                    : Text(
                        _initials(),
                        style: AppTextStyle.h4.copyWith(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _initials() {
    final fullName = '$_firstName $_lastName'.trim().isNotEmpty
        ? '$_firstName $_lastName'.trim()
        : _userName.trim();
    return fullName
        .split(RegExp(r'\s+'))
        .where((name) => name.isNotEmpty)
        .take(2)
        .map((name) => name[0])
        .join()
        .toUpperCase();
  }
}

class _MerchantIdentity extends StatelessWidget {
  final String shopName;
  final String merchantId;
  final bool compact;

  const _MerchantIdentity({
    required this.shopName,
    required this.merchantId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: shopName,
            child: Text(
              shopName.isEmpty
                  ? context.tr('merchant_name')
                  : shopName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (compact ? AppTextStyle.h5 : AppTextStyle.h4).copyWith(
                color: const Color(0xff201D27),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            merchantId.isEmpty
                ? '-'
                : '${context.tr('merchant_id')}: $merchantId',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.h5.copyWith(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
}

class _DesktopNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool showDashboard;

  const _DesktopNavigation({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.showDashboard,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _BottomNavData(
          index: 0, icon: Icons.home_rounded, label: context.tr('home')),
      _BottomNavData(
          index: 1,
          icon: Icons.support_agent_rounded,
          label: context.tr('support')),
      if (showDashboard)
        _BottomNavData(
            index: 2,
            icon: Icons.bar_chart_rounded,
            label: context.tr('dashboard')),
      _BottomNavData(
          index: 3, icon: Icons.person_rounded, label: context.tr('profile')),
    ];

    return Container(
      width: 244,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appBackground,
        border: Border(right: BorderSide(color: context.appBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DesktopNavigationItem(
                data: item,
                selected: selectedIndex == item.index,
                onTap: () => onItemSelected(item.index),
              ),
            ),
          const Spacer(),
          WebHelpCard(onContactSupport: () => onItemSelected(1)),
          const SizedBox(height: 16),
          const WebTrademarkFooter(),
        ],
      ),
    );
  }
}

/// Compact help CTA used at the bottom of the web navigation rail.
class WebHelpCard extends StatelessWidget {
  final VoidCallback onContactSupport;

  const WebHelpCard({
    super.key,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffE7DDF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100D0620),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.headset_mic_rounded,
            color: AppColors.primaryPurple,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('need_help'),
            style: AppTextStyle.h4.copyWith(
              color: const Color(0xff201D27),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('support_team_assist'),
            textAlign: TextAlign.center,
            style: AppTextStyle.h5.copyWith(
              color: const Color(0xff6E6880),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onContactSupport,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
                side: const BorderSide(color: Color(0xffD8BEFF)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.tr('contact_support')),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WebTrademarkFooter extends StatelessWidget {
  const WebTrademarkFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '\u00A9 2026 Alliance Network\u2122',
      textAlign: TextAlign.center,
      style: AppTextStyle.h5.copyWith(
        color: const Color(0xff817A91),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _DesktopNavigationItem extends StatelessWidget {
  final _BottomNavData data;
  final bool selected;
  final VoidCallback onTap;

  const _DesktopNavigationItem(
      {required this.data, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: selected
            ? AppColors.primaryPurple.withValues(alpha: .12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                Icon(data.icon,
                    color: selected
                        ? AppColors.primaryPurple
                        : context.appTextSecondary),
                const SizedBox(width: 14),
                Text(data.label,
                    style: AppTextStyle.h4.copyWith(
                        color: selected
                            ? AppColors.primaryPurple
                            : context.appTextPrimary,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      );
}

class _CommonBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool showDashboard;

  const _CommonBottomNavigation({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.showDashboard,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _BottomNavData(
        index: 0,
        icon: Icons.home_rounded,
        label: context.tr('home'),
      ),
      _BottomNavData(
        index: 1,
        icon: Icons.support_agent_rounded,
        label: context.tr('support'),
      ),
      if (showDashboard)
        _BottomNavData(
          index: 2,
          icon: Icons.bar_chart_rounded,
          label: context.tr('dashboard'),
        ),
      _BottomNavData(
        index: 3,
        icon: Icons.person_rounded,
        label: context.tr('profile'),
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: context.appBackground,
        border: Border(top: BorderSide(color: context.appBorder)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 8.0;
          const circleSize = 54.0;
          final totalGap = gap * (items.length - 1);
          final selectedWidth = (constraints.maxWidth -
                  totalGap -
                  (circleSize * (items.length - 1)))
              .clamp(112.0, 152.0);

          return Container(
            height: 64,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color:
                  context.isDarkMode ? const Color(0xff09090D) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: context.appBorder),
              boxShadow: [
                BoxShadow(
                  color: context.appShadow,
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _BottomNavItem(
                    icon: items[i].icon,
                    label: items[i].label,
                    selected: selectedIndex == items[i].index,
                    selectedWidth: selectedWidth.toDouble(),
                    circleSize: circleSize,
                    onTap: () => onItemSelected(items[i].index),
                  ),
                  if (i != items.length - 1) const SizedBox(width: gap),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BottomNavData {
  final int index;
  final IconData icon;
  final String label;

  const _BottomNavData({
    required this.index,
    required this.icon,
    required this.label,
  });
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final double selectedWidth;
  final double circleSize;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedWidth,
    required this.circleSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = selected
        ? Colors.white
        : context.appTextSecondary.withValues(alpha: .9);
    final selectedSurface = AppColors.primaryPurple;
    final unselectedSurface =
        context.isDarkMode ? const Color(0xff181820) : context.appSurfaceAlt;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: selected ? selectedWidth : circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryPurple.withValues(alpha: .14)
                : unselectedSurface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: selected
                  ? AppColors.primaryPurple.withValues(alpha: .20)
                  : context.appBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment:
                selected ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: circleSize - 10,
                height: circleSize - 10,
                margin: selected
                    ? const EdgeInsets.only(left: 5, right: 10)
                    : EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: selected ? selectedSurface : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 27),
              ),
              if (selected)
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.h4.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w900,
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
