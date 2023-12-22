import 'package:flutter/material.dart';
import 'package:sifr_latest/common_widgets/copyright_widget.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/main.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

import 'user_type_select_widget.dart';

class UserTypeSelection extends StatelessWidget {
  const UserTypeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        _onWillPop(context);
        return;
      },
      child: AppScafofld(
        eneableAppbar: false,
        child: Column(
          children: [
            Image.asset('assets/logo/oma_emirates_logo.png', height: 100),
            const Expanded(
              child: SizedBox(),
              flex: 2,
            ),
            CustomTextWidget(
              text: 'Welcome to',
              size: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.kLightGreen,
            ),
            CustomTextWidget(
              text: 'OMA',
              size: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.kheadingColor,
            ),
            CustomTextWidget(
              text: 'Merchant Onboarding',
              size: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.kheadingColor,
            ),
            const Expanded(
              child: SizedBox(),
              flex: 2,
            ),
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                const Icon(
                  Icons.location_on,
                  color: AppColors.kLightGreen,
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextWidget(text: 'Please select yourself'),
                    CustomTextWidget(
                        text: 'You are onboarding the Merchant as'),
                  ],
                )
              ],
            ),
            const Expanded(
              child: SizedBox(),
              flex: 2,
            ),
            UserSelectContainer(
              iconPath: 'assets/app_icons/sales_team.png',
              title: 'OMA Sales Team',
              onTap: () {
                Navigator.pushNamed(context, 'login');
              },
              borderColor: AppColors.kPrimaryColor,
              iconColor: AppColors.kLightGreen,
              titleColor: Color(0x99000000),
            ),
            const Expanded(
              child: SizedBox(),
              flex: 1,
            ),
            UserSelectContainer(
              iconPath: 'assets/app_icons/merchant_self.png',
              title: 'Merchant (Self)',
              titleColor: Color(0x99000000),
            ),
            const Expanded(
              child: SizedBox(),
              flex: 1,
            ),
            UserSelectContainer(
              iconPath: 'assets/app_icons/sales_partner.png',
              title: 'Sales Partner',
              titleColor: Color(0x99000000),
            ),
            const Expanded(
              child: SizedBox(),
              flex: 1,
            ),
            UserSelectContainer(
              iconPath: 'assets/app_icons/channel_partner.png',
              title: 'Channel Partner',
              titleColor: Color(0x99000000),
            ),
            const Expanded(
              child: SizedBox(),
              flex: 2,
            ),
            CopyRightWidget(),
            const Expanded(
              child: SizedBox(),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool? exitResult = customAlert.displayDialogConfirm(
        context,
        'Please confirm',
        'Do you want to quit your registration?',
        onTapConfirm(context));
    return exitResult ?? false;
  }

  onTapConfirm(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }
}
