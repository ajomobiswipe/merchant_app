import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/constants.dart';
import '../app/CustomDialogBox.dart';
import '../app/alert_service.dart';
import '../app_widget/app_bar_widget.dart';
import '../app_widget/app_button.dart';
import 'package:badges/badges.dart' as badge;

// STATEFUL WIDGET
class KYCForm extends StatefulWidget {
  final TextEditingController kycFrontImage;
  final TextEditingController kycBackImage;
  Function previous;
  Function next;

  KYCForm({
    Key? key,
    required this.previous,
    required this.next,
    required this.kycFrontImage,
    required this.kycBackImage,
  }) : super(key: key);

  @override
  State<KYCForm> createState() => _KYCFormState();
}

class _KYCFormState extends State<KYCForm> {
  AlertService alertWidget = AlertService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Global Background Pattern Widget
    return Scaffold(
        appBar: const AppBarWidget(
          action: false,
          title: 'KYC Information',
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                  widget.kycFrontImage.text != ''
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.kycFrontImage.text = '';
                            });
                          },
                          child: afterSelect(widget.kycFrontImage.text),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                          text: 'Upload reverse page of Emirates ID',
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
                  widget.kycBackImage.text != ''
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.kycBackImage.text = '';
                            });
                          },
                          child: afterSelect(widget.kycBackImage.text),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: AppButton(
                    title: 'Previous',
                    onPressed: () {
                      widget.previous();
                    },
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: AppButton(
                    title: "Next",
                    onPressed: () {
                      if (widget.kycFrontImage.text != '' &&
                          widget.kycBackImage.text != '') {
                        widget.next();
                      } else {
                        alertWidget.failure(
                            context, '', 'Please upload all Emirates ID!');
                      }
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 20.0),
          ]),
        ));
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
      setState(() {
        final file1 = File(result.path);
        int sizeInBytes = file1.lengthSync();
        double sizeInMb = sizeInBytes / (1024 * 1024);

        if (sizeInMb < 1) {
          if (type == 'kycFrontImage') {
            widget.kycFrontImage.text = result.path;
          } else if (type == 'kycBackImage') {
            widget.kycBackImage.text = result.path;
          }
        } else {
          alertWidget.failure(context, 'Failure', Constants.oneMbErrorMessage);

          if (type == 'kycFrontImage') {
            widget.kycFrontImage.text = '';
          } else if (type == 'kycBackImage') {
            widget.kycBackImage.text = '';
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
