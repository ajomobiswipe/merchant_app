import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sifr_latest/common_widgets/app_appbar.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import 'package:sifr_latest/common_widgets/icon_text_widget.dart';
import '../../config/app_color.dart';
import '../../config/constants.dart';
import '../app/CustomDialogBox.dart';
import '../app/alert_service.dart';
import '../app_widget/app_bar_widget.dart';
import '../app_widget/app_button.dart';
import 'package:badges/badges.dart' as badge;

// STATEFUL WIDGET
class DocumentUploads extends StatefulWidget {
  final TextEditingController tradeLicense;
  final TextEditingController nationalIdFront;
  final TextEditingController nationalIdBack;
  final TextEditingController cancelCheque;
  Function previous;
  Function next;

  DocumentUploads({
    Key? key,
    required this.previous,
    required this.next,
    required this.tradeLicense,
    required this.nationalIdFront,
    required this.cancelCheque,
    required this.nationalIdBack,
  }) : super(key: key);

  @override
  State<DocumentUploads> createState() => _DocumentUploadsState();
}

class _DocumentUploadsState extends State<DocumentUploads> {
  AlertService alertWidget = AlertService();
  @override
  void initState() {
    super.initState();
  }

  int currTabPosition = 3;
  //int completedTab = 3;

  Color getIconColor({
    required int position,
  }) {
    if (position <= currTabPosition - 1) {
      return Colors.green;
    } else if (position == currTabPosition) {
      return AppColors.kPrimaryColor;
    } else if (position > currTabPosition) {
      return Colors.grey;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: const AppAppbar(
          title: 'Document Uploads',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.kSelectedBackgroundColor,
                  ),
                  // height: screenHeight / 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconTextWidget(
                          screenHeight: screenHeight,
                          color: getIconColor(
                            position: 1,
                          ),
                          iconPath:
                              'assets/merchant_icons/merchant_detials.png',
                          title: "Merchant\nDetails"),
                      IconTextWidget(
                          screenHeight: screenHeight,
                          color: getIconColor(position: 2),
                          iconPath: 'assets/merchant_icons/id_proof_icon.png',
                          title: "Id\nProofs"),
                      IconTextWidget(
                          screenHeight: screenHeight,
                          color: getIconColor(position: 3),
                          iconPath:
                              'assets/merchant_icons/bussiness_proofs.png',
                          title: "Bussiness\nProofs"),
                      IconTextWidget(
                          screenHeight: screenHeight,
                          color: getIconColor(position: 4),
                          iconPath: 'assets/merchant_icons/bank_details.png',
                          title: "Bank\nDetails"),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: RichText(
                    text: TextSpan(
                        text: 'Upload your Bussines License',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                widget.tradeLicense.text != ''
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.tradeLicense.text = '';
                          });
                        },
                        child: afterSelect(widget.tradeLicense.text),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () {
                            cameraPhotoDialog(context, 'tradeLicense');
                          },
                          child: Card(
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
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: RichText(
                    text: TextSpan(
                        text: 'Upload Front page of your National ID',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                widget.nationalIdFront.text != ''
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.nationalIdFront.text = '';
                          });
                        },
                        child: afterSelect(widget.nationalIdFront.text),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () async {
                            cameraPhotoDialog(context, 'nationalIdFront');
                          },
                          child: Card(
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
                        ),
                      ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: RichText(
                    text: TextSpan(
                        text: 'Upload Back page of your National ID',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                widget.nationalIdBack.text != ''
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.nationalIdBack.text = '';
                          });
                        },
                        child: afterSelect(widget.nationalIdBack.text),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () {
                            cameraPhotoDialog(context, 'nationalIdBack');
                          },
                          child: Card(
                            elevation: 10,
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
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Upload a Cancelled Cheque',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                    textAlign: TextAlign.center,
                  ),
                ),
                widget.cancelCheque.text != ''
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.cancelCheque.text = '';
                          });
                        },
                        child: afterSelect(widget.cancelCheque.text),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () {
                            cameraPhotoDialog(context, 'cancelCheque');
                          },
                          child: Card(
                            elevation: 10,
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
                        ),
                      ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: CustomAppButton(
                        title: 'Previous',
                        onPressed: () {
                          widget.previous();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: CustomAppButton(
                        title: "Next",
                        onPressed: () {
                          if (widget.tradeLicense.text != '' &&
                              widget.nationalIdFront.text != '' &&
                              widget.nationalIdBack.text != '') {
                            widget.next();
                          } else {
                            alertWidget.failure(context, '',
                                'Please upload Trade License, Nation ID/Emirates ID\'s documents');
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
      final file1 = File(result.path);
      int sizeInBytes = file1.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      setState(() {
        if (sizeInMb < 1) {
          if (type == 'tradeLicense') {
            widget.tradeLicense.text = result.path;
          } else if (type == 'nationalIdFront') {
            widget.nationalIdFront.text = result.path;
          } else if (type == 'nationalIdBack') {
            widget.nationalIdBack.text = result.path;
          } else if (type == 'cancelCheque') {
            widget.cancelCheque.text = result.path;
          }
        } else {
          if (type == 'tradeLicense') {
            widget.tradeLicense.text = '';
          } else if (type == 'nationalIdFront') {
            widget.nationalIdFront.text = '';
          } else if (type == 'nationalIdBack') {
            widget.nationalIdBack.text = '';
          } else if (type == 'cancelCheque') {
            widget.cancelCheque.text = '';
          }
          alertWidget.failure(context, 'Failure', Constants.oneMbErrorMessage);
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
