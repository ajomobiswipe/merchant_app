import 'package:flutter/material.dart';

import '../config/app_color.dart';

InputDecoration dropdownDecoration(BuildContext context) {
  return InputDecoration(
    // label: Text(title),
    fillColor: AppColors.kTileColor,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
    prefixIcon:
        Icon(Icons.ad_units, size: 25, color: Theme.of(context).primaryColor),
  );
}
