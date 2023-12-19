import 'package:flutter/material.dart';
import 'package:sifr_latest/common_wigdets/copyright_widget.dart';
import 'package:sifr_latest/main.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';

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
        child: Column(
          children: [
            Image.asset('assets/logo/oma_emirates_logo.png', height: 120),
            Text('Welcome to'),
            Text('OMA'),
            Text('Merchant Onboarding'),
            Expanded(child: SizedBox()),
            UserSelectContainer(
              iconPath: 'assets/app_icons/sales_team.png',
              title: 'OMA Sales Team',
            ),
            SizedBox(
              height: 20,
            ),
            UserSelectContainer(
              iconPath: 'assets/app_icons/sales_team.png',
              title: 'OMA Sales Team',
            ),
            UserSelectContainer(
              iconPath: 'assets/app_icons/sales_team.png',
              title: 'OMA Sales Team',
            ),
            UserSelectContainer(
              iconPath: 'assets/app_icons/sales_team.png',
              title: 'OMA Sales Team',
            ),
            Expanded(child: SizedBox()),
            CopyRightWidget()
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
