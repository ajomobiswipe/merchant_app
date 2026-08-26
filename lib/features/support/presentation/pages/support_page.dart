import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/services/alert_service.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/contact_launcher.dart';
import 'package:anet_merchants/features/support/data/models/support_action_response_model.dart';
import 'package:anet_merchants/features/support/presentation/bloc/support_action/support_action_bloc.dart';
import 'package:anet_merchants/features/shared/presentation/widgets/home_header.dart';
import 'package:anet_merchants/features/support/presentation/pages/web_support_page.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final SessionStorage _sessionStorage = SessionStorage();

  SupportActionModel? _selectedAction;
  String _bearerToken = '';
  String _merchantId = '';
  bool _isSupportRequestPending = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    final bearerToken = await _sessionStorage.bearerToken;
    final merchantId = await _sessionStorage.merchantId;

    if (!mounted) return;

    setState(() {
      _bearerToken = bearerToken;
      _merchantId = merchantId;
    });

    _loadSupportActions();
  }

  void _loadSupportActions() {
    if (_bearerToken.isEmpty) {
      return;
    }

    context.read<SupportActionBloc>().add(
          GetSupportActionDataRequested(bearerToken: _bearerToken),
        );
  }

  void _raiseSupportRequest() {
    final selectedAction = _selectedAction;

    if (_bearerToken.isEmpty || _merchantId.isEmpty || selectedAction == null) {
      return;
    }

    setState(() {
      _isSupportRequestPending = true;
    });

    context.read<SupportActionBloc>().add(
          RaiseSupportRequestSubmitted(
            bearerToken: _bearerToken,
            merchantId: _merchantId,
            quickActionMessage: selectedAction.quickActionMessage,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupportActionBloc, SupportActionState>(
      listener: (context, state) async {
        if (state is SupportActionSuccess &&
            state.actions.isNotEmpty &&
            _selectedAction == null) {
          setState(() {
            _selectedAction = state.actions.first;
          });
        }

        if (state is SupportRequestSuccess) {
          if (mounted) {
            setState(() {
              _isSupportRequestPending = false;
            });
          }

          final message = state.raiseSupportResponse?.message.isNotEmpty == true
              ? state.raiseSupportResponse!.message
              : context.tr('support_request_success');

          await AlertService.success(
            context,
            title: context.tr('success'),
            message: message,
          );
          return;
        }

        if (state is SupportActionFailure) {
          if (_isSupportRequestPending) {
            if (mounted) {
              setState(() {
                _isSupportRequestPending = false;
              });
            }

            await AlertService.error(
              context,
              title: context.tr('error'),
              message:
                  state.error?.message ?? context.tr('support_request_failed'),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${context.tr('support_request_failed')}: ${state.error?.message ?? context.tr('unknown_error')}',
              ),
            ),
          );
        }
      },
      child: kIsWeb
          ? WebSupportPage(
              selectedAction: _selectedAction,
              onActionChanged: (action) {
                setState(() {
                  _selectedAction = action;
                });
              },
              onRaiseRequest: _raiseSupportRequest,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeHeader(),
                  const SizedBox(height: 32),
                  const _SupportHero(),
                  const SizedBox(height: 24),
                  BlocBuilder<SupportActionBloc, SupportActionState>(
                    builder: (context, state) {
                      return _QuickActionsCard(
                        actions: state.actions,
                        selectedAction: _selectedAction,
                        isLoading: state is SupportActionLoading,
                        onChanged: (action) {
                          setState(() {
                            _selectedAction = action;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const _HelpDeskCard(),
                  const SizedBox(height: 20),
                  BlocBuilder<SupportActionBloc, SupportActionState>(
                    builder: (context, state) {
                      return _RaiseRequestButton(
                        selectedAction: _selectedAction,
                        isSubmitting: state is SupportRequestSubmitting,
                        onPressed: _raiseSupportRequest,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const _ContactUsCard(),
                ],
              ),
            ),
    );
  }
}

class _SupportHero extends StatefulWidget {
  const _SupportHero();

  @override
  State<_SupportHero> createState() => _SupportHeroState();
}

class _SupportHeroState extends State<_SupportHero> {
  String _shopName = '';

  @override
  void initState() {
    super.initState();
    _loadShopName();
  }

  Future<void> _loadShopName() async {
    final shopName = await SessionStorage().shopName;

    if (!mounted) return;

    setState(() {
      _shopName = shopName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _shopName.trim().isEmpty
        ? context.tr('merchant_name')
        : _shopName.toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _AllianceLogo(),
              const SizedBox(height: 20),
              Text(
                displayName,
                style: AppTextStyle.h3.copyWith(
                  color: context.appTextPrimary,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _SupportIllustration(),
      ],
    );
  }
}

class _AllianceLogo extends StatelessWidget {
  const _AllianceLogo();

  @override
  Widget build(BuildContext context) {
    if (context.isDarkMode) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.anetLauncherIcon,
            width: 76,
            height: 58,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alliance',
                style: AppTextStyle.h2.copyWith(
                  color: context.appTextPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Network',
                style: AppTextStyle.h4.copyWith(
                  color: context.appTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Image.asset(
      AppAssets.anetLogoForBrightness(Theme.of(context).brightness),
      width: 190,
      fit: BoxFit.contain,
    );
  }
}

class _SupportIllustration extends StatelessWidget {
  const _SupportIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      height: 116,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 108,
            height: 98,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(42),
            ),
          ),
          Icon(
            Icons.support_agent_rounded,
            color: AppColors.primaryPurple,
            size: 78,
          ),
          Positioned(
            right: 6,
            top: 16,
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.primaryPurple,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final List<SupportActionModel> actions;
  final SupportActionModel? selectedAction;
  final bool isLoading;
  final ValueChanged<SupportActionModel?> onChanged;

  const _QuickActionsCard({
    required this.actions,
    required this.selectedAction,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xffF0E7FF),
                child: Icon(
                  Icons.flash_on_rounded,
                  color: AppColors.primaryPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('quick_actions'),
                style: AppTextStyle.h3.copyWith(
                  color: context.appTextPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: context.appSurfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.primaryPurple,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isLoading
                      ? Text(
                          context.tr('loading_options'),
                          style: _dropdownTextStyle(context),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<SupportActionModel>(
                            value: actions.contains(selectedAction)
                                ? selectedAction
                                : null,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primaryPurple,
                              size: 34,
                            ),
                            hint: Text(
                              context.tr('select_option'),
                              style: _dropdownTextStyle(context),
                            ),
                            items: actions
                                .map(
                                  (action) => DropdownMenuItem(
                                    value: action,
                                    child: Text(
                                      action.quickActionMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _dropdownTextStyle(context),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: actions.isEmpty ? null : onChanged,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _dropdownTextStyle(BuildContext context) {
    return AppTextStyle.h4.copyWith(
      color: context.appTextPrimary,
      fontWeight: FontWeight.w600,
    );
  }
}

class _HelpDeskCard extends StatelessWidget {
  const _HelpDeskCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Column(
            children: [
              Icon(
                Icons.headset_mic_rounded,
                color: AppColors.primaryPurple,
                size: 34,
              ),
              Text(
                context.tr('help_desk'),
                textAlign: TextAlign.center,
                style: AppTextStyle.h3.copyWith(
                  color: context.appTextPrimary,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Container(
            width: 1,
            height: 76,
            color: AppColors.primaryPurple.withValues(alpha: .22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('here_to_help'),
                  style: AppTextStyle.h3.copyWith(
                    color: context.appTextPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.tr('raise_concern'),
                  style: AppTextStyle.h4.copyWith(
                    color: context.appTextSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chat_bubble_rounded,
            color: AppColors.primaryPurple,
            size: 48,
          ),
        ],
      ),
    );
  }
}

class _RaiseRequestButton extends StatelessWidget {
  final SupportActionModel? selectedAction;
  final bool isSubmitting;
  final VoidCallback onPressed;

  const _RaiseRequestButton({
    required this.selectedAction,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryPurple;

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: selectedAction == null || isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: primary.withValues(alpha: .45),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primary.withValues(alpha: .25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.edit_square, size: 30),
            const Spacer(),
            Text(
              isSubmitting
                  ? context.tr('raising_request')
                  : context.tr('raise_request'),
              style: AppTextStyle.h4WhiteColor.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_rounded, size: 30),
          ],
        ),
      ),
    );
  }
}

class _ContactUsCard extends StatelessWidget {
  const _ContactUsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('contact_us'),
            style: AppTextStyle.h4.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          const _ContactRow(
            icon: Icons.call_rounded,
            text: '+911203129301',
            type: _ContactType.phone,
          ),
          Divider(color: context.appBorder, height: 1),
          const _ContactRow(
            icon: Icons.mail_outline_rounded,
            text: 'customer.support@alliancenetworkglobal.com',
            type: _ContactType.email,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final _ContactType type;

  const _ContactRow({
    required this.icon,
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchContact(context),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 70,
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primaryPurple.withValues(alpha: .08),
              child: Icon(icon, color: AppColors.primaryPurple, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.h4.copyWith(
                  color: context.appTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: context.appIconColor, size: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _launchContact(BuildContext context) async {
    final launched = type == _ContactType.phone
        ? await ContactLauncher.callPhone(text)
        : await ContactLauncher.sendEmail(text);

    if (!context.mounted || launched) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('open_contact_failed'))),
    );
  }
}

enum _ContactType { phone, email }

BoxDecoration _cardDecoration(BuildContext context) {
  return BoxDecoration(
    color: context.appSurface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: context.appBorder),
    boxShadow: [
      BoxShadow(
        color: context.appShadow,
        blurRadius: 22,
        offset: const Offset(0, 10),
      ),
    ],
  );
}
