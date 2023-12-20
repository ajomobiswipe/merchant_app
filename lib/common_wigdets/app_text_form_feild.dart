/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : CUSTOM_TEXT.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sifr_latest/config/app_color.dart';

//Global Text Form Field
class AppTextFormField extends StatelessWidget {
  // LOCAL VARIABLE DECLARATION
  final String title;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Color? iconColor;
  final TextEditingController? controller;
  final FormFieldValidator? validator;
  final FormFieldSetter? onSaved;
  final ValueChanged<String>? onFieldSubmitted;
  final bool required;
  final bool? readOnly;
  final bool? autofocus;
  final GestureTapCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool suffixIconTrue;
  final IconData? suffixIcon;
  final String? suffixText;
  final VoidCallback? suffixIconOnPressed;
  final String? helperText;
  final String? errorText;
  final TextStyle? helperStyle;
  final bool? obscureText;
  final bool? enabled;
  final String? obscuringCharacter;
  final String? counterText;
  final int errorMaxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final String? initialValue;
  final TextCapitalization? textCapitalization;
  final ToolbarOptions? toolbarOptions;
  final bool eneablrTitle;

  const AppTextFormField(
      {Key? key,
      required this.title,
      this.keyboardType,
      this.textInputAction,
      this.prefixIcon,
      this.controller,
      this.validator,
      this.onSaved,
      this.onFieldSubmitted,
      this.required = false,
      this.readOnly,
      this.onTap,
      this.inputFormatters,
      this.autofocus,
      this.suffixIconTrue = false,
      this.suffixIcon,
      this.suffixText,
      this.suffixIconOnPressed,
      this.helperText,
      this.helperStyle,
      this.obscureText,
      this.errorMaxLines = 2,
      this.obscuringCharacter,
      this.maxLength,
      this.counterText,
      this.onChanged,
      this.focusNode,
      this.enabled,
      this.initialValue,
      this.hintText,
      this.errorText,
      this.textCapitalization,
      this.toolbarOptions,
      this.eneablrTitle = true,
      this.iconColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eneablrTitle)
            required
                ? RichText(
                    text: TextSpan(
                        text: title,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.normal),
                        children: const [
                          TextSpan(
                              text: ' *', style: TextStyle(color: Colors.red))
                        ]),
                  )
                : RichText(
                    text: TextSpan(
                      text: title,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.normal),
                    ),
                  ),
          //Global Text Form Field
          TextFormField(
            toolbarOptions: toolbarOptions,
            initialValue: initialValue,
            controller: controller,
            keyboardType: keyboardType ?? TextInputType.text,
            textInputAction: textInputAction ?? TextInputAction.next,
            maxLength: maxLength,
            obscureText: obscureText ?? false,
            obscuringCharacter: obscuringCharacter ?? '*',
            autofocus: autofocus ?? false,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
            textCapitalization: textCapitalization ?? TextCapitalization.none,
            readOnly: readOnly ?? false,
            enabled: enabled,
            onSaved: onSaved,
            onTap: onTap,
            onChanged: onChanged,
            inputFormatters: inputFormatters,
            onFieldSubmitted: onFieldSubmitted,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: hintText ?? title,
              counterText: counterText ?? '',
              errorMaxLines: errorMaxLines,
              helperText: helperText,
              errorText: errorText,
              helperStyle: helperStyle,

              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              fillColor: AppColors.kTileColor, // Set the background color here
              filled: true,
              hintStyle: TextStyle(color: Colors.grey, fontSize: 12),

              prefixIcon: Icon(prefixIcon,
                  color: iconColor ?? Theme.of(context).primaryColor),
              suffixIcon: (suffixIconTrue && suffixText == null)
                  ? IconButton(
                      onPressed: suffixIconOnPressed,
                      icon: Icon(
                        suffixIcon,
                        size: 25,
                        color: iconColor ?? Theme.of(context).primaryColor,
                      ),
                    )
                  : suffixText != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          constraints: const BoxConstraints(
                            maxHeight: 100.0,
                            maxWidth: 100.0,
                          ),
                          child: TextButton(
                            onPressed: suffixIconOnPressed,
                            child: Text(
                              suffixText.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.red),
                            ),
                          ),
                        )
                      : null,
            ),
          )
        ]);
  }
}
