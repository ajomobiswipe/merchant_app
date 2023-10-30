/* ===============================================================
| Project : SIFR
| Page    : FORGOT_USERNAME_PAGE.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sifr_latest/config/config.dart';

import '../../models/login_models.dart';
import '../../services/user_services.dart';
import '../../widgets/loading.dart';
import '../../widgets/patternWidget.dart';
import '../../widgets/widget.dart';

// STATEFUL WIDGET
class ForgotUserName extends StatefulWidget {
  const ForgotUserName({Key? key}) : super(key: key);

  @override
  State<ForgotUserName> createState() => _ForgotUserNameState();
}

// Forgot UserName State Class
class _ForgotUserNameState extends State<ForgotUserName> {
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LoginRequestModel request = LoginRequestModel();
  UserServices userServices = UserServices();
  AlertService alertWidget = AlertService();

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingWidget()
        : Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: BackgroundPattern(childData: childData()));
  }

  // Body widget
  Widget childData() {
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Image.asset(Constants.forgotUserNameImage,
                height: 250, fit: BoxFit.fill),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Forgot Username?",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "We have sent a Username recovery mail to your registered email ID.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
            ),
            const SizedBox(
              height: 40,
            ),
            emailField(),
            const SizedBox(
              height: 20,
            ),
            AppButton(
                title: "Send",
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  submit();
                }),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  //Form submit for user name recovery
  submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setLoading(true);
      String email = await Validators.encrypt(request.email.toString());
      userServices.forgetUserName(email).then((response) {
        setLoading(false);
        var decodeData = jsonDecode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (decodeData['responseCode'].toString() == "00") {
            alertWidget.success(
                context, 'Success', decodeData['responseMessage']);
            Navigator.pushNamed(context, 'checkYourMail');
          } else {
            alertWidget.failure(
                context, 'Failure', decodeData['responseMessage']);
          }
        } else {
          alertWidget.failure(context, 'Failure', decodeData['message']);
        }
      });
    }
  }

  //TextFormField for email
  emailField() {
    return TextFormField(
        keyboardType: TextInputType.text,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: "Email ID *",
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
          prefixIcon: Icon(Icons.alternate_email,
              size: 25, color: Theme.of(context).primaryColor),
        ),
        onSaved: (value) {
          request.email = value;
          // requestModel.userName = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter email!';
          }
          if (!Validators.isValidEmail(value)) {
            return 'Check your email!';
          }
          return null;
        });
  }

  // DYNAMIC LOADING STATE
  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }
}
