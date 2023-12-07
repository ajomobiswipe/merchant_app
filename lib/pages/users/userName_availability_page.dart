/* ===============================================================
| Project : SIFR
| Page    : USER_NAME_AVAILABILITY_PAGE.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sifr_latest/widgets/app_widget/app_button.dart';

import '../../config/config.dart';
import '../../models/login_models.dart';
import '../../services/user_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/loading.dart';
import '../../widgets/patternWidget.dart';

// STATEFUL WIDGET
class UserNameAvailability extends StatefulWidget {
  const UserNameAvailability({Key? key, this.type, this.page})
      : super(key: key);
  final String? type;
  final String? page;

  @override
  State<UserNameAvailability> createState() => _UserNameAvailabilityState();
}

// User Name Availability State Class
class _UserNameAvailabilityState extends State<UserNameAvailability> {
  late bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LoginRequestModel request = LoginRequestModel();
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
              "Verify Username",
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
              child: AppButton(
                title: 'Verify',
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


      String user = await Validators.encrypt(request.userName.toString());
      userServices.userCheck(user).then((response) async {



        if (response.statusCode == 200 || response.statusCode == 201) {
          if (response.body == "true") {
            setLoading(false);
            Navigator.pop(context);
            Navigator.pushNamed(context, widget.page.toString(), arguments: {
              'type': widget.type,
              'userName': request.userName.toString()
            });
          } else {
            alertService.failure(context, 'Failure', 'Check username!');
            setLoading(false);
          }
        } else {
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
          onSaved: (value) {
            request.userName = value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Username!';
            }
            return null;
          }),
    );
  }
}
