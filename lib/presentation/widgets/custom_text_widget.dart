import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final TextAlign? textAlign;
  final bool isBold;
  final FontWeight fontWeight;
  final int? maxLines;
  final bool isUpperCase;

  const CustomTextWidget({
    super.key,
    required this.text,
    this.color = Colors.black,
    this.size = 14.0,
    this.fontWeight = FontWeight.normal,
    this.textAlign,
    this.isBold = true,
    this.maxLines,
    this.isUpperCase = false,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 400;

    return Text(
      isUpperCase ? text.toUpperCase() : text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: isSmallScreen ? size * 0.7 : size,
        fontWeight: fontWeight,
        fontFamily: isBold ? 'Mont' : 'Mont-regular',
      ),
    );
  }
}
