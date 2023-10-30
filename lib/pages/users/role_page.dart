/* ===============================================================
| Project : SIFR
| Page    : ROLE_PAGE.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';

import '../../widgets/widget.dart';

String roles = 'CUSTOMER';

// STATEFUL WIDGET
class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  _RolePageState createState() => _RolePageState();
}

// Role Page State Class
class _RolePageState extends State<RolePage> {
  // Init function for page Initialization
  @override
  void initState() {
    super.initState();
    roles = 'CUSTOMER'; // LOCAL VARIABLE INITIALIZATION
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
          child: Center(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Hello There!",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Please choose from the options below:",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/screen/sign-up.png'),
                      )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Radiobutton(),
                    const SizedBox(height: 40),
                    AppButton(
                      title: 'Register',
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigator.pushNamed(context, 'register',
                        //     arguments: roles);
                        if (roles == 'CUSTOMER') {
                          Navigator.pushNamed(context, 'signUp');
                        } else {
                          Navigator.pushNamed(context, 'merchantSignUp');
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

// Radio button Stateful Widget
class Radiobutton extends StatefulWidget {
  const Radiobutton({super.key});

  @override
  RadioButtonWidget createState() => RadioButtonWidget();
}

// Radio button State Class
class RadioButtonWidget extends State {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile(
          groupValue: roles,
          title: const Text('Do you want to Register as a Customer?'),
          value: 'CUSTOMER',
          onChanged: (val) {
            setState(() {
              roles = val!;
            });
          },
        ),
        const SizedBox(
          height: 5,
        ),
        RadioListTile(
          groupValue: roles,
          title: const Text('Do you want to Register as a Merchant?'),
          value: 'MERCHANT',
          onChanged: (val) {
            setState(() {
              roles = val!;
            });
          },
        ),
      ],
    );
  }
}
