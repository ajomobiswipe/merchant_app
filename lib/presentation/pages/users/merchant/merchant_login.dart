import 'dart:async';
import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/providers/permission.dart';
import 'package:anet_merchant_app/presentation/widgets/common_widgets/custom_app_button.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/app/alert_service.dart';
import '../../../widgets/loading.dart';

class MerchantLogin extends StatefulWidget {
  const MerchantLogin({super.key});
  static const String routeName = '/login';

  @override
  State<MerchantLogin> createState() => _MerchantLoginState();
}

class _MerchantLoginState extends State<MerchantLogin> {
  String password = "Password";
  String pin = "PIN";
  var keyboardType = TextInputType.text;
  // late PackageInfo _packageInfo = PackageInfo(
  //   appName: 'Unknown',
  //   packageName: 'Unknown',
  //   version: 'Unknown',
  //   buildNumber: 'Unknown',
  //   buildSignature: 'Unknown',
  // );

  // VARIABLE DECLARATION
  bool hidePassword = true;
  bool hideMobileOtp = true;
  bool hideEmailOtp = true;
  bool isFinished = false;
  AlertService alertWidget = AlertService();
  bool isRemember = false;

  double screenWidth = 0;
  double screenHeight = 0;

  @override
  void initState() {
    super.initState();
    DevicePermission().checkPermission();
    _checkRememberMe();
    // _initPackageInfo();
  }

  Future _checkRememberMe() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? rememberMe = pref.getBool('rememberMe');

    if (rememberMe == null) {
      isRemember = false;
      return;
    }

    isRemember = rememberMe;

