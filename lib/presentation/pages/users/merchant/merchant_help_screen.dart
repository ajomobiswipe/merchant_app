import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/form_field/custom_dropdown.dart';
import 'package:flutter/material.dart';

class MerchantHelpScreen extends StatelessWidget {
  const MerchantHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    String? selectedQuickAction;
    return MerchantScaffold(
      child: Column(
        children: [
          Center(
            child: Image.asset(
              "assets/screen/anet.png",
              height: screenHeight * 0.2,
            ),
          ),
          CustomTextWidget(
              text: Constants.storeName, size: 18),
          defaultHeight(screenHeight * 0.05),
          DropdownButtonFormField<String>(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            isDense: true,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.kPrimaryColor,
            ),
            decoration: commonInputDecoration(
              hintText: "select one",
              Icons.maps_home_work_outlined,
            ),
            value: selectedQuickAction,
            items: [
              'Paper Roll Request',
              'Settlement Bank Account Change Request',
              'Upgrade Device Request',
              'Additional / New Sound Box Request',
              'Additional / New POS Request',
              'Device not working Request',
              'Training Required Request',
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              selectedQuickAction = newValue;
            },
            validator: (value) {
              if (value == null) {
                return 'Select one!';
              }
              return null;
            },
          ),
          Spacer(),
          Row(
            children: [
              Image.asset(
                "assets/screen/help_desk.png",
                height: 60,
              ),
              defaultWidth(screenWidth * 0.05),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    text: "We are here to help!",
                    size: 18,
                  ),
                  CustomTextWidget(
                      text: "Raise Your Concern and get your \nissue resolved"),
                ],
              )
            ],
          ),
          Spacer(),
          CustomContainer(
            color: Color.fromARGB(255, 165, 162, 138),
            height: screenHeight * 0.07,
            child: CustomTextWidget(
              text: "Raise a request",
              color: Colors.white,
            ),
          ),
          Spacer(),
          CustomContainer(
            padding: EdgeInsets.symmetric(horizontal: 15),
            color: Color.fromARGB(255, 165, 162, 138),
            height: screenHeight * 0.1,
            child: Column(
              children: [
                defaultHeight(10),
                CustomTextWidget(text: "Contact us:"),
                Row(
                  children: [
                    connectWithOptions(
                      icon: const Icon(
                        Icons.phone,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    defaultWidth(20),
                    CustomTextWidget(
                        text: "+911203584948",
                        size: 12,
                        color: AppColors.black50,
                        fontWeight: FontWeight.w400),
                    const Spacer(
                      flex: 4,
                    ),
                  ],
                ),
                Row(
                  children: [
                    connectWithOptions(
                      icon: const Icon(
                        size: 20,
                        Icons.email_outlined,
                        color: Colors.white,
                      ),
                    ),
                    defaultWidth(20),
                    CustomTextWidget(
                        text: "support@alliancenetworkcompany.com",
                        size: 12,
                        color: AppColors.black50,
                        fontWeight: FontWeight.w400),
                    const Spacer(
                      flex: 4,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      onTapHome: () {
        Navigator.pop(context);
      },
    );
  }

  Column connectWithOptions({required Widget icon, Function()? onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: icon,
        ),
      ],
    );
  }
}
