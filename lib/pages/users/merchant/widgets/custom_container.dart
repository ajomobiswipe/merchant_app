import 'package:flutter/material.dart';
import 'package:anet_merchant_app/config/config.dart';

class CustomContainer extends StatelessWidget {
  final Color? color;
  final double? height;
  final double? width;
  final VoidCallback? onTap;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  const CustomContainer({
    super.key,
    this.color,
    this.height,
    this.onTap,
    this.child,
    this.padding,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        height: height, // Now height will work correctly
        width: width,
        decoration: BoxDecoration(
          color: color ?? AppColors.kPrimaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
