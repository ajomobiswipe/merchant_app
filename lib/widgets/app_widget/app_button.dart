/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : APP_BUTTON.DART
| Date    : 04-OCT-2024
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
  final Color? titleColor;
  final double? width;

  const AppButton(
      {super.key,
      required this.title,
      this.onPressed,
      this.backgroundColor,
      this.width,
      this.titleColor = Colors.white});

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
                ?.copyWith(color: titleColor, fontFamily: 'Mont')),
      ),
    );
  }
}
