/* ===============================================================
| Project : SIFR
| Page    : CHANGE_EMAIL.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:pinput/pinput.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/storage/secure_storage.dart';
import 'package:sifr_latest/widgets/app_widget/app_button.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../models/email_mobile_change_model.dart';
import '../../models/otp_validate_model.dart';
import '../../services/user_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/form_field/custom_mobile_field.dart';
import '../../widgets/form_field/custom_text.dart';

// STATEFUL WIDGET
class ChangeEmail extends StatefulWidget {
  const ChangeEmail({Key? key, this.type, this.list}) : super(key: key);
  final String? type;
  final dynamic list;

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

// Change Email State Class
class _ChangeEmailState extends State<ChangeEmail> {
  UserServices apiService = UserServices();
  BoxStorage boxStorage = BoxStorage();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AlertService alertWidget = AlertService();
  OtpValidateRequest request = OtpValidateRequest();
  UserServices userServices = UserServices();
  final _pinPutController = TextEditingController();
  final TextEditingController _mobileCodeController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  EmailOrMobileChangeModel emailOrMobileChangeModel =
      EmailOrMobileChangeModel();

  // LOCAL VARIABLE DECLARATION
  bool _isLoading = false;
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 2);
  late String? otpMessage = '';
  bool enable = true;
  String? otpVerified = '';
  String? requestType = '';
  String countryCode = 'AE';
  late Country _country =
      countries.firstWhere((element) => element.code == countryCode);
  String? mobileNoCheckMessage;
  TextStyle? style;
  String emailCheck = '';
  String mobileCheck = '';

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

  // Init function for page Initialization
  @override
  void initState() {
    otpGenerationApi(''); // Generate OTP api for emailId/mobileNo update
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
                                      validateOtp(request);
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
                            // RECENT EMAIID OR MOBILE NUMBER
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: CustomTextFormField(
                                  initialValue: widget.type == 'Email ID'
                                      ? widget.list['emailId'].toString()
                                      : widget.list['mobileNumber'].toString(),
                                  counterText: "",
                                  enabled: false,
                                  keyboardType: widget.type == 'Email ID'
                                      ? TextInputType.text
                                      : TextInputType.number,
                                  title: 'Old ${widget.type}',
                                  required: true,
                                  errorMaxLines: 2,
                                  inputFormatters: widget.type == 'Email ID'
                                      ? [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[a-z_A-Z0-9.@]'))
                                        ]
                                      : [],
                                  prefixIcon: widget.type == "Email ID"
                                      ? Icons.alternate_email
                                      : Icons.phone,
                                  suffixIconTrue: false,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter old ${widget.type}!';
                                    }
                                    if (!Validators.isValidEmail(value) &&
                                        widget.type == 'Email ID') {
                                      return Constants.emailError;
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    if (widget.type == 'Email ID') {
                                      emailOrMobileChangeModel.emailId = value;
                                    } else {
                                      emailOrMobileChangeModel.mobileNumber =
                                          value;
                                    }
                                  },
                                )),
                            // EMAIL ID AND MOBILE NUMBER
                            widget.type != 'Email ID'
                                ? Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: CustomMobileField(
                                      controller: _mobileNoController,
                                      keyboardType: TextInputType.number,
                                      title: 'New Mobile Number',
                                      enabled: !enable,
                                      required: true,
                                      helperText: mobileNoCheckMessage,
                                      helperStyle: style,
                                      prefixIcon: FontAwesome.mobile,
                                      countryCode: countryCode,
                                      onChanged: (phone) {
                                        emailOrMobileChangeModel
                                            .newMobileNumber = phone.number;
                                        emailOrMobileChangeModel
                                                .mobileCountryCode =
                                            phone.countryCode;
                                        if (phone.number.isNotEmpty &&
                                            (phone.number.length >=
                                                    _country.minLength &&
                                                phone.number.length <=
                                                    _country.maxLength)) {
                                          getEmailIdOrMobileNo(
                                              'mobileNumber', phone.number);
                                        }
                                      },
                                      onCountryChanged: (country) {
                                        setState(() {
                                          countryCode = country.code;
                                          _country = country;
                                          _mobileCodeController.text =
                                              countryCode;
                                        });
                                      },
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: CustomTextFormField(
                                      controller: _mobileNoController,
                                      counterText: "",
                                      enabled: !enable,
                                      keyboardType: TextInputType.text,
                                      title: 'New ${widget.type}',
                                      required: true,
                                      errorMaxLines: 2,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[a-z_A-Z0-9.@]'))
                                      ],
                                      prefixIcon: widget.type == "Email ID"
                                          ? Icons.alternate_email
                                          : Icons.phone,
                                      suffixIconTrue: false,
                                      helperText: emailCheck == 'false'
                                          ? Constants.emailIdSuccessMessage
                                          : '',
                                      helperStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                      textInputAction: TextInputAction.done,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter new ${widget.type}!';
                                        }
                                        if (!Validators.isValidEmail(value)) {
                                          return Constants.emailError;
                                        }
                                        if (emailCheck == 'true') {
                                          return Constants
                                              .emailIdFailureMessage;
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        if (Validators.isValidEmail(value)) {
                                          getEmailIdOrMobileNo(
                                              'emailId', value);
                                        }
                                      },
                                      onSaved: (value) {
                                        emailOrMobileChangeModel.newEmailId =
                                            value;
                                      },
                                    )),
                            const SizedBox(height: 15),
                            AppButton(
                              title: 'Submit',
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

  // Generate OTP api for emailId/mobileNo update
  Future<void> otpGenerationApi(String resend) async {
    requestType = widget.type == 'Email ID' ? 'emailChange' : 'mobileChange';
    setLoading(false);
    apiService.otpVerificationsEmail(requestType).then((response) async {
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

  // Validate OTP api function to validate OTP
  void validateOtp(OtpValidateRequest request) async {
    setLoading(false);
    request.otp = await Validators.encrypt(request.otp.toString());
    request.instId = Constants.instId;
    request.userName = boxStorage.getUsername();
    userServices.otpValidate(request).then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          stopTimer();
          setState(() {
            enable = false;
            otpVerified = decodeData['responseMessage'];
            emailOrMobileChangeModel.otp = request.otp;
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

  // Get existing emailId/mobileNo from SIFR api
  getEmailIdOrMobileNo(String type, String request) async {
    request = await Validators.encrypt(request);
    userServices.emailMobileCheck(type, request).then((response) async {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (type == 'emailId') {
          setState(() {
            emailCheck = response.body;
            mobileCheck = 'false';
          });
        } else {
          setState(() {
            mobileCheck = response.body;
            if (response.body == 'true') {
              mobileNoCheckMessage = Constants.mobileNoFailureMessage;
              style = Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.red);
            } else {
              mobileNoCheckMessage = Constants.mobileNoSuccessMessage;
              style = Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).primaryColor);
            }
          });
        }
      }
    });
  }

  // DYNAMIC LOADING STATE
  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  // Form submit function for emailId/mobileNo update
  submit() async {
    if (_formKey.currentState!.validate() && mobileCheck == 'false') {
      setLoading(false);
      _formKey.currentState!.save();
      if (widget.type == 'Email ID') {
        emailOrMobileChangeModel.emailId = await Validators.encrypt(
            emailOrMobileChangeModel.emailId.toString());
        emailOrMobileChangeModel.newEmailId = await Validators.encrypt(
            emailOrMobileChangeModel.newEmailId.toString());
      } else {
        emailOrMobileChangeModel.mobileNumber = await Validators.encrypt(
            emailOrMobileChangeModel.mobileNumber.toString());
        emailOrMobileChangeModel.newMobileNumber = await Validators.encrypt(
            emailOrMobileChangeModel.newMobileNumber.toString());
      }
      apiService
          .changeEmailOrMobile(emailOrMobileChangeModel, widget.type)
          .then((response) async {
        var decodeData = jsonDecode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (decodeData['responseCode'].toString() == "00") {
            stopTimer();
            alertWidget.success(
                context, 'Success', decodeData['responseMessage']);
            Navigator.pushNamed(context, 'myAccount');
          } else {
            mobileNoCheckMessage = '';
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

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }
}