    if (isRemember) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.merchantIdController.text =
          pref.getString('merchantId') ?? '';
      authProvider.passwordController.text = pref.getString('password') ?? '';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Consumer<AuthProvider>(builder: (context, authProvider, snapshot) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: authProvider.isLoading
            ? const LoadingWidget()
            : SizedBox(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: MediaQuery.of(context).padding.bottom,
                    left: MediaQuery.of(context).size.width * .05,
                    right: MediaQuery.of(context).size.width * .05,
                  ),
                  child: Center(
                      child: Form(
                    key: authProvider.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onTap: () {
                            if (authProvider.isOtpSent) {
                              authProvider.clearOtp();
                            }
                            // else {
                            //   Navigator.pushNamedAndRemoveUntil(
                            //       context, 'merchantLogin', (route) => false);
                            // }
                          },
                        ),

                        gapWidget(screenHeight * .01),
                        Center(
                          child: Image.asset("assets/screen/anet.png",
                              height: 100, fit: BoxFit.fill),
                        ),

                        const Center(
                          child: CustomTextWidget(
                            text: 'Before Continue, please sign in first',
                            size: 12,
                            color: AppColors.black50,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        gapWidget(screenHeight * .03),
                        // toggledButton(),
                        authProvider.isOtpSent
                            ? Container()
                            // buildTextField(
                            //     controller:
                            //         authProvider.phoneNumberOtpController,
                            //     hintText: 'Enter the OTP sent to your mobile',
                            //     labelText: "******9545",
                            //     obscureText: hideMobileOtp,
                            //     maxLength: 6,
                            //     isPasswordField: true,
                            //     inputFormatters: [
                            //       FilteringTextInputFormatter.allow(
                            //           RegExp(r'[0-9]'))
                            //     ],
                            //     keyboardType: TextInputType.number,
                            //     onSaved: (value) {
                            //       authProvider.req.mobileNumberOtp = value;
                            //     },
                            //     validator: (value) {
                            //       if (value == null || value.isEmpty) {
                            //         return 'Please enter OTP!';
                            //       }
                            //     },
                            //   )

                            : buildTextField(
                                controller: authProvider.merchantIdController,
                                hintText: 'Username',
                                labelText: "Username",
                                onSaved: (value) {
                                  authProvider.req.merchantId = value;
                                },
                                obscureText: false,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9,a-zA-Z]'))
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Username!';
                                  }
                                  if (value.length < 10) {
                                    return 'Minimum character length is 10';
                                  }
                                  return null;
                                },
                              ),
                        gapWidget(screenHeight * .01),
                        authProvider.isOtpSent
                            ? buildTextField(
                                controller: authProvider.emailOtpController,
                                hintText: 'Enter the OTP sent to your email',
                                labelText: "******@gmail.com",
                                maxLength: 6,
                                obscureText: hideEmailOtp,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]'))
                                ],
                                keyboardType: TextInputType.number,
                                isPasswordField: true,
                                onSaved: (value) {
                                  authProvider.req.emailOtp = value;
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter OTP';
                                  }
                                },
                              )
                            : Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: CustomTextWidget(
                                        text: "Password",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextFormField(
                                      controller:
                                          authProvider.passwordController,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              fontSize: 13, fontFamily: 'Mont'),
                                      obscureText: authProvider.showPassword,
                                      obscuringCharacter: '*',
                                      maxLength: null,
                                      keyboardType: TextInputType.text,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      onSaved: (value) {
                                        authProvider.req.password = value;
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter Password!';
                                        }
                                        if (value.length < 10) {
                                          return 'Minimum character length is 10';
                                        }
                                        return null;
                                      },
                                      inputFormatters: null,
                                      decoration: InputDecoration(
                                        hintText: 'Password',
                                        counterText: '',
                                        labelStyle: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(fontSize: 16),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        border: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 10),
                                        fillColor: AppColors.kTileColor,
                                        filled: true,
                                        hintStyle: const TextStyle(
                                            color: Colors.grey, fontSize: 13),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            authProvider
                                                .togglePasswordVisibility();
                                          },
                                          icon: Icon(
                                            authProvider.showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        gapWidget(screenHeight * .01),
                        //login(),
                        !authProvider.isOtpSent
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                    //forgotUserName(),
                                    Checkbox(
                                      value: isRemember,
                                      onChanged: (value) async {
                                        isRemember = value!;
                                        SharedPreferences pref =
                                            await SharedPreferences
                                                .getInstance();
                                        pref.setBool('rememberMe', value);
                                        // print(pref.getBool('rememberMe'));
                                        setState(() {});
                                      },
                                    ),
                                    const CustomTextWidget(
                                      text: "Remember me",
                                      fontWeight: FontWeight.bold,
                                      // color: AppColors.kPrimaryColor,
                                    ),
                                    const Spacer(),
                                  ])
                            : gapWidget(screenHeight * .04),
                        gapWidget(screenHeight * .01),
                        CustomAppButton(
                          title: authProvider.isOtpSent ? "Verify" : 'Sign In',
                          onPressed: authProvider.onPresSendButton,
                        ),
                        !authProvider.isOtpSent
                            ? Center(child: forgotPassword())
                            : gapWidget(screenHeight * .01),
                        gapWidget(screenHeight * .01),
                        const Center(
                          child: CustomTextWidget(
                            text: '--- Or ---',
                            size: 18,
                          ),
                        ),
                        gapWidget(screenHeight * .01),
                        const Center(
                          child: CustomTextWidget(
                            text: 'Connect With Us',
                            size: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        gapWidget(screenHeight * .02),

                        Row(
                          children: [
                            const Expanded(
                              flex: 4,
                              child: SizedBox(),
                            ),
                            connectWithOptions(
                              icon: const Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            CustomTextWidget(
                                text: "+911203584948",
                                size: 18,
                                color: AppColors.black50,
                                fontWeight: FontWeight.w400),
                            const Expanded(
                              flex: 4,
                              child: SizedBox(),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(
                              flex: 4,
                              child: SizedBox(),
                            ),
                            connectWithOptions(
                              icon: const Icon(
                                Icons.email_outlined,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            CustomTextWidget(
                                text: "support@alliancenetworkcompany.com",
                                size: 12,
                                color: AppColors.black50,
                                fontWeight: FontWeight.w400),
                            const Expanded(
                              flex: 4,
                              child: SizedBox(),
                            ),
                          ],
                        ),

                        // copyRightWidget(packageInfoVersion: _packageInfo.version),
                        gapWidget(screenHeight * .02),
                      ],
                    ),
                  )),
                ),
              ),
      );
    });
  }

  Widget gapWidget(double height) {
    return SizedBox(height: height);
  }

  Column connectWithOptions({required Widget icon, Function()? onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
              backgroundColor: AppColors.kPrimaryColor, child: icon),
        ),
      ],
    );
  }

  Widget buildTextField(
      {required TextEditingController controller,
      required String hintText,
      required String labelText,
      required bool obscureText,
      required Function(String?) onSaved,
      required String? Function(String?)? validator,
      int? maxLength,
      TextInputType keyboardType = TextInputType.text,
      bool? isPasswordField,
      List<TextInputFormatter>? inputFormatters}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: CustomTextWidget(
              text: labelText,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            controller: controller,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: 13, fontFamily: 'Mont'),
            obscureText: isPasswordField == true ? obscureText : false,
            obscuringCharacter: '*',
            maxLength: maxLength,
            keyboardType: keyboardType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onSaved: onSaved,
            validator: validator,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hintText,
              counterText: '',
              labelStyle:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              fillColor: AppColors.kTileColor,
              filled: true,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              // suffixIcon: isPasswordField == true
              //     ? IconButton(
              //         onPressed: () {
              //           setState(() {
              //             if (controller == _passwordController) {
              //               hidePassword = !hidePassword;
              //             } else if (controller == _phoneNumberOtpController) {
              //               hideMobileOtp = !hideMobileOtp;
              //             } else if (controller == _emailOtpController) {
              //               hideEmailOtp = !hideEmailOtp;
              //             }
              //           });
              //         },
              //         icon: Icon(
              //           (controller == _passwordController && hidePassword) ||
              //                   (controller == _phoneNumberOtpController &&
              //                       hideMobileOtp) ||
              //                   (controller == _emailOtpController &&
              //                       hideEmailOtp)
              //               ? Icons.visibility_off
              //               : Icons.visibility,
              //           color: Theme.of(context).primaryColor,
              //         ),
              //       )
              //     : null,
            ),
          ),
        ],
      ),
    );
  }

  forgotPassword() {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, 'forgotPassword');
      },
      child: const CustomTextWidget(
        text: "Forgot Password?",
        color: AppColors.kPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
