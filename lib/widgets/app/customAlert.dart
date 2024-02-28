/* ===============================================================
| Project : SIFR
| Page    : CUSTOM ALERT.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

import 'dart:io' show Platform, exit;

// Dependencies
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sifr_latest/common_widgets/copyright_widget.dart';
import 'package:sifr_latest/config/app_color.dart';

// Custom Alert Class
class CustomAlert {
  // LOCAL VARIABLE DECLARATION
  bool? response;

  // Global Confirm Dialog
  displayDialogConfirm(BuildContext context, String title, String message,
      void Function() function) async {
    double paddingSymmetric = MediaQuery.of(context).size.width * .05;
    double paddingTop = MediaQuery.of(context).size.height * .02;

    Widget actionButton({bool fromNo = false}) {
      return GestureDetector(
        onTap: () {
          if (!fromNo) {
            Navigator.pop(context);
            response = false;
          } else {
            response = true;
            function();
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
          padding:  EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*.05,vertical: MediaQuery.of(context).size.height*.01),
          decoration: BoxDecoration(border: Border.all(color: Colors.black.withOpacity(.5)),borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: Text(
              !fromNo ? 'No' : 'Yes',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      );
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height*.03,
                left: paddingSymmetric,
                right: paddingSymmetric),
            contentPadding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height*.015,
                left: paddingSymmetric,
                right: paddingSymmetric),
            actionsPadding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height*.03,
              bottom: paddingTop,
              right: paddingSymmetric,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10.0), // Set the border radius
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              message,
              style: const TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w400),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  actionButton(fromNo: true),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .025,
                  ),
                  actionButton()
                ],
              )
            ],
          );
        });
  }

  // Global Mpin Dialog
  displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              'Alert',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "Please add MPIN to proceed further",
              style: TextStyle(color: Colors.white70),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Colors.white70, width: 2), //<-- SEE HERE
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, 'addNewMpin');
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          );
        });
  }

  // Global Mpin Dialog
  rootExits(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              'Alert',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "Root or Developer Mode has been enabled in your mobile.\nPlease disable and try again.",
              style: TextStyle(color: Colors.white70),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Colors.white70, width: 2), //<-- SEE HERE
                  ),
                  onPressed: () {
                    if (Platform.isAndroid) {
                      SystemNavigator.pop();
                    } else if (Platform.isIOS) {
                      exit(0);
                    }
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          );
        });
  }
}
