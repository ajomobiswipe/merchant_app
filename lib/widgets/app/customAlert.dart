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

// Custom Alert Class
class CustomAlert {
  // LOCAL VARIABLE DECLARATION
  bool? response;
  // Global Confirm Dialog
  displayDialogConfirm(BuildContext context, String title, String message,
      void Function() function) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              'Alert',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.white70, width: 2), //<-- SEE HERE
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          response = false;
                        },
                        child: const Text(
                          'No',
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.white70, width: 2), //<-- SEE HERE
                        ),
                        onPressed: () {
                          response = true;
                          function();
                        },
                        child: const Text(
                          'Yes',
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
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
