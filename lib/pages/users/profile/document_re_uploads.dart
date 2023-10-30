import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:sifr_latest/config/config.dart';

import '../../../services/services.dart';
import '../../../widgets/loading.dart';
import '../../../widgets/widget.dart';

class DocumentReUploads extends StatefulWidget {
  const DocumentReUploads({Key? key, this.params}) : super(key: key);
  final dynamic params;
  @override
  State<DocumentReUploads> createState() => _DocumentReUploadsState();
}

class _DocumentReUploadsState extends State<DocumentReUploads> {
  bool _isLoading = false;

  AlertService alertService = AlertService();
  KycService kycService = KycService();

  /// DOCUMENTS INFO
  String tradeLicense = '';
  String nationalIdFront = '';
  String nationalIdBack = '';
  String cancelCheque = '';
  int mbSize = 1;
  dynamic data = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      data = widget.params;
    });
    setState(() {
      var imageArray = data['content'].split(',');
    });
  }

  Widget titleWidget(title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: RichText(
        text: TextSpan(
          text: title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
          children: const [
            TextSpan(
                text: ' *',
                style: TextStyle(
                    color: Colors.red, decoration: TextDecoration.none))
          ],
        ),
      ),
    );
  }

  Widget title1() {
    return Text(
      "",
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline),
    );
  }

  @override
  Widget build(BuildContext context) {
    var object = widget.params;
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Update ${object['key']}',
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (object['key'] == 'National ID') ...nationalIdNew(),
                    if (object['key'] == 'Trade License') ...tradeLicenseNew(),
                    if (object['key'] == 'Cancelled Cheque')
                      ...cancelChequeNew(),
                    const SizedBox(height: 30.0),
                    AppButton(
                      title: "Update",
                      onPressed: () {
                        uploadMerchantDocuments();

                        // if (nationalIdFront == '' ||
                        //     nationalIdBack == '' ||
                        //     tradeLicense == '') {
                        //   alertService.failure(
                        //       context, '', 'Please upload all valid documents');
                        // } else {
                        //   uploadMerchantDocuments();
                        // }
                      },
                    ),
                    const SizedBox(height: 30.0),
                  ],
                ),
              ),
            ),
    );
  }

  nationalIdNew() {
    return [
      Align(
        alignment: Alignment.centerLeft,
        child: titleWidget('Upload your National/Emirates ID Front'),
      ),
      nationalIdFrontWidget(),
      const SizedBox(height: 30),
      Align(
        alignment: Alignment.centerLeft,
        child: titleWidget('Upload your National/Emirates ID Back'),
      ),
      nationalIdBackWidget(),
    ];
  }

  tradeLicenseNew() {
    return [
      const SizedBox(height: 30),
      Align(
        alignment: Alignment.centerLeft,
        child: titleWidget('Upload your Trade License'),
      ),
      tradeLicenseWidget(),
    ];
  }

  cancelChequeNew() {
    return [
      const SizedBox(height: 30.0),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Upload your Cancelled Cheque",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
        ),
      ),
      cancelChequeWidget(),
    ];
  }

  Future<String> _download(String url) async {
    final response = await http.get(Uri.parse(url));
    final imageName = path.basename(url);
    final appDir = await pathProvider.getApplicationDocumentsDirectory();
    final localPath = path.join(appDir.path, imageName);
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);
    return localPath;
  }

  uploadMerchantDocuments() async {
    setState(() {
      _isLoading = true;
    });
    var imageArray = data['content'].split(',');
    String kycFront = await _download(data['customerFrontKycImg']);
    String kycBack = await _download(data['customerBackKycImg']);
    if (data['key'] == 'National ID') {
      tradeLicense = await _download(imageArray[2]);
      if (imageArray[3] != '') {
        cancelCheque = await _download(imageArray[3]);
      }
    }
    if (data['key'] == 'Trade License') {
      nationalIdFront = await _download(imageArray[0]);
      nationalIdBack = await _download(imageArray[1]);
      if (imageArray[3] != '') {
        cancelCheque = await _download(imageArray[3]);
      }
    }
    if (data['key'] == 'Cancelled Cheque') {
      nationalIdFront = await _download(imageArray[0]);
      nationalIdBack = await _download(imageArray[1]);
      tradeLicense = await _download(imageArray[2]);
    }
    var data1 = {
      'kycFront': kycFront,
      'kycBack': kycBack,
      'nationalIdFront': nationalIdFront,
      'nationalIdBack': nationalIdBack,
      'tradeLicense': tradeLicense,
      'cancelCheque': cancelCheque
    };
    kycService.uploadMerchantDocuments(data1).then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          setState(() {
            _isLoading = false;
          });
          alertService.successPopup(
              context, 'Success', decodeData['responseMessage'], () {
            Navigator.pushNamed(context, 'profile');
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          alertService.failure(
              context, 'Failure', decodeData['responseMessage']);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        alertService.failure(context, 'Failure', decodeData['message']);
      }
    });
  }

  tradeLicenseWidget() {
    return tradeLicense != ''
        ? GestureDetector(
            onTap: () {
              setState(() {
                tradeLicense = '';
              });
            },
            child: AppModule.afterFileChange(tradeLicense),
          )
        : AppModule.beforeUploadContent(context, onTab: () {
            cameraPhotoDialog(context, 'tradeLicense');
          });
  }

  nationalIdFrontWidget() {
    return nationalIdFront != ''
        ? GestureDetector(
            onTap: () {
              setState(() {
                nationalIdFront = '';
              });
            },
            child: AppModule.afterFileChange(nationalIdFront),
          )
        : AppModule.beforeUploadContent(context, onTab: () {
            cameraPhotoDialog(context, 'nationalIdFront');
          });
  }

  nationalIdBackWidget() {
    return nationalIdBack != ''
        ? GestureDetector(
            onTap: () {
              setState(() {
                nationalIdBack = '';
              });
            },
            child: AppModule.afterFileChange(nationalIdBack),
          )
        : AppModule.beforeUploadContent(context, onTab: () {
            cameraPhotoDialog(context, 'nationalIdBack');
          });
  }

  cancelChequeWidget() {
    return cancelCheque != ''
        ? GestureDetector(
            onTap: () {
              setState(() {
                cancelCheque = '';
              });
            },
            child: AppModule.afterFileChange(cancelCheque),
          )
        : AppModule.beforeUploadContent(context, onTab: () {
            cameraPhotoDialog(context, 'cancelCheque');
          });
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
      // var lastSeparator = result.path.lastIndexOf(Platform.pathSeparator);
      // var newPath = '${result.path.substring(0, lastSeparator + 1)}$type.jpg';
      // result.rename(newPath);
      var newPath = result.path;
      final file1 = File(newPath);
      int sizeInBytes = file1.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      setState(() {
        if (sizeInMb < 1) {
          if (type == 'nationalIdFront') {
            nationalIdFront = newPath;
          } else if (type == 'nationalIdBack') {
            nationalIdBack = newPath;
          } else if (type == 'tradeLicense') {
            tradeLicense = newPath;
          } else if (type == 'cancelCheque') {
            cancelCheque = newPath;
          }
        } else {
          alertService.failure(context, 'Failure', Constants.oneMbErrorMessage);
          if (type == 'nationalIdFront') {
            nationalIdFront = '';
          } else if (type == 'nationalIdBack') {
            nationalIdBack = '';
          } else if (type == 'tradeLicense') {
            tradeLicense = '';
          } else if (type == 'cancelCheque') {
            cancelCheque = '';
          }
        }
      });
    }
  }
}
