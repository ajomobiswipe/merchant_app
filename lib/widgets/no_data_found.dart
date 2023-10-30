/* ===============================================================
| Project : SIFR
| Page    : NO_DATA_FOUND.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';

// Global No Data Found Widget
class NoDataFound extends StatelessWidget {
  const NoDataFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/screen/no_data.jpg',
              height: 100, fit: BoxFit.fill),
          const Text(
            "No data found!",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    ));
  }
}
