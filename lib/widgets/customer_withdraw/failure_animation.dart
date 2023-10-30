/* ===============================================================
| Project : SIFR
| Page    : FAILURE.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// STATEFUL WIDGET
class Failure extends StatefulWidget {
  final dynamic receipt;
  const Failure({Key? key, this.receipt}) : super(key: key);

  @override
  State<Failure> createState() => _FailureState();
}

// Failure State Class
class _FailureState extends State<Failure> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Lottie.asset('assets/lottie/receipt_error.json'),
            Text(
              "Transaction Failed",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "receiptFailure",
                    arguments: {'receipt': widget.receipt});
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold)),
              child: const Text("View Receipt"),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "home");
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold)),
              child: const Text("Dashboard"),
            ),
            const SizedBox(
              height: 200,
            ),
          ],
        ),
      ),
    ));
  }
}
