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
import 'package:anet_merchants/features/transactions/data/models/pos_txn_history_response_model.dart';
import 'package:pdf/widgets.dart' as pw;

class TransactionInvoicePage extends StatefulWidget {
  final PosTransactionModel transaction;

  const TransactionInvoicePage({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionInvoicePage> createState() => _TransactionInvoicePageState();
}

class _TransactionInvoicePageState extends State<TransactionInvoicePage> {
  String _merchantDisplayLabel = '';
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadMerchantDisplayLabel();
  }

  Future<void> _loadMerchantDisplayLabel() async {
    final storage = SessionStorage();
    final dropdownItems = await storage.merchantDropdownItems;
    final matchedMerchant = dropdownItems.where(
      (item) =>
          !item.isAll &&
          item.merchantId.trim() == widget.transaction.merchantId.trim(),
    );
    final merchantDisplayLabel = matchedMerchant.isNotEmpty
        ? matchedMerchant.first.displayLabel
        : await storage.activeMerchantDisplayLabel;
    if (!mounted) return;

    setState(() {
      _merchantDisplayLabel = merchantDisplayLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final terminalAddress = _valueOrFallback(transaction.terminalAddress);

    return CommonScaffold(
      selectedIndex: 0,
      onBottomNavItemSelected: (index) => index == 3
          ? NavigationHelper.goToRoot(context, AppRoutes.profile)
          : NavigationHelper.goHomeAndClearStack(context, AppRoutes.home),
      bottomAction: InvoiceDownloadAction(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
          child: SizedBox(
            height: 58,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isDownloading ? null : _downloadReceipt,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isDownloading
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
        ),
      ),
      body: InvoicePageShell(
        mobilePadding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 380;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InvoiceNavigationHeader(
                  onBack: () => NavigationHelper.backOrGo(
                    context,
                    AppRoutes.home,
                  ),
                ),
                SizedBox(height: compact ? 18 : 24),
                _BrandHeader(
                  merchantDisplayLabel: _merchantDisplayLabel,
                ),
                const SizedBox(height: 8),
                Align(
                  child: Text(
                    terminalAddress,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.h4.copyWith(
                      color: context.appTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 18 : 22),
                _TwoColumnRow(
                  leftLabel: context.tr('date'),
                  leftValue: transaction.transactionDate,
                  rightLabel: context.tr('time'),
                  rightValue: transaction.transactionTime,
                  compact: compact,
                ),
                _TwoColumnRow(
                  leftLabel: context.tr('tid'),
                  leftValue: transaction.terminalId,
                  rightLabel: context.tr('mid'),
                  rightValue: transaction.merchantId,
                  compact: compact,
                ),
                _TwoColumnRow(
                  leftLabel: context.tr('batch_no'),
                  leftValue: transaction.batchNo,
                  rightLabel: context.tr('invoice'),
                  rightValue: transaction.stan,
                  compact: compact,
                ),
                SizedBox(height: compact ? 10 : 14),
                Center(
                  child: Text(
                    _transactionType(transaction.transactionType),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.h2.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 10 : 14),
                _TwoColumnRow(
                  leftLabel: context.tr('card_type'),
                  leftValue: transaction.schemeName.isEmpty
                      ? _schemeFromCard(transaction.cardNo)
                      : transaction.schemeName.toUpperCase(),
                  rightLabel: context.tr('exp'),
                  rightValue: 'XX/XX',
                  compact: compact,
                ),
                _TwoColumnRow(
                  leftLabel: context.tr('card_no'),
                  leftValue: transaction.cardNo,
                  rightLabel: '',
                  rightValue: _posEntryMode(transaction.posEntryMode),
                  leftFlex: 3,
                  rightFlex: 1,
                  compact: compact,
                ),
                _TwoColumnRow(
                  leftLabel: context.tr('auth_code'),
                  leftValue: transaction.authCode,
                  rightLabel: context.tr('rrn'),
                  rightValue: transaction.rrn,
                  compact: compact,
                ),
                _InvoiceLine(
                  label: 'AID',
                  value: transaction.acquirerId,
                  compact: compact,
                ),
                _InvoiceLine(
                  label: 'LABEL',
                  value: transaction.schemeName.isEmpty
                      ? _schemeFromCard(transaction.cardNo)
                      : transaction.schemeName.toUpperCase(),
                  compact: compact,
                ),
                _TwoColumnRow(
                  leftLabel: 'TVR',
                  leftValue: 'N/A',
                  rightLabel: 'TSI',
                  rightValue: 'N/A',
                  compact: compact,
                ),
                _InvoiceLine(
                  label: 'TC',
                  value: 'N/A',
                  compact: compact,
                ),
                Divider(
                  height: compact ? 22 : 26,
                  color: context.appBorder,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('amount'),
                      style: AppTextStyle.h4.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: compact ? 16 : 22),
                    Text(
                      _currency(transaction.currency),
                      style: AppTextStyle.h3.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: compact ? 16 : 22),
                    Text(
                      _valueOrFallback(transaction.amount),
                      style: AppTextStyle.h4.copyWith(
                        color: context.appTextPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: compact ? 22 : 26,
                  color: context.appBorder,
                ),
                Center(
                  child: Text(
                    _pinMessage(transaction.posEntryMode),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (transaction.nameOnCard.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    transaction.nameOnCard,
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  context.tr('merchant_satisfied_terms'),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.h5.copyWith(
                    color: context.appTextSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    context.tr('thank_you_merchant_copy'),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.h5.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _downloadReceipt() async {
    if (_isDownloading) return;

    setState(() => _isDownloading = true);
    try {
      final pdfBytes = await (await _buildPdf()).save();
      final reference = widget.transaction.stan.trim().isNotEmpty
          ? widget.transaction.stan
          : widget.transaction.rrn;
      await downloadInvoicePdf(
        bytes: pdfBytes,
        filename: 'pos_invoice_$reference.pdf',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('invoice_ready'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('invoice_prepare_failed'))),
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
            pw.SizedBox(height: 12),
            _pdfCenter(
              _merchantDisplayLabel.trim().isEmpty
                  ? 'MERCHANT NAME'
                  : _merchantDisplayLabel.toUpperCase(),
              bold: true,
              size: 12.5,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfCenter(
              _valueOrFallback(transaction.terminalAddress),
              bold: true,
              size: 13,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 18),
            _pdfTwoColumn(
              'Date',
              transaction.transactionDate,
              'Time',
              transaction.transactionTime,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfTwoColumn(
              'TID',
              transaction.terminalId,
              'MID',
              transaction.merchantId,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfTwoColumn(
              'BATCH NO',
              transaction.batchNo,
              'INVOICE',
              transaction.stan,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 14),
            _pdfCenter(
              _transactionType(transaction.transactionType),
              bold: true,
              size: 22,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            pw.SizedBox(height: 12),
            _pdfTwoColumn(
              'CARD TYPE',
              transaction.schemeName.isEmpty
                  ? _schemeFromCard(transaction.cardNo)
                  : transaction.schemeName.toUpperCase(),
              'EXP',
              'XX/XX',
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfTwoColumn(
              'CARD NO',
              transaction.cardNo,
              '',
              _posEntryMode(transaction.posEntryMode),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfTwoColumn(
              'AUTH CODE',
              transaction.authCode,
              'RRN',
              transaction.rrn,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'AID',
              transaction.acquirerId,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'LABEL',
              transaction.schemeName.isEmpty
                  ? _schemeFromCard(transaction.cardNo)
                  : transaction.schemeName.toUpperCase(),
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfTwoColumn(
              'TVR',
              'N/A',
              'TSI',
              'N/A',
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            _pdfLine(
              'TC',
              'N/A',
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            pw.Divider(),
            _pdfAmount(
              _currency(transaction.currency),
              transaction.amount,
              boldFont: boldFont,
            ),
            pw.Divider(),
            _pdfCenter(
              _pinMessage(transaction.posEntryMode),
              bold: true,
              regularFont: regularFont,
              boldFont: boldFont,
            ),
            if (transaction.nameOnCard.isNotEmpty) ...[
              pw.SizedBox(height: 18),
              pw.Text(
                transaction.nameOnCard,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                ),
              ),
            ],
            pw.SizedBox(height: 18),
            pw.Text(
              '* I am Satisfied with the goods/Services received and agree to pay as per issuer terms.',
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 12,
              ),
            ),
            pw.SizedBox(height: 12),
            _pdfCenter(
              'THANK YOU MERCHANT\nPLEASE KEEP THIS COPY',
              regularFont: regularFont,
              boldFont: boldFont,
            ),
          ],
        ),
      ),
    );

    return pdf;
  }

  static String _valueOrFallback(String value) => value.isEmpty ? 'N/A' : value;

  static String _currency(String code) => code == '356' ? 'INR' : 'INR';

  static String _transactionType(String value) {
    if (value == 'OSAL001') return 'SALE';
    if (value == 'VSAL001') return 'VOID-SALE';
    return value.isEmpty ? 'N/A' : value;
  }

  static String _posEntryMode(String value) {
    if (value == '051') return 'Chip';
    if (value == '071') return 'CTLS';
    return value.isEmpty ? 'N/A' : value;
  }

  static String _pinMessage(String value) {
    if (value == '051') return 'PIN VERIFIED OK SIGNATURE NOT REQUIRED';
    if (value == '071') return 'PIN NOT REQUIRED FOR CONTACTLESS TRANSACTION';
    return value.isEmpty ? 'N/A' : value;
  }

  static String _schemeFromCard(String cardNumber) {
    final normalized = cardNumber.replaceAll(RegExp(r'\s+|-'), '');
    if (normalized.isEmpty) return 'N/A';
    if (normalized.startsWith('4')) return 'VISA';
    if (normalized.startsWith('5')) return 'MASTERCARD';
    if (normalized.startsWith('34') || normalized.startsWith('37')) {
      return 'AMERICAN EXPRESS';
    }
    if (normalized.startsWith('6')) return 'RUPAY';
    return 'UNKNOWN';
  }
}

class _BrandHeader extends StatelessWidget {
  final String merchantDisplayLabel;

  const _BrandHeader({required this.merchantDisplayLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.asset(
            AppAssets.anetLogoForBrightness(Theme.of(context).brightness),
            width: 230,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          merchantDisplayLabel.trim().isEmpty
              ? 'MERCHANT NAME'
              : merchantDisplayLabel.toUpperCase(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.h3.copyWith(
            color: context.appTextPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _TwoColumnRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;
  final int leftFlex;
  final int rightFlex;
  final bool compact;

  const _TwoColumnRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: leftFlex,
            child: _InvoiceLine(
              label: leftLabel,
              value: leftValue,
              compact: compact,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: rightFlex,
            child: _InvoiceLine(
              label: rightLabel,
              value: rightValue,
              compact: compact,
              textAlign: TextAlign.right,
              crossAxisAlignment: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceLine extends StatelessWidget {
  final String label;
  final String value;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final bool compact;

  const _InvoiceLine({
    required this.label,
    required this.value,
    this.textAlign = TextAlign.left,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.isEmpty ? 'N/A' : value;
    final alignment = crossAxisAlignment == CrossAxisAlignment.end
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 2 : 4),
      child: Align(
        alignment: alignment,
        child: Text.rich(
          TextSpan(
            style: AppTextStyle.h5.copyWith(
              color: context.appTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 14.5 : 16,
            ),
            children: [
              if (label.isNotEmpty)
                TextSpan(
                  text: '$label  ',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              TextSpan(text: displayValue),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
        ),
      ),
    );
  }
}

pw.Widget _pdfLogo(pw.MemoryImage logoImage) {
  return pw.Center(
    child: pw.Image(
      logoImage,
      width: 235,
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
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.RichText(
      text: pw.TextSpan(
        style: pw.TextStyle(
          font: regularFont,
          fontSize: 15,
        ),
        children: [
          pw.TextSpan(
            text: '$key  ',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
              fontSize: 15,
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
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _pdfInline(
          leftKey,
          leftValue,
          regularFont: regularFont,
          boldFont: boldFont,
        ),
        pw.SizedBox(width: 18),
        _pdfInline(
          rightKey,
          rightValue,
          regularFont: regularFont,
          boldFont: boldFont,
          textAlign: pw.TextAlign.right,
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
  pw.TextAlign textAlign = pw.TextAlign.left,
}) {
  return pw.RichText(
    textAlign: textAlign,
    text: pw.TextSpan(
      style: pw.TextStyle(
        font: regularFont,
        fontSize: 15,
      ),
      children: [
        if (key.isNotEmpty)
          pw.TextSpan(
            text: '$key  ',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              font: boldFont,
              fontSize: 15,
            ),
          ),
        pw.TextSpan(text: value.isEmpty ? 'N/A' : value),
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
        pw.SizedBox(width: 18),
        pw.Text(
          currency,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 18,
            font: boldFont,
          ),
        ),
        pw.SizedBox(width: 18),
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
