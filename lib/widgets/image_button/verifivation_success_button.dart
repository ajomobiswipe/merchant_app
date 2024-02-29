import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sifr_latest/config/app_color.dart';

class VerificationSuccessButton extends StatelessWidget {
  final double iconSize;
  const VerificationSuccessButton({super.key, this.iconSize = 40});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/merchant_icons/successtick.svg",
      height: iconSize,
    );
    // return Image.asset("assets/app_icons/verified_icon.png",height: iconSize,);assets\merchant_icons\successtick.svg
  }
}
