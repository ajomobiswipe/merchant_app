import 'package:flutter/material.dart';
import 'package:sifr_latest/common_widgets/copyright_widget.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(),
        ),
        Image.asset(
          "assets/app_icons/success_symbol.png",
          height: 60,
        ),
        SizedBox(
          height: 10,
        ),
        CustomTextWidget(
          text: "Payment is successfull!",
          fontWeight: FontWeight.bold,
          size: 24,
          color: AppColors.kLightGreen,
        ),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextWidget(
              text: "Payment Of ",
            ),
            CustomTextWidget(
              text: "152454",
              fontWeight: FontWeight.bold,
            ),
            CustomTextWidget(
              text: " has been Recived",
            ),
          ],
        ),
        CustomTextWidget(
          text: "Successfully.",
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextWidget(
              text: "Auto ",
              size: 14,
              color: AppColors.kPrimaryColor,
            ),
            CustomTextWidget(
              text: " eNACH ",
              fontWeight: FontWeight.w800,
              size: 14,
              color: AppColors.kPrimaryColor,
            ),
            CustomTextWidget(
              text: "Request is Initiated to the",
              size: 14,
              color: AppColors.kPrimaryColor,
            ),
          ],
        ),
        CustomTextWidget(
          text: "merchant for Registration.",
          size: 14,
          color: AppColors.kPrimaryColor,
        ),
        SizedBox(
          height: 30,
        ),
        CustomTextWidget(
          text: "Check for the Status in",
          fontWeight: FontWeight.w800,
          size: 18,
          color: Colors.grey.shade700,
        ),
        GestureDetector(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                'myApplications',
                (route) => false,
              );
            },
            child: CustomTextWidget(
              text: "My Applications",
              size: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.kPrimaryColor,
            )),
        Expanded(
          child: SizedBox(),
        ),
        copyRightWidget(),
        SizedBox(
          height: 30,
        )
      ],
    ));
  }
}
