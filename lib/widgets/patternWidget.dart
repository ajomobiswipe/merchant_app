/* ===============================================================
| Project : SIFR
| Page    : BACKGROUND_PATTERN.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';

// STATEFUL WIDGET
class BackgroundPattern extends StatefulWidget {
  final Widget childData;
  const BackgroundPattern({Key? key, required this.childData})
      : super(key: key);

  @override
  State<BackgroundPattern> createState() => _BackgroundPatternState();
}

// Background Pattern State Class
class _BackgroundPatternState extends State<BackgroundPattern> {
  @override
  Widget build(BuildContext context) {
    //Global Background Pattern Widget
    return Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg-pattern/10.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: MediaQuery.of(context).padding.bottom,
              left: 25,
              right: 25,
            ),
            child: widget.childData,
          ),
        ));
  }
}
