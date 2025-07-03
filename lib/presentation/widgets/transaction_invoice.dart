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
    if (code == "356") return "INR";
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
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Colors.red,
        child: Icon(Icons.close, color: Colors.white, size: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     GestureDetector(
            //       onTap: () => Navigator.pop(context),
            //       child: Container(
            //         decoration: BoxDecoration(
            //           color: Colors.red,
            //           shape: BoxShape.circle,
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.black.withOpacity(0.2),
            //               blurRadius: 6,
            //               offset: Offset(0, 3),
            //             ),
            //           ],
            //         ),
            //         padding: const EdgeInsets.all(8),
            //         child: Icon(
            //           Icons.close,
            //           color: Colors.white,
            //           size: 24,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // defaultHeight(basePadding),

            Center(
              child: Image.asset(
                'assets/screen/anet.png',
                height: screenHeight * .1,
                width: screenWidth * 0.5,
              ),
            ),
            defaultHeight(basePadding),
            Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.9,
                  child: CustomTextWidget(
                    text: Provider.of<AuthProvider>(context).merchantDbaName,
                    maxLines: 3,
                  ),
                ),
              ],
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
            defaultHeight(basePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  isBold: false,
                  size: 12,
                  text: "TID: ${transaction.terminalId ?? "N/A"}",
                  isUpperCase: true,
                ),
                CustomTextWidget(
                  size: 12,
                  isBold: false,
                  text: "MID: ${transaction.merchantId ?? "N/A"}",
                  isUpperCase: true,
                ),
              ],
            ),
            defaultHeight(basePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  isBold: false,
                  size: 12,
                  text: "BATCH NO: ${transaction.batchNo ?? "N/A"}",
                  isUpperCase: true,
                ),
                CustomTextWidget(
                  size: 12,
                  isBold: false,
                  text: "INVOICE: ${transaction.stan ?? "N/A"}",
                  isUpperCase: true,
                ),
              ],
            ),
            defaultHeight(basePadding),

            // Transaction Type
            Center(
              child: CustomTextWidget(
                isBold: true,
                text: getTransactionType(transaction),
                size: 20,
              ),
            ),
            defaultHeight(basePadding),

            // MID & TID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text:
                      "CARD TYPE: ${transaction.schemeName ?? getSchemeNameFromCardNumber(transaction.cardNo)}",
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "EXP: XX/XX",
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
                  text: "CARD NO: ${transaction.cardNo ?? "N/A"}",
                  isUpperCase: true,
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: getPosEntryMode(transaction.posEntryMode),
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
                  text: "AUTH CODE: ${transaction.authCode ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "RRN: ${transaction.rrn ?? "N/A"}",
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
                  text: "AID: ${transaction.acquirerId ?? "N/A"}",
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
                  text: "LABEL: ${transaction.schemeName ?? "N/A"}",
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
                  text: "TC: ${transaction.batchNo ?? "N/A"}  ",
                  size: 12,
                  isBold: false,
                ),
              ],
            ),
            defaultHeight(basePadding),

            // Cardholder Name

            Divider(),
            // Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            Divider(),
            // Transaction Confirmation Message
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: CustomTextWidget(
                      textAlign: TextAlign.center,
                      text: getPinVerifyMessage(type: transaction.posEntryMode),
                      size: 14,
                      isBold: false,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            ),

            defaultHeight(mediumPadding),
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

            SizedBox(
              width: screenWidth * 0.9,
              child: CustomTextWidget(
                textAlign: TextAlign.center,
                text:
                    "* I am Satisfied with the goods/Services received and agree to pay as per issuer terms.",
                size: 14,
                isBold: false,
                maxLines: 3,
              ),
            ),
            SizedBox(
              width: screenWidth * 0.9,
              child: CustomTextWidget(
                textAlign: TextAlign.center,
                text: "THANK YOU MERCHANT\nPLEASE KEEP THIS COPY",
                size: 14,
                isBold: false,
                maxLines: 3,
              ),
            ),
            SizedBox(
              width: screenWidth * 0.9,
              child: CustomTextWidget(
                textAlign: TextAlign.center,
                text: "<<MERCHANT COPY>>",
                size: 18,
                isBold: true,
                maxLines: 3,
              ),
            ),
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

  getTransactionType(TransactionElement? txn) {
    if (txn == null) return "N/A";
    if (txn.transactionType == "OSAL001") {
      return "SALE";
    }

    if (txn.transactionType == "VSAL001") {
      return "VOID-SALE";
    }
    if (txn.transactionType == "POS-REVERSAL") {
      return "POS-REVERSAL";
    }

    return txn.transactionType ?? "N/A";
  }

  getPosEntryMode(String? type) {
    if (type == "051") return "Chip";
    if (type == "071") return "CTLS";
    return type ?? "N/A";
  }

  getPinVerifyMessage({String? type}) {
    if (type == "051") return "PIN VERIFIED OK SIGNATURE NOT REQUIRED";
    if (type == "071") return "PIN NOT REQUIRED FOR CONTACTLESS TRANSACTION";

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

    final merchantName =
        Provider.of<AuthProvider>(context, listen: false).merchantDbaName;

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.symmetric(
            horizontal: screenWidth * .1, vertical: screenHeight * 0.05),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Image(pw.MemoryImage(logo), height: logoSize),
              ),
              pw.SizedBox(height: screenHeight * .02),

              /// Merchant Name
              centerText(
                merchantName,
                fontData: fontDataBold,
                fontWeight: pw.FontWeight.bold,
                size: 14,
              ),
              pw.SizedBox(height: screenHeight * .02),

              /// Date & Time
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText("Date: ${transaction.transactionDate ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText("Time: ${transaction.transactionTime ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .02),

              /// TID & MID
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText("TID: ${transaction.terminalId ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText("MID: ${transaction.merchantId ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .02),

              /// Batch & Invoice
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText("BATCH NO: ${transaction.batchNo ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText("INVOICE: ${transaction.stan ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .02),

              /// Transaction Type
              centerText(getTransactionType(transaction),
                  size: 24, fontData: fontDataBold),
              pw.SizedBox(height: screenHeight * .02),

              /// CARD TYPE & EXP
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText(
                      "CARD TYPE: ${transaction.schemeName ?? getSchemeNameFromCardNumber(transaction.cardNo)}",
                      fontData: fontDataRegular),
                  pdfCustomText("EXP: XX/XX", fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .02),

              /// CARD NO & ENTRY MODE
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText("CARD NO: ${transaction.cardNo ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText(getPosEntryMode(transaction.posEntryMode),
                      fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .02),

              /// AUTH & RRN
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pdfCustomText("AUTH CODE: ${transaction.authCode ?? "N/A"}",
                      fontData: fontDataRegular),
                  pdfCustomText("RRN: ${transaction.rrn ?? "N/A"}",
                      fontData: fontDataRegular),
                ],
              ),
              pw.SizedBox(height: screenHeight * .02),

              /// AID
              pdfCustomText("AID: ${transaction.acquirerId ?? "N/A"}",
                  fontData: fontDataRegular),
              pw.SizedBox(height: screenHeight * .02),

              /// LABEL
              pdfCustomText("LABEL: ${transaction.schemeName ?? "N/A"}",
                  fontData: fontDataRegular),
              pw.SizedBox(height: screenHeight * .02),

              /// TVR & TSI
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

              /// TC
              pdfCustomText("TC: ${transaction.batchNo ?? "N/A"}",
                  fontData: fontDataRegular),
              pw.Divider(),

              /// Amount
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  pw.Text("AMOUNT",
                      style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          font: pw.Font.ttf(fontDataBold.buffer.asByteData()))),
                  pw.Text(getCurrencySymbol(transaction.currency),
                      style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          font: pw.Font.ttf(fontDataBold.buffer.asByteData()))),
                  pw.Text(transaction.amount ?? "N/A",
                      style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          font: pw.Font.ttf(fontDataBold.buffer.asByteData()))),
                ],
              ),
              pw.Divider(),

              /// PIN Message
              centerText(getPinVerifyMessage(type: transaction.posEntryMode),
                  size: 14, fontData: fontDataRegular),
              pw.SizedBox(height: screenHeight * .02),

              /// Cardholder Name
              if (transaction.nameOnCard != null)
                pw.Column(children: [
                  pdfCustomText(transaction.nameOnCard!,
                      fontData: fontDataBold, fontweight: pw.FontWeight.bold),
                  pw.SizedBox(height: screenHeight * .02),
                ]),

              /// Satisfaction & Footer
              centerText(
                  "* I am Satisfied with the goods/Services received and agree to pay as per issuer terms.",
                  size: 14,
                  fontData: fontDataRegular),
              pw.SizedBox(height: screenHeight * .01),
              centerText("THANK YOU MERCHANT\nPLEASE KEEP THIS COPY",
                  size: 14, fontData: fontDataRegular),
              pw.SizedBox(height: screenHeight * .01),
              centerText("<<MERCHANT COPY>>", size: 18, fontData: fontDataBold),
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

  pw.Widget centerText(String value,
      {double size = 12,
      Uint8List? fontData,
      pw.FontStyle? fontStyle,
      pw.FontWeight? fontWeight}) {
    final customFont = pw.Font.ttf(fontData!.buffer.asByteData());
    return pw.Center(
      child: pw.Text(value,
          style: pw.TextStyle(
            fontSize: size,
            fontStyle: fontStyle,
            fontWeight: fontWeight,
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
