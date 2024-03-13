import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import 'package:sifr_latest/widgets/app/customAlert.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';
import '../../services/user_services.dart';
import '../../widgets/qr_code_widget.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic>? merchantDetails;

  const PaymentPage({super.key, this.merchantDetails});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  UserServices userServices = UserServices();
  late final Map<String, dynamic>? invoiceDetails;
  CustomAlert customAlert = CustomAlert();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (kDebugMode) print(widget.merchantDetails!['merchantId']);

    getMerchantInvoiceDetails(widget.merchantDetails!['merchantId'], 0);
  }

  getMerchantInvoiceDetails(merchantId, int count) async {
    invoiceDetails = widget.merchantDetails!['merchantProductDetailsResponse'];
    if (kDebugMode) print(invoiceDetails);

    setState(() {});

    //if(kDebugMode)print("----AllMerchantApplications called----$merchantId");
    //
    // var response = await userServices.getMerchantInvoiceDetails(merchantId);
    //
    // final Map<String, dynamic> data = json.decode(response.body);
    //
    //if(kDebugMode)print(data);
    //
    // if (data['totalAmount'] != null) {
    //   invoiceDetails = data;
    //  if(kDebugMode)print(invoiceDetails);
    //   setState(() {});
    //   return;
    // }
    //
    // if(count==0){
    //   getMerchantInvoiceDetails("ADIBM0000000362",1);
    // }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle() {
      return const TextStyle(fontWeight: FontWeight.bold);
    }

    return AppScafofld(
        closePressed: () {

        },
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: invoiceDetails!['merchantProductDetails'] != null
            ? ListView(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextWidget(
                        text: "Invoice Details",
                        size: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextWidget(
                          text: "${widget.merchantDetails!['mobile']}",
                          size: 14,
                        ),
                        CustomTextWidget(
                          text: "${widget.merchantDetails!['name']}",
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DataTable(
                    columnSpacing: 10,
                    dataRowMinHeight: 20,
                    dataRowMaxHeight: 30,
                    columns: [
                      DataColumn(
                          label: Text(
                        'Product',
                        style: textStyle(),
                      )),
                      DataColumn(
                          label: Text(
                        'Quantity',
                        style: textStyle(),
                      )),
                      DataColumn(
                          label: Text(
                        'Unit Price',
                        style: textStyle(),
                      )),
                      DataColumn(
                          label: Text(
                        'Amount',
                        style: textStyle(),
                      )),
                    ],
                    rows: [
                      for (var item
                          in invoiceDetails!['merchantProductDetails'])
                        DataRow(cells: [
                          customDataCell(data: item['productName']),
                          customDataCell(data: item['qty'].toString()),
                          customDataCell(data: item['unitPrice'].toString()),
                          customDataCell(data: item['amount'].toString()),
                        ]),

                      // DataRow(cells: [
                      //   customDatacell(data: "Android Pos"),
                      //   customDatacell(data: "1"),
                      //   customDatacell(data: "1000"),
                      //   customDatacell(data: "1000"),
                      // ]),
                      // DataRow(cells: [
                      //   customDatacell(data: "Sound Box"),
                      //   customDatacell(data: "2"),
                      //   customDatacell(data: "3000"),
                      //   customDatacell(data: "6000"),
                      // ]),
                      // DataRow(cells: [
                      //   customDatacell(data: "SoftPos"),
                      //   customDatacell(data: "1"),
                      //   customDatacell(data: "3000"),
                      //   customDatacell(data: "3000"),
                      // ]),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const CustomTextWidget(
                                  text: "Total",
                                  fontWeight: FontWeight.bold,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                CustomTextWidget(
                                  text: '${invoiceDetails!['totalAmount']}',
                                  fontWeight: FontWeight.bold,
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                CustomTextWidget(
                                  text: "GST ${invoiceDetails!['gst']}",
                                  fontWeight: FontWeight.bold,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                CustomTextWidget(
                                  text: '${invoiceDetails!['gstAmount']}',
                                  fontWeight: FontWeight.bold,
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                const CustomTextWidget(
                                  text: "Payable Amount",
                                  fontWeight: FontWeight.bold,
                                ),
                                const SizedBox(
                                  width: 40,
                                ),
                                CustomTextWidget(
                                  text: '${invoiceDetails!['payableAmount']}',
                                  fontWeight: FontWeight.bold,
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          QRCode(
                            qrSize: 250,
                            qrBackgroundColor: Colors.white,
                            qrPadding: 13,
                            qrBorderRadius: 10,
                            qrForegroundColor: Theme.of(context).primaryColor,
                            qrData:
                                //"upi://pay?pa=7558877098@apl&pn=Ajo Sebastian&am=500&cu=INR&tn=justForFun",
                                "000201010212260800043456520499953039785406100.235802IT5907Druidia6005MILAN6233012910000001#QRID00000421##10001#",
                            gapLess: false,
                            // embeddedImage: AssetImage("assets/logo.jpg"),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const CustomTextWidget(
                            text: "Scan The QR ",
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const CustomTextWidget(text: "OR "),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomAppButton(
                    title: 'Payment Link',
                    onPressed: () {
                      Navigator.pushNamed(context, "PaymentSuccessPage");
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                ],
              )
            : const Center(
                child: Text('No Data found'),
              ));
  }

  DataCell customDataCell({required String data}) => DataCell(CustomTextWidget(
        text: data,
        size: 12,
      ));
}
