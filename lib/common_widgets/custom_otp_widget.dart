import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import 'package:sifr_latest/pages/users/signup/customer/customer.dart';
import 'package:sifr_latest/services/services.dart';

import '../config/app_color.dart';
import '../main.dart';
import '../widgets/app/customAlert.dart';
import '../widgets/custom_text_widget.dart';
import '../widgets/form_field/custom_text.dart';

class CustomOtpWidget extends StatefulWidget {
  final Function(String)? onCompleted;
  String? Function(String?)? validator;
  final TextEditingController phonemumbercontroller;

  CustomOtpWidget({
    Key? key,
    this.onCompleted,
    this.validator,
    required this.phonemumbercontroller,
  }) : super(key: key);

  @override
  State<CustomOtpWidget> createState() => _CustomOtpWidgetState();
}

class _CustomOtpWidgetState extends State<CustomOtpWidget> {
  TextEditingController pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  UserServices userServices = UserServices();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool isOtpVisible = false;

  Future checkForExistingMerchant(String number) async {
    var response = await userServices.checkForExistingMerchant(number);
    if (response.statusCode != 200) return;
    var jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  void onTapConfirm() {
    Navigator.push<void>(
      context,
      CupertinoPageRoute<void>(
        builder: (BuildContext context) =>
            MerchantSignup(verifiednumber: widget.phonemumbercontroller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    /// Optionally you can use form to validate the Pinput
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextFormField(
            titleEneabled: false,
            title: "Merchant Mobile Number",
            hintText: "Enter Merchant Mobile Number",
            enabled: true,
            controller: widget.phonemumbercontroller,
            keyboardType: TextInputType.number,

            maxLength: 10,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
            ],

            prefixIcon: Icons.phone,

            onChanged: (phone) {
              setState(() {});
            },
            suffixIcon: widget.phonemumbercontroller.text.length == 10
                ? GestureDetector(
                    onTap: () async {
                      if (widget.phonemumbercontroller.text.isEmpty) {
                        return;
                      }
                      if (widget.phonemumbercontroller.text.length < 10) {
                        return;
                      }

                      FocusManager.instance.primaryFocus?.unfocus();

                      var response = await checkForExistingMerchant(
                          widget.phonemumbercontroller.text);

                      if (kDebugMode) print(response);

                      if (response['statusCode'] == 208) {
                        print('hello');
                        if (mounted) {
                          CustomAlert().displayDialogConfirm(
                              context,
                              'Continue',
                              '${response['errorMessage']}',
                              onTapConfirm);
                        }
                      } else {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('OTP has been sent successfully'),
                              duration:
                                  Duration(seconds: 3), // Optional duration
                            ),
                          );
                        });

                        setState(() {
                          isOtpVisible = true;
                        });
                      }
                    },
                    child: const Column(
                      children: [
                        Icon(
                          Icons.send,
                          color: AppColors.kLightGreen,
                        ),
                        CustomTextWidget(
                          text: "Send",
                          size: 10,
                          color: AppColors.kLightGreen,
                        )
                      ],
                    ),
                  )
                : Container(width: 0),

            suffixIconTrue: true,

            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone Number is Mandatory!';
              }
              if (value.length < 10) {
                return 'Length should be equal to 10 numbers';
              }

              return null;
            },

            // validator: (value) {
            //  if(kDebugMode)print(value);
            //   return '';
            // },
          ),
          // const AppTextFormField(
          //   title: 'Enther the Merchant Mobile Number',
          //   required: false,
          //   suffixIcon: Icons.send_outlined,
          //   iconColor: AppColors.kLightGreen,
          //   eneablrTitle: false,
          //   suffixIconTrue: true,
          // ),
          const SizedBox(
            height: 30,
          ),

          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      CustomTextWidget(
                        text: "Verify the Number with OTP",
                        color: Colors.black.withOpacity(.6),
                        size: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      CustomTextWidget(
                        text: "sent on the Merchant Mobile Number",
                        color: Colors.black.withOpacity(.6),
                        size: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Directionality(
                // Specify direction if desired
                textDirection: TextDirection.ltr,
                child: Pinput(
                  obscureText: true,
                  controller: pinController,
                  focusNode: focusNode,
                  // androidSmsAutofillMethod:
                  //     AndroidSmsAutofillMethod.smsUserConsentApi,
                  // listenForMultipleSmsOnAndroid: true,
                  defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  validator: widget.validator,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // onClipboardFound: (value) {
                  //  if(kDebugMode)print('onClipboardFound: $value');
                  //   pinController.setText(value);
                  // },
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: widget.onCompleted,

                  // (pin) {
                  //  if(kDebugMode)print('onCompleted: $pin');
                  // },
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
              CustomAppButton(
                backgroundColor: (isOtpVisible)
                    ? AppColors.getMaterialColorFromColor(
                        AppColors.kPrimaryColor)
                    : Colors.white.withOpacity(.5),
                title: 'Verify',
                onPressed: () {
                  if (!isOtpVisible) return;

                  focusNode.unfocus();
                  formKey.currentState!.save();
                  if (formKey.currentState!.validate()) {
                    Navigator.push<void>(
                      context,
                      CupertinoPageRoute<void>(
                        builder: (BuildContext context) => MerchantSignup(
                            verifiednumber: widget.phonemumbercontroller),
                      ),
                    );
                  }

                  if (kDebugMode) print(pinController.text);
                  // Navigator.pushNamed(context, 'merchantOnboarding');
                  // Navigator.push(context, route);
                },
              ),
              if (isOtpVisible)
                TextButton(
                    onPressed: () {},
                    child: const CustomTextWidget(
                      text: 'Resend OTP',
                      color: Colors.green,
                      size: 15,
                      fontWeight: FontWeight.bold,
                    )),
            ],
          ),
        ],
      ),
    );
  }
}
