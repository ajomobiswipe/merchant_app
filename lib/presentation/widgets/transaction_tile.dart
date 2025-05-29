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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
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
                      formatTime(transaction.transactionTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              CustomContainer(
                color: (transaction.responseCode == "000" ||
                        transaction.responseCode == "00")
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
                child: Icon(
                  Icons.info_outline,
                  color: Colors.blueAccent.shade200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTransactionStatus(TransactionElement txn) {
    if (txn.voided == true) return "Voided";
    if (txn.responseCode == "68") return "Reversed";
    if (txn.responseCode != "00") return "Failed";
    if (txn.responseCode == "00") return "Success";
    if (txn.settled == true || txn.batchClosed == true) return "Completed";
    return "Pending";
  }
}
