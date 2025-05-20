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

  String formatTime(String? time) {
    if (time == null) return "N/A";
    try {
      final parsedTime = DateFormat("HHmmss").parse(time);
      return DateFormat("hh:mm:ss a").format(parsedTime);
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.payment, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "₹ ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      transaction.amount ?? "0.00",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formatTime(transaction.transactionTime),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          CustomContainer(
            color: transaction.responseCode == "00" ? Colors.green : Colors.red,
            width: width * 0.22,
            height: 20,
            child: CustomTextWidget(
              size: 10,
              text: getTransactionStatus(transaction),
              color: Colors.white,
            ),
          ),
          defaultWidth(width * 0.02),
          GestureDetector(
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
            child: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }

  String getTransactionStatus(TransactionElement txn) {
    if (txn.voided == true) return "Voided";
    if (txn.isReverse == true) return "Reversed";
    if (txn.responseCode != "00") return "Failed";
    if (txn.responseCode == "00") return "Success";
    if (txn.settled == true || txn.batchClosed == true) return "Completed";
    return "Pending";
  }
}
