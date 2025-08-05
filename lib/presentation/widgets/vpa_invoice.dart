import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:flutter/material.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class ShowVpaTransactionInvoice extends StatelessWidget {
  final Map<String, dynamic> transaction;
  const ShowVpaTransactionInvoice({super.key, required this.transaction});

  String getCurrencySymbol(String? code) {
    if (code == "356" || code == "INR") return "INR";
    return "₹"; // Since it's UPI-based
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
            Center(
              child: CustomTextWidget(
                text: transaction["addr"] ?? "N/A",
                size: 13,
                maxLines: 3,
                isBold: false,
              ),
            ),
            defaultHeight(basePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildKeyValueRow(
                    "Date", transaction["ts"]?.split("T").first ?? "N/A"),
                buildKeyValueRow(
                    "Time", transaction["ts"]?.split("T").last ?? "N/A"),
              ],
            ),
            defaultHeight(basePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildKeyValueRow(
                    "Merchant ID", transaction["merchantId"] ?? "N/A"),
                buildKeyValueRow("Ref ID", transaction["refId"] ?? "N/A"),
              ],
            ),
            defaultHeight(basePadding),
            buildKeyValueRow(
                "Transaction Type", getTransactionType(transaction)),
            defaultHeight(basePadding),
            buildKeyValueRow(
                "Account Type", transaction["accountDetailsAccType"] ?? "N/A"),
            defaultHeight(basePadding),
            buildKeyValueRow("Mobile", transaction["mobileNumber"] ?? "N/A"),
            defaultHeight(basePadding),
            buildKeyValueRow(
                "Customer VPA", transaction["customerVpa"] ?? "N/A"),
            defaultHeight(basePadding),
            buildKeyValueRow("Payee VPA", transaction["creditVpa"] ?? "N/A"),
            defaultHeight(basePadding),
            buildKeyValueRow("RRN", transaction["rrn"] ?? "N/A"),
            defaultHeight(basePadding),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextWidget(
                  text: "AMOUNT ",
                  size: 16,
                  isBold: true,
                ),
                SizedBox(width: screenWidth * 0.05),
                CustomTextWidget(
                  text: getCurrencySymbol(transaction["code"]?.toString()),
                  size: 20,
                  isBold: true,
                ),
                SizedBox(width: screenWidth * 0.05),
                CustomTextWidget(
                  text: transaction["transactionAmount"] ?? "N/A",
                  size: 16,
                  isBold: true,
                ),
              ],
            ),
            Divider(),
            defaultHeight(basePadding),
            if (transaction["regName"] != null &&
                transaction["regName"].toString().isNotEmpty)
              Column(
                children: [
                  CustomTextWidget(
                    text: transaction["regName"],
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
            defaultHeight(mediumPadding),
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
      onTapHome: () => Navigator.pop(context),
      onTapSupport: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, "merchantHelpScreen");
      },
    );
  }

  Future<void> generatePDF(BuildContext context, double screenWidth,
      double screenHeight, double logoSize) async {
    final pdf = pw.Document();
    final logo =
        (await rootBundle.load('assets/screen/anet.png')).buffer.asUint8List();
    final merchantName =
        Provider.of<AuthProvider>(context, listen: false).merchantDbaName;
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Image(pw.MemoryImage(logo), height: logoSize),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  merchantName,
                  style: pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 5),
                centerText(transaction["addr"]),
                pw.SizedBox(height: 10),
                buildPdfKeyValueRow(
                    "Date", transaction["ts"]?.split("T").first),
                buildPdfKeyValueRow("Time", transaction["ts"]?.split("T").last),
                buildPdfKeyValueRow("Merchant ID", transaction["merchantId"]),
                buildPdfKeyValueRow("Ref ID", transaction["refId"]),
                buildPdfKeyValueRow(
                    "Transaction Type", getTransactionType(transaction)),
                buildPdfKeyValueRow(
                    "Account Type", transaction["accountDetailsAccType"]),
                buildPdfKeyValueRow("Mobile", transaction["mobileNumber"]),
                buildPdfKeyValueRow("Customer VPA", transaction["customerVpa"]),
                buildPdfKeyValueRow("Payee VPA", transaction["creditVpa"]),
                buildPdfKeyValueRow("RRN", transaction["rrn"]),
                pw.Divider(),
                pw.Center(
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text("AMOUNT ",
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 5),
                      pw.Text(getCurrencySymbol(transaction["code"]),
                          style: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(width: 5),
                      pw.Text(transaction["transactionAmount"] ?? "N/A",
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Divider(),
                if (transaction["regName"] != null &&
                    transaction["regName"].toString().isNotEmpty)
                  pw.Center(
                    child: pw.Text(
                      transaction["regName"],
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                pw.SizedBox(height: 10),
                centerText(
                    "* I am Satisfied with the goods/Services received and agree to pay as per issuer terms."),
                centerText("THANK YOU MERCHANT\nPLEASE KEEP THIS COPY"),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  Widget buildKeyValueRow(String key, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomTextWidget(
          text: key,
          size: 13,
          isBold: true,
        ),
        CustomTextWidget(
          text: value ?? "N/A",
          size: 13,
          isBold: false,
        ),
      ],
    );
  }

  pw.Widget buildPdfKeyValueRow(String key, String? value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(key,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.Text(value ?? "N/A", style: pw.TextStyle(fontSize: 13)),
      ],
    );
  }

  String getTransactionType(Map<String, dynamic> transaction) {
    final String? code = transaction["transactionType"];
    switch (code) {
      case "00":
      case "TRANSFER":
        return "Cash Withdrawal";
      case "21":
        return "Balance Enquiry";
      case "22":
        return "Mini Statement";
      default:
        return code ?? "N/A";
    }
  }

  pw.Widget centerText(String? text) {
    return pw.Center(
      child: pw.Text(
        text ?? "N/A",
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 12),
      ),
    );
  }
}
