import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/form_field/custom_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Forgot Password'),
          ),
      body: Consumer<AuthProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: height * 0.05), // Adjusted for better spacing
                Image.asset('assets/screen/anet.png', width: width * 0.5),
                SizedBox(height: height * 0.05),
                const CustomTextWidget(
                  size: 14,
                  text: 'Enter your Username to reset your password',
                ),
                const SizedBox(height: 16),

                buildTextField(
                  controller: provider.merchantIdController,
                  hintText: 'Username',
                  labelText: 'Username',
                  obscureText: false,
                  context: context,
                  onSaved: (value) {
                    // provider.req.emailOrPhone = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Username!';
                    }
                    if (value.length < 4) {
                      return 'Username must be at least 4 characters long!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomContainer(
                  onTap: () => provider.forgotPassword(),
                  height: 40,
                  child: const CustomTextWidget(
                    text: 'Submit',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
