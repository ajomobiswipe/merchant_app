/* ===============================================================
| Project : SIFR
| Page    : RECENT_TRANSACTION.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../config/endpoints.dart';

// STATELESS WIDGET
class RecentTransactions extends StatelessWidget {
  const RecentTransactions(this.list, {super.key});

  // LOCAL VARIABLE DECLARATION
  final dynamic list;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'transactionDetails',
            arguments: {'receipt': list});
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  child: Icon(
                    FontAwesome.money_bill_solid,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        list['fundSource'] == 'ACCOUNT'
                            ? list['accountNumber']
                            : list['cardReferenceNumber'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        list['tranDateTime'],
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.black45),
                      ),
                      Text(
                        list['tranType'],
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.black45, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'AED ${list['amount']}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: list['processFlag'] == 'DEBIT'
                              ? Colors.red
                              : Theme.of(context).primaryColor),
                    ),
                    IconButton(
                        onPressed: () {
                          downloadPDF();
                        },
                        icon: const Icon(LineAwesome.cloud_download_alt_solid))
                  ],
                ),
              ],
            )),
      ),
    );
  }

  //Generate pdf
  Future<void> downloadPDF() async {
    dynamic receiptData = list;
    var htmlContent = """
   <!DOCTYPE html>
<html>
  <head>
    <title>Withdraw Receipt</title>
  </head>
  <style>@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap');body{font-family: 'Poppins', sans-serif;}.wid-rpt{/*width: 500px;margin: auto;*/padding: 50px 30px;}.wid-rpt img{width: 400px;}.wid-rpt__receipt{text-align: center;margin: 50px 0px;}.wid-rpt__receipt p{line-height: 0px!important;}.wid-rpt__receipt h1{font-weight: 600; font-size: 27px;}.wid-rpt__receipt p{font-size: 21px;}tr{line-height: 5px !important;}td p{line-height: 0px !important;}.wid-rpt_bot-dash-bor{border-bottom: 2px dashed #000;margin: 20px 0px;}.txt-end{text-align: end;}.wid-rpt_thanks-txt{font-size: 23px;text-align: center;}.wid-rpt_mod-pay p{font-size: 20px;}</style>
  <body>
    <section class="wid-rpt">
      <div>
        <center><img src="${EndPoints.sifrLogo}/OmaPay_Logo.PNG"></center>
      </div>
      <div class="wid-rpt__receipt">
        <h1>${receiptData['tranDateTime'].toString()}</h1>
        <p>${receiptData['tranDateTime'].toString()}</p>
      </div>
      <table style="width:100%">
        <tr>
          <td>
            <h2>Receipt Number</h2>
          </td>
          <td>
            <h2 class="txt-end">${receiptData['receiptNumber'].toString()}</h2>
          </td>
        </tr>
        <tr>
          <td>
            <h2>Terminal ID</h2>
          </td>
          <td>
            <h2 class="txt-end">${receiptData['terminalId'].toString()}</h2>
          </td>
        </tr>
        <tr>
          <td>
            <h2>Merchant</h2>
          </td>
          <td>
            <h2 class="txt-end">${receiptData['merchantId'].toString()}</h2>
          </td>
        </tr>
        <tr>
          <td>
            <h2>RRN</h2>
          </td>
          <td>
            <h2 class="txt-end">${receiptData['retrivalReferenceNumber'].toString()}</h2>
          </td>
        </tr>
        <tr>
          <td>
            <h2>Trace Number</h2>
          </td>
          <td>
            <h2 class="txt-end">${receiptData['traceNumber'].toString()}</h2>
          </td>
        </tr>
        <tr>
          <td>
            <h2>Auth Code</h2>
          </td>
          <td>
            <h2 class="txt-end">${receiptData['authCode'].toString()}</h2>
          </td>
        </tr>
      </table>
      <div class="wid-rpt_bot-dash-bor"></div>
      <table style="width:100%" class="wid-rpt_mod-pay">
        <tr>
          <td>
            <h2>Mode of Payment</h2>
          </td>
          <td>
            <h2 class="txt-end">Account</h2>
          </td>
        </tr>
        <tr>
          <td>
            <p>${receiptData['fundSource'].toString()}</p>
          </td>
          <td>
            <p class="txt-end">${receiptData['fundSource'].toString() == "ACCOUNT" ? receiptData['accountNumber'].toString() : receiptData['cardReferenceNumber'].toString()}</p>
          </td>
        </tr>
        <tr>
          <td>
            <h2>Amount</h2>
          </td>
          <td>
            <h2 class="txt-end">Fee amount</h2>
          </td>
        </tr>
        <tr>
          <td>
            <p>AED ${receiptData['amount'].toString()}</p>
          </td>
          <td>
            <p class="txt-end">${receiptData['feeAmount'].toString()}</p>
          </td>
        </tr>
      </table>
      <div class="wid-rpt_thanks-txt">
        <p>Thanks for using Service</p>
      </div>
    </section>
  </body>
</html>
    """;
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final targetPath = appDocDir.path;
    const targetFileName = "withdraw_receipt";
    String generatedPdfFilePath;

    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent, targetPath, targetFileName);
    generatedPdfFilePath = generatedPdfFile.path;
    OpenFile.open(generatedPdfFilePath);
  }
}
