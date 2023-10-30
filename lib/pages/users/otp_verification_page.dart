/* ===============================================================
| Project : SIFR
| Page    : OTP_VERIFICATION_PAGE.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:sifr_latest/models/models.dart';
import 'package:sifr_latest/widgets/app_widget/app_button.dart';

import '../../config/config.dart';
import '../../services/user_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/loading.dart';

// STATEFUL WIDGET
class OTPVerification extends StatefulWidget {
  const OTPVerification({Key? key, this.userName, this.type}) : super(key: key);
  final String? userName;
  final String? type;

  @override
  State<OTPVerification> createState() => _OTPVerificationState();
}

// OTP Verification Class
class _OTPVerificationState extends State<OTPVerification> {
  final _pinPutController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  AlertService alertWidget = AlertService();
  UserServices userServices = UserServices();
  ResetPasscode resetPasscode = ResetPasscode();
  OtpValidateRequest request = OtpValidateRequest();

  // LOCAL VARIABLE DECLARATION
  bool hidePassword = true;
  bool hideCnfPassword = true;
  late String? otpMessage = '';
  String? otpVerified = '';
  String? code;
  bool _isLoading = false;
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 2);
  bool enable = true;
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

  // Form submit function for password/pin reset
  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      setLoading(false);
      _formKey.currentState!.save();
      resetPasscode.otp =
          await Validators.encrypt(resetPasscode.otp.toString());
      resetPasscode.instId = Constants.instId;
      resetPasscode.pwdResetType = Constants.pwdResetType;
      resetPasscode.userName = widget.userName.toString();
      resetPasscode.deviceType = Constants.deviceType;
      if (widget.type == 'PIN') {
        resetPasscode.newPin =
            await Validators.encrypt(resetPasscode.newPin.toString());
        resetPasscode.confirmNewPin =
            await Validators.encrypt(resetPasscode.confirmNewPin.toString());
      } else {
        resetPasscode.newPassword =
            await Validators.encrypt(resetPasscode.newPassword.toString());
        resetPasscode.confirmNewPassword = await Validators.encrypt(
            resetPasscode.confirmNewPassword.toString());
      }
      userServices.resetPassword(resetPasscode).then((response) {
        var decodeData = jsonDecode(response.body);
        if (decodeData['responseCode'].toString() == "00") {
          alertWidget.success(
              context, 'Success', decodeData['responseMessage']);
          Navigator.pushNamed(context, 'login');
          setLoading(true);
        } else {
          alertWidget.failure(
              context, 'Failure', decodeData['responseMessage']);
          setLoading(true);
        }
      });
    }
  }

  // Init function for page Initialization
  @override
  void initState() {
    otpGenerationApi(widget.userName.toString(),
        ''); // Generate OTP api for password/pin reset
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

        // color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
    );
    return Scaffold(
      appBar: const AppBarWidget(
        title: "Verification",
        action: false,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: !_isLoading
          ? const LoadingWidget()
          : Form(
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
                          height: 20,
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
                        // Align(
                        //   alignment: Alignment.center,
                        //   child: Image.asset('assets/screen/verification.png',
                        //       height: 200, fit: BoxFit.fill),
                        // ),
                        const SizedBox(
                          height: 30,
                        ),
                        // Verification Code Input
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
                                autofocus: true,
                                obscureText: true,
                                obscuringCharacter: '*',
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
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: countdownTimer!.isActive
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("OTP will expire in $minutes:$seconds",
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
                                                      widget.userName
                                                          .toString(),
                                                      'resend');
                                                },
                                                child: Text(
                                                  "Resend OTP",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displaySmall
                                                      ?.copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                          height: 40,
                        ),
                        Text(
                          "Reset ${widget.type}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // PASSWORD
                        passwordField(),
                        // CONFIRM PASSWORD
                        const SizedBox(height: 15),
                        confirmPasswordField(),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: AppButton(
                            title: 'Reset ${widget.type}',
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
                  )),
            ),
    );
  }

  //Custom text-field
  passwordField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: TextFormField(
        autofocus: true,
        controller: _passwordController,
        enabled: !enable,
        keyboardType: widget.type == 'PIN'
            ? TextInputType.number
            : TextInputType.visiblePassword,
        maxLength: widget.type == 'PIN' ? 4 : 14,
        obscureText: hidePassword,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: widget.type == 'PIN'
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
        decoration: InputDecoration(
          counterText: "",
          labelText: "${widget.type} *",
          labelStyle: TextStyle(color: Theme.of(context).primaryColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          errorMaxLines: 2,
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          prefixIcon: isIcon
              ? const Icon(Icons.check_circle_outline,
                  size: 25, color: Colors.green)
              : Icon(Icons.lock,
                  size: 25, color: Theme.of(context).primaryColor),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                hidePassword = !hidePassword;
              });
            },
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
          ),
        ),
        onSaved: (value) {
          widget.type == 'PIN'
              ? resetPasscode.newPin = value
              : resetPasscode.newPassword = value;
        },
        onChanged: (value) {
          if (_passwordController.text.isNotEmpty &&
              _passwordController.text == _confirmPasswordController.text) {
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
            return '${widget.type} is Mandatory!';
          }
          if (!Validators.isPassword(value) && widget.type == 'Password') {
            return 'Use 8 or more letters with a mix of letters, numbers & symbols';
          }
          if (widget.type == "PIN") {
            if (value.length != 4) {
              return 'PIN must be 4 digit';
            }
            if (Validators.isConsecutive(value) != -1) {
              return 'PIN should not be consecutive digits.';
            }
          }

          return null;
        },
      ),
    );
  }

  //Custom text-field
  confirmPasswordField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: TextFormField(
        controller: _confirmPasswordController,
        enabled: !enable,
        keyboardType: widget.type == 'PIN'
            ? TextInputType.number
            : TextInputType.visiblePassword,
        maxLength: widget.type == 'PIN' ? 4 : 14,
        obscureText: hideCnfPassword,
        inputFormatters: widget.type == 'PIN'
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        autofocus: true,
        decoration: InputDecoration(
          counterText: "",
          labelText: 'Confirm ${widget.type} *',
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
          prefixIcon: isIcon
              ? const Icon(Icons.check_circle_outline,
                  size: 25, color: Colors.green)
              : Icon(Icons.lock,
                  size: 25, color: Theme.of(context).primaryColor),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                hideCnfPassword = !hideCnfPassword;
              });
            },
            color: Theme.of(context).primaryColor.withOpacity(0.8),
            icon:
                Icon(hideCnfPassword ? Icons.visibility_off : Icons.visibility),
          ),
        ),
        onChanged: (value) {
          if (_passwordController.text.isNotEmpty &&
              _passwordController.text == _confirmPasswordController.text) {
            setState(() {
              isIcon = true;
            });
          } else {
            setState(() {
              isIcon = false;
            });
          }
        },
        onSaved: (value) {
          widget.type == 'PIN'
              ? resetPasscode.confirmNewPin = value
              : resetPasscode.confirmNewPassword = value;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Confirm ${widget.type} is Mandatory!';
          }
          if (value != _passwordController.text) {
            return 'Both ${widget.type} must match!';
          }
          return null;
        },
      ),
    );
  }

  // Validate OTP api function to validate OTP
  Future<void> validateOtpApi(OtpValidateRequest request) async {
    setLoading(false);
    request.userName = widget.userName;
    request.instId = Constants.instId;
    request.otp = await Validators.encrypt(request.otp.toString());
    userServices.otpValidate(request).then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          stopTimer();
          setState(() {
            enable = false;
            otpVerified = decodeData['responseMessage'];
            resetPasscode.otp = request.otp;
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

  // Generate OTP api for password/pin reset
  void otpGenerationApi(String userName, String resend) {
    setLoading(false);
    userServices.otpVerification(userName).then((response) async {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          if (resend.isEmpty) {
            startTimer();
          } else {
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
