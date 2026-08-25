import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:anet_merchants/config/routes/routes.dart';
import 'package:anet_merchants/core/common/app_assets.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/common/common_scaffold.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/storage/session_storage.dart';
import 'package:anet_merchants/core/utils/navigation_helper.dart';
import 'package:anet_merchants/features/invoices/presentation/widgets/invoice_page_shell.dart';
import 'package:anet_merchants/features/invoices/utils/invoice_pdf_downloader.dart';
import 'package:anet_merchants/features/transactions/data/models/merchant_vpa_txn_response_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

class VpaInvoicePage extends StatefulWidget {
  final MerchantVpaTransactionModel transaction;

  const VpaInvoicePage({
    super.key,
    required this.transaction,
  });

  @override
  State<VpaInvoicePage> createState() => _VpaInvoicePageState();
}

class _VpaInvoicePageState extends State<VpaInvoicePage> {
  String _shopName = '';
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadShopName();
  }

  Future<void> _loadShopName() async {
    final shopName = await SessionStorage().shopName;
    if (!mounted) return;
    setState(() => _shopName = shopName);
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;

    return CommonScaffold(
      selectedIndex: 0,
      onBottomNavItemSelected: (index) => index == 3
          ? NavigationHelper.goToRoot(context, AppRoutes.profile)
          : NavigationHelper.goHomeAndClearStack(context, AppRoutes.home),
      bottomAction: InvoiceDownloadAction(
        child: _DownloadButton(
          onPressed: _isDownloading ? null : _downloadPdf,
          isDownloading: _isDownloading,
        ),
      ),
      body: InvoicePageShell(
        mobilePadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InvoiceNavigationHeader(
              onBack: () => NavigationHelper.backOrGo(
                context,
                AppRoutes.home,
              ),
            ),
            const SizedBox(height: 28),
            const _AllianceLogo(),
            const SizedBox(height: 24),
            Text(
              _shopName.trim().isEmpty
                  ? 'MERCHANT NAME'
                  : _shopName.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.h3.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 28),
            _TwoColumnRow(
              leftLabel: 'Date',
              leftValue: _dateText(transaction.addedOn),
              rightLabel: 'Time',
              rightValue: _timeText(transaction.addedOn),
            ),
            _TwoColumnRow(
              leftLabel: 'Merchant ID',
              leftValue: transaction.merchantId,
              rightLabel: 'Ref ID',
              rightValue: transaction.refId,
            ),
            _InvoiceLine(
              label: 'Transaction Type',
              value: _transactionType(transaction.transactionType),
            ),
            _InvoiceLine(
                label: 'Transaction Status', value: transaction.status),
            _InvoiceLine(
              label: 'Account Type',
              value: transaction.accountDetailsAccType,
            ),
            _InvoiceLine(
              label: 'Customer Name',
              value: transaction.payerName,
            ),
            _InvoiceLine(
              label: 'Payee Name',
              value: transaction.payeeName,
            ),
            _InvoiceLine(label: 'Customer VPA', value: transaction.customerVpa),
            _InvoiceLine(label: 'Payee VPA', value: transaction.creditVpa),
            _InvoiceLine(label: 'RRN', value: transaction.rrn),
            const SizedBox(height: 12),
            Divider(color: context.appBorder),
            _AmountRow(
              currency: _currency(transaction.code),
              amount: transaction.transactionAmount,
            ),
            Divider(color: context.appBorder),
            const SizedBox(height: 24),
            Text(
              'THANK YOU FOR USING OUR SERVICE',
              textAlign: TextAlign.center,
              style: AppTextStyle.h3.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep this receipt for your records.',
              textAlign: TextAlign.center,
              style: AppTextStyle.h4.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf() async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);
    try {
      final pdfBytes = await (await _buildPdf()).save();
      final reference = widget.transaction.refId.trim().isNotEmpty
          ? widget.transaction.refId
          : widget.transaction.rrn;
      await downloadInvoicePdf(
        bytes: pdfBytes,
        filename: 'qr_invoice_$reference.pdf',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice is ready.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to prepare the invoice.')),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<pw.Document> _buildPdf() async {
    final transaction = widget.transaction;
    final pdf = pw.Document();
    final logoBytes =
        (await rootBundle.load(AppAssets.anetLogo)).buffer.asUint8List();
    final regularFontBytes =
        (await rootBundle.load('assets/fonts/muli/Muli.ttf'))
            .buffer
            .asUint8List();
    final boldFontBytes =
        (await rootBundle.load('assets/fonts/muli/Muli-Bold.ttf'))
            .buffer
            .asUint8List();
    final regularFont = pw.Font.ttf(regularFontBytes.buffer.asByteData());
    final boldFont = pw.Font.ttf(boldFontBytes.buffer.asByteData());
    final logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(34),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _pdfLogo(logoImage),
            pw.SizedBox(height: 16),
            _pdfCenter(
              _shopName.trim().isEmpty
                  ? 'MERCHANT NAME'
                  : _shopName.toUpperCase(),
              bold: true,
              size: 14,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 28),
            _pdfTwoColumn(
              'Date',
              _dateText(transaction.addedOn),
              'Time',
              _timeText(transaction.addedOn),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfTwoColumn(
              'Merchant ID',
              transaction.merchantId,
              'Ref ID',
              transaction.refId,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'Transaction Type',
              _transactionType(transaction.transactionType),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'Transaction Status',
              transaction.status,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'Account Type',
              transaction.accountDetailsAccType,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'Customer Name',
              transaction.payerName,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'Payee Name',
              transaction.payeeName,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'Customer VPA',
              transaction.customerVpa,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'Payee VPA',
              transaction.creditVpa,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'RRN',
              transaction.rrn,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 14),
            pw.Divider(),
            _pdfAmount(
              _currency(transaction.code),
              transaction.transactionAmount,
              boldFont: boldFont,
            ),
            pw.Divider(),
            pw.SizedBox(height: 24),
            _pdfCenter(
              'THANK YOU FOR USING OUR SERVICE',
              bold: true,
              size: 16,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 8),
            _pdfCenter(
              'Keep this receipt for your records.',
              bold: true,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  static String _dateText(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value.split('T').first;
    return DateFormat('yyyy-MM-dd').format(parsed);
  }

  static String _timeText(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value.contains('T') ? value.split('T').last : 'N/A';
    }
    return DateFormat('HH:mm:ss.SSS').format(parsed);
  }

  static String _currency(String code) {
    return code == '356' || code.toUpperCase() == 'INR' ? 'INR' : 'INR';
  }

  static String _transactionType(String value) {
    if (value == '00' || value == 'TRANSFER') return 'Cash Withdrawal';
    if (value == '21') return 'Balance Enquiry';
    if (value == '22') return 'Mini Statement';
    return value.isEmpty ? 'N/A' : value;
  }
}

class _AllianceLogo extends StatelessWidget {
  const _AllianceLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.anetLogoForBrightness(Theme.of(context).brightness),
      width: 220,
      fit: BoxFit.contain,
    );
  }
}

class _TwoColumnRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  const _TwoColumnRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: _InlineInvoiceLine(label: leftLabel, value: leftValue)),
          const SizedBox(width: 10),
          Expanded(
              child: _InlineInvoiceLine(label: rightLabel, value: rightValue)),
        ],
      ),
    );
  }
}

