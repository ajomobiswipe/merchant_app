import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:anet_merchants/config/theme/app_theme_controller.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/services/app_update_service.dart';
import 'package:anet_merchants/core/services/device_app_info_service.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/features/auth/auth.dart';
import 'package:anet_merchants/features/shared/shared.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SessionStorage _sessionStorage = SessionStorage();
  late final Future<UserInfoModel?> _userInfoFuture;
  late final Future<DeviceAppInfo> _deviceAppInfoFuture;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = _sessionStorage.userInfo;
    _deviceAppInfoFuture = DeviceAppInfoService().getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserInfoModel?>(
      future: _userInfoFuture,
      builder: (context, snapshot) {
        final userInfo = snapshot.data;

        if (kIsWeb) {
          return _WebProfileLayout(
            userInfo: userInfo,
            infoFuture: _deviceAppInfoFuture,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeHeader(),
              const SizedBox(height: 28),
              _ProfileHeader(userInfo: userInfo),
              const SizedBox(height: 20),
              _InfoSection(userInfo: userInfo),
              const SizedBox(height: 20),
              _DeviceAppDetailsSection(infoFuture: _deviceAppInfoFuture),
              const SizedBox(height: 20),
              const _SettingsSection(),
              const SizedBox(height: 20),
              const _AboutSection(),
            ],
          ),
        );
      },
    );
  }
}

/// Wider, responsive composition for the browser. It keeps the mobile
/// profile widgets and their existing blocs, session data, and actions.
class _WebProfileLayout extends StatelessWidget {
  final UserInfoModel? userInfo;
  final Future<DeviceAppInfo> infoFuture;

