import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sifr_latest/config/app_color.dart';
import 'package:sifr_latest/main.dart';
import 'package:sifr_latest/services/services.dart';
import 'package:sifr_latest/widgets/app_widget/app_button.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

Future<void> aadhaarOtpWidget(
    {required BuildContext context,
    required String aadhaarNumber,
    required String requestId,
    required Function(bool validated, String addharHelpertext)
        onSubmit}) async {
  UserServices userServices = UserServices();
  final _otpCtrl = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  bool isOtpVerifying = false;
  const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
  const fillColor = Color.fromRGBO(243, 246, 249, 0);
  const borderColor = Color.fromRGBO(23, 171, 144, 0.4);
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
      return AlertDialog(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState1) {
            return Stack(
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomTextWidget(
                        text: "Verify your Aadhaar Otp sent to",
                        size: 14,
                        color: AppColors.kPrimaryColor,
                      ),
                      CustomTextWidget(
                        text:
                            "********${aadhaarNumber[aadhaarNumber.length - 4]}${aadhaarNumber[aadhaarNumber.length - 3]}${aadhaarNumber[aadhaarNumber.length - 2]}${aadhaarNumber[aadhaarNumber.length - 1]}",
                        size: 12,
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Directionality(
                        // Specify direction if desired
                        textDirection: TextDirection.ltr,
                        child: Pinput(
                          length: 6,
                          controller: _otpCtrl,
                          focusNode: focusNode,
                          androidSmsAutofillMethod:
                              AndroidSmsAutofillMethod.smsUserConsentApi,
                          listenForMultipleSmsOnAndroid: true,
                          defaultPinTheme: defaultPinTheme,
                          obscureText: true,
                          obscuringCharacter: "*",
                          separatorBuilder: (index) => const SizedBox(width: 8),
                          validator: (value) {
                            if (value!.isNotEmpty && value.length < 4) {
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
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // CustomTextWidget(
                                    //     text: "Verifying Otp",
                                    //     color: AppColors.kPrimaryColor,
                                    //     size: 26),
                                    // CustomTextWidget(text: "Please wait..."),
                                    CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : AppButton(
                              backgroundColor: AppColors.kPrimaryColor,
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  setState1(() {
                                      isOtpVerifying = true;
                                    });
                                  focusNode.unfocus();

                                  var responseBody =
                                      await userServices.validateAddhaarOtp(
                                          aadhaarNumber,
                                          _otpCtrl.text,
                                          requestId);

                                  print('response123$responseBody');



                                  if (responseBody.statusCode == 200 ||
                                      responseBody.statusCode == 201) {
                                    if (responseBody.body.toString() ==
                                        "true") {
                                      onSubmit(true, "Verified");
                                      Navigator.of(context).pop();
                                    } else {

                                      Navigator.of(context).pop();
                                      onSubmit(false, "Verification failed.Try after some time");
                                      alertService.error("Verification failed.Try after some time");


                                      // setState1(() {
                                      //   errorMessage = "Verification failed";
                                      //   isOtpVerifying = false;
                                      //   _otpCtrl.clear();
                                      // });
                                      // alertService.error("Verification failed");
                                    }
                                  } else {

                                    Navigator.of(context).pop();

                                    onSubmit(false, "Failed try Again");

                                    alertService.error("Verification failed");

                                    // setState1(() {
                                    //   errorMessage = "Invalid otp";
                                    //   isOtpVerifying = false;
                                    //   _otpCtrl.clear();
                                    // });

                                    // onSubmit(false, "Failed try Again");
                                    // alertService.error("Invalid otp");
                                  }
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
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.kRedColor,
                    ),
                    onPressed: () {
                      onSubmit(false, "Verification Canceled By User");
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
