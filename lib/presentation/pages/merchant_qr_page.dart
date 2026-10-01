import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/vpa_qr_item.dart';
import 'package:anet_merchant_app/data/services/merchant_service.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/form_field/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantQrPage extends StatefulWidget {
  const MerchantQrPage({super.key});

  @override
  State<MerchantQrPage> createState() => _MerchantQrPageState();
}

class _MerchantQrPageState extends State<MerchantQrPage> {
  static const int _pageSize = 200;
  static const int _maxPages = 5;

  bool _loading = true;
  List<VpaQrItem> _qrItems = const [];
  VpaQrItem? _selectedQr;

  @override
  void initState() {
    super.initState();
    _loadQrData();
  }

  Future<void> _loadQrData() async {
    List<VpaQrItem> items = const [];
    try {
      final prefs = await SharedPreferences.getInstance();
      var merchantId = prefs.getString('acqMerchantId') ?? '';
      if (merchantId.isEmpty || merchantId == '0') {
        merchantId = prefs.getString('merchantId') ?? '';
      }

      final allItems = <VpaQrItem>[];
      var totalElements = 0;

      for (var page = 0; page < _maxPages; page++) {
        final response = await MerchantServices().getListOfVpaAndQrData(
          {
            'merchantId': merchantId,
            'isReconsiled': true,
            'isSettled': true,
          },
          pageNumber: page,
          pageSize: _pageSize,
        );

        if (response.statusCode != 200) {
          break;
        }

        final pageData = response.data['pageData'] ?? {};
        final parsed = parseVpaQrContent(pageData['content']);
        allItems.addAll(parsed);
        totalElements = pageData['totalElements'] ?? allItems.length;

        final last = pageData['last'] == true;
        final empty = pageData['empty'] == true || parsed.isEmpty;
        if (last || empty || (totalElements > 0 && allItems.length >= totalElements)) {
          break;
        }
      }

      final seen = <String>{};
      items = [
        for (final item in allItems)
          if (seen.add(item.vpa)) item,
      ];
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
    return MerchantScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomTextWidget(
            text: "Merchant QR",
            size: 20,
            fontWeight: FontWeight.w900,
          ),
          defaultHeight(16),
          if (_loading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_qrItems.isEmpty)
            const Expanded(
              child: Center(
                child: CustomTextWidget(
                  text: "No merchant QR available",
                  size: 16,
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CustomTextWidget(
                      text: "Select QR",
                      size: 14,
                    ),
                    defaultHeight(8),
                    DropdownButtonFormField<VpaQrItem>(
                      key: ValueKey(_selectedQr?.vpa),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.kPrimaryColor,
                      ),
                      decoration: commonInputDecoration(
                        Icons.qr_code_2,
                        hintText: "Select QR",
                      ),
                      initialValue: _selectedQr,
                      items: _qrItems
                          .map(
                            (item) => DropdownMenuItem<VpaQrItem>(
                              value: item,
                              child: CustomTextWidget(
                                text: item.vpa,
                                maxLines: 1,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedQr = value);
                      },
                    ),
                    defaultHeight(24),
                    if (_selectedQr != null) _QrPreview(item: _selectedQr!),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QrPreview extends StatelessWidget {
  final VpaQrItem item;

  const _QrPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffE9E2F0)),
          ),
          child: QrImageView(
            data: item.qrCode,
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
        defaultHeight(16),
        SelectableText(
          item.vpa,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Mont',
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        defaultHeight(16),
        CustomContainer(
          height: 48,
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: item.vpa));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('VPA copied')),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.copy_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              CustomTextWidget(
                text: "Copy VPA",
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
