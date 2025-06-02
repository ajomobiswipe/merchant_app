import 'package:flutter/material.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ShowTransactionInvoice extends StatelessWidget {
  final TransactionElement transaction;
  const ShowTransactionInvoice({super.key, required this.transaction});

  String getCurrencySymbol(String? code) {
    if (code == "356") return "INR   ₹";
    return "\$";
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double basePadding = screenHeight * 0.01;

    return MerchantScaffold(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
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
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Image.asset(
                'assets/screen/anet.png',
                height: 100,
                width: screenWidth * 0.5,
              ),
            ),
            defaultHeight(basePadding),

            // Date and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  isBold: false,
                  size: 14,
                  text: "Date ${transaction.transactionDate ?? "N/A"}",
                ),
                CustomTextWidget(
                  size: 14,
                  isBold: false,
                  text: "Time ${transaction.transactionTime ?? "N/A"}",
                ),
              ],
            ),
            defaultHeight(basePadding),

            // Transaction Type
            Center(
              child: CustomTextWidget(
                isBold: false,
                text: transaction.transactionType ?? "N/A",
                size: 20,
              ),
            ),
            defaultHeight(basePadding),

            // MID & TID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "MID:     ${transaction.merchantId ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "TID:     ${transaction.terminalId ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
              ],
            ),
            defaultHeight(basePadding),

            // Batch & Invoice
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "Batch     ${transaction.batchNo ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "Invoice     ${transaction.traceNumber ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
              ],
            ),
            defaultHeight(basePadding),

            // RRN & PAN SEQ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "RRN:     ${transaction.rrn ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "PAN SEQ     ${transaction.traceNumber ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
              ],
            ),
            defaultHeight(basePadding),

            // Entry Mode & Card Brand
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text:
                      "${transaction.posEntryMode ?? "N/A"} (${transaction.schemeName ?? "N/A"})",
                  size: 16,
                  isBold: false,
                ),
              ],
            ),
            defaultHeight(basePadding),

            // Cardholder Name
            if (transaction.nameOnCard != null)
              CustomTextWidget(
                text: transaction.nameOnCard!,
                size: 14,
              ),
            defaultHeight(basePadding),

            // Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "AMOUNT ",
                  size: 16,
                  isBold: true,
                ),
                CustomTextWidget(
                  text: getCurrencySymbol(transaction.currency),
                  size: 20,
                  isBold: true,
                ),
                CustomTextWidget(
                  text: transaction.amount ?? "N/A",
                  size: 16,
                  isBold: true,
                ),
              ],
            ),
            defaultHeight(basePadding),

            // Auth Code
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "AUTH CODE  : ${transaction.authCode ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
              ],
            ),
            defaultHeight(basePadding),

            // Transaction Confirmation Message
            Center(
              child: Column(
                children: [
                  CustomTextWidget(
                    text: "PLEASE DEBIT MY ACCOUNT",
                    size: 14,
                    isBold: false,
                  ),
                  CustomTextWidget(
                    text: "PIN VERIFIED OK SIGNATURE NOT REQUIRED",
                    size: 14,
                    isBold: false,
                  ),
                ],
              ),
            ),
            defaultHeight(basePadding),

            // Label / Process Code
            CustomTextWidget(
              text:
                  "Label  ${transaction.processCode ?? ""} ${transaction.schemeName ?? "N/A"} ",
              size: 12,
              isBold: false,
            ),
            defaultHeight(basePadding),

            // Optional Tags (placeholders unless backend supplies them)
            CustomTextWidget(
              text: "AID  ${transaction.terminalId ?? "N/A"}  ",
              size: 12,
              isBold: false,
            ),
            defaultHeight(basePadding),
            CustomTextWidget(
              text: "TVR  ${transaction.batchNo ?? "N/A"}  ",
              size: 12,
              isBold: false,
            ),
            defaultHeight(basePadding),
            CustomTextWidget(
              text: "TSI  ${transaction.terminalId ?? "N/A"}  ",
              size: 12,
              isBold: false,
            ),
            defaultHeight(basePadding),
            CustomTextWidget(
              text: "CID  ${transaction.terminalId ?? "N/A"}  ",
              size: 12,
              isBold: false,
            ),
            defaultHeight(basePadding),
            CustomTextWidget(
              text: "AC  ${transaction.terminalId ?? "N/A"}  ",
              size: 12,
              isBold: false,
            ),

            const SizedBox(height: 16),

            // Download Button
            CustomContainer(
              onTap: () => generatePDF(context),
              height: 70,
              child: const CustomTextWidget(
                text: "Download",
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      onTapHome: () {
        Navigator.pop(context);
      },
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

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.symmetric(horizontal: 44, vertical: 24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Image(pw.MemoryImage(logo), height: 100)),
              pw.SizedBox(height: 10),
              rowText("Date", transaction.transactionDate ?? "N/A"),
              rowText("Time", transaction.transactionTime ?? "N/A"),
              centerText(transaction.transactionType ?? "N/A", size: 20),
              pw.SizedBox(height: 10),
              rowText("MID", transaction.merchantId ?? "N/A"),
              rowText("TID", transaction.terminalId ?? "N/A"),
              rowText("Batch", transaction.batchNo ?? "N/A"),
              rowText("Invoice", transaction.traceNumber ?? "N/A"),
              rowText("RRN", transaction.rrn ?? "N/A"),
              rowText("PAN SEQ", transaction.traceNumber ?? "N/A"),
              rowText("Entry/Card Brand",
                  "${transaction.posEntryMode ?? "N/A"} (${transaction.schemeName ?? "N/A"})"),
              if (transaction.nameOnCard != null)
                centerText(transaction.nameOnCard!, size: 14),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Amount",
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      "${getCurrencySymbol(transaction.currency)} ${transaction.amount ?? "N/A"}",
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 10),
              rowText("AUTH CODE", transaction.authCode ?? "N/A"),
              pw.Divider(),
              centerText("PLEASE DEBIT MY ACCOUNT"),
              centerText("PIN VERIFIED OK SIGNATURE NOT REQUIRED"),
              pw.Divider(),
              rowText("LABEL",
                  "${transaction.processCode ?? ""} ${transaction.schemeName ?? "N/A"}"),
              rowText("AID", transaction.terminalId ?? "N/A"),
              rowText("TVR", transaction.batchNo ?? "N/A"),
              rowText("TSI", transaction.terminalId ?? "N/A"),
              rowText("CID", transaction.terminalId ?? "N/A"),
              rowText("AC", transaction.terminalId ?? "N/A"),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice.pdf');
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

  pw.Widget centerText(String value, {double size = 12}) {
    return pw.Center(
      child: pw.Text(value, style: pw.TextStyle(fontSize: size)),
    );
  }
}
