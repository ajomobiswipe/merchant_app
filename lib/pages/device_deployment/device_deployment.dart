import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sifr_latest/common_widgets/app_appbar.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import '../../config/config.dart';
import '../../config/constants.dart';
import '../../widgets/app/camera_image_picker.dart';

import 'package:badges/badges.dart' as badge;

import '../../widgets/widget.dart';

// STATEFUL WIDGET
class DeviceDeploymentScreen extends StatefulWidget {
  const DeviceDeploymentScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DeviceDeploymentScreen> createState() => _DeviceDeploymentScreenState();
}

class _DeviceDeploymentScreenState extends State<DeviceDeploymentScreen> {
  final TextEditingController testTransactionChargeSlipImage =
      TextEditingController();
  final TextEditingController deviceAtStoreImage = TextEditingController();
  final TextEditingController deviceSerialNumberCntrl = TextEditingController();
  Position? _currentPosition;
  final AlertService alertWidget = AlertService();

  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      //_getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    //Global Background Pattern Widget
    return Scaffold(
      appBar: const AppAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            const SizedBox(
              height: 20.0,
            ),
            Text("Curley Tales",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black)),
            Text("13574588898978",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black)),
            const SizedBox(
              height: 20.0,
            ),
            // CustomTextWidget(
            //     text:
            //         'lat ${_currentPosition?.latitude ?? ""} long ${_currentPosition?.longitude ?? ""}'),
            // Center(
            //   child: Text(
            //       "Uploading your store's inside image, outside image, and store Address.",
            //       textAlign: TextAlign.center,
            //       style: Theme.of(context)
            //           .textTheme
            //           .bodySmall
            //           ?.copyWith(color: Colors.grey)),
            // ),
            CustomTextFormField(
              title: 'MAP Device Serial Number',
              controller: deviceSerialNumberCntrl,
              required: true,
              textCapitalization: TextCapitalization.words,
              // enabled: _firstNameController.text.isEmpty ||
              //         _firstNameController.text.length < 3
              //     ? enabledLast = false
              //     : enabledLast = true,
              prefixIcon: LineAwesome.mobile_alt_solid,
              validator: (value) {
                value = value.trim();
                if (value == null || value.isEmpty) {
                  return 'Device Serial is Mandatory!';
                }
                if (value.length < 10) {
                  return 'Minimum 10 characters';
                }

                return null;
              },
              onChanged: (String value) {
                value = value.trim();
              },
              onSaved: (value) {
                // merchantPersonalReq.poaNumber = value;
              },
              onFieldSubmitted: (value) {
                // _lastNameController.text = value.trim();
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: RichText(
                      text: TextSpan(
                          text: 'Test Transaction Chargeslip Image',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                          children: const [
                            TextSpan(
                                text: ' *',
                                style: TextStyle(
                                    color: Colors.red,
                                    decoration: TextDecoration.none))
                          ]),
                    ),
                  ),
                  testTransactionChargeSlipImage.text != ''
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              testTransactionChargeSlipImage.text = '';
                            });
                          },
                          child:
                              afterSelect(testTransactionChargeSlipImage.text),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GestureDetector(
                            onTap: () {
                              cameraPhotoDialog(
                                  context, 'testTransactionChargeSlipImage');
                            },
                            child: Card(
                              elevation: 10,
                              // margin: const EdgeInsets.all(10.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: SizedBox(
                                width: double.maxFinite,
                                height: 150,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Icon(
                                        LineAwesome.camera_retro_solid,
                                        size: 40,
                                        color: Theme.of(context).primaryColor,
                                      ),

                                      Text(
                                        'Click the image of test transaction Chargeslip',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Valid File formats: JPG, PNG. Maximum size < 1 MB',
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                      // Image.asset('assets/logo.jpg'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: RichText(
                      text: TextSpan(
                          text: 'Image Of Device At Store',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline),
                          children: const [
                            TextSpan(
                                text: ' *',
                                style: TextStyle(
                                    color: Colors.red,
                                    decoration: TextDecoration.none))
                          ]),
                    ),
                  ),
                  deviceAtStoreImage.text != ''
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              deviceAtStoreImage.text = '';
                            });
                          },
                          child: afterSelect(deviceAtStoreImage.text),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GestureDetector(
                            onTap: () {
                              cameraPhotoDialog(context, 'deviceAtStoreImage');
                            },
                            child: Card(
                              elevation: 10,
                              // margin: const EdgeInsets.all(10.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: SizedBox(
                                width: double.maxFinite,
                                height: 150,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Icon(
                                        LineAwesome.camera_retro_solid,
                                        size: 40,
                                        color: Theme.of(context).primaryColor,
                                      ),

                                      Text(
                                        'Click the image of Device At Store',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Valid File formats: JPG, PNG. Maximum size < 1 MB',
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                      // Image.asset('assets/logo.jpg'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            Center(
              child: CustomAppButton(
                title: "Deploy",
                onPressed: () {
                  if (testTransactionChargeSlipImage.text != '' &&
                      deviceAtStoreImage.text != '') {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      'myApplications',
                      (route) => false,
                    );
                    alertWidget.success(context, '', 'Deployment Completed!');
                    // next();
                  } else {
                    alertWidget.failure(
                        context, '', 'Please upload All images!');
                  }
                },
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  cameraPhotoDialog(BuildContext context, String type) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CameraImagePicker(onCameraBTNPressed: () {
          uploadAction(type, ImageSource.camera);
        }, onGalleryBTNPressed: () {
          uploadAction(type, ImageSource.gallery);
        });
      },
    );
  }

  uploadAction(String type, ImageSource src) async {
    final ImagePicker picker = ImagePicker();
    XFile? photo = await picker.pickImage(source: src);
    if (photo != null) {
      _cropImage(type, File(photo.path));
    }
  }

  _cropImage(type, pickedFile) async {
    late String path;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop your Photo',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Crop your Photo',
        ),
      ],
    );
    if (croppedFile != null) {
      path = croppedFile.path;
      compress(type, File(path));
    }
  }

  compress(type, File file) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.path}_$type.jpg',
      quality: 60,
    );

    if (result != null) {
      setState(() {
        final file1 = File(result.path);
        int sizeInBytes = file1.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb < 1) {
          if (type == 'testTransactionChargeSlipImage') {
            testTransactionChargeSlipImage.text = result.path;
          } else if (type == 'deviceAtStoreImage') {
            deviceAtStoreImage.text = result.path;
          }
        } else {
          alertWidget.failure(context, 'Failure', Constants.oneMbErrorMessage);

          if (type == 'testTransactionChargeSlipImage') {
            testTransactionChargeSlipImage.text = '';
          } else if (type == 'deviceAtStoreImage') {
            deviceAtStoreImage.text = '';
          }
        }
      });
    }
  }

  Widget afterSelect(path) {
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
