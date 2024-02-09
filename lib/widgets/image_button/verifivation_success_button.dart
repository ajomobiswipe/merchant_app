import 'package:flutter/cupertino.dart';

class VerificationSuccessButton extends StatelessWidget {
  final double iconSize;
  const VerificationSuccessButton({super.key, this.iconSize=40});

  @override
  Widget build(BuildContext context) {
    return Image.asset("assets/app_icons/verified_icon.png",height: iconSize,);
  }
}
