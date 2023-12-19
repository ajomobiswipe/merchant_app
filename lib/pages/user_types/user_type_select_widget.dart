import 'package:flutter/material.dart';
import 'package:sifr_latest/config/config.dart';

class UserSelectContainer extends StatelessWidget {
  final String iconPath;
  final String title;
  final Function()? onTap;

  const UserSelectContainer(
      {super.key, required this.iconPath, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: AppColors.kTileColor,
        border: Border.all(width: 2, color: AppColors.kBorderColor),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Image.asset(
              iconPath, // Replace with your image asset
              width: 50.0,
              height: 50.0,
            ),
            SizedBox(width: 10.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
