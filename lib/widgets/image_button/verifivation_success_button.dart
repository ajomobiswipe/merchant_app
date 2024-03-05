import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VerificationSuccessButton extends StatelessWidget {
  final double iconSize;
  const VerificationSuccessButton({super.key, this.iconSize = 40});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/app_icons/verified_icon.png",
      height: iconSize,
    );
  }
}
