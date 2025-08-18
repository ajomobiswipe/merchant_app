/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : ALERT_SERVICE.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// // Dependencies or Plugins - Models - Services - Global Functions
// import 'package:anet_merchant_app/core/state_key.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// // import 'package:lottie/lottie.dart';

// //Alert Service Class
// class AlertService {
//   //Global Success Alert
//   success(String message) {
//     final snackBar = SnackBar(
//       elevation: 0,
//       content: Text(message),
//       backgroundColor: Colors.green,
//       showCloseIcon: true,
//       behavior: SnackBarBehavior.floating,
//     );

//     StateKey.snackBarKey.currentState!
//       ..hideCurrentSnackBar()
//       ..showSnackBar(snackBar);
//   }

//   //Global Failure Alert
//   failure(BuildContext context, String? title, String message) {

//     error(message);
//   }

//   //Global Error Alert
//   error(String message) {
//     final snackBar = SnackBar(
//       elevation: 0,
//       content: Text(message),
//       backgroundColor: Colors.red,
//       showCloseIcon: true,
//       behavior: SnackBarBehavior.floating,
//     );

//     StateKey.snackBarKey.currentState!
//       ..hideCurrentSnackBar()
//       ..showSnackBar(snackBar);
//   }

//   //Global Error Toast
//   errorToast(String message) {
//     return Fluttertoast.showToast(
//         msg: message,
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0);
//   }
// }

import 'package:anet_merchant_app/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlertService {
  AlertService();
  //Global Error Toast
  // errorToast(String message) {
  //   return Fluttertoast.showToast(
  //       msg: message,
  //       toastLength: Toast.LENGTH_LONG,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  // }

  void _showSnackBar({
    required Color color,
    required IconData icon,
    required String title,
    required String message,
    String? actionText,
    VoidCallback? actionCallback,
  }) {
    final snackBar = SnackBar(
      elevation: 10,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(width: 2, color: color)),
      content: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
          if (actionText != null)
            TextButton(
              onPressed: actionCallback ??
                  () => ScaffoldMessenger.of(
                          NavigationService.navigatorKey.currentState!.context)
                      .hideCurrentSnackBar(),
              style: TextButton.styleFrom(foregroundColor: color),
              child: Text(actionText),
            ),
        ],
      ),
    );

    ScaffoldMessenger.of(NavigationService.navigatorKey.currentState!.context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void success(String message) {
    _showSnackBar(
      color: Colors.green,
      icon: Icons.check_circle,
      title: 'Successful !!',
      message: message,
    );
  }

  void info(String message) {
    _showSnackBar(
      color: Colors.blue,
      icon: Icons.info,
      title: 'Information',
      message: message,
      actionText: "Got it !",
    );
  }

  void error(String message) {
    _showSnackBar(
      color: Colors.red,
      icon: Icons.warning,
      title: 'Error',
      message: message,
    );
  }

  void warning(String message) {
    _showSnackBar(
      color: Colors.red,
      icon: Icons.error,
      title: 'Warning',
      message: message,
      actionText: "Go back",
    );
  }
}
