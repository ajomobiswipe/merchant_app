/* ===============================================================
| Project : SIFR
| Page    : SUCCESS_RECEIPT.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

// STATEFUL WIDGET
class SuccessReceiptForDemo extends StatefulWidget {

  const SuccessReceiptForDemo({super.key});


  @override
  State<SuccessReceiptForDemo> createState() => _SuccessReceiptForDemoState();
}

// Success Receipt State Class
class _SuccessReceiptForDemoState extends State<SuccessReceiptForDemo> {
  // LOCAL VARIABLE DECLARATION
  late String generatedPdfFilePath;

  // Init function for page Initialization
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var data = jsonDecode(widget.receipt);
    // var data = widget.receipt;
    return WillPopScope(
        onWillPop: () async {
          debugPrint("Will pop");
          Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            // title: Text(data['receiptIcon']['successHeader'].toString()),
            title: const Text('Payment Success'),
            centerTitle: true,
            automaticallyImplyLeading: true,
            elevation: 5,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Lottie.asset('assets/lottie/sifr-congrats.json', height: 200),
                // Center(
                //     child: Column(
                //   children: <Widget>[
                //     Image.network(
                //         data['receiptIcon']['iconPath'][0].toString()),
                //     // Image.network('https://softposreceipt.omaemirates.com:8988/SoftPOS/SifrLogo/OmaPay_Logo.PNG'),
                //   ],
                // )),
                const SizedBox(
                  height: 20,
                ),

                const Center(
                  child: Text("Your Payment is success",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                // const Center(
                //   child: Text("Transaction Receipt",
                //       style:
                //           TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                // ),
                const SizedBox(
                  height: 5,
                ),
                // Center(
                //     child: Text(data['receipt']['tranDateTime'].toString(),
                //         style: const TextStyle(fontSize: 12))),
                const SizedBox(
                  height: 20,
                ),
                // Padding(
                //   padding:
                //       const EdgeInsets.only(right: 10, left: 10, bottom: 5),
                //   child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           "Receipt Number",
                //           style: Theme.of(context)
                //               .textTheme
                //               .bodyMedium
                //               ?.copyWith(
                //                   color: Colors.black54,
                //                   fontWeight: FontWeight.bold),
                //         ),
                //         Text(
                //           data['receipt']['receiptNumber'].toString(),
                //         )
                //       ]),
                // ),
                // Padding(
                //   padding:
                //       const EdgeInsets.only(right: 10, left: 10, bottom: 5),
                //   child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           "Terminal ID",
                //           style: Theme.of(context)
                //               .textTheme
                //               .bodyMedium
                //               ?.copyWith(
                //                   color: Colors.black54,
                //                   fontWeight: FontWeight.bold),
                //         ),
                //         Text(
                //           data['receipt']['terminalId'].toString(),
                //         )
                //       ]),
                // ),
                // Padding(
                //   padding:
                //       const EdgeInsets.only(right: 10, left: 10, bottom: 5),
                //   child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           "Merchant Name",
                //           style: Theme.of(context)
                //               .textTheme
                //               .bodyMedium
                //               ?.copyWith(
                //                   color: Colors.black54,
                //                   fontWeight: FontWeight.bold),
                //         ),
                //         Text(
                //           data['receipt']['merchantName'].toString(),
                //         )
                //       ]),
                // ),
                // Padding(
                //   padding:
                //       const EdgeInsets.only(right: 10, left: 10, bottom: 5),
                //   child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           "Merchant",
                //           style: Theme.of(context)
                //               .textTheme
                //               .bodyMedium
                //               ?.copyWith(
                //                   color: Colors.black54,
                //                   fontWeight: FontWeight.bold),
                //         ),
                //         Text(
                //           data['receipt']['merchantId'].toString(),
                //         )
                //       ]),
                // ),
                // Padding(
                //   padding:
                //       const EdgeInsets.only(right: 10, left: 10, bottom: 5),
                //   child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           "RRN",
                //           style: Theme.of(context)
                //               .textTheme
                //               .bodyMedium
                //               ?.copyWith(
                //                   color: Colors.black54,
                //                   fontWeight: FontWeight.bold),
                //         ),
                //         Text(
                //           data['receipt']['retrivalReferenceNumber'].toString(),
                //         )
                //       ]),
                // ),
                // Padding(
                //   padding:
                //       const EdgeInsets.only(right: 10, left: 10, bottom: 5),
                //   child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           "Trace Number",
                //           style: Theme.of(context)
                //               .textTheme
                //               .bodyMedium
                //               ?.copyWith(
                //                   color: Colors.black54,
                //                   fontWeight: FontWeight.bold),
                //         ),
                //         Text(
                //           data['receipt']['traceNumber'].toString(),
                //         )
                //       ]),
                // ),
                // Padding(
                //   padding:
                //       const EdgeInsets.only(right: 10, left: 10, bottom: 5),
                //   child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           "Auth Code",
                //           style: Theme.of(context)
                //               .textTheme
                //               .bodyMedium
                //               ?.copyWith(
                //                   color: Colors.black54,
                //                   fontWeight: FontWeight.bold),
                //         ),
                //         Text(
                //           data['receipt']['authCode'].toString(),
                //         )
                //       ]),
                // ),
                // const SizedBox(
                //   height: 10,
                // ),
                // Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Column(
                //             mainAxisAlignment: MainAxisAlignment.start,
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 "Mode of Payment",
                //                 style: Theme.of(context)
                //                     .textTheme
                //                     .bodyMedium
                //                     ?.copyWith(
                //                         color: Colors.black54,
                //                         fontWeight: FontWeight.bold),
                //               ),
                //               // const SizedBox(height: 5,),
                //               Text(
                //                 data['receipt']['fundSource'].toString(),
                //               ),
                //             ],
                //           ),
                //           Column(
                //             mainAxisAlignment: MainAxisAlignment.end,
                //             crossAxisAlignment: CrossAxisAlignment.end,
                //             children: [
                //               Text(
                //                 "Account",
                //                 style: Theme.of(context)
                //                     .textTheme
                //                     .bodyMedium
                //                     ?.copyWith(
                //                         color: Colors.black54,
                //                         fontWeight: FontWeight.bold),
                //               ),
                //               // const SizedBox(height: 5,),
                //               Text(
                //                 data['receipt']['accountNumber'].toString(),
                //               ),
                //             ],
                //           ),
                //         ])),
                // Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Column(
                //             mainAxisAlignment: MainAxisAlignment.start,
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 "Amount",
                //                 style: Theme.of(context)
                //                     .textTheme
                //                     .bodyMedium
                //                     ?.copyWith(
                //                         color: Colors.black54,
                //                         fontWeight: FontWeight.bold),
                //               ),
                //               Text(
                //                 // ${receiptData['receipt']['currencyCode'].toString()}
                //                 "AED ${data['receipt']['amount'].toString()}",
                //               ),
                //             ],
                //           ),
                //           Column(
                //             mainAxisAlignment: MainAxisAlignment.end,
                //             crossAxisAlignment: CrossAxisAlignment.end,
                //             children: [
                //               Text(
                //                 "Fee Amount",
                //                 style: Theme.of(context)
                //                     .textTheme
                //                     .bodyMedium
                //                     ?.copyWith(
                //                         color: Colors.black54,
                //                         fontWeight: FontWeight.bold),
                //               ),
                //               Text(
                //                 data['receipt']['feeAmount'].toString(),
                //               ),
                //             ],
                //           )
                //         ])),
                // const SizedBox(
                //   height: 20,
                // ),
                // Center(
                //   child: Text(data['receiptIcon']['footer'].toString()),
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     TextButton(
                //       onPressed: () {
                //         downloadPdf();
                //       },
                //       child: Text(
                //         'Download Receipt',
                //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //             fontWeight: FontWeight.bold,
                //             decoration: TextDecoration.underline),
                //       ),
                //     ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, 'home', (route) => false);
                    },
                    child: Text(
                      'Go to Dashboard',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                    ))
                //   ],
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 15),
                //   child: RichText(
                //     textAlign: TextAlign.justify,
                //     softWrap: true,
                //     text: TextSpan(
                //       text: 'Disclaimer: ',
                //       style: Theme.of(context)
                //           .textTheme
                //           .bodyMedium
                //           ?.copyWith(fontWeight: FontWeight.bold),
                //       children: const <TextSpan>[
                //         TextSpan(
                //             text:
                //                 'Sifr will not responsible for the transaction occurs through Sifr App. Not responsible for any fraud or third party transaction. Sifr will debit commission from the transaction amount. Also Sifr will reverse the fund any time to the customer if merchant have insufficient fund during transaction',
                //             style: TextStyle(fontWeight: FontWeight.normal)),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ));
  }

//   //Generate pdf
//   Future<void> downloadPdf() async {
//     // dynamic receiptData = widget.receipt;
//     var receiptData = jsonDecode(widget.receipt);
//     var date = DateFormat('dd-MM-yyyy hh:mm:ss a')
//         .format(DateTime.parse(receiptData['receipt']['tranDateTime']))
//         .toString();
//     var htmlContent = """
//    <!DOCTYPE html>
// <html>
//   <head>
//     <title>Withdraw Receipt</title>
//   </head>
//   <style>@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;300;400;500;600;700;800;900&display=swap');body{font-family: 'Poppins', sans-serif;}.wid-rpt{/*width: 500px;margin: auto;*/padding: 50px 30px;}.wid-rpt img{width: 400px;}.wid-rpt__receipt{text-align: center;margin: 50px 0px;}.wid-rpt__receipt p{line-height: 0px!important;}.wid-rpt__receipt h1{font-weight: 600; font-size: 27px;}.wid-rpt__receipt p{font-size: 21px;}tr{line-height: 5px !important;}td p{line-height: 0px !important;}.wid-rpt_bot-dash-bor{border-bottom: 2px dashed #000;margin: 20px 0px;}.txt-end{text-align: end;}.wid-rpt_thanks-txt{font-size: 23px;text-align: center;}.wid-rpt_mod-pay p{font-size: 20px;}</style>
//   <body>
//     <section class="wid-rpt">
//       <div>
//         <center><img src="${receiptData['receiptIcon']['iconPath'][0].toString()}"></center>
//       </div>
//       <div class="wid-rpt__receipt">
//         <h1>${receiptData['receiptIcon']['successHeader'].toString()}</h1>
//         <p>${date.toString()}</p>
//       </div>
//       <table style="width:100%">
//         <tr>
//           <td>
//             <h2>Receipt Number</h2>
//           </td>
//           <td>
//             <h2 class="txt-end">${receiptData['receipt']['receiptNumber'].toString()}</h2>
//           </td>
//         </tr>
//         <tr>
//           <td>
//             <h2>Terminal ID</h2>
//           </td>
//           <td>
//             <h2 class="txt-end">${receiptData['receipt']['terminalId'].toString()}</h2>
//           </td>
//         </tr>
//         <tr>
//           <td>
//             <h2>Merchant Name</h2>
//           </td>
//           <td>
//             <h2 class="txt-end">${receiptData['receipt']['merchantName'].toString()}</h2>
//           </td>
//         </tr>
//         <tr>
//           <td>
//             <h2>Merchant</h2>
//           </td>
//           <td>
//             <h2 class="txt-end">${receiptData['receipt']['merchantId'].toString()}</h2>
//           </td>
//         </tr>
//         <tr>
//           <td>
//             <h2>RRN</h2>
//           </td>
//           <td>
//             <h2 class="txt-end">${receiptData['receipt']['retrivalReferenceNumber'].toString()}</h2>
//           </td>
//         </tr>
//         <tr>
//           <td>
//             <h2>Trace Number</h2>
//           </td>
//           <td>
//             <h2 class="txt-end">${receiptData['receipt']['traceNumber'].toString()}</h2>
//           </td>
//         </tr>
//         <tr>
//           <td>
//             <h2>Auth Code</h2>
//           </td>
//           <td>
//             <h2 class="txt-end">${receiptData['receipt']['authCode'].toString()}</h2>
//           </td>
//         </tr>
//       </table>
//       <div class="wid-rpt_bot-dash-bor"></div>
//       <table style="width:100%" class="wid-rpt_mod-pay">
//         <tr>
//           <td>
//             <h2>Mode of Payment</h2>
//           </td>
//           <td>
//             <h2 class="txt-end">Account</h2>
//           </td>
//         </tr>
//         <tr>
//           <td>
//             <p>${receiptData['receipt']['fundSource'].toString()}</p>
//           </td>
//           <td>
//             <p class="txt-end">${receiptData['receipt']['accountNumber'].toString()}</p>
//           </td>
//         </tr>
//         <tr>
//           <td>
//             <h2>Amount</h2>
//           </td>
//           <td>
//             <h2 class="txt-end">Fee amount</h2>
//           </td>
//         </tr>
//         <tr>
//           <td>
//             <p>AED ${receiptData['receipt']['amount'].toString()}</p>
//           </td>
//           <td>
//             <p class="txt-end">${receiptData['receipt']['feeAmount'].toString()}</p>
//           </td>
//         </tr>
//       </table>
//       <div class="wid-rpt_thanks-txt">
//         <p>${receiptData['receiptIcon']['footer'].toString()}</p>
//       </div>
//     </section>
//   </body>
// </html>
//     """;
//     Directory appDocDir = await getApplicationDocumentsDirectory();
//     final targetPath = appDocDir.path;
//     const targetFileName = "withdraw_receipt";
//
//     final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
//         htmlContent, targetPath, targetFileName);
//     generatedPdfFilePath = generatedPdfFile.path;
//     OpenFile.open(generatedPdfFilePath);
//   }
}
