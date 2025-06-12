import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
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
import 'package:provider/provider.dart';

class ShowTransactionInvoice extends StatelessWidget {
  final TransactionElement transaction;
  const ShowTransactionInvoice({super.key, required this.transaction});

  String getCurrencySymbol(String? code) {
    if (code == "356") return "INR   \₹";
    return "\$";
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double basePadding = screenHeight * 0.01;
    double mediumPadding = screenHeight * 0.02;
    double logoSize = screenHeight * .1;

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
            defaultHeight(basePadding),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.5,
                  child: CustomTextWidget(
                    text: Provider.of<AuthProvider>(context).merchantDbaName,
                    maxLines: 3,
                  ),
                ),
              ],
            ),
            Center(
              child: Image.asset(
                'assets/screen/anet.png',
                height: screenHeight * .1,
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
                  size: 12,
                  text: "Date: ${transaction.transactionDate ?? "N/A"}",
                  isUpperCase: true,
                ),
                CustomTextWidget(
                  size: 12,
                  isBold: false,
                  text: "Time: ${transaction.transactionTime ?? "N/A"}",
                  isUpperCase: true,
                ),
              ],
            ),
            defaultHeight(screenHeight * .015),

            // Transaction Type
            Center(
              child: CustomTextWidget(
                isBold: false,
                text: getTransactionType(transaction.transactionType),
                size: 20,
              ),
            ),
            defaultHeight(screenHeight * .015),

            // MID & TID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "MID: ${transaction.merchantId ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "TID: ${transaction.terminalId ?? "N/A"}",
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
                  text: "Batch: ${transaction.batchNo ?? "N/A"}",
                  isUpperCase: true,
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "Invoice: ${transaction.traceNumber ?? "N/A"}",
                  isUpperCase: true,
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
                  text: "RRN: ${transaction.rrn ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "PAN SEQ: ${transaction.traceNumber ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
              ],
            ),
            defaultHeight(basePadding),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "AUTH CODE: ${transaction.authCode ?? "N/A"}",
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
                      "${getPosEntryMode(transaction.posEntryMode) ?? "N/A"} (${transaction.schemeName ?? getSchemeNameFromCardNumber(transaction.cardNo)})",
                  size: 12,
                  isBold: false,
                ),
              ],
            ),

            defaultHeight(basePadding),

            // Cardholder Name
            if (transaction.nameOnCard != null)
              Column(
                children: [
                  CustomTextWidget(
                    text: transaction.nameOnCard!,
                    size: 12,
                    isBold: true,
                  ),
                  defaultHeight(mediumPadding),
                ],
              ),

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

            // Auth Code

            // Transaction Confirmation Message
            Center(
              child: Column(
                children: [
                  Divider(),
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
                  Divider(),
                ],
              ),
            ),

            defaultHeight(mediumPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text:
                      "Label: ${transaction.processCode ?? ""} ${transaction.schemeName ?? "N/A"} ",
                  isUpperCase: true,
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "AID: ${transaction.terminalId ?? "N/A"}  ",
                  size: 12,
                  isBold: false,
                ),
              ],
            ),

            // // Label / Process Code
            // CustomTextWidget(
            //   text:
            //       "Label: ${transaction.processCode ?? ""} ${transaction.schemeName ?? "N/A"} ",
            //   size: 12,
            //   isBold: false,
            // ),
            // defaultHeight(basePadding),

            // // Optional Tags (placeholders unless backend supplies them)
            // CustomTextWidget(
            //   text: "AID: ${transaction.terminalId ?? "N/A"}  ",
            //   size: 12,
            //   isBold: false,
            // ),
            defaultHeight(basePadding),
            // CustomTextWidget(
            //   text: "TVR: ${transaction.batchNo ?? "N/A"}  ",
            //   size: 12,
            //   isBold: false,
            // ),
            // defaultHeight(basePadding),
            // CustomTextWidget(
            //   text: "TSI: ${transaction.terminalId ?? "N/A"}  ",
            //   size: 12,
            //   isBold: false,
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "TVR: ${transaction.batchNo ?? "N/A"}  ",
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "TSI: ${transaction.terminalId ?? "N/A"}  ",
                  size: 12,
                  isBold: false,
                ),
              ],
            ),

            defaultHeight(basePadding),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "CID: ${transaction.terminalId ?? "N/A"}  ",
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "AC: ${transaction.terminalId ?? "N/A"}  ",
                  size: 12,
                  isBold: false,
                ),
              ],
            ),
            // CustomTextWidget(
            //   text: "CID: ${transaction.terminalId ?? "N/A"}  ",
            //   size: 12,
            //   isBold: false,
            // ),
            // defaultHeight(basePadding),
            // CustomTextWidget(
            //   text: "AC: ${transaction.terminalId ?? "N/A"}  ",
            //   size: 12,
            //   isBold: false,
            // ),

            defaultHeight(mediumPadding),

            // Download Button
            CustomContainer(
              onTap: () =>
                  generatePDF(context, screenWidth, screenHeight, logoSize),
              height: screenHeight * 0.06,
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

  getTransactionType(String? type) {
    if (type == "OSAL001") return "SALE";
    if (type == "VSAL001") return "Void";
    return type ?? "N/A";
  }

  getPosEntryMode(String? type) {
    if (type == "051") return "Chip";
    if (type == "071") return "Contactless";
    return type ?? "N/A";
  }

  String getSchemeNameFromCardNumber(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) return "N/A";

    // Remove any spaces or dashes
    cardNumber = cardNumber.replaceAll(RegExp(r'\s+|-'), '');

    if (cardNumber.startsWith('4')) return "Visa";
    if (cardNumber.startsWith('5')) return "MasterCard";
    if (cardNumber.startsWith('6')) {
      if (cardNumber.startsWith('6011') ||
          cardNumber.startsWith('65') ||
          (int.tryParse(cardNumber.substring(0, 6)) ?? 0) >= 622126 &&
              (int.tryParse(cardNumber.substring(0, 6)) ?? 0) <= 622925) {
        return "Discover";
      }
      if (cardNumber.startsWith('60') ||
          cardNumber.startsWith('608') ||
          cardNumber.startsWith('6521') ||
          cardNumber.startsWith('6522')) {
        return "RuPay";
      }
      return "Discover";
    }
    if (cardNumber.startsWith('34') || cardNumber.startsWith('37')) {
      return "American Express";
    }
    if (cardNumber.startsWith('36') ||
        cardNumber.startsWith('38') ||
        cardNumber.startsWith('39')) {
      return "Diners Club";
    }

    return "Unknown";
  }

  Future<void> generatePDF(BuildContext context, double screenWidth,
      double screenHeight, double logoSize) async {
    final pdf = pw.Document();
    final logo =
        (await rootBundle.load('assets/screen/anet.png')).buffer.asUint8List();

    final fontDataBold =
        (await rootBundle.load("assets/fonts/Montserrat-Bold.ttf"))
            .buffer
            .asUint8List();

    final fontDataRegular =
        (await rootBundle.load("assets/fonts/Montserrat-Regular.ttf"))
            .buffer
            .asUint8List();

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.symmetric(
            horizontal: screenWidth * .05, vertical: screenHeight * 0.05),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                  child: pw.Image(pw.MemoryImage(logo), height: logoSize)),
              pw.SizedBox(height: screenHeight * .02),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText("Date: ${transaction.transactionDate ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText("Time: ${transaction.transactionTime ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .025),
              // rowText("Date", transaction.transactionDate ?? "N/A"),
              // rowText("Time", transaction.transactionTime ?? "N/A"),
              centerText(getTransactionType(transaction.transactionType),
                  size: 24, fontData: fontDataRegular),
              pw.SizedBox(height: screenHeight * .025),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText("MID: ${transaction.merchantId ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText("TID: ${transaction.terminalId ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .02),
              // rowText("MID", transaction.merchantId ?? "N/A"),
              // rowText("TID", transaction.terminalId ?? "N/A"),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText("Batch: ${transaction.batchNo ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText("Invoice: ${transaction.traceNumber ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .02),
              // rowText("Batch", transaction.batchNo ?? "N/A"),
              // rowText("Invoice", transaction.traceNumber ?? "N/A"),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText("RRN: ${transaction.rrn ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText("PAN SEQ: ${transaction.traceNumber ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .02),
              // rowText("RRN", transaction.rrn ?? "N/A"),
              // rowText("PAN SEQ", transaction.traceNumber ?? "N/A"),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pdfCustomText("AUTH CODE: ${transaction.authCode ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .02),
              // rowText("RRN", transaction.rrn ?? "N/A"),
              // rowText("PAN SEQ", transaction.traceNumber ?? "N/A"),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText(
                      "${getPosEntryMode(transaction.posEntryMode) ?? "N/A"} (${transaction.schemeName ?? getSchemeNameFromCardNumber(transaction.cardNo)})",
                      fontData: fontDataRegular),
                ],
              ),
              // rowText("AUTH CODE", transaction.authCode ?? "N/A"),
              // rowText("Entry/Card Brand",
              //     "${transaction.posEntryMode ?? "N/A"} (${transaction.schemeName ?? "N/A"})"),
              pw.SizedBox(height: screenHeight * .025),

              if (transaction.nameOnCard != null)
                pw.Column(
                  children: [
                    pdfCustomText(transaction.nameOnCard!,
                        fontweight: pw.FontWeight.bold, fontData: fontDataBold),
                    pw.SizedBox(height: screenHeight * .025),
                  ],
                ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Amount",
                      style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          font: pw.Font.ttf(fontDataBold.buffer.asByteData()))),
                  pw.Text(" INR ${transaction.amount ?? "N/A"}",
                      style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          font: pw.Font.ttf(fontDataBold.buffer.asByteData()))),
                ],
              ),
              pw.SizedBox(height: screenHeight * .025),
              pw.Divider(thickness: .2),
              centerText("PLEASE DEBIT MY ACCOUNT",
                  size: 20, fontData: fontDataRegular),
              centerText("PIN VERIFIED OK SIGNATURE NOT REQUIRED",
                  size: 20, fontData: fontDataRegular),
              pw.Divider(thickness: .2),
              pw.SizedBox(height: screenHeight * .03),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText(
                      "LABEL: ${transaction.processCode ?? ""} ${transaction.schemeName ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText("AID: ${transaction.terminalId ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              // rowText("LABEL",
              //     "${transaction.processCode ?? ""} ${transaction.schemeName ?? "N/A"}"),
              // rowText("AID", transaction.terminalId ?? "N/A"),
              pw.SizedBox(height: screenHeight * .02),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText("TVR: ${transaction.batchNo ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText("TSI: ${transaction.terminalId ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .02),
              // rowText("TVR", transaction.batchNo ?? "N/A"),
              // rowText("TSI", transaction.terminalId ?? "N/A"),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText("CID: ${transaction.terminalId ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText("AC: ${transaction.terminalId ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              // rowText("CID", transaction.terminalId ?? "N/A"),
              // rowText("AC", transaction.terminalId ?? "N/A"),
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
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 80),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget centerText(String value, {double size = 12, Uint8List? fontData}) {
    final customFont = pw.Font.ttf(fontData!.buffer.asByteData());
    return pw.Center(
      child: pw.Text(value,
          style: pw.TextStyle(
            fontSize: size,
            font: customFont,
          )),
    );
  }

  pw.Widget pdfCustomText(String value,
      {pw.FontWeight? fontweight, required fontData}) {
    final customFont = pw.Font.ttf(fontData.buffer.asByteData());

    return pw.Text(value.toUpperCase(),
        style: pw.TextStyle(
            font: customFont,
            fontSize: 16,
            fontWeight: fontweight ?? pw.FontWeight.normal));
  }
}
