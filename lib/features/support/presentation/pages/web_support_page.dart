import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/utils/contact_launcher.dart';
import 'package:anet_merchants/features/support/data/models/support_action_response_model.dart';
import 'package:anet_merchants/features/support/presentation/bloc/support_action/support_action_bloc.dart';

/// Browser-specific Support layout.
///
/// This page deliberately reuses the SupportActionBloc supplied by
/// [SupportPage], so selecting a quick action and raising a request have the
/// exact same behaviour as the mobile screen.
class WebSupportPage extends StatelessWidget {
  final SupportActionModel? selectedAction;
  final ValueChanged<SupportActionModel?> onActionChanged;
  final VoidCallback onRaiseRequest;

  const WebSupportPage({
    super.key,
    required this.selectedAction,
    required this.onActionChanged,
    required this.onRaiseRequest,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xffFCFBFF),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 16 : 26,
                    compact ? 18 : 26,
                    compact ? 16 : 26,
                    30,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1160),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          BlocBuilder<SupportActionBloc, SupportActionState>(
                            builder: (context, state) => _WebQuickActionsCard(
                              actions: state.actions,
                              selectedAction: selectedAction,
                              isLoading: state is SupportActionLoading,
                              onChanged: onActionChanged,
                            ),
                          ),
                          SizedBox(height: compact ? 16 : 18),
                          const _WebHelpBanner(),
                          SizedBox(height: compact ? 16 : 18),
                          BlocBuilder<SupportActionBloc, SupportActionState>(
                            builder: (context, state) => _WebRaiseRequestCard(
                              isSubmitting: state is SupportRequestSubmitting,
                              isEnabled: selectedAction != null,
                              onPressed: onRaiseRequest,
                            ),
                          ),
                          SizedBox(height: compact ? 20 : 24),
                          const _WebContactUsCard(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WebQuickActionsCard extends StatelessWidget {
  final List<SupportActionModel> actions;
  final SupportActionModel? selectedAction;
  final bool isLoading;
  final ValueChanged<SupportActionModel?> onChanged;

  const _WebQuickActionsCard({
    required this.actions,
    required this.selectedAction,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeSelection =
        actions.contains(selectedAction) ? selectedAction : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _webSupportSurface(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('quick_actions'),
            style: AppTextStyle.h4.copyWith(
              color: const Color(0xff171320),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 74,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xffE9E2F0)),
            ),
            child: Row(
              children: [
                _webSupportIcon(Icons.description_outlined),
                const SizedBox(width: 14),
                Expanded(
                  child: isLoading
                      ? Text(
                          context.tr('loading_options'),
                          style: _webSecondaryTextStyle,
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<SupportActionModel>(
                            value: activeSelection,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xff6F16D9),
                            ),
                            hint: Text(
                              context.tr('select_option'),
                              style: _webSecondaryTextStyle,
                            ),
                            selectedItemBuilder: (context) => actions
                                .map(
                                  (action) => Align(
                                    alignment: Alignment.centerLeft,
                                    child: _QuickActionText(
                                      action: action,
                                      primaryOnly: false,
                                    ),
                                  ),
                                )
                                .toList(),
                            items: actions
                                .map(
                                  (action) => DropdownMenuItem(
                                    value: action,
                                    child: _QuickActionText(
                                      action: action,
                                      primaryOnly: true,
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
}

class _QuickActionText extends StatelessWidget {
  final SupportActionModel action;
  final bool primaryOnly;

  const _QuickActionText({
    required this.action,
    required this.primaryOnly,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = _quickActionSubtitle(context, action);
    if (primaryOnly || subtitle == null) {
      return Text(
        action.quickActionMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.h5.copyWith(
          color: const Color(0xff1A1622),
          fontWeight: FontWeight.w800,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          action.quickActionMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.h5.copyWith(
            color: const Color(0xff1A1622),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(subtitle, style: _webSecondaryTextStyle),
      ],
    );
  }

  String? _quickActionSubtitle(BuildContext context, SupportActionModel action) {
    if (action.quickActionStatus.trim().isNotEmpty) {
      return action.quickActionStatus;
    }

    if (action.quickActionMessage.toLowerCase().contains('paper roll')) {
      return context.tr('request_paper_roll');
    }

    return context.tr('submit_support_request');
  }
}

class _WebHelpBanner extends StatelessWidget {
  const _WebHelpBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 118),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: _webSupportSurface(),
      child: Row(
        children: [
          _webSupportIcon(Icons.headset_mic_rounded, size: 34),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('here_to_help'),
                  style: AppTextStyle.h4.copyWith(
                    color: const Color(0xff171320),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('raise_concern').replaceAll('\n', ' '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _webSecondaryTextStyle.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          const _SupportChatArtwork(),
        ],
      ),
    );
  }
}

class _SupportChatArtwork extends StatelessWidget {
  const _SupportChatArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            top: 23,
            child: _bubble(const Color(0xffE5D8FF), 50, 33),
          ),
          Positioned(
            left: 7,
            top: 10,
            child: _bubble(AppColors.primaryPurple, 62, 42),
          ),
          const Positioned(
            left: 18,
            top: 22,
            child: Row(
              children: [
                _ChatDot(),
                SizedBox(width: 6),
                _ChatDot(),
                SizedBox(width: 6),
                _ChatDot(),
              ],
            ),
          ),
          Positioned(
            right: 6,
            top: 0,
            child: Icon(
              Icons.auto_awesome,
              size: 14,
              color: AppColors.primaryPurple.withValues(alpha: .65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(Color color, double width, double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      );
}

class _ChatDot extends StatelessWidget {
  const _ChatDot();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: SizedBox(width: 6, height: 6),
      );
}

class _WebRaiseRequestCard extends StatelessWidget {
  final bool isSubmitting;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _WebRaiseRequestCard({
    required this.isSubmitting,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && !isSubmitting;
    final primary = AppColors.primaryPurple;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      enabled: enabled,
      label: context.tr('raise_request'),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(11),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 80),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: enabled
                    ? primary
                    : primary.withValues(alpha: isDark ? .46 : .45),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: isDark ? .32 : .22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_square,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSubmitting
                              ? context.tr('raising_request')
                              : context.tr('raise_request'),
                          style: AppTextStyle.h4WhiteColor.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('submit_new_support_request'),
                          style: AppTextStyle.h5.copyWith(
                            color: Colors.white.withValues(alpha: .88),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSubmitting)
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  else
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 34,
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

class _WebContactUsCard extends StatelessWidget {
  const _WebContactUsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: _webSupportSurface(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('contact_us').replaceAll(':', ''),
            style: AppTextStyle.h4.copyWith(
              color: const Color(0xff171320),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xffE9E2F0)),
          const _WebContactRow(
            icon: Icons.call_rounded,
            text: '+911203129301',
            type: _WebContactType.phone,
          ),
          const Divider(height: 1, color: Color(0xffE9E2F0)),
          const _WebContactRow(
            icon: Icons.mail_outline_rounded,
            text: 'customer.support@alliancenetworkglobal.com',
            type: _WebContactType.email,
          ),
        ],
      ),
    );
  }
}

class _WebContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final _WebContactType type;

  const _WebContactRow({
    required this.icon,
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchContact(context),
      borderRadius: BorderRadius.circular(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 70),
        child: Row(
          children: [
            _webSupportIcon(icon, size: 28),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.h5.copyWith(
                  color: const Color(0xff25202F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xff514C60),
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchContact(BuildContext context) async {
    final launched = type == _WebContactType.phone
        ? await ContactLauncher.callPhone(text)
        : await ContactLauncher.sendEmail(text);

    if (!context.mounted || launched) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('open_contact_failed'))),
    );
  }
}

enum _WebContactType { phone, email }

Widget _webSupportIcon(IconData icon, {double size = 28}) => Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xffF3EBFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primaryPurple, size: size),
    );

final TextStyle _webSecondaryTextStyle = AppTextStyle.h5.copyWith(
  color: const Color(0xff6E6880),
  fontWeight: FontWeight.w600,
);

BoxDecoration _webSupportSurface() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xffE9E2F0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A171023),
          blurRadius: 16,
          offset: Offset(0, 5),
        ),
      ],
    );
