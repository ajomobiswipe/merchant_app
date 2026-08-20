import 'package:flutter/material.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';

class RecentTransactionsHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onRefresh;

  const RecentTransactionsHeader({
    super.key,
    this.title = '',
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.isEmpty ? context.tr('recent_transactions') : title,
            style: AppTextStyle.h3.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.sync_rounded),
          color: AppColors.primaryPurple,
          iconSize: 30,
          tooltip: context.tr('refresh'),
        ),
        Text(
          context.tr('refresh'),
          style: AppTextStyle.h5.copyWith(
            color: AppColors.primaryPurple,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
