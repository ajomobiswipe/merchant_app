import 'package:flutter/material.dart';
import 'package:sifr_latest/config/config.dart';

class CustomAppButton extends StatelessWidget {
  // LOCAL VARIABLE DECLARATION
  final String title;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double width;
  final double height;

  bool fromOtpScreen;
  bool isOtpVisible;

  CustomAppButton(
      {Key? key,
      required this.title,
      this.onPressed,
      this.backgroundColor,
      this.width = 1,
      this.height = 50,
      this.fromOtpScreen = false,
      this.isOtpVisible = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ??
                AppColors.getMaterialColorFromColor(AppColors.kPrimaryColor),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        child: Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: fromOtpScreen
                    ? !isOtpVisible
                        ? Colors.white.withOpacity(.5)
                        : Colors.white
                    : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