class _InvoiceLine extends StatelessWidget {
  final String label;
  final String value;

  const _InvoiceLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyle.h4.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.h4.copyWith(
                color: context.appTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineInvoiceLine extends StatelessWidget {
  final String label;
  final String value;

  const _InlineInvoiceLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: AppTextStyle.h4.copyWith(color: context.appTextPrimary),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(text: value.isEmpty ? ' N/A' : ' $value'),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String currency;
  final String amount;

  const _AmountRow({
    required this.currency,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'AMOUNT',
            style: AppTextStyle.h2.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 28),
          Text(
            currency,
            style: AppTextStyle.h2.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 28),
          Text(
            amount.isEmpty ? 'N/A' : amount,
            style: AppTextStyle.h2.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isDownloading;

  const _DownloadButton({
    required this.onPressed,
    required this.isDownloading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
      child: SizedBox(
        height: 54,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isDownloading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  context.tr('download'),
                  style: AppTextStyle.h4WhiteColor.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    );
  }
}

pw.Widget _pdfLogo(pw.MemoryImage logoImage) {
  return pw.Center(
    child: pw.Image(
      logoImage,
      width: 220,
      fit: pw.BoxFit.contain,
    ),
  );
}

pw.Widget _pdfLine(
  String key,
  String value, {
  required pw.Font regularFont,
  required pw.Font boldFont,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.RichText(
      text: pw.TextSpan(
        style: pw.TextStyle(font: regularFont),
        children: [
          pw.TextSpan(
            text: '$key  ',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
            ),
          ),
          pw.TextSpan(text: value.isEmpty ? 'N/A' : value),
        ],
      ),
    ),
  );
}

pw.Widget _pdfTwoColumn(
  String leftKey,
  String leftValue,
  String rightKey,
  String rightValue, {
  required pw.Font regularFont,
  required pw.Font boldFont,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: _pdfInline(
            leftKey,
            leftValue,
            regularFont: regularFont,
            boldFont: boldFont,
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: _pdfInline(
            rightKey,
            rightValue,
            regularFont: regularFont,
            boldFont: boldFont,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _pdfInline(
  String key,
  String value, {
  required pw.Font regularFont,
  required pw.Font boldFont,
}) {
  return pw.RichText(
    text: pw.TextSpan(
      style: pw.TextStyle(font: regularFont),
      children: [
        if (key.isNotEmpty)
          pw.TextSpan(
            text: '$key ',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
            ),
          ),
        pw.TextSpan(text: value.isEmpty ? ' N/A' : ' $value'),
      ],
    ),
  );
}

pw.Widget _pdfAmount(
  String currency,
  String amount, {
  required pw.Font boldFont,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 12),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          'AMOUNT',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 18,
            font: boldFont,
          ),
        ),
        pw.SizedBox(width: 24),
        pw.Text(
          currency,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 18,
            font: boldFont,
          ),
        ),
        pw.SizedBox(width: 24),
        pw.Text(
          amount.isEmpty ? 'N/A' : amount,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 18,
            font: boldFont,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _pdfCenter(
  String text, {
  bool bold = false,
  double size = 12,
  required pw.Font regularFont,
  required pw.Font boldFont,
}) {
  return pw.Center(
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        font: bold ? boldFont : regularFont,
      ),
    ),
  );
}
