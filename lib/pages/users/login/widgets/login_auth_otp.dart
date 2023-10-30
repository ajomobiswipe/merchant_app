import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shimmer_widget/flutter_shimmer_widget.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/services/services.dart';
import 'package:sifr_latest/widgets/app/alert_service.dart';
import 'package:sms_autodetect/sms_autodetect.dart';

import '../../../../models/models.dart';
import '../../../../storage/secure_storage.dart';

class LoginAuthOTP extends StatefulWidget {
  const LoginAuthOTP({Key? key, this.userDetails}) : super(key: key);
  final dynamic userDetails;
  @override
  State<LoginAuthOTP> createState() => _LoginAuthOTPState();
}

class _LoginAuthOTPState extends State<LoginAuthOTP> {
  bool _isLoadingButton = false;
  bool _enableButton = false;
  final FocusNode _nodeText1 = FocusNode();
  final _otpFocus = FocusNode();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController textEditingController = TextEditingController(text: "");

  UserServices userServices = UserServices();
  AlertService alertService = AlertService();
  LoginRequestModel requestModel = LoginRequestModel();

  String message = '';
  String otpCode = '';
  dynamic userDetails;
  bool enableOtpField = true;

  /// NEW SMS
  String signature = "{{ app signature }}";

  bool isLoading = false;

  @override
  void initState() {
    setState(() {
      userDetails = jsonDecode(widget.userDetails);
    });
    generateOtp(userDetails['userName']);
    _startListeningSms();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    SmsAutoDetect().unregisterListener();
  }

  KeyboardActionsConfig _buildKeyboardActionsConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Theme.of(context).primaryColor,
      actions: [
        KeyboardActionsItem(focusNode: _otpFocus, toolbarButtons: [
              (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                child: const Text(
                  "Done",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: KeyboardActions(
              config: _buildKeyboardActionsConfig(context),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      Constants.forgotPasswordImage,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'OTP Verification',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  messageWithLoading(),
                  const SizedBox(height: 20),
                  Text(
                    "Enter OTP to Continue Login",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  PinCodeTextField(
                    autoDisposeControllers: false,
                    appContext: context,
                    length: 4,
                    obscureText: true,
                    enabled: enableOtpField,
                    focusNode: _otpFocus,
                    obscuringCharacter: '*',
                    obscuringWidget: const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        "*",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      fieldOuterPadding:
                      const EdgeInsets.only(left: 8, right: 8),
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(2),
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      selectedColor: Theme.of(context).primaryColor,
                      selectedFillColor: Theme.of(context).primaryColor,
                      inactiveColor: Theme.of(context).primaryColor,
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    animationDuration: const Duration(milliseconds: 200),
                    autoDismissKeyboard: false,
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    mainAxisAlignment: MainAxisAlignment.center,
                    onCompleted: (v) {
                      // print("Pin Comleted: $v");
                    },
                    onChanged: (value) {
                      // print(value);
                      setState(() {
                        // print("x");
                        otpCode = value;
                        if (value.length == 4) {
                          _enableButton = true;
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                        } else {
                          _enableButton = false;
                        }

                        // _enableButton ? _verifyOtpCode : null;
                      });
                    },
                    beforeTextPaste: (text) {
                      return false;
                    },
                  ),
                  const SizedBox(height: 30.0),
                  submitOtp(),
                  const SizedBox(height: 20.0),
                  Text(
                    "Didn't you receive any OTP?",
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () {
                      generateOtp(userDetails['userName']);
                    },
                    child: const Text(
                      "Resend OTP",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // ElevatedButton(
                  //   child: const Text('Get app signature'),
                  //   onPressed: () async {
                  //     signature = await SmsAutoDetect().getAppSignature;
                  //     setState(() {});
                  //     print(signature);
                  //   },
                  // ),
                ],
              )),
        ),
      ),
    );
  }

  messageWithLoading() {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: FlutterShimmnerLoadingWidget(
          count: 2,
          animate: true,
          color: Colors.grey.shade400,
          align: TextAlign.center,
          rebuildOnStateChange: true,
        ),
      );
    } else {
      return Text(
        message,
        style: Theme.of(context).textTheme.titleSmall,
        textAlign: TextAlign.center,
      );
    }
  }

  /// listen sms
  _startListeningSms() async {
    await SmsAutoDetect().listenForCode;
    signature = await SmsAutoDetect().getAppSignature;
    setState(() {});
  }

  Widget submitOtp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: SizedBox(
        height: 50,
        width: double.maxFinite,
        child: ElevatedButton(
          onPressed: _enableButton ? _verifyOtpCode : null,
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: _setUpButtonChild(),
        ),
      ),
    );
  }

  Widget _setUpButtonChild() {
    if (_isLoadingButton) {
      return const SizedBox(
        width: 19,
        height: 19,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return const Text(
        "Submit OTP",
        style: TextStyle(color: Colors.white),
      );
    }
  }

  /// SEND NEW OR RESEND OTP
  generateOtp(String username) {
    setState(() {
      message = "Please wait...";
      isLoading = true;
      enableOtpField = false;
    });
    userServices.otpVerification(username).then((response) {
      var data = jsonDecode(response.body);
      if (data['responseCode'] == "00") {
        setState(() {
          message = data['responseMessage'];
          isLoading = false;
          enableOtpField = true;
        });
      }
    });
  }

  /// VERIFY OTP
  _verifyOtpCode() async {
    _isLoadingButton = !_isLoadingButton;
    FocusScope.of(context).requestFocus(FocusNode());
    var params = {
      "instId": Constants.instId,
      "userName": userDetails['userName'],
      "otp": await Validators.encrypt(otpCode),
    };
    userServices.otpValidate(params).then((response) async {
      var data = jsonDecode(response.body);
      if (data['responseCode'].toString() == "00") {
        var params = {
          "instId": Constants.instId,
          "userName": userDetails['userName'],
          "deviceId": await Validators.encrypt(await Global.getUniqueId()),
        };
        enableOtpField = false;
        userServices.deviceRegister(params).then((response) {
          setState(() {
            _isLoadingButton = false;
            _enableButton = false;
          });
          submitLoginForm();
          alertService.success(
              context, "Success", data['responseMessage'].toString());
        });
      } else {
        textEditingController.clear();
        setState(() {
          _isLoadingButton = false;
          _enableButton = false;
        });
        alertService.failure(
            context, "Failed", data['responseMessage'].toString());
      }
    });
  }

  /// SIGN IN TO THE APP
  submitLoginForm() async {
    requestModel.instId = Constants.instId;
    requestModel.deviceType = Constants.deviceType;
    requestModel.userName = userDetails['userName'];
    requestModel.deviceId =
    await Validators.encrypt(await Global.getUniqueId());

    if (userDetails['pin'] == null) {
      requestModel.password = userDetails['password'].toString();
    } else {
      requestModel.pin = userDetails['pin'].toString();
    }
    userServices.loginService(requestModel).then((response) async {
      var result = jsonDecode(response.body);
      var code = response.statusCode;
      if (code == 200 || code == 201) {
        if (result['responseCode'] == "00") {
          saveSecureStorage(result);
          Navigator.pushReplacementNamed(context, 'home');
        } else if (result['responseCode'] == "03") {
          alertService.failure(context, 'Failure', result['responseMessage']);
          Navigator.pushNamed(context, 'loginAuthOtp',
              arguments: {'userDetails': json.encode(requestModel)});
        } else {
          alertService.failure(context, 'Failure', result['responseMessage']);
        }
      } else {
        alertService.failure(context, 'Failure', result['message']);
      }
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
}
