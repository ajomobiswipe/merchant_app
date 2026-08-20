import 'package:flutter/material.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';

class QuickActions extends StatelessWidget {
  final TransactionTab selectedTab;
  final ValueChanged<TransactionTab> onTabSelected;

  const QuickActions({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            label: context.tr('pos_txns_history'),
            compactLabel: context.tr('pos_txns_compact'),
            icon: Icons.credit_card_rounded,
            selected: selectedTab == TransactionTab.pos,
            onPressed: () => onTabSelected(TransactionTab.pos),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            label: context.tr('qr_txns_history'),
            compactLabel: context.tr('qr_txns_compact'),
            icon: Icons.qr_code_2_rounded,
            selected: selectedTab == TransactionTab.qr,
            onPressed: () => onTabSelected(TransactionTab.qr),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            label: context.tr('settlements'),
            compactLabel: context.tr('settlements_compact'),
            icon: Icons.currency_rupee_rounded,
            selected: selectedTab == TransactionTab.settlements,
            onPressed: () => onTabSelected(TransactionTab.settlements),
          ),
        ),
      ],
    );
  }
}

enum TransactionTab {
  pos,
  qr,
  settlements;

  String get title {
    switch (this) {
      case TransactionTab.pos:
        return 'POS transactions';
      case TransactionTab.qr:
        return 'QR transactions';
      case TransactionTab.settlements:
        return 'Settlements';
    }
  }

  String localizedTitle(BuildContext context) {
    switch (this) {
      case TransactionTab.pos:
        return context.tr('pos_txns_history');
      case TransactionTab.qr:
        return context.tr('qr_txns_history');
      case TransactionTab.settlements:
        return context.tr('settlements');
    }
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final String compactLabel;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.label,
    required this.compactLabel,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.primaryPurple;
    final background =
        selected ? AppColors.successGreen : context.appSurfaceAlt;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 118;
        final displayLabel = isCompact ? compactLabel : label;
        final iconBoxSize = isCompact ? 28.0 : 32.0;
        final iconSize = isCompact ? 18.0 : 21.0;
        final chevronSize = isCompact ? 17.0 : 21.0;

        return Material(
          color: background,
          borderRadius: BorderRadius.circular(14),
          elevation: selected ? 2 : 0,
          shadowColor: context.appShadow,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: isCompact ? 58 : 66,
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 6 : 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : AppColors.primaryPurple.withValues(alpha: .12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: iconBoxSize,
                    height: iconBoxSize,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: .18)
                          : AppColors.primaryPurple.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, color: foreground, size: iconSize),
                  ),
                  SizedBox(width: isCompact ? 5 : 8),
                  Expanded(
                    child: Text(
                      displayLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.h5.copyWith(
                        color: selected ? Colors.white : context.appTextPrimary,
                        fontSize: isCompact ? 11 : null,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: foreground,
                    size: chevronSize,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
