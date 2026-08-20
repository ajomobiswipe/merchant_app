import 'package:flutter/material.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';

class MerchantOverview extends StatefulWidget {
  const MerchantOverview({super.key});

  @override
  State<MerchantOverview> createState() => _MerchantOverviewState();
}

class _MerchantOverviewState extends State<MerchantOverview> {
  String _shopName = '';
  String _merchantId = '';

  @override
  void initState() {
    super.initState();
    _loadShopName();
  }

  Future<void> _loadShopName() async {
    final storage = SessionStorage();
    final shopName = await storage.activeShopName;
    final merchantId = await storage.activeAcqMerchantId;
    final baseMerchantId = await storage.merchantId;

    if (!mounted) return;

    setState(() {
      _shopName = shopName;
      _merchantId =
          merchantId == '0' || merchantId.isEmpty ? baseMerchantId : merchantId;
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
              Text(
                displayName,
                style: AppTextStyle.h3.copyWith(
                  height: 1.2,
                  color: context.appTextPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (_merchantId.trim().isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  '${context.tr('merchant_id')} : $_merchantId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.h5.copyWith(
                    color: context.appTextSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        const _PaymentIllustration(),
      ],
    );
  }
}

class _PaymentIllustration extends StatelessWidget {
  const _PaymentIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 56,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(34),
            ),
          ),
          Positioned(
            left: 12,
            top: 9,
            child: Container(
              width: 33,
              height: 43,
              decoration: BoxDecoration(
                color: const Color(0xffF6EDFF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primaryPurple, width: 2.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.currency_rupee,
                      color: AppColors.primaryPurple,
                      size: 12,
                    ),
                  ),
                  const _DocumentLine(width: 22),
                  const _DocumentLine(width: 17),
                  const _DocumentLine(width: 24),
                ],
              ),
            ),
          ),
          Positioned(
            right: 2,
            bottom: 5,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xff7B36D8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Positioned(
            right: 1,
            top: 11,
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.primaryPurple,
              size: 10,
            ),
          ),
          Positioned(
            left: 2,
            top: 28,
            child: Icon(Icons.star, color: AppColors.primaryPurple, size: 8),
          ),
        ],
      ),
    );
  }
}

class _DocumentLine extends StatelessWidget {
  final double width;

  const _DocumentLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 2,
      margin: const EdgeInsets.only(left: 7, top: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: .36),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
