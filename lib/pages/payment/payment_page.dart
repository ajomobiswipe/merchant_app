import 'package:flutter/material.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import 'package:sifr_latest/config/app_color.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/app_widget/app_button.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScafofld(
        child: ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
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
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Quantity')),
            DataColumn(label: Text('Unit Price')),
            DataColumn(label: Text('Amount')),
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
                      CustomTextWidget(text: "Total"),
                      SizedBox(
                        width: 20,
                      ),
                      CustomTextWidget(text: "10000")
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      CustomTextWidget(text: "GST 18%"),
                      SizedBox(
                        width: 20,
                      ),
                      CustomTextWidget(text: "1800")
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      CustomTextWidget(text: "Payeable Amount"),
                      SizedBox(
                        width: 40,
                      ),
                      CustomTextWidget(text: "11800")
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
                Image.network(
                  "https://www.pixartprinting.it/blog/wp-content/uploads/2022/06/qr_code_cos_e.png",
                  height: 200,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextWidget(text: "Scan The QR "),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomAppButton(
              title: 'Payment Link',
              onPressed: () {
                Navigator.pushNamed(context, "PaymentSuccessPage");
              },
            ),
          ],
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
