import 'package:anet_merchant_app/core/app_color.dart';
import 'package:flutter/material.dart';

class CustomAppButton extends StatelessWidget {
  // LOCAL VARIABLE DECLARATION
  final String title;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;
  final Color? backgroundColor;
  final double width;
  final double height;
  final bool fromOtpScreen;
  final bool isOtpVisible;

  const CustomAppButton(
      {super.key,
      required this.title,
      this.onPressed,
      this.onLongPressed,
      this.backgroundColor,
      this.width = 1,
      this.height = 50,
      this.fromOtpScreen = false,
      this.isOtpVisible = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * width,
      height: height,
      child: ElevatedButton(
        onLongPress: onLongPressed,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ??
                AppColors.getMaterialColorFromColor(AppColors.kPrimaryColor),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: Text(title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: fromOtpScreen
                    ? !isOtpVisible
                        ? Colors.white.withValues(alpha: .5)
                        : Colors.white
                    : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Mont')),
      ),
    );
  }
}
