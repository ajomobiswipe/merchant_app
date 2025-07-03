import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/get_settlement_dashboard_data.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ShowSettledTransactionInvoice extends StatelessWidget {
  final SettledSummaryPageContent transaction;
  const ShowSettledTransactionInvoice({super.key, required this.transaction});

  String formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double basePadding = screenHeight * 0.01;

    return MerchantScaffold(
      child: Stack(
        children: [
          Positioned(
            right: 16,
            top: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.close, color: Colors.white, size: 28),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: screenHeight,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/screen/anet.png',
                    height: 100,
                    width: screenWidth * 0.5,
                  ),
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text: "Date: ${formatDate(transaction.tranDate)}",
                  size: 14,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text: "RRN: ${transaction.rrn ?? "N/A"}",
                  size: 14,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text: "Approval Code: ${transaction.approveCode ?? "N/A"}",
                  size: 14,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text: "MID: ${transaction.mid ?? "N/A"}",
                  size: 14,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text: "UTR: ${transaction.utr ?? "N/A"}",
                  size: 14,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text:
                      "Gross Amount: ₹ ${transaction.grossTransactionAmount?.toStringAsFixed(2) ?? "N/A"}",
                  size: 14,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text:
                      "MDR: ₹ ${transaction.mdrAmount?.toStringAsFixed(2) ?? "N/A"}",
                  size: 14,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text:
                      "GST: ₹ ${transaction.gst?.toStringAsFixed(2) ?? "N/A"}",
                  size: 14,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text:
                      "Payable Amount: ₹ ${transaction.totalAmountPayable?.toStringAsFixed(2) ?? "N/A"}",
                  size: 16,
                  isBold: true,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text:
                      "Merchant Payment Done: ${transaction.merPayDone == true ? "Yes" : "No"}",
                  size: 14,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text:
                      "MIS Done: ${transaction.misDone == true ? "Yes" : "No"}",
                  size: 14,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text:
                      "Reconciled: ${transaction.reconciled == true ? "Yes" : "No"}",
                  size: 14,
                ),
                const Spacer(),
                CustomContainer(
                  onTap: () => generatePDF(context),
                  height: screenHeight * 0.06,
                  child: const CustomTextWidget(
                    text: "Download",
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onTapHome: () => Navigator.pop(context),
      onTapSupport: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, "merchantHelpScreen");
      },
    );
  }

  Future<void> generatePDF(BuildContext context) async {
    final pdf = pw.Document();
    final logo =
        (await rootBundle.load('assets/screen/anet.png')).buffer.asUint8List();
    final inrIcon =
        (await rootBundle.load('assets/screen/rupee.png')).buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.symmetric(horizontal: 120, vertical: 24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Image(pw.MemoryImage(logo), height: 100)),
              pw.SizedBox(height: 10),
              rowText("Date", formatDate(transaction.tranDate)),
              rowText("RRN", transaction.rrn ?? "N/A"),
              rowText("Approval Code", transaction.approveCode ?? "N/A"),
              rowText("MID", transaction.mid ?? "N/A"),
              rowText("UTR", transaction.utr ?? "N/A"),
              rowTextWithINR(
                  "Gross Amount",
                  transaction.grossTransactionAmount?.toStringAsFixed(2) ??
                      "N/A",
                  inrIcon),
              rowTextWithINR("MDR",
                  transaction.mdrAmount?.toStringAsFixed(2) ?? "N/A", inrIcon),
              rowTextWithINR(
                  "GST", transaction.gst?.toStringAsFixed(2) ?? "N/A", inrIcon),
              rowText("Total Payable",
                  transaction.totalAmountPayable?.toStringAsFixed(2) ?? "N/A"),
              rowText("Merchant Payment Done",
                  transaction.merPayDone == true ? "Yes" : "No"),
              rowText("MIS Done", transaction.misDone == true ? "Yes" : "No"),
              rowText(
                  "Reconciled", transaction.reconciled == true ? "Yes" : "No"),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/settled_invoice.pdf');
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  pw.Widget rowText(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("$label:", style: pw.TextStyle(fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget rowTextWithINR(String label, String value, Uint8List inrIcon) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("$label:", style: pw.TextStyle(fontSize: 12)),
          pw.Spacer(),
          pw.Image(pw.MemoryImage(inrIcon), width: 12, height: 12),
          pw.SizedBox(width: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
