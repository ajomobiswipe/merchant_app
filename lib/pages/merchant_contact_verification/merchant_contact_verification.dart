import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sifr_latest/common_widgets/copyright_widget.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/widget.dart';

import '../../common_widgets/custom_otp_widget.dart';
import '../../config/app_color.dart';
import '../../widgets/custom_text_widget.dart';
import '../../widgets/form_field/custom_mobile_field.dart';

class MerchantContactVerification extends StatefulWidget {
  const MerchantContactVerification({super.key});

  @override
  State<MerchantContactVerification> createState() =>
      _MerchantContactVerificationState();
}

class _MerchantContactVerificationState
    extends State<MerchantContactVerification> {
  TextEditingController _mobileNoController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _mobileNoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScafofld(
      child: ListView(
        children: [
          Row(
            children: [
              CustomTextWidget(
                  text: "Merchant Mobile Number",
                  size: 16,
                  fontWeight: FontWeight.w700),
            ],
          ),
          CustomTextFormField(
            title: 'Mobile Number',
            enabled: true,
            controller: _mobileNoController,
            keyboardType: TextInputType.number,
            required: true,
            onChanged: (phone) {},
            suffixIcon: Icons.send_rounded,
            suffixIconTrue: true,
            suffixIconOnPressed: () {
              print("otp sent to ${_mobileNoController.text}");
            },
            onTap: () {
              print("ontap");
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  CustomTextWidget(
                      text: "Verify the Number with OTP",
                      fontWeight: FontWeight.w800),
                  CustomTextWidget(text: "sent on the Merchant Mobile Number"),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          CustomOtpWidget(
            onCompleted: (pin) {
              print('onCompleted: $pin');
            },
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () {},
              child: CustomTextWidget(
                text: 'Resend OTP',
                color: AppColors.kLightGreen,
                size: 16,
              )),
          const SizedBox(
            height: 20,
          ),
          CopyRightWidget()
        ],
      ),
    );
  }
}
