import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

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
import 'package:anet_merchants/features/settlements/data/models/settlement_history_response_model.dart';

class SettlementInvoicePage extends StatefulWidget {
  final SettlementItemModel transaction;

  const SettlementInvoicePage({
    super.key,
    required this.transaction,
  });

  @override
  State<SettlementInvoicePage> createState() => _SettlementInvoicePageState();
}

class _SettlementInvoicePageState extends State<SettlementInvoicePage> {
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
            const SizedBox(height: 26),
            Image.asset(
              AppAssets.anetLogoForBrightness(Theme.of(context).brightness),
              height: 94,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),
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
            _InvoiceLine(
              label: context.tr('date'),
              value: _formatDate(transaction.tranDate),
            ),
            _InvoiceLine(label: 'RRN', value: transaction.rrn),
            _InvoiceLine(
              label: 'Approval Code',
              value: transaction.approveCode,
            ),
            _InvoiceLine(label: 'MID', value: transaction.mid),
            _InvoiceLine(label: 'UTR', value: transaction.utr),
            const SizedBox(height: 8),
            Divider(color: context.appBorder),
            _AmountLine(
              label: 'Gross Amount',
              amount: transaction.grossTransactionAmount,
            ),
            _AmountLine(label: 'MDR', amount: transaction.mdrAmount),
            _AmountLine(label: 'GST', amount: transaction.gst),
            Divider(color: context.appBorder),
            _TotalAmount(amount: transaction.totalAmountPayable),
            Divider(color: context.appBorder),
            const SizedBox(height: 12),
            _InvoiceLine(
              label: 'Merchant Payment Done',
              value: _yesNo(transaction.merPayDone),
            ),
            _InvoiceLine(label: 'MIS Done', value: _yesNo(transaction.misDone)),
            _InvoiceLine(
              label: 'Reconciled',
              value: _yesNo(transaction.reconciled),
            ),
            const SizedBox(height: 30),
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
                fontWeight: FontWeight.w800,
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
      final reference = widget.transaction.utr.trim().isNotEmpty
          ? widget.transaction.utr
          : widget.transaction.rrn;
      await downloadInvoicePdf(
        bytes: pdfBytes,
        filename: 'settlement_invoice_$reference.pdf',
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
            pw.SizedBox(height: 18),
            _pdfCenter(
              _shopName.trim().isEmpty
                  ? 'MERCHANT NAME'
                  : _shopName.toUpperCase(),
              bold: true,
              size: 14,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 26),
            _pdfLine(
              'Date',
              _formatDate(transaction.tranDate),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'RRN',
              _fallback(transaction.rrn),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'Approval Code',
              _fallback(transaction.approveCode),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'MID',
              _fallback(transaction.mid),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'UTR',
              _fallback(transaction.utr),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
            _pdfLine(
              'Gross Amount',
              'INR ${transaction.grossTransactionAmount.toStringAsFixed(2)}',
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'MDR',
              'INR ${transaction.mdrAmount.toStringAsFixed(2)}',
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'GST',
              'INR ${transaction.gst.toStringAsFixed(2)}',
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            pw.Divider(),
            _pdfAmount(transaction.totalAmountPayable, boldFont: boldFont),
            pw.Divider(),
            pw.SizedBox(height: 12),
            _pdfLine(
              'Merchant Payment Done',
              _yesNo(transaction.merPayDone),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'MIS Done',
              _yesNo(transaction.misDone),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'Reconciled',
              _yesNo(transaction.reconciled),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 28),
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
              _fallback(value),
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

class _AmountLine extends StatelessWidget {
  final String label;
  final double amount;

  const _AmountLine({
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return _InvoiceLine(
      label: label,
      value: 'Rs. ${amount.toStringAsFixed(2)}',
    );
  }
}

class _TotalAmount extends StatelessWidget {
  final double amount;

  const _TotalAmount({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'PAYABLE',
            style: AppTextStyle.h2.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 26),
          Text(
            'INR',
            style: AppTextStyle.h2.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 26),
          Text(
            amount.toStringAsFixed(2),
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
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: isDownloading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Icon(Icons.download_rounded, size: 26),
          label: Text(
            isDownloading ? 'Preparing...' : context.tr('download'),
            style: AppTextStyle.h4WhiteColor.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return DateFormat('dd-MM-yyyy').format(date);
}

String _fallback(String value) => value.trim().isEmpty ? 'N/A' : value;

String _yesNo(bool value) => value ? 'Yes' : 'No';

pw.Widget _pdfLogo(pw.MemoryImage logoImage) {
  return pw.Center(
    child: pw.Image(
      logoImage,
      width: 220,
      fit: pw.BoxFit.contain,
    ),
  );
}

pw.Widget _pdfCenter(
  String value, {
  bool bold = false,
  double size = 12,
  required pw.Font regularFont,
  required pw.Font boldFont,
}) {
  return pw.Text(
    value,
    textAlign: pw.TextAlign.center,
    style: pw.TextStyle(
      fontSize: size,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      font: bold ? boldFont : regularFont,
    ),
  );
}

pw.Widget _pdfLine(
  String label,
  String value, {
  required pw.Font regularFont,
  required pw.Font boldFont,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            font: boldFont,
          ),
        ),
        pw.SizedBox(width: 18),
        pw.Expanded(
          child: pw.Text(
            _fallback(value),
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 12, font: regularFont),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _pdfAmount(
  double amount, {
  required pw.Font boldFont,
}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 14),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          'PAYABLE',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            font: boldFont,
          ),
        ),
        pw.SizedBox(width: 22),
        pw.Text(
          'INR',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            font: boldFont,
          ),
        ),
        pw.SizedBox(width: 22),
        pw.Text(
          amount.toStringAsFixed(2),
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            font: boldFont,
          ),
        ),
      ],
    ),
  );
}