  const _WebProfileLayout({
    required this.userInfo,
    required this.infoFuture,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 900;

        return ColoredBox(
          color: const Color(0xffFCFBFF),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              twoColumns ? 32 : 20,
              twoColumns ? 32 : 24,
              twoColumns ? 32 : 20,
              32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.tr('profile'),
                      style: AppTextStyle.h2.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _WebProfileSummary(userInfo: userInfo),
                    const SizedBox(height: 20),
                    _InfoSection(userInfo: userInfo),
                    const SizedBox(height: 20),
                    if (twoColumns)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _DeviceAppDetailsSection(
                              infoFuture: infoFuture,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Expanded(child: _SettingsSection()),
                        ],
                      )
                    else ...[
                      _DeviceAppDetailsSection(infoFuture: infoFuture),
                      const SizedBox(height: 20),
                      const _SettingsSection(),
                    ],
                    const SizedBox(height: 20),
                    const _AboutSection(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WebProfileSummary extends StatelessWidget {
  final UserInfoModel? userInfo;

  const _WebProfileSummary({required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE7E2EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120D0620),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: _ProfileHeader(userInfo: userInfo),
    );
  }
}

class _DeviceAppDetailsSection extends StatelessWidget {
  final Future<DeviceAppInfo> infoFuture;

  const _DeviceAppDetailsSection({required this.infoFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DeviceAppInfo>(
      future: infoFuture,
      builder: (context, snapshot) {
        final info = snapshot.data;
        final unavailableOrLoading = kIsWeb && snapshot.hasError
            ? context.tr('not_available')
            : context.tr('loading');

        return _ProfileCard(
          title: context.tr('device_application'),
          children: [
            _InfoTile(
              icon: Icons.new_releases_rounded,
              label: context.tr('app_version'),
              value: info == null
                  ? unavailableOrLoading
                  : _fallback(info.appVersion, context.tr('not_available')),
            ),
            _InfoTile(
              icon: Icons.system_update_rounded,
              label: context.tr('os_version'),
              value: info == null
                  ? unavailableOrLoading
                  : _fallback(info.osVersion, context.tr('not_available')),
            ),
            _InfoTile(
              icon: Icons.devices_rounded,
              label: context.tr('platform'),
              value: info == null
                  ? unavailableOrLoading
                  : _fallback(info.platform, context.tr('not_available')),
            ),
            _InfoTile(
              icon: Icons.phone_android_rounded,
              label: context.tr('device_model'),
              value: info == null
                  ? unavailableOrLoading
                  : _fallback(info.deviceModel, context.tr('not_available')),
            ),
            if (!kIsWeb) const _CheckForUpdatesTile(showDivider: false),
          ],
        );
      },
    );
  }
}

class _CheckForUpdatesTile extends StatefulWidget {
  final bool showDivider;

  const _CheckForUpdatesTile({
    this.showDivider = true,
  });

  @override
  State<_CheckForUpdatesTile> createState() => _CheckForUpdatesTileState();
}

class _CheckForUpdatesTileState extends State<_CheckForUpdatesTile> {
  final AppUpdateService _updateService = const AppUpdateService();
  bool _checking = false;

  Future<void> _checkForUpdates() async {
    if (_checking) return;

    setState(() => _checking = true);
    final updateInfo = await _updateService.checkForUpdate();
    if (!mounted) return;
    setState(() => _checking = false);

    if (!updateInfo.updateAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('app_up_to_date'))),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: !updateInfo.forceUpdate,
      builder: (context) {
        return AlertDialog(
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
              onPressed: () => _updateService.openUpdate(updateInfo),
              child: Text(context.tr('update')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActionTile(
      icon: Icons.system_update_alt_rounded,
      label: context.tr('check_for_updates'),
      value: _checking
          ? context.tr('loading')
          : context.tr('tap_check_app_updates'),
      onTap: _checkForUpdates,
      showDivider: widget.showDivider,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserInfoModel? userInfo;

  const _ProfileHeader({required this.userInfo});

  @override
  Widget build(BuildContext context) {
    final displayName = _displayName(context);
    final initials = _initials(displayName, userInfo?.shopName ?? '');

    return Column(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: AppColors.primaryPurple,
          child: kIsWeb && initials.isEmpty
              ? const Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 42,
                )
              : Text(
                  initials.isEmpty ? 'AN' : initials,
                  style: AppTextStyle.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
        const SizedBox(height: 14),
        Text(
          displayName,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.h3.copyWith(
            color: context.appTextPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _fallback(userInfo?.email, context.tr('no_email')),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.h4.copyWith(
            color: context.appTextSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _displayName(BuildContext context) {
    final firstName = userInfo?.firstName.trim() ?? '';
    final lastName = userInfo?.lastName.trim() ?? '';
    final fullName =
        [firstName, lastName].where((value) => value.isNotEmpty).join(' ');

    if (fullName.isNotEmpty) {
      return fullName;
    }

    return _fallback(userInfo?.shopName, context.tr('merchant_user'));
  }
}

class _InfoSection extends StatelessWidget {
  final UserInfoModel? userInfo;

  const _InfoSection({required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      title: context.tr('basic_info'),
      children: [
        _InfoTile(
          icon: Icons.storefront_rounded,
          label: context.tr('shop_name'),
          value: _fallback(userInfo?.shopName, context.tr('not_available')),
        ),
        _InfoTile(
          icon: Icons.badge_rounded,
          label: context.tr('merchant_id'),
          value: _fallback(userInfo?.merchantId, context.tr('not_available')),
        ),
        _InfoTile(
          icon: Icons.verified_user_rounded,
          label: context.tr('role'),
          value: _fallback(userInfo?.role, context.tr('not_available')),
        ),
        _InfoTile(
          icon: Icons.phone_android_rounded,
          label: context.tr('device_type'),
          value: _fallback(userInfo?.deviceType, context.tr('not_available')),
          showDivider: false,
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      title: context.tr('app_settings'),
      children: [
        const _LanguageSelector(),
        const SizedBox(height: 14),
        const _ColorSchemeSelector(),
        // Theme (system / light / dark) is native-only. Web, including
        // mobile browsers, always uses the light brand theme.
        if (!kIsWeb)
          AnimatedBuilder(
            animation: appThemeController,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _IconBubble(icon: Icons.palette_rounded),
                        const SizedBox(width: 12),
                        Text(
                          context.tr('theme'),
                          style: AppTextStyle.h4.copyWith(
                            color: context.appTextPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: AppThemePreference.values.map((preference) {
                        return _ThemeChip(
                          label: _themeLabel(context, preference),
                          selected:
                              appThemeController.themePreference == preference,
                          onTap: () =>
                              appThemeController.setThemePreference(preference),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      title: context.tr('about_app'),
      children: [
        _InfoTile(
          icon: Icons.info_rounded,
          label: context.tr('app_name'),
          value: 'ANET Merchants',
        ),
        _InfoTile(
          icon: Icons.payments_rounded,
          label: context.tr('description'),
          value: context.tr('app_description'),
          showDivider: false,
        ),
      ],
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appLanguageController,
      builder: (context, _) {
        return Row(
          children: [
            const _IconBubble(icon: Icons.language_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('app_language'),
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<AppLanguage>(
                      value: appLanguageController.language,
                      isExpanded: true,
                      dropdownColor: context.appSurface,
                      style: AppTextStyle.h4.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      items: AppLanguage.values
                          .map(
                            (language) => DropdownMenuItem<AppLanguage>(
                              value: language,
                              child: Text(languageLabel(language)),
                            ),
                          )
                          .toList(),
                      onChanged: (language) {
                        if (language == null) return;
                        appLanguageController.setLanguage(language);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ColorSchemeSelector extends StatelessWidget {
  const _ColorSchemeSelector();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appColorPaletteController,
      builder: (context, _) {
        return Row(
          children: [
            const _IconBubble(icon: Icons.color_lens_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('color_combination'),
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<AppColorSchemePreference>(
                      value: appColorPaletteController.preference,
                      isExpanded: true,
                      dropdownColor: context.appSurface,
                      style: AppTextStyle.h4.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      items: AppColorSchemePreference.values
                          .map(
                            (preference) =>
                                DropdownMenuItem<AppColorSchemePreference>(
                              value: preference,
                              child: _ColorSchemeOption(
                                palette: palettes[preference]!,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (preference) {
                        if (preference == null) return;
                        appColorPaletteController.setPreference(preference);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ColorSchemeOption extends StatelessWidget {
  final AppColorPalette palette;

  const _ColorSchemeOption({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ColorDot(color: palette.primary),
        const SizedBox(width: 6),
        _ColorDot(color: palette.success),
        const SizedBox(width: 6),
        _ColorDot(color: palette.headline),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            palette.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;

  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: context.appBorder),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appBorder),
        boxShadow: [
          BoxShadow(
            color: context.appShadow,
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.h3.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _IconBubble(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.h4.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: context.appBorder),
          ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool showDivider;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                _IconBubble(icon: icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyle.h5.copyWith(
                          color: context.appTextSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.h4.copyWith(
                          color: context.appTextPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appTextSecondary,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: context.appBorder),
          ),
      ],
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;

  const _IconBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: context.appSurfaceAlt,
      child: Icon(icon, color: AppColors.primaryPurple, size: 24),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPurple : context.appSurfaceAlt,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: AppTextStyle.h5.copyWith(
            color: selected ? Colors.white : context.appTextPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

String _fallback(String? value, String fallback) {
  final normalized = value?.trim() ?? '';
  return normalized.isEmpty ? fallback : normalized;
}

String _initials(String displayName, String shopName) {
  final source = displayName.trim().isEmpty ? shopName : displayName;
  final words = source
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.trim().isNotEmpty)
      .toList();

  if (words.isEmpty) return '';

  if (words.length == 1) {
    return words.first.characters.take(2).toString().toUpperCase();
  }

  return '${words.first.characters.first}${words.last.characters.first}'
      .toUpperCase();
}

String _themeLabel(BuildContext context, AppThemePreference preference) {
  switch (preference) {
    case AppThemePreference.system:
      return context.tr('system');
    case AppThemePreference.light:
      return context.tr('light');
    case AppThemePreference.dark:
      return context.tr('dark');
  }
}
