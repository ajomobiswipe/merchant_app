import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/logout_helper.dart';
import 'package:anet_merchants/features/shared/shared.dart';
import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:anet_merchants/features/transactions/data/models/pos_txn_history_response_model.dart';

class MobileHomeGreeting extends StatefulWidget {
  final VoidCallback onProfileTap;

  const MobileHomeGreeting({super.key, required this.onProfileTap});

  @override
  State<MobileHomeGreeting> createState() => _MobileHomeGreetingState();
}

class _MobileHomeGreetingState extends State<MobileHomeGreeting> {
  String _shopName = '';

  @override
  void initState() {
    super.initState();
    _loadShopName();
  }

  Future<void> _loadShopName() async {
    final shopName = await SessionStorage().activeShopName;
    if (!mounted) return;
    setState(() => _shopName = shopName);
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? context.tr('good_morning')
        : hour < 17
            ? context.tr('good_afternoon')
            : context.tr('good_evening');
    final shop = _shopName.trim().isEmpty
        ? context.tr('merchant_name')
        : _shopName;
    final initials = _initials(shop);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTextStyle.h5.copyWith(
                  color: context.appTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: shop,
                      style: AppTextStyle.h2.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const TextSpan(text: ' 👋'),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('home_summary_subtitle'),
                style: AppTextStyle.h5.copyWith(
                  color: context.appTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _RoundIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: context.tr('notifications'),
          onTap: () => context.push(AppRoutes.notifications),
        ),
        const SizedBox(width: 8),
        _RoundIconButton(
          icon: Icons.logout_rounded,
          tooltip: context.tr('logout'),
          onTap: () => LogoutHelper.logout(context),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: context.tr('profile'),
          child: InkWell(
            onTap: widget.onProfileTap,
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: context.appElevatedSurface,
              child: Text(
                initials,
                style: AppTextStyle.h4.copyWith(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MobileHomeHeroCard extends StatelessWidget {
  final String title;
  final int transactionCount;
  final double amount;

  const MobileHomeHeroCard({
    super.key,
    required this.title,
    required this.transactionCount,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryPurple;
    final scale = _homeScale(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(primary, Colors.white, .12) ?? primary,
            primary,
            Color.lerp(primary, const Color(0xFF4C1D95), .18) ?? primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .28),
            blurRadius: 14 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        12 * scale,
        14 * scale,
        12 * scale,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: _HeroBars(scale: scale * .72),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    color: Colors.white.withValues(alpha: .92),
                    size: 16 * scale,
                  ),
                  SizedBox(width: 6 * scale),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.h5WhiteColor.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12 * scale,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * scale),
              Text(
                '₹ ${amount.toStringAsFixed(2)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Muli',
                  fontSize: 28 * scale,
                  height: 1.1,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                '$transactionCount ${context.tr('transactions')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.h5WhiteColor.copyWith(
                  color: Colors.white.withValues(alpha: .86),
                  fontWeight: FontWeight.w700,
                  fontSize: 12 * scale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MobileHomeChannelTiles extends StatelessWidget {
  final TransactionTab selectedTab;
  final int posCount;
  final int qrCount;
  final int settlementCount;
  final bool enableQrAndSettlements;
  final ValueChanged<TransactionTab> onSelected;
  final ValueChanged<TransactionTab> onViewAll;

  const MobileHomeChannelTiles({
    super.key,
    required this.selectedTab,
    required this.posCount,
    required this.qrCount,
    required this.settlementCount,
    required this.enableQrAndSettlements,
    required this.onSelected,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final gap = (8 * _homeScale(context)).clamp(6.0, 12.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ChannelTile(
            icon: Icons.credit_card_rounded,
            label: context.tr('pos_transactions'),
            count: posCount,
            selected: selectedTab == TransactionTab.pos,
            iconColor: AppColors.primaryPurple,
            onTap: () => onSelected(TransactionTab.pos),
            onViewAll: () => onViewAll(TransactionTab.pos),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _ChannelTile(
            icon: Icons.qr_code_2_rounded,
            label: context.tr('qr_transactions'),
            count: qrCount,
            selected: selectedTab == TransactionTab.qr,
            enabled: enableQrAndSettlements,
            iconColor: const Color(0xFF059669),
            onTap: () => onSelected(TransactionTab.qr),
            onViewAll: () => onViewAll(TransactionTab.qr),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _ChannelTile(
            icon: Icons.description_outlined,
            label: context.tr('settlement_summary'),
            count: settlementCount,
            selected: selectedTab == TransactionTab.settlements,
            enabled: enableQrAndSettlements,
            iconColor: const Color(0xFFEA580C),
            onTap: () => onSelected(TransactionTab.settlements),
            onViewAll: () => onViewAll(TransactionTab.settlements),
          ),
        ),
      ],
    );
  }
}

class MobileHomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const MobileHomeSectionHeader({
    super.key,
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyle.h3.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryPurple,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            children: [
              Text(
                context.tr('view_all'),
                style: AppTextStyle.h5.copyWith(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class MobileHomeTxnTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? rrn;
  final String dateTimeText;
  final String amount;
  final String status;
  final bool successful;
  final VoidCallback? onTap;

  const MobileHomeTxnTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.dateTimeText,
    required this.amount,
    required this.status,
    required this.successful,
    this.rrn,
    this.onTap,
  });

  factory MobileHomeTxnTile.fromPos({
    required PosTransactionModel transaction,
    VoidCallback? onTap,
  }) {
    return MobileHomeTxnTile(
      icon: Icons.credit_card_rounded,
      title: _posTitle(transaction.transactionType),
      subtitle: _maskedCard(transaction.schemeName, transaction.cardNo),
      dateTimeText: _formatPosDate(
        transaction.transactionDate,
        transaction.transactionTime,
      ),
      amount: _rupee(transaction.amount),
      status: transaction.responseDesc.isEmpty
          ? transaction.responseCode
          : transaction.responseDesc,
      successful: transaction.responseCode == '00' ||
          transaction.responseDesc.toLowerCase().contains('success'),
      onTap: onTap,
    );
  }

  factory MobileHomeTxnTile.fromVpa({
    required MerchantVpaTransactionModel transaction,
    VoidCallback? onTap,
  }) {
    final vpa = transaction.customerVpa.trim();
    final rrn = transaction.rrn.trim();
    return MobileHomeTxnTile(
      icon: Icons.qr_code_2_rounded,
      title: transaction.transactionType.trim().isEmpty
          ? 'QR'
          : transaction.transactionType,
      subtitle: vpa.isEmpty
          ? (transaction.payerName.trim().isEmpty
              ? '-'
              : transaction.payerName.trim())
          : vpa,
      rrn: rrn.isEmpty ? null : rrn,
      dateTimeText: _formatIso(transaction.addedOn),
      amount: _rupee(transaction.transactionAmount),
      status: transaction.status,
      successful: transaction.status.toLowerCase().contains('success'),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chipBg = _statusChipBg(context, success: successful);
    final chipFg = _statusChipFg(context, success: successful);
    final details = [
      if (subtitle.trim().isNotEmpty && subtitle.trim() != '-') subtitle.trim(),
      if (rrn != null && rrn!.isNotEmpty) '${context.tr('rrn')} $rrn',
    ].join('  ·  ');

    final background = _tileBackground(context);
    final titleColor = _tileTitleColor(context);
    final mutedColor = _tileMutedColor(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _tileBorder(context)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withValues(
                      alpha: context.isDarkMode ? .22 : .10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.h4.copyWith(
                          color: titleColor,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      if (details.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.h5.copyWith(
                            color: mutedColor,
                            height: 1.2,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Text(
                        dateTimeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.h5.copyWith(
                          color: mutedColor,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: AppTextStyle.h4.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 92),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(status),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.h5.copyWith(
                          color: chipFg,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MobileHomeSettlementTile extends StatelessWidget {
  final SettlementItemModel settlement;
  final VoidCallback? onTap;

  const MobileHomeSettlementTile({
    super.key,
    required this.settlement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSettled = settlement.isSettledStatus;
    final date = settlement.tranDate == null
        ? 'N/A'
        : DateFormat('d MMM yyyy').format(settlement.tranDate!);
    final utr = settlement.utr.trim().isEmpty ? 'N/A' : settlement.utr;
    final chipBg = isSettled
        ? _statusChipBg(context, success: true)
        : (context.isDarkMode
            ? const Color(0xFF3A2A10)
            : const Color(0xFFFFF6DF));
    final chipFg = isSettled
        ? _statusChipFg(context, success: true)
        : (context.isDarkMode
            ? const Color(0xFFFBBF24)
            : const Color(0xFFA66D00));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _tileBackground(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _tileBorder(context)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _tintedSurface(context, const Color(0xff18A957)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Color(0xff18A957),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.h4.copyWith(
                        color: _tileTitleColor(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr('utr')}: $utr',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.h5.copyWith(
                        color: _tileMutedColor(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${settlement.transactionCount} ${context.tr('transactions')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.h5.copyWith(
                        color: _tileMutedColor(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${context.tr('gross_amount')}: Rs. ${settlement.grossTransactionAmount.toStringAsFixed(2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.h5.copyWith(
                        color: _tileTitleColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${context.tr('net_payable')}: Rs. ${settlement.totalAmountPayable.toStringAsFixed(2)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.h5.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      isSettled
                          ? context.tr('settled')
                          : context.tr('pending_settlements'),
                      style: AppTextStyle.h5.copyWith(
                        color: chipFg,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _tileMutedColor(context),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class MobileHomeSettlementSummary extends StatelessWidget {
  final double settledAmount;
  final double deductions;
  final double pendingAmount;

  const MobileHomeSettlementSummary({
    super.key,
    required this.settledAmount,
    required this.deductions,
    this.pendingAmount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SettlementMetricCard(
        label: context.tr('settled_amount'),
        subtitle: context.tr('total_amount_settled_today'),
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.primaryPurple,
        amount: settledAmount,
      ),
      _SettlementMetricCard(
        label: context.tr('deductions'),
        subtitle: context.tr('total_deductions_today'),
        icon: Icons.percent_rounded,
        color: const Color(0xffB03060),
        amount: deductions,
      ),
      _SettlementMetricCard(
        label: context.tr('pending_settlements'),
        subtitle: context.tr('total_pending_settlements'),
        icon: Icons.schedule_rounded,
        color: const Color(0xffB89116),
        amount: pendingAmount,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 640) {
            return Column(
              children: [
                for (var index = 0; index < cards.length; index++) ...[
                  cards[index],
                  if (index != cards.length - 1) const SizedBox(height: 10),
                ],
              ],
            );
          }

          return Row(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                Expanded(child: cards[index]),
                if (index != cards.length - 1) const SizedBox(width: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SettlementMetricCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double amount;

  const _SettlementMetricCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _tileBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _tileBorder(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.h5.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.h5.copyWith(
                    color: context.appTextSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rs. ${amount.toStringAsFixed(2)}',
                  style: AppTextStyle.h4.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
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

class _ChannelTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final bool enabled;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback onViewAll;

  const _ChannelTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.iconColor,
    required this.onTap,
    required this.onViewAll,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scale = _homeScale(context);
    final radius = 16 * scale;
    final wash = _tintedSurface(context, iconColor);

    return Opacity(
      opacity: enabled ? 1 : .45,
      child: Material(
        color: wash,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: (148 * scale).clamp(132, 184),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: selected
                  ? iconColor.withValues(alpha: .45)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: enabled ? onTap : null,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    10 * scale,
                    12 * scale,
                    10 * scale,
                    4 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14 * scale,
                        backgroundColor: iconColor,
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 15 * scale,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.h5.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          fontSize: (12 * scale).clamp(10, 14),
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Text(
                        '$count',
                        style: AppTextStyle.h2.copyWith(
                          color: context.appTextPrimary,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          fontSize: (22 * scale).clamp(16, 28),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: enabled ? onViewAll : null,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    10 * scale,
                    4 * scale,
                    10 * scale,
                    10 * scale,
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          context.tr('view_all'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.h5.copyWith(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            fontSize: (12 * scale).clamp(10, 14),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16 * scale,
                        color: AppColors.primaryPurple,
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

double _homeScale(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return (width / 390).clamp(0.82, 1.18);
}

Color _tileBackground(BuildContext context) {
  return context.isDarkMode ? context.appSurface : Colors.white;
}

Color _tileBorder(BuildContext context) {
  return context.isDarkMode ? context.appBorder : const Color(0xFFE8E8E8);
}

Color _tileTitleColor(BuildContext context) {
  return context.isDarkMode ? context.appTextPrimary : const Color(0xFF111827);
}

Color _tileMutedColor(BuildContext context) {
  return context.isDarkMode ? context.appTextSecondary : const Color(0xFF6B7280);
}

Color _tintedSurface(BuildContext context, Color tint) {
  return Color.alphaBlend(
    tint.withValues(alpha: context.isDarkMode ? .28 : .14),
    _tileBackground(context),
  );
}

Color _statusChipBg(BuildContext context, {required bool success}) {
  if (context.isDarkMode) {
    return success ? const Color(0xFF14301C) : const Color(0xFF3A1C1C);
  }
  return success ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
}

Color _statusChipFg(BuildContext context, {required bool success}) {
  if (context.isDarkMode) {
    return success ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5);
  }
  return success ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
}

class _HeroBars extends StatelessWidget {
  final double scale;

  const _HeroBars({this.scale = 1});

  @override
  Widget build(BuildContext context) {
    const heights = [18.0, 28.0, 24.0, 36.0, 48.0, 62.0];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final height in heights)
          Container(
            width: 10 * scale,
            height: height * scale,
            margin: EdgeInsets.only(left: 5 * scale),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .22),
              borderRadius: BorderRadius.circular(6 * scale),
            ),
          ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: context.appElevatedSurface,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: context.appIconColor),
          ),
        ),
      ),
    );
  }
}

String _initials(String source) {
  final words = source
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  if (words.isEmpty) return 'A';
  if (words.length == 1) {
    return words.first.characters.take(2).toString().toUpperCase();
  }
  return '${words.first.characters.first}${words.last.characters.first}'
      .toUpperCase();
}

String _posTitle(String type) {
  switch (type.trim()) {
    case 'VSAL001':
      return 'Void Sale';
    default:
      return 'Sale Transaction';
  }
}

String _maskedCard(String scheme, String cardNo) {
  final digits = cardNo.replaceAll(RegExp(r'\s+|-'), '');
  final last4 =
      digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
  final brand = scheme.trim().isEmpty ? 'CARD' : scheme.trim().toUpperCase();
  if (last4.isEmpty) return brand;
  return '$brand  ••••  $last4';
}

String _formatPosDate(String date, String time) {
  try {
    final parsed = DateFormat('MM/dd/yyyy HH:mm:ss').parse('$date $time');
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  } on FormatException {
    return [date, time].where((value) => value.isNotEmpty).join(', ');
  }
}

String _formatIso(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value.isEmpty ? '-' : value;
  return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
}

String _rupee(String amount) {
  final parsed = double.tryParse(amount) ?? 0;
  return '₹ ${parsed.toStringAsFixed(2)}';
}

String _statusLabel(String status) {
  final value = status.trim();
  if (value.isEmpty) return '—';
  final lower = value.toLowerCase();
  if (lower.contains('success') || lower == '00' || lower.contains('approved')) {
    return 'Success';
  }
  if (lower.contains('fail') ||
      lower.contains('decline') ||
      lower.contains('error')) {
    return 'Failed';
  }
  if (value.length == 1) return value.toUpperCase();
  return '${value[0].toUpperCase()}${value.substring(1).toLowerCase()}';
}
