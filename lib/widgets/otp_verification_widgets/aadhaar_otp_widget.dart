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
    required Function(bool validated, String addharHelpertext)
        onSubmit}) async {
  UserServices userServices = UserServices();
  final _otpCtrl = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
  const fillColor = Color.fromRGBO(243, 246, 249, 0);
  const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

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
    // barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
          content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomTextWidget(
                text: "Verify your Aadhaar Otp sent to",
                size: 14,
                color: AppColors.kLightGreen,
              ),
              CustomTextWidget(
                text:
                    "********${aadhaarNumber[aadhaarNumber.length - 4]}${aadhaarNumber[aadhaarNumber.length - 3]}${aadhaarNumber[aadhaarNumber.length - 2]}${aadhaarNumber[aadhaarNumber.length - 1]}",
                size: 12,
                color: AppColors.black,
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
                  //   debugPrint('onClipboardFound: $value');
                  //   pinController.setText(value);
                  // },
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) {
                    debugPrint('onCompleted: $pin');
                  },
                  onChanged: (value) {
                    debugPrint('onChanged: $value');
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
              SizedBox(
                height: 40,
              ),
              AppButton(
                backgroundColor: AppColors.kPrimaryColor,
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    focusNode.unfocus();
                    userServices
                        .validateAddhaarOtp(aadhaarNumber, _otpCtrl.text)
                        .then((response) async {
                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        if (response.body.toString() == "true") {
                          onSubmit(true, "Verified");
                          Navigator.of(context).pop();
                        } else {
                          alertService.error("Verification failed");
                        }
                      } else {
                        onSubmit(false, "Failed try Again");
                        alertService.error("Invalid otp");
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
      ));
    },
  );
}
