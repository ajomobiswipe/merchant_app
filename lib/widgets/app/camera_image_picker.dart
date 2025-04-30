/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : CUSTOM_DIALOG.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// STATEFUL WIDGET
class CameraImagePicker extends StatefulWidget {
  final Function onCameraBTNPressed;

  const CameraImagePicker({
    super.key,
    required this.onCameraBTNPressed,
  });

  @override
  CameraImagePickerState createState() => CameraImagePickerState();
}

// Custom Dialogue Class
class CameraImagePickerState extends State<CameraImagePicker> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  //Body Widget
  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding:
              const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    splashColor: Theme.of(context).primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      checkAndRequestCameraPermissions();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text("Camera"),
                        // <-- Text
                      ],
                    ),
                  ),
                  // InkWell(
                  //   splashColor: Theme.of(context).primaryColor,
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     widget.onGalleryBTNPressed();
                  //   },
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: <Widget>[
                  //       Icon(
                  //         FontAwesome.photo_film,
                  //         size: 30,
                  //         color: Theme.of(context).primaryColor,
                  //       ),
                  //       const SizedBox(
                  //         height: 5,
                  //       ),
                  //       const Text("Gallery"), // <-- Text
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Check And Request Camera Permissions globally
  checkAndRequestCameraPermissions() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      openAppSettings();
    } else {
      widget.onCameraBTNPressed();
    }
  }
}
