/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : CUSTOM ALERT.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies
import 'package:flutter/material.dart';
import 'package:anet_merchant_app/config/app_color.dart';
import 'package:anet_merchant_app/main.dart';

// Custom Alert Class
class CustomAlert {
  // LOCAL VARIABLE DECLARATION
  bool? response;

  // Global Confirm Dialog
  displayDialogConfirm(BuildContext context, String title, String message,
      void Function() function,
      {Map<String, dynamic>? merchantInfo,
      dynamic merchantSignupNavigation,
      String? phoneNumber}) async {
    double paddingSymmetric = MediaQuery.of(context).size.width * .05;
    double paddingTop = MediaQuery.of(context).size.height * .02;

    Widget actionButton({bool fromYes = false}) {
      return GestureDetector(
        onTap: () {
          if (!fromYes) {
            Navigator.pop(context);
            response = false;
          } else {
            response = true;

            if (merchantInfo == null) {
              function();
            } else {
              if (phoneNumber == null) {
                merchantSignupNavigation!(
                  merchantInfo: merchantInfo,
                );
              } else {
                merchantSignupNavigation!(
                  merchantInfo: merchantInfo,
                  phoneNumber: phoneNumber,
                );
              }
            }
          }
        },
        // style: OutlinedButton.styleFrom(
        //   side: const BorderSide(
        //       color: Colors.black87, width: 1), //<-- SEE HERE
        // ),
        // onPressed: () {
        //   if(!fromNo){
        //     Navigator.pop(context);
        //     response = false;
        //   }else{
        //     response = true;
        //     function();
        //   }
        // },
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * .05,
              vertical: MediaQuery.of(context).size.height * .01),
          decoration: BoxDecoration(
              color: fromYes ? Theme.of(context).primaryColor : Colors.red,
              borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: Text(
              !fromYes ? 'No' : 'Yes',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    try {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * .03,
                  left: paddingSymmetric,
                  right: paddingSymmetric),
              contentPadding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * .015,
                  left: paddingSymmetric,
                  right: paddingSymmetric),
              actionsPadding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * .03,
                bottom: paddingTop,
                right: paddingSymmetric,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10.0), // Set the border radius
              ),
              title: title == ''
                  ? Container()
                  : Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              content: Text(
                message,
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    actionButton(fromYes: true),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .025,
                    ),
                    actionButton()
                  ],
                )
              ],
            );
          });
    } catch (e) {
      alertService.error(e.toString());
    }
  }
}
