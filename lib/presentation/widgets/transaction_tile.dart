import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/transaction_invoice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final TransactionElement transaction;
  final double width;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.width,
  });
  String formattedDateTime(String? date, String? time) {
    if (date == null || time == null) return "N/A";

    try {
      final input = '$date $time'; // Combine to "26/05/2025 17:45:01"
      final inputFormat = DateFormat("dd/MM/yyyy HH:mm:ss");

      final dateTime = inputFormat.parse(input);

      final formattedDate =
          DateFormat("d MMM yy").format(dateTime); // e.g., 26 May
      final formattedTime =
          DateFormat("h:mm a").format(dateTime); // e.g., 5:45 PM

      return "$formattedDate | $formattedTime";
    } catch (e) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              spreadRadius: -1,
              blurRadius: 5,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                child: const Icon(Icons.payment, color: Colors.blueAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "₹ ",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          transaction.amount ?? "0.00",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formattedDateTime(transaction.transactionDate,
                          transaction.transactionTime),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    // CustomTextWidget(
                    //     size: 10, text: getTransactionStatustext(transaction))
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowTransactionInvoice(
                        transaction: transaction,
                      ),
                    ),
                  );
                },
                child: Row(children: [
                  CustomContainer(
                    color: transaction.transactionType == "OSAL001"
                        ? Colors.green
                        : Colors.red,
                    width: width * 0.22,
                    height: 24,
                    // borderRadius: 12,
                    child: CustomTextWidget(
                      size: 12,
                      text: getTransactionStatus(transaction),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  defaultWidth(width * 0.02),
                  Icon(
                    Icons.info_outline,
                    color: Colors.blueAccent.shade200,
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  String getTransactionStatustext(TransactionElement txn) {
    return "${txn.transactionType ?? 'N/A'} V ${txn.voided.toString()} ${txn.responseCode ?? 'N/A'}";
  }

  String getTransactionStatus(TransactionElement txn) {
    if (txn.transactionType == "OSAL001") {
      return "Success";
    }

    if (txn.transactionType == "VSAL001") {
      return "VOID-SALE";
    }
    if (txn.transactionType == "POS-REVERSAL") {
      return "Reversal";
    }

    return txn.transactionType ?? "N/A";
  }

  getTransactionType(TransactionElement? element) {
    if (element == null) return "N/A";
    if (element.transactionType == "OSAL001" && element.voided == false)
      return "SALE";

    if (element.transactionType == "OSAL001" &&
        element.voided == true) if (element.transactionType == "VSAL001")
      return "Void";
    return "Void-Sale";
  }
}
