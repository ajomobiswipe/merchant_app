import 'package:flutter/material.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';
import '../../widgets/qr_code_widget.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyle() {
      return const TextStyle(fontWeight: FontWeight.bold);
    }

    return AppScafofld(
        child: ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextWidget(
              text: "Invoice Details",
              size: 22,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                text: "65456456454",
                size: 14,
              ),
              CustomTextWidget(
                text: "Mariah Stanley",
                size: 22,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        DataTable(
          columnSpacing: 20,
          dataRowMinHeight: 20,
          dataRowMaxHeight: 30,
          columns: [
            DataColumn(
                label: Text(
              'Product',
              style: _textStyle(),
            )),
            DataColumn(
                label: Text(
              'Quantity',
              style: _textStyle(),
            )),
            DataColumn(
                label: Text(
              'Unit Price',
              style: _textStyle(),
            )),
            DataColumn(
                label: Text(
              'Amount',
              style: _textStyle(),
            )),
          ],
          rows: [
            DataRow(cells: [
              customDatacell(data: "Android Pos"),
              customDatacell(data: "1"),
              customDatacell(data: "1000"),
              customDatacell(data: "1000"),
            ]),
            DataRow(cells: [
              customDatacell(data: "Sound Box"),
              customDatacell(data: "2"),
              customDatacell(data: "3000"),
              customDatacell(data: "6000"),
            ]),
            // DataRow(cells: [
            //   customDatacell(data: "SoftPos"),
            //   customDatacell(data: "1"),
            //   customDatacell(data: "3000"),
            //   customDatacell(data: "3000"),
            // ]),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      CustomTextWidget(
                        text: "Total",
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      CustomTextWidget(
                        text: "10000",
                        fontWeight: FontWeight.bold,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      CustomTextWidget(
                        text: "GST 18%",
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      CustomTextWidget(
                        text: "1800",
                        fontWeight: FontWeight.bold,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      CustomTextWidget(
                        text: "Payeable Amount",
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(
                        width: 40,
                      ),
                      CustomTextWidget(
                        text: "11800",
                        fontWeight: FontWeight.bold,
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        SizedBox(
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
                SizedBox(
                  height: 20,
                ),
                CustomTextWidget(
                  text: "Scan The QR ",
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextWidget(text: "OR "),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        CustomAppButton(
          title: 'Payment Link',
          onPressed: () {
            Navigator.pushNamed(context, "PaymentSuccessPage");
          },
        ),
        SizedBox(
          height: 40,
        ),
      ],
    ));
  }

  DataCell customDatacell({required String data}) => DataCell(CustomTextWidget(
        text: data,
        size: 12,
      ));
}
