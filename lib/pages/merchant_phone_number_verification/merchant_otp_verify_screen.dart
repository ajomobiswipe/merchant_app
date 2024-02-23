import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sifr_latest/common_widgets/app_text_form_feild.dart';
import 'package:sifr_latest/common_widgets/custom_otp_widget.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';
import 'package:sifr_latest/widgets/widget.dart';

import 'merchant_regn_type_selector.dart';

class MerchantOTPVerifyScreen extends StatefulWidget {
  const MerchantOTPVerifyScreen({super.key});

  @override
  State<MerchantOTPVerifyScreen> createState() =>
      _MerchantOTPVerifyScreenState();
}

class _MerchantOTPVerifyScreenState extends State<MerchantOTPVerifyScreen> {
  final TextEditingController _mobileNoController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _mobileNoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leadingWidth: 200,
        leading: PopupMenuButton<int>(
          color: Colors.white,
          itemBuilder: (context) => [
            // PopupMenuItem 1
            const PopupMenuItem(
              value: 1,
              // row with 2 children
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.black87,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "My Profile",
                    style: TextStyle(color: Colors.black87),
                  )
                ],
              ),
            ),
            // PopupMenuItem 2
            const PopupMenuItem(
              value: 2,
              // row with two children
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Colors.black87,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "My Applications",
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 3,
              // row with two children
              child: Row(
                children: [
                  Icon(
                    Icons.contact_page_outlined,
                    color: Colors.black87,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Settings", style: TextStyle(color: Colors.black87))
                ],
              ),
            ),
            const PopupMenuItem(
              value: 4,
              // row with two children
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Colors.black87,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Log Out",
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
          offset: const Offset(40, 40),
          // icon:

          elevation: 2,

          onSelected: (value) {
            if (value == 1) {
              Navigator.pushNamed(context, 'profileNewScreen');
            } else if (value == 2) {
              Navigator.pushNamed(context, 'myApplications');
            } else if (value == 3) {
              Navigator.pushNamed(context, 'settings');
            } else if (value == 4) {
              logout.bottomSheet(context);
              // Navigator.pushNamed(context, 'DeviceDeploymentScreen');
            }
          },
          // color: Colors.black12,

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10, left: 10),
                height: 100,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.blue),
                child: Image.asset(
                  'assets/app_icons/businessMan.png',
                  height: 80,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Vinay'),
              )
            ],
          ),
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
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.kLightGreen,
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(
                        text: 'Please select your merchant type',
                        size: 12,
                        isBold: false),
                    CustomTextWidget(
                        text:
                            'You are onboarding a new or an \nexisting merchant',
                        size: 14,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.left,
                        isBold: false),
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
                  flex: 1,
                  child: SizedBox(),
                ),
                MerchantRegnTypeSelector(
                  iconPath: "assets/app_icons/new_merchant.png",
                  title: 'New \nMerchant',
                  iconColor: AppColors.kLightGreen,
                  borderColor: AppColors.kPrimaryColor,
                  flex: 8,
                  titleColor: Colors.black54,
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
                MerchantRegnTypeSelector(
                  iconPath: "assets/app_icons/existing_merchant.png",
                  title: 'Existing\nMerchant',
                  flex: 8,
                  titleColor: Colors.black54,
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                CustomTextWidget(
                    text: "Merchant Mobile Number",
                    size: 16,
                    fontWeight: FontWeight.w700),
              ],
            ),
            const SizedBox(
              height: 10,
            ),


            CustomOtpWidget(
              onCompleted: (pin) {
                print('onCompleted: $pin');
              },
              phonemumbercontroller: _mobileNoController,
              validator: (pin) {
                if (pin == "1234") {
                  return null;
                } else {
                  return "invalid otp";
                }
              },
            ),


            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
