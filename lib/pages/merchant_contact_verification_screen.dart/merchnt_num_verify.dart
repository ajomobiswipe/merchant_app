import 'package:flutter/material.dart';
import 'package:sifr_latest/common_wigdets/app_text_form_feild.dart';
import 'package:sifr_latest/common_wigdets/custom_otp_widget.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/pages/merchant_contact_verification_screen.dart/merchant_regn_type_selector.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

class MerchantNumVerify extends StatefulWidget {
  const MerchantNumVerify({super.key});

  @override
  State<MerchantNumVerify> createState() => _MerchantNumVerifyState();
}

class _MerchantNumVerifyState extends State<MerchantNumVerify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: GestureDetector(
            child: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            onTap: () {},
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 0),
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
            ),
            const AppTextFormField(
              title: 'Search with merchant mobile number',
              required: false,
              suffixIcon: Icons.search,
              iconColor: AppColors.black,
              eneablrTitle: false,
              suffixIconTrue: true,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.kLightGreen,
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                        text: 'Please select yourmerchant type', size: 10),
                    CustomTextWidget(
                        text:
                            'You are onboarding a new or an \nexisting merchant',
                        size: 14,
                        textAlign: TextAlign.left),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Row(
              children: [
                Expanded(
                  child: SizedBox(),
                  flex: 1,
                ),
                MerchantRegnTypeSelector(
                  iconPath: "assets/app_icons/new_merchant.png",
                  title: 'New \nMerchant',
                  iconColor: AppColors.kLightGreen,
                  borderColor: AppColors.kPrimaryColor,
                  flex: 8,
                ),
                Expanded(
                  child: SizedBox(),
                  flex: 1,
                ),
                MerchantRegnTypeSelector(
                  iconPath: "assets/app_icons/existing_merchant.png",
                  title: 'Existing\nMerchant',
                  flex: 8,
                ),
                Expanded(
                  child: SizedBox(),
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                CustomTextWidget(text: "Merchant Mobile Number"),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const AppTextFormField(
              title: 'Enther the Merchant Mobile Number',
              required: false,
              suffixIcon: Icons.send_outlined,
              iconColor: AppColors.kLightGreen,
              eneablrTitle: false,
              suffixIconTrue: true,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomTextWidget(text: "verify the Number with OTP"),
            CustomTextWidget(text: "sent on the Merchant Mobile Number"),
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
                )),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
