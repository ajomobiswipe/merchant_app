import 'package:flutter/material.dart';
import 'package:sifr_latest/common_widgets/copyright_widget.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

class SignUpSucessScreen extends StatelessWidget {
  const SignUpSucessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScafofld(
      canPop: false,
      eneableAppbar:false,
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(),
        ),
        Image.asset(
          "assets/app_icons/success_sumbol.png",
          height: 60,
        ),
        SizedBox(
          height: 10,
        ),
        CustomTextWidget(
          text: "Congratulations!",
          fontWeight: FontWeight.bold,
          size: 24,
          color: AppColors.kLightGreen,
        ),
        SizedBox(
          height: 30,
        ),
        CustomTextWidget(
          text:
              "Merchant onboarding application\nhas been submitted successfully..",
        ),
        SizedBox(
          height: 30,
        ),
        CustomTextWidget(
          text: "Check for the Status in",
          fontWeight: FontWeight.w800,
          size: 16,
          color: Colors.grey.shade500,
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
