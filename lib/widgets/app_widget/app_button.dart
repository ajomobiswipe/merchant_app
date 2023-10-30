/* ===============================================================
| Project : SIFR
| Page    : APP_BUTTON.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies
import 'package:flutter/material.dart';

// App Button Class
class AppButton extends StatelessWidget {
  // LOCAL VARIABLE DECLARATION
  final String title;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double? width;

  const AppButton(
      {Key? key,
      required this.title,
      this.onPressed,
      this.backgroundColor,
      this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width == null
          ? double.maxFinite
          : MediaQuery.of(context).size.width * width!,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Theme.of(context).primaryColor),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white)),
      ),
    );
  }
}
