/* ===============================================================
| Project : SIFR
| Page    : TRANSACTION_DETAILS.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../config/endpoints.dart';
import '../widget.dart';

// STATEFUL WIDGET
class TransactionDetails extends StatefulWidget {
  final dynamic receipt;
  const TransactionDetails({Key? key, this.receipt}) : super(key: key);

  @override
  State<TransactionDetails> createState() => _TransactionDetailsState();
}

// Transaction Details State Class
class _TransactionDetailsState extends State<TransactionDetails> {
  //Height of sizebox
  final defaultHeight = const SizedBox(
    height: 20,
  );
  //Devider widget
  final defaultDivider = const Divider(
    indent: 10,
    endIndent: 10,
    color: Colors.grey,
  );
  late String generatedPdfFilePath;

  // Init function for page Initialization
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.receipt;
    return Scaffold(
        appBar: AppBarWidget(
          title: "${data['processFlag']} Details",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: [
              defaultHeight,
              Center(
                child: Image.network('${EndPoints.sifrLogo}/OmaPay_Logo.PNG'),
              ),
              defaultHeight,
              Center(
                child: Text(
                  "Transaction Receipt",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Center(
                  child: Text(
                data['tranDateTime'].toString(),
                style: Theme.of(context).textTheme.titleSmall,
              )),
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Receipt Number",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.normal),
                      ),
                      Text(
                        data['receiptNumber'].toString(),
                        style: Theme.of(context).textTheme.titleSmall,
                      )
                    ]),
              ),
              data['terminalId'] != null
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Terminal ID",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.normal),
                                ),
                                Text(
                                  data['terminalId'] ?? 'NIL',
                                  style: Theme.of(context).textTheme.titleSmall,
                                )
                              ]),
                        ),
                      ],
                    )
                  : Container(),
              data['merchantId'] != null
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Merchant ID",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.normal),
                                ),
                                Text(
                                  data['merchantId'] ?? 'NIL',
                                  style: Theme.of(context).textTheme.titleSmall,
                                )
                              ]),
                        ),
                      ],
                    )
                  : Container(),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "RRN",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.normal),
                      ),
                      Text(
                        data['retrivalReferenceNumber'].toString(),
                        style: Theme.of(context).textTheme.titleSmall,
                      )
                    ]),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Trace Number",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.normal),
                      ),
                      Text(
                        data['traceNumber'] ?? 'NIL',
                        style: Theme.of(context).textTheme.titleSmall,
                      )
                    ]),
              ),
              const SizedBox(
                height: 5,
              ),
              data['authCode'] != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Auth Code",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.normal),
                            ),
                            Text(
                              data['authCode'].toString(),
                              style: Theme.of(context).textTheme.titleSmall,
                            )
                          ]),
                    )
                  : Container(),
              const SizedBox(height: 5),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mode of Payment",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.normal),
                            ),
                            // const SizedBox(height: 5,),
                            Text(
                              data['fundSource'].toString() == 'null'
                                  ? 'NIL'
                                  : data['fundSource'].toString(),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Account/Card",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.normal),
                            ),
                            Text(
                              data['fundSource'].toString() == "ACCOUNT"
                                  ? data['accountNumber'].toString()
                                  : data['cardReferenceNumber'].toString(),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ])),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Amount",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.normal),
                            ),
                            Text(
                              // ${receiptData['receipt']['currencyCode'].toString()}
                              "AED ${data['amount'].toString()}",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Fee Amount",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.normal),
                            ),
                            Text(
                              data['feeAmount'].toString(),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        )
                      ])),
              const SizedBox(
                height: 20,
              ),
              const Center(
                child: Text("Thanks for using Service"),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: TextButton(
                    onPressed: () {
                      downloadPDF();
                    },
                    child: Text(
                      'Download Receipt',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    )),
              ),
              Center(
                child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'complaintTypeDetails',
                          arguments: {'receipt': data, 'type': 'transaction'});
                    },
                    child: Text(
                      'Raise a Complaint',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    )),
              ),
            ],
          ),
        )));
  }

  // Generate pdf
  Future<void> downloadPDF() async {
    dynamic receiptData = widget.receipt;
    var merchantId = "";
    var terminalId = "";
    if (receiptData['merchantId'] != null) {
      merchantId = """<tr>
      <td>
      <h2>Merchant</h2>
    </td>
    <td>
    <h2 class="txt-end">${receiptData['merchantId'].toString()}</h2>
    </td>
    </tr>""";
    }
    if (receiptData['terminalId'] != null) {
      terminalId = """<tr>
          <td>
            <h2>Terminal ID</h2>
          </td>
          
          <td>
            <h2 class="txt-end">${receiptData['terminalId'].toString()}</h2>
          </td>
        </tr>""";
    }
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
        $terminalId
       $merchantId
        <tr>
          <td>
            <h2>RRN</h2>
          </td>
          <td>
            <h2 class="txt-end">${receiptData['retrivalReferenceNumber'].toString()}</h2>
          </td>
        </tr>
        <tr >
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
            <p>${receiptData['fundSource'].toString() == 'null' ? 'NIL' : receiptData['fundSource'].toString()}</p>
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

    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent, targetPath, targetFileName);
    generatedPdfFilePath = generatedPdfFile.path;
    OpenFile.open(generatedPdfFilePath);
  }
}
