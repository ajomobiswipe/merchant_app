import 'package:flutter/cupertino.dart';

copyRightWidget({String? packageInfoVersion}) {
  TextStyle textStyle() {
    return const TextStyle(fontFamily: 'Mont-Regular', fontSize: 13);
  }

  return Column(
    children: [
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Copyright © 2025 AllianceNetwork Company.',
              style: textStyle(),
            ),
            Text(
              'All rights reserved .',
              style: textStyle(),
            ),
            if (packageInfoVersion != null)
              Text(
                "Version ${packageInfoVersion.toString()}",
                style: textStyle(),
              ),
          ],
        ),
      ),
    ],
  );
}
