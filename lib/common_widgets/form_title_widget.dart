import 'package:flutter/material.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/helpers/default_height.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

class FormTitleWidget extends StatelessWidget {
  final String subWord;
  final String? mainWord;
  const FormTitleWidget({super.key, required this.subWord, this.mainWord});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          text: mainWord ?? 'Please Enter',
          size: 18,
          fontWeight: FontWeight.w600,
        ),
        defaultWidth(10),
        Column(
          children: [
            CustomTextWidget(
              size: 18,
              fontWeight: FontWeight.w400,
              text: subWord,
              color: AppColors.kLightGreen,
            ),
            Container(
              height: 6,
              width: subWord.length.toDouble() * 5,
              decoration: BoxDecoration(
                  color: AppColors.kPrimaryColor,
                  borderRadius: BorderRadius.circular(15)),
            )
          ],
        )
      ],
    );
  }
}
