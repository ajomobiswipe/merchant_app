/* ===============================================================
| Project : SIFR
| Page    : ALERT_SERVICE.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:sifr_latest/config/config.dart';
import '../../config/state_key.dart';
import '../widget.dart';

//Alert Service Class
class AlertService {
  //Global Success Alert
  success(BuildContext context, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      width: double.infinity,
      content: AwesomeSnackbarContent(
        title: title.toString().isEmpty ? 'Success' : title.toString(),
        message: message,
        contentType: ContentType.success,
        inMaterialBanner: true,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  //Global Failure Alert
  failure(BuildContext context, String? title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      width: double.infinity,
      content: AwesomeSnackbarContent(
        title: title.toString().isEmpty ? 'Failed!' : title.toString(),
        message: message,
        contentType: ContentType.failure,
        inMaterialBanner: true,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  //Global Warning Alert
  warn(BuildContext context, String? title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      width: double.infinity,
      content: AwesomeSnackbarContent(
        title: title.toString().isEmpty ? 'Warning!' : title.toString(),
        message: message,
        contentType: ContentType.warning,
        inMaterialBanner: true,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  //Global Error Alert
  error(String message) {

    final snackBar = SnackBar(
      elevation: 0,
      content: Text(message),

      backgroundColor: Colors.red,
      showCloseIcon:true,

      behavior: SnackBarBehavior.floating,
    );

    // final snackBar = SnackBar(
    //   elevation: 0,
    //   behavior: SnackBarBehavior.floating,
    //   backgroundColor: Colors.transparent,
    //   width: double.infinity,
    //   content: AwesomeSnackbarContent(
    //     title: 'Failed',
    //     message: message,
    //     contentType: ContentType.failure,
    //     inMaterialBanner: true,
    //   ),
    // );
    StateKey.snackBarKey.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  //Global Success Popup
  Future<void> successPopup(BuildContext context, String title, String? message,
      VoidCallback? onPressed) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.kPrimaryColor,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/success-tick.json',
                  height: MediaQuery.of(context).size.height / 5,
                ),
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      message ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AppButton(
                    titleColor: AppColors.white,
                    title: "Okay",
                    backgroundColor: AppColors.kLightGreen,
                    onPressed: onPressed,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //Global Error Toast
  errorToast(String message) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
