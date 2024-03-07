import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sifr_latest/config/app_color.dart';
import 'package:sifr_latest/main.dart';
import 'package:sifr_latest/services/services.dart';
import 'package:sifr_latest/widgets/app_widget/app_button.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

Future<void> emailOtpWidget(
    {required BuildContext context,
    required String title,
    required String emailId,
    required String? Function(String?)? validator,
    required Function(bool validated, String emailhelperText) onSubmit}) async {
  UserServices userServices = UserServices();
  final _otpCtrl = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool isOtpVerifying = false;
  var focusedBorderColor = const Color.fromRGBO(23, 171, 144, 1);
  const fillColor = Color.fromRGBO(243, 246, 249, 0);
  var borderColor = const Color.fromRGBO(23, 171, 144, 0.4);
  String errorMessage = "";

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 22,
      color: Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: borderColor),
    ),
  );

  //if(data.devices!.isNotEmpty)
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shadowColor: Colors.white,
            surfaceTintColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              width: double.infinity,
              child: Stack(
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomTextWidget(
                          text: "Verify email",
                          size: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.kPrimaryColor,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextWidget(
                          text: title,
                          size: 12,
                          color: Colors.black,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Directionality(
                          // Specify direction if desired
                          textDirection: TextDirection.ltr,
                          child: Pinput(
                            controller: _otpCtrl,
                            focusNode: focusNode,
                            androidSmsAutofillMethod:
                                AndroidSmsAutofillMethod.smsUserConsentApi,
                            listenForMultipleSmsOnAndroid: true,
                            obscureText: true,
                            obscuringCharacter: "*",
                            defaultPinTheme: defaultPinTheme,
                            separatorBuilder: (index) =>
                                const SizedBox(width: 8),
                            validator: (value) {
                              if (value!.isEmpty || value.length < 4) {
                                return '4 digits required';
                              } else {
                                null;
                              }
                              return null;
                            },
                            // onClipboardFound: (value) {
                            //  if(kDebugMode)print('onClipboardFound: $value');
                            //   pinController.setText(value);
                            // },
                            hapticFeedbackType: HapticFeedbackType.lightImpact,
                            onCompleted: (pin) {
                              if (kDebugMode) print('onCompleted: $pin');
                            },
                            onChanged: (value) {
                              if (kDebugMode) print('onChanged: $value');
                            },
                            cursor: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 9),
                                  width: 22,
                                  height: 1,
                                  color: focusedBorderColor,
                                ),
                              ],
                            ),
                            focusedPinTheme: defaultPinTheme.copyWith(
                              decoration: defaultPinTheme.decoration!.copyWith(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: focusedBorderColor),
                              ),
                            ),
                            submittedPinTheme: defaultPinTheme.copyWith(
                              decoration: defaultPinTheme.decoration!.copyWith(
                                color: fillColor,
                                borderRadius: BorderRadius.circular(19),
                                border: Border.all(color: focusedBorderColor),
                              ),
                            ),
                            errorPinTheme: defaultPinTheme.copyBorderWith(
                              border: Border.all(color: Colors.redAccent),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (errorMessage != "")
                          CustomTextWidget(
                            text: errorMessage,
                            color: Colors.red,
                          ),
                        const SizedBox(
                          height: 20,
                        ),
                        isOtpVerifying
                            ? Container(
                                color: AppColors.white,
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  ],
                                ),
                              )
                            : AppButton(
                                backgroundColor: AppColors.kPrimaryColor,
                                onPressed: () {
                                  setState(
                                    () {
                                      isOtpVerifying = true;
                                    },
                                  );
                                  if (formKey.currentState!.validate()) {
                                    focusNode.unfocus();

                                    userServices
                                        .verifyEmailOtp(
                                            emailId: emailId,
                                            otp: _otpCtrl.text)
                                        .then((response) async {
                                      if (kDebugMode)
                                        print('anas${response.body}');
                                      if (response.statusCode == 200 ||
                                          response.statusCode == 201) {
                                        onSubmit(true, "Verified");

                                        Navigator.of(context).pop();
                                      } else {
                                        onSubmit(false, "validation failed");
                                        alertService.error("Invalid otp");
                                        errorMessage = "Invalid otp";
                                        setState(
                                          () {
                                            isOtpVerifying = false;
                                            _otpCtrl.clear();
                                          },
                                        );
                                      }
                                    });
                                  }
                                },
                                title: "Submit",
                                // child: const Text('Validate'),
                              ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: InkWell(
                      child: const Icon(
                        Icons.close,
                        color: AppColors.kRedColor,
                      ),
                      onTap: () {
                        onSubmit(false, "Verification Canceled By User");
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
