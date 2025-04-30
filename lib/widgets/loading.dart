/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : LOADING.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:anet_merchant_app/config/app_color.dart';

// Global Loading
class LoadingWidget extends StatelessWidget {
  final bool isTextFieldLoading;
  final String? loadingText;

  const LoadingWidget(
      {super.key, this.isTextFieldLoading = false, this.loadingText});

  @override
  Widget build(BuildContext context) {
    if (isTextFieldLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: LoadingAnimationWidget.hexagonDots(
          color: AppColors.kLightGreen,
          size: 34,
          //color: Theme.of(context).primaryColor,
        ),
      );
    }
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 80.0,
              child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.kPrimaryColor,

                size: 60,
                //color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              loadingText ?? 'Please Wait...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  color: AppColors.kLightGreen),
            ),
          ],
        ),
      ),
    );
  }
}
