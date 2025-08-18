/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : CUSTOM_DROPDOWN.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:anet_merchant_app/core/app_color.dart';
import 'package:flutter/material.dart';

InputDecoration commonInputDecoration(IconData? prefixIcon,
    {String? hintText,
    double? rightPadding,
    IconData? suffixIcon,
    String? helperText,
    TextStyle? helperStyle,
    String? labelText,
    VoidCallback? onTapSuffixIcon}) {
  return InputDecoration(
    // label: Text(title),
    helperText: helperText,
    helperStyle: helperStyle,
    hintText: hintText ?? '',
    fillColor: Colors.grey[300],
    filled: true,
    labelText: labelText,

    contentPadding: EdgeInsets.only(
        left: 10, top: 10, bottom: 10, right: rightPadding ?? 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: const BorderSide(
        color: Colors.black,
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
    prefixIcon: Icon(prefixIcon, size: 25, color: AppColors.kPrimaryColor),
    suffixIcon: suffixIcon == null
        ? null
        : GestureDetector(
            onTap: onTapSuffixIcon,
            child: Icon(suffixIcon, size: 25, color: AppColors.kPrimaryColor),
          ),
  );
}
