import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/storage/secure_storage.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../config/constants.dart';
import '../../config/global.dart';
import '../../config/validators.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widget.dart';

class LoginPinNew extends StatefulWidget {
  const LoginPinNew({Key? key}) : super(key: key);

  @override
  State<LoginPinNew> createState() => _LoginPinNewState();
}

class _LoginPinNewState extends State<LoginPinNew> {
  BoxStorage boxStorage = BoxStorage();
  LoginRequestModel requestModel = LoginRequestModel();
  AlertService alertWidget = AlertService();
  UserServices userServices = UserServices();

  String title = "Enter your Login PIN";
  List<int> firstRow = [1, 2, 3], secondRow = [4, 5, 6], thirdRow = [7, 8, 9];
  int pinLength = 4;
  String pinEntered = "";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LoadingWidget()
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20.0),
                  // const CircleAvatar(
                  //   backgroundColor: Colors.white,
                  //   minRadius: 52.0,
                  //   child: CircleAvatar(
                  //     radius: 50.0,
                  //     backgroundImage: NetworkImage(
                  //         'https://avatars0.githubusercontent.com/u/28812093?s=460&u=06471c90e03cfd8ce2855d217d157c93060da490&v=4'),
                  //   ),
                  // ),
                  Image.asset('assets/logo/logo2.png',
                      height: 30, fit: BoxFit.fill),
                  const SizedBox(height: 10.0),

                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 24),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    "Welcome ${boxStorage.getUsername().toString().toUpperCase()}",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                              (pinEntered.isNotEmpty)
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              color: Theme.of(context).primaryColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                            (pinEntered.length >= 2)
                                ? Icons.circle
                                : Icons.circle_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                              (pinEntered.length >= 3)
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              color: Theme.of(context).primaryColor),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                              (pinEntered.length == 4)
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                  // Text(
                  //   alert,
                  //   style: TextStyle(
                  //       color: (pinEntered == workingPin)
                  //           ? Colors.green
                  //           : Colors.red),
                  // ),
                  // Expanded(child: Container()),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: firstRow.map((e) => number(e)).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: secondRow.map((e) => number(e)).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: thirdRow.map((e) => number(e)).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Opacity(
                        opacity: 0,
                        child: AbsorbPointer(
                          absorbing: true,
                          child: number(0),
                        ),
                      ),
                      number(0),
                      IconButton(
                          onPressed: () => backSpace(),
                          icon: Icon(Icons.backspace_outlined,
                              color: Theme.of(context).primaryColor))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'forgotPage',
                              arguments: 'PIN');
                        },
                        child: Text(
                          'Forget PIN?',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(decoration: TextDecoration.underline),
                        ),
                      ),
                      const Text("|"),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, 'login');
                          },
                          child: Text(
                            'Login using Password',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    decoration: TextDecoration.underline),
                          )),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCustomerInfo();
  }

  getCustomerInfo() {
    String customerId = boxStorage.getCustomerId();
    userServices.getUserDetails(customerId).then((result) {
      // print(result);
    });
  }

  Widget number(int item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: InkWell(
        onTap: () => numberClicked(item),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            item.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }

  numberClicked(int item) {
    if (pinEntered.length < 4) {
      pinEntered = pinEntered + item.toString();
    }
    if (pinEntered.length == pinLength) {
      formSubmit(pinEntered);
    }
    setState(() {});
  }

  formSubmit(pin) async {
    setLoading(true);
    requestModel.instId = Constants.instId;
    requestModel.deviceType = Constants.deviceType;
    requestModel.userName = boxStorage.getUsername();

    requestModel.pin = pin;
    requestModel.pin = await Validators.encrypt(pin.toString());
    requestModel.deviceId =
        await Validators.encrypt(await Global.getUniqueId());
    userServices.loginService(requestModel).then((response) async {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          setLoading(false);
          saveSecureStorage(decodeData);
          Navigator.pushNamed(context, 'home');
        } else {
          setLoading(false);
          setState(() {
            pinEntered = '';
          });
          alertWidget.failure(context, 'Failure', decodeData['message']);
        }
      } else {
        setState(() {
          pinEntered = '';
        });
        alertWidget.failure(context, 'Failure', decodeData['message']);
        setLoading(false);
      }
    });
  }

  setLoading(bool tf) {
    setState(() {
      isLoading = tf;
    });
  }

  saveSecureStorage(decodeData) async {
    /// NEW HIVE STORAGE CONTROLS
    var datetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String dateStr = datetime.toString();
    BoxStorage secureStorage = BoxStorage();
    secureStorage.saveUserDetails(decodeData);
    secureStorage.save('lastLogin', dateStr);
    secureStorage.save('isLogged', true);
    if (decodeData['role'].toString() == "MERCHANT") {
      secureStorage.save('merchantStatus', decodeData['status'].toString());
    }

    /// OLD Shared Preferences STORAGE CONTROLS
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
  }

  backSpace() {
    if (pinEntered.isNotEmpty) {
      pinEntered = pinEntered.substring(0, pinEntered.length - 1);
    }
    setState(() {});
  }
}
