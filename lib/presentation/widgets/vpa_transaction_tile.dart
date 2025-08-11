import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/transaction_invoice.dart';
import 'package:anet_merchant_app/presentation/widgets/vpa_invoice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VpaTransactionTile extends StatelessWidget {
  final dynamic transaction; // dynamic map
  final double width;

  const VpaTransactionTile({
    super.key,
    required this.transaction,
    required this.width,
  });

  String formattedDateTime(String? isoDateTime) {
    if (isoDateTime == null || isoDateTime.isEmpty) return "N/A";
    try {
      final parsedDate = DateTime.parse(isoDateTime);
      final formattedDate = DateFormat("d MMM yy").format(parsedDate);
      final formattedTime = DateFormat("h:mm a").format(parsedDate);
      return "$formattedDate | $formattedTime";
    } catch (e) {
      return "N/A";
    }
  }

  String getTransactionStatus(String? type) {
    switch (type) {
      case "OSAL001":
        return "Success";
      case "VSAL001":
        return "VOID-SALE";
      case "POS-REVERSAL":
        return "Reversal";
      default:
        return type ?? "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = transaction['transactionAmount'] ?? "0.00";
    final transactionType =
        transaction['orgStatus'] ?? "N/A"; // assuming this indicates type
    final transactionDateTime = transaction['addedOn']; // ISO 8601 format
    final showTransactionStatus =
        transactionType == "SUCCESS" ? "Success" : transactionType;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                child: const Icon(Icons.qr_code_2_outlined,
                    color: Colors.blueAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CustomTextWidget(
                          text: "₹ ",
                          size: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        CustomTextWidget(
                          text: amount ?? "0.00",
                          size: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    CustomTextWidget(
                      text: formattedDateTime(transactionDateTime),
                      size: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowVpaTransactionInvoice(
                        transaction: transaction, // should be compatible
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    CustomContainer(
                      color: showTransactionStatus == "Success"
                          ? Colors.green
                          : Colors.red,
                      width: width * 0.22,
                      height: 24,
                      child: CustomTextWidget(
                        size: 12,
                        text: showTransactionStatus,
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
            ],
          ),
        ),
      ),
    );
  }
}
