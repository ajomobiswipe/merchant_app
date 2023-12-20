import 'package:flutter/material.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/helpers/default_height.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

class MerchantOrderDetails extends StatefulWidget {
  const MerchantOrderDetails({super.key});

  @override
  State<MerchantOrderDetails> createState() => _MerchantOrderDetailsState();
}

class _MerchantOrderDetailsState extends State<MerchantOrderDetails> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return AppScafofld(
      child: Column(
        children: [
          defaultHeight(20),
          Row(
            children: [
              CustomTextWidget(
                  text: "Merchant order",
                  fontWeight: FontWeight.w500,
                  size: 24),
            ],
          ),
          defaultHeight(20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.kSelectedBackgroundColor,
            ),
            // height: screenHeight / 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/app_icons/merchant_order_icon.png',
                        height: screenHeight / 25,
                        color: AppColors.kPrimaryColor,
                      ),
                      CustomTextWidget(
                        text: "Order\nDetails",
                        textAlign: TextAlign.center,
                        size: 8,
                        color: AppColors.kPrimaryColor,
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
