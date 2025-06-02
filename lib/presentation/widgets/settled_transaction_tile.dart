import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/get_settlement_history_model.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/show_settled_transaction_invoice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SettledTransactionTile extends StatelessWidget {
  final SettledTransaction transaction;
  final double width;

  const SettledTransactionTile({
    super.key,
    required this.transaction,
    required this.width,
  });

  String formattedDateTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";

    try {
      final formattedDate =
          DateFormat("d MMM").format(dateTime); // e.g., 26 May
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShowSettledTransactionInvoice(
                transaction: transaction,
              ),
            ),
          );
        },
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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                            transaction.grossTransactionAmount.toString(),
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
                        formattedDateTime(transaction.tranDate),
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
                  color: transaction.merPayDone == true
                      ? Colors.green
                      : Colors.red,
                  width: width * 0.22,
                  height: 24,
                  child: CustomTextWidget(
                    size: 12,
                    text: transaction.merPayDone == true ? "Success" : "Failed",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                defaultWidth(width * 0.02),
                Icon(
                  Icons.info_outline,
                  color: Colors.blueAccent.shade200,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
