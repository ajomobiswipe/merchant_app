/* ===============================================================
| Project : SIFR
| Page    : CUSTOM_MOBILE_FIELD.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:sifr_latest/config/config.dart';

//Global Mobile Field
class CustomMobileField extends StatelessWidget {
  // LOCAL VARIABLE DECLARATION
  final String? title;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final FormFieldValidator? validator;
  final FormFieldSetter? onSaved;
  final bool required;
  final bool? readOnly;
  final bool? enabled;
  final String? countryCode;
  final TextStyle? helperStyle;
  final String? helperText;
  final GestureTapCallback? onTap;
  final ValueChanged<PhoneNumber>? onChanged;
  final ValueChanged<Country>? onCountryChanged;

  const CustomMobileField(
      {Key? key, this.title,
      this.keyboardType,
      this.textInputAction,
      this.prefixIcon,
      this.controller,
      this.validator,
      this.helperText,
      this.helperStyle,
      this.onSaved,
      this.required = false,
      this.readOnly,
      this.onTap,
      this.onChanged,
      this.onCountryChanged,
      this.countryCode,
      this.enabled})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          required
              ? RichText(
                  text: TextSpan(
                      text: title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87),
                      children: const [
                        TextSpan(
                            text: ' *', style: TextStyle(color: Colors.red))
                      ]),
                )
              : title!=null?Text(
                  title!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.normal),
                ):Container(),
          //Global Mobile Number Field
          IntlPhoneField(
            controller: controller,
            keyboardType: keyboardType ?? TextInputType.phone,
            textInputAction: textInputAction ?? TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            showCountryFlag: false,
            initialCountryCode: countryCode,
            pickerDialogStyle: PickerDialogStyle(
                countryCodeStyle:
                    TextStyle(color: Theme.of(context).primaryColor),
                countryNameStyle: Theme.of(context).textTheme.bodyMedium),
            flagsButtonPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            showDropdownIcon: true,
            dropdownIconPosition: IconPosition.trailing,
            validator: validator,
            readOnly: readOnly ?? false,
            onSaved: onSaved,
            onChanged: onChanged,
            enabled: enabled ?? false,
            onTap: onTap,
            onCountryChanged: onCountryChanged,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              hintText: title,
              hintStyle: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.normal, fontSize: 16),
              helperText: helperText,
              helperStyle: helperStyle,
              errorMaxLines: 3,
              counterText: '',
              fillColor: AppColors.kTileColor,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.transparent)),
              disabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.transparent)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColor)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 5),
              prefixIcon: Icon(prefixIcon ?? Icons.alternate_email,
                  color: Theme.of(context).primaryColor),
            ),
          )
        ]);
  }
}
