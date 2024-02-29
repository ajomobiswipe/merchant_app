import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sifr_latest/config/app_color.dart';

class VerificationSuccessButton extends StatelessWidget {
  final double iconSize;
  const VerificationSuccessButton({super.key, this.iconSize = 40});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/app_icons/success_sumbol.png",
      height: iconSize,
    );

    return SvgPicture.asset(
      "assets/merchant_icons/successtick.svg",
      height: iconSize,
      color: Colors.green,
    );
    // return Image.asset("assets/app_icons/verified_icon.png",height: iconSize,);assets\merchant_icons\successtick.svg
  }
}
