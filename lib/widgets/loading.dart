/* ===============================================================
| Project : SIFR
| Page    : LOADING.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// Global Loading
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 80.0,
              child: LoadingAnimationWidget.newtonCradle(
                size: 200,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              'Please Wait...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold, decoration: TextDecoration.none),
            ),
          ],
        ),
      ),
    );
  }
}
