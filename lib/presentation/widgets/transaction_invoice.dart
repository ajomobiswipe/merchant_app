import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';

class ShowTransactionInvoice extends StatelessWidget {
  final TransactionElement transaction;
  const ShowTransactionInvoice({super.key, required this.transaction});

  String getCurrencySymbol(String? code) {
    if (code == "356") return "₹";
    // Add more currency codes if needed
    return "\$";
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double basePadding = screenHeight * 0.01;

    return MerchantScaffold(
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
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
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: screenHeight,
            padding: const EdgeInsets.all(16),
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

                // Date and Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      isBold: false,
                      size: 14,
                      text: "Date ${transaction.transactionDate ?? "N/A"}",
                    ),
                    CustomTextWidget(
                      size: 14,
                      isBold: false,
                      text: "Time ${transaction.transactionTime ?? "N/A"}",
                    ),
                  ],
                ),
                defaultHeight(basePadding),

                // Transaction Type
                Center(
                  child: CustomTextWidget(
                    isBold: false,
                    text: transaction.transactionType ?? "N/A",
                    size: 20,
                  ),
                ),
                defaultHeight(basePadding),

                // MID & TID
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

                // Batch & Invoice
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      text: "Batch     ${transaction.batchNo ?? "N/A"}",
                      size: 12,
                      isBold: false,
                    ),
                    CustomTextWidget(
                      text: "Invoice     ${transaction.traceNumber ?? "N/A"}",
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
                      text: "RRN:     ${transaction.rrn ?? "N/A"}",
                      size: 12,
                      isBold: false,
                    ),
                    CustomTextWidget(
                      text: "PAN SEQ     ${transaction.traceNumber ?? "N/A"}",
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
                          "${transaction.posEntryMode ?? "N/A"} (${transaction.schemeName ?? "N/A"})",
                      size: 16,
                      isBold: false,
                    ),
                  ],
                ),
                defaultHeight(basePadding),

                // Cardholder Name
                if (transaction.nameOnCard != null)
                  CustomTextWidget(
                    text: transaction.nameOnCard!,
                    size: 14,
                  ),
                defaultHeight(basePadding),

                // Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      text: "Amount",
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
                defaultHeight(basePadding),

                // Auth Code
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      text: "AUTH CODE  : ${transaction.authCode ?? "N/A"}",
                      size: 12,
                      isBold: false,
                    ),
                  ],
                ),
                defaultHeight(basePadding),

                // Transaction Confirmation Message
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

                // Label / Process Code
                CustomTextWidget(
                  text:
                      "Label  ${transaction.processCode ?? ""} ${transaction.schemeName ?? "N/A"} ",
                  size: 12,
                  isBold: false,
                ),
                defaultHeight(basePadding),

                // Optional Tags (placeholders unless backend supplies them)
                CustomTextWidget(
                  text: "AID  ${transaction.terminalId ?? "N/A"}  ",
                  size: 12,
                  isBold: false,
                ),
                defaultHeight(basePadding),
                CustomTextWidget(
                  text: "TVR  ${transaction.batchNo ?? "N/A"}  ",
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
                const Spacer(),

                // Download Button
                CustomContainer(
                  onTap: () {
                    // TODO: Add download functionality
                  },
                  height: 70,
                  child: const CustomTextWidget(
                    text: "Download",
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
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
