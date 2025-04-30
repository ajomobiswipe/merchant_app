import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:anet_merchant_app/helpers/default_height.dart';
import 'package:anet_merchant_app/pages/users/merchant/widgets/custom_container.dart';
import 'package:anet_merchant_app/pages/users/merchant/widgets/transaction_invoice.dart';
import 'package:anet_merchant_app/widgets/custom_text_widget.dart';

class TransactionTile extends StatelessWidget {
  final dynamic transaction;
  final double width;

  const TransactionTile(
      {super.key, required this.transaction, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            transaction.paymentMethod!.type! == "UPI"
                ? Icons.qr_code
                : Icons.payment,
          ),
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
                      transaction.amount!.value.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd-MMM-yy | hh:mm a')
                      .format(transaction.timestamp!),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          CustomContainer(
            color:
                transaction.status! == "Completed" ? Colors.green : Colors.red,
            width: width * 0.22,
            height: 20,
            child: CustomTextWidget(
              size: 10,
              text: transaction.status!,
              color: Colors.white,
            ),
          ),
          defaultWidth(width * 0.02),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ShowTransactionInvoice(transaction: transaction),
                  ),
                );
                ;
              },
              child: const Icon(Icons.info_outline)),
        ],
      ),
    );
  }
}
