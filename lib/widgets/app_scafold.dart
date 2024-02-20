import 'package:flutter/material.dart';
import 'package:sifr_latest/common_widgets/app_appbar.dart';

class AppScafofld extends StatelessWidget {
  final bool eneableAppbar;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  dynamic Function()? onPressed;
  AppScafofld(
      {super.key,
      required this.child,
      this.padding,
      this.eneableAppbar = true,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: eneableAppbar
          ? AppAppbar(
              onPressed: onPressed ??
                  () {
                    Navigator.pop(context);
                  },
            )
          : null,
      body: Padding(
          padding: padding ??
              EdgeInsets.only(left: 15, right: 15, top: eneableAppbar ? 0 : 40),
          child: child),
    );
  }
}
