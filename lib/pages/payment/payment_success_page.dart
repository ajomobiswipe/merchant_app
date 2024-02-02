import 'package:flutter/material.dart';
import 'package:sifr_latest/common_widgets/copyright_widget.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScafofld(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(),
        ),
        Image.asset(
          "assets/app_icons/success_sumbol.png",
          height: 100,
        ),
        CustomTextWidget(
          text: "Payment Successfull",
          fontWeight: FontWeight.w900,
          size: 24,
          color: AppColors.kLightGreen,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextWidget(text: "Payment Of ", size: 16),
            CustomTextWidget(
              text: "152454",
              fontWeight: FontWeight.w800,
              size: 16,
            ),
            CustomTextWidget(text: "has been Recived", size: 16),
          ],
        ),
        CustomTextWidget(text: "Successfully.", size: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextWidget(
              text: "Auto ",
              size: 16,
              color: AppColors.kPrimaryColor,
            ),
            CustomTextWidget(
              text: " eNACH ",
              fontWeight: FontWeight.w800,
              size: 16,
              color: AppColors.kPrimaryColor,
            ),
            CustomTextWidget(
              text: "Request is Initiated to the",
              size: 16,
              color: AppColors.kPrimaryColor,
            ),
          ],
        ),
        CustomTextWidget(
          text: "merchant for Registration.",
          size: 16,
          color: AppColors.kPrimaryColor,
        ),
        CustomTextWidget(
          text: "Check for the Status in",
          fontWeight: FontWeight.w800,
          size: 18,
          color: Colors.grey.shade700,
        ),
        TextButton(
            onPressed: () {
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
        CopyRightWidget(),
        SizedBox(
          height: 30,
        )
      ],
    ));
  }
}
