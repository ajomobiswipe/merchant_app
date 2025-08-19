import 'package:anet_merchant_app/core/app_color.dart' show AppColors;
import 'package:anet_merchant_app/presentation/pages/merchant_login.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/widgets/common_widgets/custom_app_button.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/form_field/custom_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPassword extends StatefulWidget {
  final String userName;
  const ResetPassword({super.key, required this.userName});

  @override
  State<ResetPassword> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ResetPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _userNameController = TextEditingController();
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  // late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userNameController = TextEditingController(text: widget.userName);
      _confirmPasswordController = TextEditingController();
      // authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<AuthProvider>(context, listen: false).showResetOtp();
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(bool isResetOtpSent) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      if (_formKey.currentState!.validate()) {
        if (isResetOtpSent) {
          await authProvider.validateMerchantLoginOtp(
              userName: widget.userName, fromResetPassword: true);
        } else {
          await authProvider.resetPassword(
              widget.userName,
              _currentPasswordController.text,
              _newPasswordController.text,
              _confirmPasswordController.text);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * .05,
        right: MediaQuery.of(context).size.width * .05,
      ),
      child: Form(
          key: _formKey,
          child: Selector<AuthProvider, bool>(
            selector: (_, provider) {
              return provider.isResetOtpSent;
            },
            builder: (context, isResetOtpSent, wchild) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Password
                  if (isResetOtpSent)
                    Column(
                      children: [
                        OtpField(),
                      ],
                    ),

                  if (!isResetOtpSent)
                    Selector<AuthProvider, List<bool>>(
                      selector: (_, provider) {
                        return [
                          provider.showCurrentPassword,
                          provider.showNewPassword,
                          provider.showConfirmPassword
                        ];
                      },
                      builder: (_, listOfBool, __) {
                        return Column(
                          children: [
                            buildTextField(
                                controller: _userNameController,
                                hintText: 'Username',
                                labelText: "Username",
                                onSaved: (value) {
                                  // authProvider.req.merchantId = value;
                                },
                                validator: (value) {
                                  return null;
                                },
                                context: context,
                                obscureText: false,
                                isReadModeOnly: true),
                            ResetPasswordFormField(
                              authProvider: Provider.of<AuthProvider>(context,
                                  listen: false),
                              hintText: "Current Password",
                              controller: _currentPasswordController,
                              isPasswordShow: listOfBool[0],
                              isCurrentPassword: true,
                              validatorFunction: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Password!';
                                }
                                if (value.length < 8) {
                                  return 'Minimum character length is 8';
                                }
                                return null;
                              },
                            ),
                            ResetPasswordFormField(
                              authProvider: Provider.of<AuthProvider>(context,
                                  listen: false),
                              hintText: "New Password",
                              controller: _newPasswordController,
                              isPasswordShow: listOfBool[1],
                              isNewPassword: true,
                              validatorFunction: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Password!';
                                }

                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'Password must contain at least one uppercase letter';
                                }
                                if (!RegExp(r'[a-z]').hasMatch(value)) {
                                  return 'Password must contain at least one lowercase letter';
                                }
                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'Password must contain at least one digit';
                                }
                                if (!RegExp(r'[!@#\$&*~%^()\-_=+{};:,<.>]')
                                    .hasMatch(value)) {
                                  return 'Password must contain at least one special character';
                                }
                                if (value.length < 8) {
                                  return 'Minimum character length is 8';
                                }
                                if (value.contains(' ')) {
                                  return 'Password cannot contain spaces';
                                }
                                if (value == _currentPasswordController.text) {
                                  return 'New password cannot be the same!';
                                }
                                return null;
                              },
                            ),
                            ResetPasswordFormField(
                              authProvider: Provider.of<AuthProvider>(context,
                                  listen: false),
                              hintText: "Confirm Password",
                              controller: _confirmPasswordController,
                              isPasswordShow: listOfBool[2],
                              isConfirmPassword: true,
                              validatorFunction: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Password!';
                                }
                                if (value.length < 8) {
                                  return 'Minimum character length is 8';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              },
                            ),
                          ],
                        );
                      },
                    ),

                  SizedBox(height: MediaQuery.of(context).size.height * .02),

                  CustomAppButton(
                    title: 'Reset Password',
                    onPressed: () {
                      _submitForm(isResetOtpSent);
                    },
                  ),
                ],
              );
            },
          )),
    ));
  }
}

class ResetPasswordFormField extends StatelessWidget {
  final AuthProvider authProvider;
  final String hintText;
  final TextEditingController controller;
  final bool isCurrentPassword;
  final bool isNewPassword;
  final bool isConfirmPassword;
  final bool isPasswordShow;
  final String? Function(String?)? validatorFunction;

  const ResetPasswordFormField(
      {super.key,
      required this.authProvider,
      required this.hintText,
      required this.controller,
      this.isCurrentPassword = false,
      this.isNewPassword = false,
      this.isConfirmPassword = false,
      this.isPasswordShow = false,
      this.validatorFunction});

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
            controller: controller,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontSize: 13, fontFamily: 'Mont'),
            obscureText: !isPasswordShow,
            obscuringCharacter: '*',
            keyboardType: TextInputType.text,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onSaved: (value) {
              // authProvider.req.password = value;
            },
            validator: validatorFunction,
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
              suffixIcon: IconButton(
                onPressed: () {
                  authProvider.toggleResetPasswordVisibility(
                      isCurrentPassword: isCurrentPassword,
                      isNewPassword: isNewPassword,
                      isConfirmPassword: isConfirmPassword);
                },
                icon: Icon(
                  isPasswordShow ? Icons.visibility : Icons.visibility_off,
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
