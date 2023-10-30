import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pin_code_widget/flutter_pin_code_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/config/config.dart';

import '../../models/login_models.dart';
import '../../services/user_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/loading.dart';

class LoginPin extends StatefulWidget {
  const LoginPin({Key? key}) : super(key: key);

  @override
  State<LoginPin> createState() => _LoginPinState();
}

class _LoginPinState extends State<LoginPin> {
  String user = '';
  String customerId = '';
  bool isLoading = false;
  LoginRequestModel requestModel = LoginRequestModel();
  AlertService alertWidget = AlertService();
  UserServices userServices = UserServices();
  @override
  void initState() {
    getUserDetails();
    super.initState();
  }

  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user = prefs.getString('userName')!;
      customerId = prefs.getString('custId')!;
    });
  }

  final ThemeData specialThemeData = ThemeData(
    // brightness: Theme.of(context).brightness.,
    brightness: Brightness.light,
    primaryColor: const Color(0xff6374db),
    // and so on...
  );
  @override
  Widget build(BuildContext context) {
    var isDarkMode = context.isDarkMode;
    return isLoading
        ? const LoadingWidget()
        : Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      minRadius: 35.0,
                      child: CircleAvatar(
                        radius: 30.0,
                        child: Icon(
                          Icons.supervised_user_circle,
                        ),
                        // backgroundImage: NetworkImage(
                        //     'https://avatars0.githubusercontent.com/u/28812093?s=460&u=06471c90e03cfd8ce2855d217d157c93060da490&v=4'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Welcome ${user.toString().toUpperCase()}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none)),
                    const SizedBox(height: 10),
                    Text('Enter your Login PIN',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none)),
                    const SizedBox(height: 20),
                    Expanded(
                      child: PinCodeWidget(
                        buttonColor: Theme.of(context).cardColor,
                        emptyIndicatorColor: Colors.grey,
                        deleteButtonColor: Colors.white,
                        deleteIconColor: Colors.grey,
                        filledIndicatorColor: Theme.of(context).primaryColor,
                        onPressColorAnimation: Theme.of(context).primaryColor,
                        onFullPin: (value, __) {
                          submitLoginForm(value);
                        },
                        onChangedPinLength: (length) {},
                        initialPinLength: 4,
                        onChangedPin: (pin) {},
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.bottomCenter,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Text(
                    //         "DON'T HAVE ACCOUNT? ",
                    //         textAlign: TextAlign.center,
                    //         style:
                    //             Theme.of(context).textTheme.bodyLarge?.copyWith(
                    //                   fontWeight: FontWeight.normal,
                    //                   fontSize: 16,
                    //                 ),
                    //       ),
                    //       InkWell(
                    //         child: Text(
                    //           "SIGN UP",
                    //           textAlign: TextAlign.center,
                    //           style: Theme.of(context)
                    //               .textTheme
                    //               .bodyLarge
                    //               ?.copyWith(
                    //                 fontWeight: FontWeight.bold,
                    //                 decoration: TextDecoration.underline,
                    //                 fontSize: 16,
                    //               ),
                    //           // style: TextStyle(
                    //           //     color: Theme.of(context).primaryColorDark,
                    //           //     fontWeight: FontWeight.bold,
                    //           //     fontSize: 16,
                    //           //     decoration: TextDecoration.underline),
                    //         ),
                    //         onTap: () {
                    //           Navigator.pushNamed(context, 'role');
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          );
  }

  submitLoginForm(String pin) async {
    requestModel.instId = Constants.instId;
    requestModel.deviceType = Constants.deviceType;
    requestModel.userName = user;
    requestModel.pin = await Validators.encrypt(pin.toString());
    setLoading(true);
    userServices.loginService(requestModel).then((response) async {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          saveSecureStorage(decodeData);
          setLoading(false);
          Navigator.pushNamed(context, 'home');
        } else {
          setLoading(false);
          alertWidget.failure(context, 'Failure', decodeData['message']);
        }
      } else {
        alertWidget.failure(context, 'Failure', decodeData['message']);
        setLoading(false);
      }
    });
  }

  saveSecureStorage(decodeData) async {
    var datetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String dateStr = datetime.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', decodeData['bearerToken'].toString());
    prefs.setString('userName', decodeData['userName'].toString());
    prefs.setString('role', decodeData['role'].toString());
    prefs.setString('lastLogin', dateStr);
    prefs.setBool('isLogged', true);
    prefs.setString('custId', decodeData['custId'].toString());
    if (decodeData['role'].toString() == "MERCHANT") {
      prefs.setString('merchantId', decodeData['merchantId'].toString());
      prefs.setString('terminalId', decodeData['terminalId'].toString());
      prefs.setString(
          'kycExpiryAlertMsg', decodeData['kycExpiryAlertMsg'].toString());
    }
    // final StorageItem newItem = StorageItem('userInfo', decodeData);
    // storage.saveUserInfo(newItem);
  }

  setLoading(bool tf) {
    setState(() {
      isLoading = tf;
    });
  }
}
