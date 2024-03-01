/* ===============================================================
| Project : SIFR
| Page    : USER_NAME_AVAILABILITY_PAGE.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';

import '../../config/config.dart';
import '../../services/user_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/loading.dart';
import '../../widgets/patternWidget.dart';

// STATEFUL WIDGET
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({
    Key? key,
  }) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

// User Name Availability State Class
class _ForgotPasswordState extends State<ForgotPassword> {
  late bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameCtrl = TextEditingController();
  // LoginRequestModel request = LoginRequestModel();
  UserServices userServices = UserServices();
  AlertService alertService = AlertService();

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingWidget()
        : Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: BackgroundPattern(
              childData: childData(),
            ));
  }

  //Body widget
  childData() {
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Image.asset(Constants.forgotOTPImage,
                height: 250, fit: BoxFit.fill),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Forgot Your Password?",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Enter the Username associated with your account",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
            ),
            const SizedBox(
              height: 10,
            ),
            userNameField(),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomAppButton(
                title: 'Send verification link',
                onPressed: () {
                  submit();
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Form submit to check whether user exist or not for password/pin reset
  submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setLoading(true);
      String username = usernameCtrl.text;
      // String user = await Validators.encrypt(request.userName.toString());
      userServices.sendForgotPasswordLink(username).then((response) async {
        if (response.statusCode == 200 || response.statusCode == 201) {
          var parsedResponse = json.decode(response.body);
          //  parsedResponse['responseMessage']
          // Print the responseMessage
          if (kDebugMode) print(parsedResponse['responseMessage'].toString());
          alertService.success(context, 'Link send Success',
              parsedResponse['responseMessage'].toString());
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);

          setLoading(false);
        } else {
          alertService.failure(context, 'Link send Failed',
              json.decode(response.body)['message'] ?? "Something went wrong");
          setLoading(false);
        }
      });
    }
  }

  // DYNAMIC LOADING STATE
  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  // TextFormField for userName
  userNameField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: TextFormField(
          controller: usernameCtrl,
          keyboardType: TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'\w'))
          ],
          decoration: InputDecoration(
            labelText: "Username *",
            labelStyle: TextStyle(color: Theme.of(context).primaryColor),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            prefixIcon: Icon(Icons.person,
                size: 25, color: Theme.of(context).primaryColor),
          ),
          // onSaved: (value) {
          //   request.userName = value;
          // },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Username!';
            } else if (value.length < 3) {
              return "Username length should be greater than 3";
            }
            return null;
          }),
    );
  }
}
