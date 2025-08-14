import 'package:anet_merchant_app/presentation/pages/merchant_login.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/widgets/common_widgets/custom_app_button.dart';
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
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passwordController = TextEditingController();
      _confirmPasswordController = TextEditingController();
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<AuthProvider>(context, listen: false).showResetOtp();
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(bool isResetOtpSent) async {
    try {
      if (_formKey.currentState!.validate()) {
        if (isResetOtpSent) {
          await authProvider.validateMerchantLoginOtp(
              userName: widget.userName, fromResetPassword: true);
        } else {
          await authProvider.resetPassword(widget.userName,
              _passwordController.text, _confirmPasswordController.text);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
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
                          OtpField(
                            authProvider: authProvider,
                          ),
                        ],
                      ),

                    if (!isResetOtpSent)
                      Column(
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(labelText: "Password"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a password";
                              }

                              return null;
                            },
                          ),

                          SizedBox(height: 16),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration:
                                InputDecoration(labelText: "Confirm Password"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please confirm your password";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 24),
                        ],
                      ),

                    CustomAppButton(
                      title: 'Reset Password',
                      onPressed: () {
                        _submitForm(isResetOtpSent);
                      },
                    ),
                  ],
                );
              },
            )));
  }
}
