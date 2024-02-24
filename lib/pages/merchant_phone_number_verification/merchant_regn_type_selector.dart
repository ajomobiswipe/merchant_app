import 'package:flutter/material.dart';
import 'package:sifr_latest/config/config.dart';

class MerchantRegnTypeSelector extends StatelessWidget {
  final String iconPath;
  final String title;
  final Color? iconColor;
  final Color? titleColor;
  final Color? borderColor;
  final Function()? onTap;


  const MerchantRegnTypeSelector(
      {super.key,
      required this.iconPath,
      required this.title,
      this.onTap,
      this.iconColor,
      this.titleColor,
      this.borderColor,
      });

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 10, vertical: screenHeight * 0.02),
            decoration: BoxDecoration(
              color: AppColors.kTileColor,
              border: Border.all(
                  width: 1.2, color: borderColor ?? AppColors.kBorderColor),
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Column(
              children: [
                Image.asset(
                  iconPath,
                  width: 50.0,
                  height: 50.0,
                  color: iconColor,
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: titleColor),
                ),
              ],
            ),
          ),
        );
  }
}
