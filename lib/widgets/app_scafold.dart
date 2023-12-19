import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sifr_latest/common_wigdets/app_appbar.dart';

class AppScafofld extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const AppScafofld({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppbar(),
      body: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
          child: child),
    );
  }
}
