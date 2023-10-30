/* ===============================================================
| Project : SIFR
| Page    : APP_MODULE.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:io';
import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

// App Module Class
class AppModule {
  // File upload content widget
  static beforeUploadContent(BuildContext context,
      {GestureTapCallback? onTab}) {
    return GestureDetector(
      onTap: onTab,
      child: Card(
        elevation: 10,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: SizedBox(
          width: double.maxFinite,
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Icon(
                  LineAwesome.cloud_upload_alt_solid,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),

                Text(
                  'Take Photo or Choose file',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Valid File formats: JPG, PNG. Maximum size < 1 MB',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                // Image.asset('assets/logo.jpg'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // After uploading file widget
  static afterFileChange(String path) {
    return badge.Badge(
      position: badge.BadgePosition.topEnd(top: -5, end: 10),
      showBadge: true,
      ignorePointer: false,
      //elevation: 5,
      badgeStyle: const badge.BadgeStyle(elevation: 5),
      badgeContent: const Icon(Icons.close, color: Colors.white, size: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: SizedBox(
            width: double.maxFinite,
            height: 150,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
