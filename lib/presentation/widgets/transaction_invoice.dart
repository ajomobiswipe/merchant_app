import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowTransactionInvoice extends StatelessWidget {
  final TransactionElement transaction;
  const ShowTransactionInvoice({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double basePadding = screenHeight * 0.01;
    return MerchantScaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Icon(Icons.close),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/screen/anet.png',
                height: 100,
              ),
            ),
            defaultHeight(basePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                    isBold: false,
                    size: 14,
                    text:
                        "Date ${transaction.timestamp != null ? DateFormat('dd/MM/yy').format(transaction.timestamp!) : "N/A"}"),
                CustomTextWidget(
                    size: 14,
                    isBold: false,
                    text:
                        "Time ${transaction.timestamp != null ? DateFormat('HH:mm:ss').format(transaction.timestamp!) : "N/A"}"),
              ],
            ),
            defaultHeight(basePadding),
            Center(
                child: CustomTextWidget(
              isBold: false,
              text: transaction.transactionType ?? "N/A",
              size: 20,
            )),
            defaultHeight(basePadding),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "Batch     ${transaction.batchNumber ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "Invoice     ${transaction.invoiceNumber ?? "N/A"}",
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
                  text: "RRN:     ${transaction.authorization!.rrn ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
                CustomTextWidget(
                  text: "PAN SEQ     ${transaction.transactionId ?? "N/A"}",
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
                  text:
                      "${transaction.entryMode ?? "N/A"} (${transaction.paymentMethod?.card?.brand ?? ""})",
                  size: 16,
                  isBold: false,
                ),
              ],
            ),
            defaultHeight(basePadding),
            if (transaction.paymentMethod != null &&
                transaction.paymentMethod!.card != null &&
                transaction.paymentMethod!.card!.cardholderName != null)
              CustomTextWidget(
                text: "${transaction.paymentMethod!.card!.cardholderName}",
                size: 14,
              ),
            defaultHeight(basePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "Amount  ${transaction.amount!.currency!.name}",
                  size: 16,
                  isBold: true,
                ),
                CustomTextWidget(
                  text:
                      "${transaction.amount!.currency!.name == 'INR' ? '₹' : '\$'}",
                  size: 20,
                  isBold: true,
                ),
                CustomTextWidget(
                  text: "${transaction.amount!.value ?? "N/A"}",
                  size: 16,
                  isBold: true,
                ),
              ],
            ),
            defaultHeight(basePadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text:
                      "AUTH CODE  : ${transaction.authorization!.authCode ?? "N/A"}",
                  size: 12,
                  isBold: false,
                ),
              ],
            ),
            defaultHeight(basePadding),
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
            CustomTextWidget(
              text:
                  "Label  ${transaction.paymentMethod?.card?.brand ?? ""} ${transaction.paymentMethod?.type ?? "N/A"} ",
              size: 12,
              isBold: false,
            ),
            defaultHeight(basePadding),
            CustomTextWidget(
              text: "AID  ${transaction.terminalId ?? "N/A"}  ",
              size: 12,
              isBold: false,
            ),
            defaultHeight(basePadding),
            CustomTextWidget(
              text: "TVR  ${transaction.batchNumber ?? "N/A"}  ",
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
            Spacer(),
            CustomContainer(
              onTap: () {},
              height: 70,
              child: CustomTextWidget(
                text: "Download",
                color: Colors.white,
              ),
            )
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
}
