import 'package:flutter/material.dart';
import 'package:sifr_latest/config/app_color.dart';

import '../widgets/custom_text_widget.dart';

class IconTextWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final Color color;

  const IconTextWidget({
    super.key,
    required this.screenHeight,
    required this.iconPath,
    required this.title,
    required this.color,
  });

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Image.asset(
            iconPath,
            height: screenHeight / 25,
            color: color,
          ),
          CustomTextWidget(
            text: title,
            textAlign: TextAlign.center,
            size: 8,
            color: AppColors.kPrimaryColor,
          )
        ],
      ),
    );
  }
}
