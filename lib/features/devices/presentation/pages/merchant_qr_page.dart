import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/common/common_scaffold.dart';
import 'package:anet_merchants/core/common/responsive_layout.dart';
import 'package:anet_merchants/core/di/injection_container.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';
import 'package:anet_merchants/features/devices/data/models/vpa_qr_parser.dart';
import 'package:anet_merchants/features/devices/data/repository/merchant_qr_repository.dart';
import 'package:anet_merchants/features/shared/presentation/widgets/flow_page_header.dart';

class MerchantQrPage extends StatefulWidget {
  const MerchantQrPage({super.key});

  @override
  State<MerchantQrPage> createState() => _MerchantQrPageState();
}

class _MerchantQrPageState extends State<MerchantQrPage> {
  final SessionStorage _sessionStorage = SessionStorage();
  List<VpaQrItem> _qrItems = const [];
  VpaQrItem? _selectedQr;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQrData();
  }

  Future<void> _loadQrData() async {
    List<VpaQrItem> items;
    try {
      final bearerToken = await _sessionStorage.bearerToken;
      final email = await _sessionStorage.email;
      var merchantId = await _sessionStorage.activeAcqMerchantId;
      if (merchantId.isEmpty || merchantId == '0') {
        merchantId = await _sessionStorage.merchantId;
      }

      items = await sl<MerchantQrRepository>().getVpaAndQrData(
        merchantId: merchantId,
        bearerToken: bearerToken,
        clientUniqueId: email,
      );
    } catch (_) {
      items = const [];
    }

    if (!mounted) return;
    setState(() {
      _qrItems = items;
      _selectedQr = items.isEmpty ? null : items.first;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle(
      kIsWeb && AppBreakpoints.isTabletOrLarger(context)
          ? AppPlatform.web
          : AppPlatform.mobile,
    );

    return CommonScaffold(
      selectedIndex: 3,
      onBottomNavItemSelected: (index) {
        if (index == 3) {
          NavigationHelper.goToRoot(context, AppRoutes.profile);
          return;
        }
        NavigationHelper.goHomeAndClearStack(context, AppRoutes.home);
      },
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          kIsWeb ? 24 : 20,
          kIsWeb ? 24 : 12,
          kIsWeb ? 24 : 20,
          24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FlowPageHeader(),
                const SizedBox(height: 20),
                Text(
                  context.tr('merchant_qr'),
                  style: style.h2.copyWith(
                    color: context.appTextPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 20),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_qrItems.isEmpty)
                  Text(
                    context.tr('no_merchant_qr'),
                    style: style.h4.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else ...[
                  Text(
                    context.tr('select_qr'),
                    style: style.h5.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _QrDropdown(
                    items: _qrItems,
                    selected: _selectedQr,
                    onChanged: (value) {
                      setState(() => _selectedQr = value);
                    },
                  ),
                  const SizedBox(height: 28),
                  if (_selectedQr != null) _QrPreview(item: _selectedQr!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QrDropdown extends StatelessWidget {
  final List<VpaQrItem> items;
  final VpaQrItem? selected;
  final ValueChanged<VpaQrItem?> onChanged;

  const _QrDropdown({
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle(
      kIsWeb && AppBreakpoints.isTabletOrLarger(context)
          ? AppPlatform.web
          : AppPlatform.mobile,
    );

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.appSurfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<VpaQrItem>(
          value: selected,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primaryPurple,
            size: 28,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<VpaQrItem>(
                  value: item,
                  child: Text(
                    item.vpa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style.h4.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ),
    );
  }
}

class _QrPreview extends StatelessWidget {
  final VpaQrItem item;

  const _QrPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyle(
      kIsWeb && AppBreakpoints.isTabletOrLarger(context)
          ? AppPlatform.web
          : AppPlatform.mobile,
    );
    final payeeName = item.payeeName;

    return Column(
      children: [
        if (payeeName.isNotEmpty) ...[
          Text(
            payeeName,
            textAlign: TextAlign.center,
            style: style.h4.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffE9E2F0)),
          ),
          child: QrImageView(
            data: item.payload,
            size: 240,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SelectableText(
          item.vpa,
          textAlign: TextAlign.center,
          style: style.h4.copyWith(
            color: context.appTextPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: item.vpa));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('vpa_copied'))),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(context.tr('copy_vpa')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
              side: BorderSide(
                color: AppColors.primaryPurple.withValues(alpha: .4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
