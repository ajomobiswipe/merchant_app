import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/config.dart';
import '../../../services/services.dart';
import '../../../widgets/loading.dart';
import '../../../widgets/widget.dart';

class ReUploadKyc extends StatefulWidget {
  const ReUploadKyc({Key? key, this.params}) : super(key: key);
  final dynamic params;

  @override
  State<ReUploadKyc> createState() => _ReUploadKycState();
}

class _ReUploadKycState extends State<ReUploadKyc> {
  bool _isLoading = false;
  int mbSize = 1;
  String kycFrontImage = '';
  String kycBackImage = '';
  AlertService alertWidget = AlertService();
  KycService kycService = KycService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, 'myAccount');
        return true;
      },
      child: Scaffold(
        appBar: const AppBarWidget(
          title: 'Upload KYC',
        ),
        body: _isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                child: kyc(),
              ),
      ),
    );
  }

  /// KYC INFORMATION
  Widget kyc() {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      const SizedBox(height: 20.0),
      Center(
        child: Text(
          'Uploading your KYC is used to protect financial institutions against fraud, corruption, money laundering and terrorist financing',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),
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
                    text: 'Upload front page of Emirates ID',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            kycFrontImage != ''
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        kycFrontImage = '';
                      });
                    },
                    child: afterSelect(kycFrontImage),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: () {
                        cameraPhotoDialog(context, 'kycFrontImage');
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
                    text: 'Upload reverse page of Emirates ID',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            kycBackImage != ''
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        kycBackImage = '';
                      });
                    },
                    child: afterSelect(kycBackImage),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: () {
                        cameraPhotoDialog(context, 'kycBackImage');
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
          ],
        ),
      ),
      const SizedBox(height: 20.0),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: AppButton(
          title: "Submit",
          onPressed: () async {
            if (kycFrontImage != '' && kycBackImage != '') {
              submitKyc();
            } else {
              alertWidget.failure(context, '', 'Please upload Emirates ID!');
            }
          },
        ),
      ),
      const SizedBox(height: 20.0),
    ]);
  }

  submitKyc() {
    setState(() {
      _isLoading = true;
    });
    var req = {
      'front': kycFrontImage,
      'back': kycBackImage,
    };
    kycService.uploadKyc(req).then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          setState(() {
            _isLoading = false;
          });
          alertWidget.successPopup(
              context, 'Success', decodeData['responseMessage'], () {
            Navigator.pushNamed(context, 'myAccount');
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          alertWidget.failure(
              context, 'Failure', decodeData['responseMessage']);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        alertWidget.failure(context, 'Failure', decodeData['message']);
      }
    });
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

  cameraPhotoDialog(BuildContext context, String type) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogBox(onCameraBTNPressed: () {
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
      var newPath = result.path;
      final file1 = File(newPath);
      int sizeInBytes = file1.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb < 1) {
        setState(() {
          if (type == 'kycFrontImage') {
            kycFrontImage = newPath;
          } else if (type == 'kycBackImage') {
            kycBackImage = newPath;
          }
        });
      } else {
        setState(() {
          alertWidget.failure(context, 'Failure', Constants.oneMbErrorMessage);
          if (type == 'kycFrontImage') {
            kycFrontImage = '';
          } else if (type == 'kycBackImage') {
            kycBackImage = '';
          }
        });
      }
    }
  }
}
