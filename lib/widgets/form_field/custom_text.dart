/* ===============================================================
| Project : SIFR
| Page    : CUSTOM_TEXT.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sifr_latest/config/app_color.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

//Global Text Form Field
class CustomTextFormField extends StatelessWidget {
  // LOCAL VARIABLE DECLARATION
  final String title;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final Color? iconColor;
  final TextEditingController? controller;
  final FormFieldValidator? validator;
  final FormFieldSetter? onSaved;
  final ValueChanged<String>? onFieldSubmitted;
  final bool required;
  final bool? readOnly;
  final bool titleEneabled;
  final bool? autofocus;
  final GestureTapCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool suffixIconTrue;
  final Widget? suffixIcon;
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
  final int? minLines;
  final int? maxLines;
  final bool fromDocument;

  const CustomTextFormField(
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
      this.minLines,
      this.maxLines,
      this.iconColor = Colors.black,
      this.prefixWidget, this.titleEneabled=true,this.fromDocument=false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(titleEneabled) SizedBox(
            height: 20,
          ),
          if(titleEneabled) CustomTextWidget(
              text: "$title *", fontWeight: FontWeight.w200, size: 14),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextFormField(
              style: const TextStyle(color: Colors.black,fontSize: 13),
              minLines: minLines,
              toolbarOptions: toolbarOptions,
              initialValue: initialValue,
              controller: controller,
              keyboardType: keyboardType ?? TextInputType.text,
              textInputAction: textInputAction ?? TextInputAction.next,
              maxLength: maxLength,
              maxLines: maxLines,
              obscureText: obscureText ?? false,
              obscuringCharacter: obscuringCharacter ?? '*',
              autofocus: autofocus ?? false,
              autovalidateMode: !fromDocument?AutovalidateMode.onUserInteraction:null,
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
                fillColor: AppColors.kTileColor,
                filled: true,
                hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: Colors.black.withOpacity(.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.transparent)),
                disabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.transparent)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                prefixIcon: prefixWidget ??
                    Icon(prefixIcon, color: iconColor!.withOpacity(0.7)),
                suffixIcon: (suffixIconTrue && suffixText == null)
                    ? IconButton(
                        onPressed: suffixIconOnPressed,
                        icon: suffixIcon??Text("Eeeor"),
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
            ),
          )
        ]);
  }
}
