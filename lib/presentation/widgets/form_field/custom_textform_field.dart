import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildTextField(
    {required TextEditingController controller,
    required String hintText,
    required String labelText,
    required bool obscureText,
    required BuildContext context,
    required Function(String?) onSaved,
    required String? Function(String?)? validator,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    bool? isPasswordField,
    List<TextInputFormatter>? inputFormatters,
    bool isReadModeOnly = false}) {
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
          readOnly: isReadModeOnly,
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
          ),
        ),
      ],
    ),
  );
}
