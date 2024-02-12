import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../common_widgets/icon_text_widget.dart';
import '../../config/app_color.dart';

Container appTabbar({
  required double screenHeight,
  required int currTabPosition,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: AppColors.kSelectedBackgroundColor,
    ),
    // height: screenHeight / 10,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconTextWidget(
            screenHeight: screenHeight,
            color: getIconColor(
              currTabPosition: currTabPosition,
              position: 1,
            ),
            iconPath: 'assets/merchant_icons/merchant_detials.png',
            title: "Merchant\nDetails"),
        IconTextWidget(
            screenHeight: screenHeight,
            color: getIconColor(currTabPosition: currTabPosition, position: 2),
            iconPath: 'assets/merchant_icons/id_proof_icon.png',
            title: "Id\nProofs"),
        IconTextWidget(
            screenHeight: screenHeight,
            color: getIconColor(currTabPosition: currTabPosition, position: 3),
            iconPath: 'assets/merchant_icons/bussiness_proofs.png',
            title: "Bussiness\nProofs"),
        IconTextWidget(
            screenHeight: screenHeight,
            color: getIconColor(currTabPosition: currTabPosition, position: 4),
            iconPath: 'assets/merchant_icons/bank_details.png',
            title: "Bank\nDetails"),
      ],
    ),
  );
}

Color getIconColor({
  required int position,
  required int currTabPosition,
}) {
  if (position <= currTabPosition - 1) {
    return Colors.green;
  } else if (position == currTabPosition) {
    return AppColors.kPrimaryColor;
  } else if (position > currTabPosition) {
    return Colors.grey;
  }
  return Colors.black;
}
