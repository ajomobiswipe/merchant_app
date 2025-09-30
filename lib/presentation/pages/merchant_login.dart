import 'dart:async';
import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/data/services/connectivity_service.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/providers/permission.dart';
import 'package:anet_merchant_app/presentation/widgets/common_widgets/custom_app_button.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/form_field/custom_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/loading.dart';

class MerchantLogin extends StatefulWidget {
  const MerchantLogin({super.key});
  static const String routeName = '/login';

  @override
  State<MerchantLogin> createState() => _MerchantLoginState();
}

class _MerchantLoginState extends State<MerchantLogin> {
  double screenWidth = 0;
  double screenHeight = 0;

  late AuthProvider authProvider;

  final _formKey = GlobalKey<FormState>();

  @override

  /// Initializes the state of the widget, sets up the AuthProvider,
  /// checks device permissions, and verifies connectivity. It also
  /// resets the authProvider and checks if the "remember me" option
  /// is enabled to auto-fill login details.

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.resetAllAndCheckRememberMe();
    });
    DevicePermission().checkPermission();
    ConnectivityService().checkConnectivity();
  }

  @override

  /// Disposes the widget and resets the authentication provider.
  ///
  /// This method is called when the widget is removed from the widget tree.
  /// It ensures that the `authProvider` is reset by calling `resetAll`
  /// with the `fromDispose` parameter set to true, which prevents
  /// notification of listeners.

  void dispose() {
    super.dispose();
    authProvider.resetAllAndCheckRememberMe(fromDispose: true);
  }

  /// Copies the given [mailId] to the clipboard and shows a
  /// snackbar to let the user know that the copying was successful.
  Future<void> _copyToClipboard(String mailId) async {
    Clipboard.setData(ClipboardData(text: mailId));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$mailId Copied to clipboard'),
        duration: Duration(seconds: 5)));
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Selector<AuthProvider, bool>(
        selector: (_, provider) => provider.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) return const LoadingWidget();
          return SizedBox(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: MediaQuery.of(context).padding.bottom,
                left: MediaQuery.of(context).size.width * .05,
                right: MediaQuery.of(context).size.width * .05,
              ),
              child: Center(
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, snapshot) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (authProvider.isOtpSent)
                            GestureDetector(
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                              onTap: () {
                                if (authProvider.isOtpSent) {
                                  authProvider.clearOtp();
                                }
                              },
                            ),
                          gapWidget(screenHeight * .05),
                          Center(
                            child: Image.asset(
                              "assets/screen/anet.png",
                              width: screenWidth * 0.5,
                            ),
                          ),
                          const Center(
                            child: CustomTextWidget(
                              text: 'Before Continue, please sign in first',
                              size: 12,
                              color: AppColors.black50,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          gapWidget(screenHeight * .02),
                          const Center(
                            child: CustomTextWidget(
                              text: 'Merchant Sign In',
                              size: 18,
                              color: AppColors.kPrimaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          gapWidget(screenHeight * .01),
                          Selector<AuthProvider, bool>(
                            selector: (_, provider) => provider.isOtpSent,
                            builder: (context, isOtpSent, child) {
                              if (!isOtpSent) {
                                return buildTextField(
                                  controller: authProvider.merchantIdController,
                                  hintText: 'Username or Email',
                                  labelText: "Username or Email",
                                  onSaved: (value) {
                                    authProvider.req.merchantId = value;
                                  },
                                  context: context,
                                  obscureText: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9a-zA-Z.@ ,\-]'))
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Username!';
                                    }
                                    return null;
                                  },
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          gapWidget(screenHeight * .01),
                          Selector<AuthProvider, bool>(
                            selector: (_, provider) => provider.isOtpSent,
                            builder: (context, isOtpSent, child) {
                              if (isOtpSent) {
                                return OtpField();
                              } else {
                                return PasswordField(
                                  authProvider: authProvider,
                                  hintText: "Password",
                                );
                              }
                            },
                          ),
                          gapWidget(screenHeight * .01),
                          Selector<AuthProvider, bool>(
                            selector: (_, provider) => provider.isOtpSent,
                            builder: (context, isOtpSent, child) {
                              if (!isOtpSent) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Checkbox(
                                      value: authProvider.isRemember,
                                      onChanged: (value) {
                                        if (value != null) {
                                          authProvider.setRememberMe(value);
                                        }
                                      },
                                    ),
                                    const CustomTextWidget(
                                      text: "Remember me",
                                      fontWeight: FontWeight.bold,
                                    ),
                                    const Spacer(),
                                  ],
                                );
                              } else {
                                return gapWidget(screenHeight * .04);
                              }
                            },
                          ),
                          gapWidget(screenHeight * .01),
                          CustomAppButton(
                            title:
                                authProvider.isOtpSent ? "Verify" : 'Sign In',
                            onPressed: () {
                              authProvider.onPresSendButton(_formKey);
                            },
                          ),
                          Selector<AuthProvider, bool>(
                            selector: (_, provider) => provider.isOtpSent,
                            builder: (context, isOtpSent, child) {
                              if (!isOtpSent) {
                                return Center(child: forgotPassword());
                              } else {
                                return gapWidget(screenHeight * .01);
                              }
                            },
                          ),
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
                              InkWell(
                                onTap: () async {
                                  final Uri phoneUri =
                                      Uri(scheme: 'tel', path: '911203129301');
                                  if (await canLaunchUrl(phoneUri)) {
                                    await launchUrl(phoneUri);
                                  }
                                },
                                child: CustomTextWidget(
                                    text: "+911203129301",
                                    size: 18,
                                    color: AppColors.black50,
                                    fontWeight: FontWeight.w400),
                              ),
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
                              InkWell(
                                onTap: () async {
                                  final mail = Constants.supportEmail;
                                  final Uri emailUri = Uri(
                                    scheme: 'mailto',
                                    path: mail,
                                    query: 'subject=Support Request',
                                  );
                                  if (await canLaunchUrl(emailUri)) {
                                    try {
                                      await launchUrl(emailUri);
                                    } catch (error) {
                                      _copyToClipboard(mail);
                                    }
                                  } else {
                                    _copyToClipboard(mail);
                                  }
                                },
                                child: CustomTextWidget(
                                    text: Constants.supportEmail,
                                    size: 12,
                                    color: AppColors.black50,
                                    fontWeight: FontWeight.w400),
                              ),
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
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
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

class OtpField extends StatelessWidget {
  const OtpField({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Selector<AuthProvider, bool>(
      selector: (_, provider) => provider.showEmailOtp,
      builder: (context, showEmailOtp, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: CustomTextWidget(
                  text: "Enter the OTP sent to your email",
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: authProvider.emailOtpController,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: 13, fontFamily: 'Mont'),
                obscureText: !showEmailOtp,
                obscuringCharacter: '*',
                maxLength: 6,
                keyboardType: TextInputType.number,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onSaved: (value) {
                  authProvider.req.emailOtp = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter OTP';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                ],
                decoration: InputDecoration(
                  hintText: 'Enter the OTP sent to your email',
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
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  fillColor: AppColors.kTileColor,
                  filled: true,
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  suffixIcon: IconButton(
                    onPressed: () {
                      authProvider.toggleEmailOtpVisibility();
                    },
                    icon: Icon(
                      showEmailOtp ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PasswordField extends StatelessWidget {
  final AuthProvider authProvider;
  final String hintText;
  const PasswordField(
      {super.key, required this.authProvider, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: CustomTextWidget(
              text: hintText,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextFormField(
            controller: authProvider.passwordController,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: 13, fontFamily: 'Mont'),
            obscureText: !authProvider.showPassword,
            obscuringCharacter: '*',
            keyboardType: TextInputType.text,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onSaved: (value) {
              authProvider.req.password = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Password!';
              }
              // if (value.length < 10) {
              //   return 'Minimum character length is 10';
              // }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Password',
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
              suffixIcon: IconButton(
                onPressed: () {
                  authProvider.togglePasswordVisibility();
                },
                icon: Icon(
                  authProvider.showPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
