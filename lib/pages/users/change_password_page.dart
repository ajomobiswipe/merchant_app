/* ===============================================================
| Project : SIFR
| Page    : CHANGE_PASSWORD.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/widgets/app_widget/app_button.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../models/change_password_model.dart';
import '../../models/otp_validate_model.dart';
import '../../services/user_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/form_field/custom_text.dart';

// STATEFUL WIDGET
class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key, this.type}) : super(key: key);
  final String? type;

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

// Change Password State Class
class _ChangePasswordState extends State<ChangePassword> {
  UserServices apiService = UserServices();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ChangePasswordModel changePasswordModel = ChangePasswordModel();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  AlertService alertWidget = AlertService();
  OtpValidateRequest request = OtpValidateRequest();
  UserServices userServices = UserServices();
  final _pinPutController = TextEditingController();

  // LOCAL VARIABLE DECLARATION
  bool hideOldPassword = true;
  bool hidePassword = true;
  bool hideCnfPassword = true;
  bool _isLoading = false;
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 2);
  late String? otpMessage = '';
  bool enable = true;
  String? otpVerified = '';
  late IconData icon;
  bool isIcon = false;

  // start timer function for OTP
  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  // Stop timer function for OTP
  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  // Reset timer function for OTP
  void resetTimer() {
    stopTimer();
    setState(() => myDuration = const Duration(minutes: 2));
  }

  // Count down function for OTP
  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  // Form submit function for password/pin/mPin update
  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      setLoading(false);
      _formKey.currentState!.save();
      if (widget.type == 'MPIN') {
        changePasswordModel.mPin =
            await Validators.encrypt(changePasswordModel.mPin.toString());
        changePasswordModel.newMpin =
            await Validators.encrypt(changePasswordModel.newMpin.toString());
        changePasswordModel.confirmNewMpin = await Validators.encrypt(
            changePasswordModel.confirmNewMpin.toString());
        apiService
            .changePassword(changePasswordModel, 'MPIN')
            .then((response) async {
          var decodeData = jsonDecode(response.body);
          if (decodeData['responseCode'].toString() == "00") {
            stopTimer();
            alertWidget.success(
                context, 'Success', decodeData['responseMessage']);
            Navigator.pushNamed(context, 'myAccount');
          } else {
            if (decodeData['responseCode'].toString() == "01") {
              alertWidget.failure(
                  context, 'Failure', decodeData['responseMessage']);
            } else {
              alertWidget.failure(context, 'Failure', decodeData['message']);
            }
          }
          setLoading(true);
        });
      } else {
        if (widget.type == "Password") {
          changePasswordModel.password =
              await Validators.encrypt(changePasswordModel.password.toString());
          changePasswordModel.newPassword = await Validators.encrypt(
              changePasswordModel.newPassword.toString());
          changePasswordModel.confirmNewPassword = await Validators.encrypt(
              changePasswordModel.confirmNewPassword.toString());
        } else {
          changePasswordModel.pin =
              await Validators.encrypt(changePasswordModel.pin.toString());
          changePasswordModel.newPin =
              await Validators.encrypt(changePasswordModel.newPin.toString());
          changePasswordModel.confirmNewPin = await Validators.encrypt(
              changePasswordModel.confirmNewPin.toString());
        }
        apiService
            .changePassword(changePasswordModel, 'Password')
            .then((response) async {
          var decodeData = jsonDecode(response.body);
          if (response.statusCode == 200 || response.statusCode == 201) {
            if (decodeData['responseCode'].toString() == "00") {
              stopTimer();
              alertWidget.success(
                  context, 'Success', decodeData['responseMessage']);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.clear();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, 'login', (route) => false);
            } else {
              alertWidget.failure(
                  context, 'Failure', decodeData['responseMessage']);
            }
          } else {
            alertWidget.failure(context, 'Failure', decodeData['message']);
          }
          setLoading(true);
        });
      }
    }
  }

  // Init function for page Initialization
  @override
  void initState() {
    otpGenerationApi(''); // Generate OTP api for password/pin/mPin update
    icon = widget.type == "Password" ? Icons.lock : Icons.pin;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: context.isDarkMode
            ? Colors.white
            : const Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
    );
    return Scaffold(
        appBar: AppBarWidget(
          title: "Update ${widget.type}",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: _isLoading
              ? Form(
                  key: _formKey,
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "OTP Verification",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  decoration: TextDecoration.none),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              otpMessage ??
                                  "We've sent a 4 digits verification code to your Mail.Please enter the code below to verify it's you!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                  height: 1.5),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: Pinput(
                                    enabled: enable,
                                    keyboardType: TextInputType.number,
                                    defaultPinTheme: defaultPinTheme,
                                    obscureText: true,
                                    obscuringCharacter: '*',
                                    autofocus: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    length: 4,
                                    isCursorAnimationEnabled: false,
                                    controller: _pinPutController,
                                    onCompleted: (String pin) {
                                      request.otp = pin;
                                      validateOtpApi(request);
                                    },
                                  )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: countdownTimer!.isActive
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            "OTP will expire in $minutes:$seconds",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    decoration:
                                                        TextDecoration.none)),
                                        const TextButton(
                                          onPressed: null,
                                          child: Text(
                                            'Resend OTP',
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Align(
                                      alignment: Alignment.center,
                                      child: otpVerified == ''
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                    "I didn't get the Code or OTP Expires.",
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall),
                                                TextButton(
                                                    onPressed: () {
                                                      otpGenerationApi(
                                                          'resend');
                                                    },
                                                    child: Text(
                                                      "Resend OTP",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displaySmall
                                                          ?.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline),
                                                    )),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  otpVerified!,
                                                  textAlign: TextAlign.center,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 14,
                                                      ),
                                                ),
                                              ],
                                            ),
                                    ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Update ${widget.type}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // PASSWORD
                            Padding(
                                padding: const EdgeInsets.all(8),
                                child: CustomTextFormField(
                                  title: 'Old ${widget.type}',
                                  required: true,
                                  controller: _oldPasswordController,
                                  obscureText: hideOldPassword,
                                  counterText: "",
                                  autofocus: true,
                                  maxLength: maxLength(),
                                  enabled: !enable,
                                  keyboardType: widget.type == 'Password'
                                      ? TextInputType.text
                                      : TextInputType.number,
                                  inputFormatters: widget.type == 'Password'
                                      ? []
                                      : [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                  errorMaxLines: 2,
                                  prefixIcon: widget.type == "Password"
                                      ? Icons.lock
                                      : Icons.pin,
                                  suffixIconTrue: true,
                                  suffixIcon: hideOldPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  suffixIconOnPressed: () {
                                    setState(() {
                                      hideOldPassword = !hideOldPassword;
                                    });
                                  },
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter  old ${widget.type}!';
                                    }
                                    if (widget.type == "Password" &&
                                        !Validators.isPassword(value)) {
                                      return 'Use 8 or more characters with a mix of letters, numbers & symbols';
                                    }
                                    if (widget.type == "PIN" &&
                                        value.length != 4) {
                                      return 'PIN must be 4 digit';
                                    }
                                    if (widget.type == "MPIN" &&
                                        value.length != 6) {
                                      return 'MPIN must be 6 digit';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    if (widget.type == "Password") {
                                      changePasswordModel.password = value;
                                    } else if (widget.type == "PIN") {
                                      changePasswordModel.pin = value;
                                    } else {
                                      changePasswordModel.mPin = value;
                                    }
                                  },
                                )),
                            // New PASSWORD
                            Padding(
                                padding: const EdgeInsets.all(8),
                                child: CustomTextFormField(
                                  controller: _passwordController,
                                  obscureText: hidePassword,
                                  counterText: "",
                                  maxLength: maxLength(),
                                  suffixIconTrue: true,
                                  enabled: !enable,
                                  keyboardType: widget.type == "Password"
                                      ? TextInputType.visiblePassword
                                      : TextInputType.number,
                                  title: 'New ${widget.type}',
                                  required: true,
                                  inputFormatters: widget.type == 'Password'
                                      ? []
                                      : [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                  errorMaxLines: 2,
                                  textInputAction: TextInputAction.next,
                                  //prefixIcon: icon,
                                  prefixIcon: isIcon
                                      ? Icons.check_circle_outline
                                      : icon,
                                  iconColor: isIcon ? Colors.green : null,
                                  suffixIcon: hidePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  suffixIconOnPressed: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                  onChanged: (value) {
                                    if (_passwordController.text.isNotEmpty &&
                                        _passwordController.text ==
                                            _confirmPasswordController.text) {
                                      setState(() {
                                        isIcon = true;
                                      });
                                    } else {
                                      setState(() {
                                        isIcon = false;
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter  new ${widget.type}!';
                                    }
                                    if (widget.type == "Password" &&
                                        !Validators.isPassword(value)) {
                                      return 'Use 8 or more characters with a mix of letters, numbers & symbols';
                                    }
                                    if (widget.type == "PIN") {
                                      if (value.length != 4) {
                                        return 'PIN must be 4 digit';
                                      }
                                      if (Validators.isConsecutive(value) !=
                                          -1) {
                                        return 'PIN should not be consecutive digits.';
                                      }
                                    }
                                    if (widget.type == "MPIN") {
                                      if (value.length != 6) {
                                        return 'MPIN must be 6 digit';
                                      }
                                      if (Validators.isConsecutive(value) !=
                                          -1) {
                                        return 'MPIN should not be consecutive digits.';
                                      }
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    if (widget.type == "Password") {
                                      changePasswordModel.newPassword = value;
                                    } else if (widget.type == "PIN") {
                                      changePasswordModel.newPin = value;
                                    } else {
                                      changePasswordModel.newMpin = value;
                                    }
                                  },
                                )),
                            // CONFIRM PASSWORD
                            Padding(
                                padding: const EdgeInsets.all(8),
                                child: CustomTextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: hideCnfPassword,
                                  counterText: "",
                                  maxLength: maxLength(),
                                  enabled: !enable,
                                  keyboardType: widget.type == "Password"
                                      ? TextInputType.visiblePassword
                                      : TextInputType.number,
                                  title: 'Confirm ${widget.type}',
                                  required: true,
                                  inputFormatters: widget.type == 'Password'
                                      ? []
                                      : [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                  errorMaxLines: 2,
                                  //prefixIcon: icon,
                                  prefixIcon: isIcon
                                      ? Icons.check_circle_outline
                                      : icon,
                                  iconColor: isIcon ? Colors.green : null,
                                  suffixIcon: hideCnfPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  suffixIconTrue: true,
                                  suffixIconOnPressed: () {
                                    setState(() {
                                      hideCnfPassword = !hideCnfPassword;
                                    });
                                  },
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) {
                                    if (_passwordController.text.isNotEmpty &&
                                        _passwordController.text ==
                                            _confirmPasswordController.text) {
                                      setState(() {
                                        isIcon = true;
                                      });
                                    } else {
                                      setState(() {
                                        isIcon = false;
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Confirm ${widget.type}!';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Both ${widget.type} must match!';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    if (widget.type == "Password") {
                                      changePasswordModel.confirmNewPassword =
                                          value;
                                    } else if (widget.type == "PIN") {
                                      changePasswordModel.confirmNewPin = value;
                                    } else {
                                      changePasswordModel.confirmNewMpin =
                                          value;
                                    }
                                  },
                                )),
                            const SizedBox(height: 20),
                            AppButton(
                              title: 'Submit ',
                              onPressed: () {
                                submit();
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      )),
                )
              : const LoadingWidget(),
        ));
  }

  // Generate OTP api for password/pin/mPin update
  Future<void> otpGenerationApi(String resend) async {
    setLoading(false);
    apiService.otpVerifications().then((response) async {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          if (resend.isEmpty) {
            startTimer();
          } else {
            stopTimer();
            resetTimer();
            startTimer();
          }
          setState(() {
            otpMessage = decodeData['responseMessage'].toString();
          });
        } else {
          alertWidget.failure(context, 'Failure', decodeData['message']);
        }
      } else {
        alertWidget.failure(context, 'Failure', decodeData['message']);
      }
      setLoading(true);
    });
  }

  // Function to return maximum length
  int? maxLength() {
    if (widget.type == "Password") {
      return 14;
    } else if (widget.type == "PIN") {
      return 4;
    } else {
      return 6;
    }
  }

  // Validate OTP api function to validate OTP
  void validateOtpApi(OtpValidateRequest request) async {
    setLoading(false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    request.instId = Constants.instId;
    request.userName = prefs.getString('userName')!;
    request.otp = await Validators.encrypt(request.otp.toString());
    userServices.otpValidate(request).then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          stopTimer();
          setState(() {
            enable = false;
            otpVerified = decodeData['responseMessage'];
            changePasswordModel.otp = request.otp;
          });
        } else {
          setState(() {
            otpVerified = '';
          });
          alertWidget.failure(
              context, 'Failure', decodeData['responseMessage']);
        }
      } else {
        alertWidget.failure(context, 'Failure', decodeData['message']);
      }
      setLoading(true);
    });
  }

  // DYNAMIC LOADING STATE
  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _formKey.currentState?.dispose();
    countdownTimer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }
}
