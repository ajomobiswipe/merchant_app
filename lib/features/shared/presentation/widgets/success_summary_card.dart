import 'package:flutter/material.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';

class SuccessSummaryCard extends StatelessWidget {
  final int transactionCount;
  final double amount;
  final String? title;

  const SuccessSummaryCard({
    super.key,
    required this.transactionCount,
    required this.amount,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 340;
        final iconSize = isTight ? 38.0 : 46.0;
        final horizontalGap = isTight ? 7.0 : 10.0;
        final primary = AppColors.primaryPurple;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: 112,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: isDark ? .34 : .24),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            isTight ? 10 : 14,
            12,
            isTight ? 10 : 14,
            10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? context.tr('today_success'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.h5WhiteColor.copyWith(
                  fontSize: isTight ? 12 : null,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _SummaryIcon(
                          icon: Icons.account_balance_wallet_outlined,
                          size: iconSize,
                        ),
                        SizedBox(width: horizontalGap),
                        Expanded(
                          child: _SummaryValue(
                            value: transactionCount.toString(),
                            label: context.tr('transactions'),
                            tight: isTight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 42,
                    margin: EdgeInsets.symmetric(horizontal: horizontalGap),
                    color: Colors.white.withValues(alpha: .22),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        _SummaryIcon(
                          icon: Icons.currency_rupee_rounded,
                          size: iconSize,
                        ),
                        SizedBox(width: horizontalGap),
                        Expanded(
                          child: _SummaryValue(
                            value: 'Rs. ${amount.toStringAsFixed(2)}',
                            label: context.tr('amount'),
                            tight: isTight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const _SummaryIcon({
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white, size: size * .56),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String value;
  final String label;
  final bool tight;

  const _SummaryValue({
    required this.value,
    required this.label,
    this.tight = false,
  });

  @override
  Widget build(BuildContext context) {
    const alignment = Alignment.centerLeft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: alignment,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            child: Text(
              value,
              maxLines: 1,
              style: (tight ? AppTextStyle.h3 : AppTextStyle.h2).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Align(
          alignment: alignment,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            child: Text(
              label,
              maxLines: 1,
              style: AppTextStyle.h5WhiteColor.copyWith(
                fontSize: tight ? 11 : null,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
