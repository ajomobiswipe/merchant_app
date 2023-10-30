import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;

import '../../../config/config.dart';
import '../../../services/services.dart';
import '../../../widgets/loading.dart';
import '../../../widgets/widget.dart';

class CancelledChequeUpload extends StatefulWidget {
  const CancelledChequeUpload({Key? key, this.params}) : super(key: key);
  final dynamic params;

  @override
  State<CancelledChequeUpload> createState() => _CancelledChequeUploadState();
}

class _CancelledChequeUploadState extends State<CancelledChequeUpload> {
  AlertService alertService = AlertService();
  KycService kycService = KycService();

  bool _isLoading = false;
  String cancelCheque = '';

  List merchantArray = [];

  @override
  void initState() {
    setState(() {
      merchantArray = widget.params['content'].split(',');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: "Upload Cancelled Cheque",
        action: false,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: titleWidget('Upload your Cancelled Cheque'),
                    ),
                    cancelChequeWidget(),
                    const SizedBox(height: 10),
                    AppButton(
                      title: "Update",
                      onPressed: () {
                        if (cancelCheque == '') {
                          alertService.failure(
                              context, '', 'Please upload image!');
                        } else {
                          // uploadTrade();
                          submitUpload();
                        }
                      },
                    ),
                    const SizedBox(height: 30.0),
                  ],
                ),
              ),
            ),
    );
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

  Future<String> _download(String url) async {
    final response = await http.get(Uri.parse(url));
    final imageName = path.basename(url);
    final appDir = await pathProvider.getTemporaryDirectory();
    final localPath = path.join(appDir.path, imageName);
    final imageFile = File(localPath);
    await imageFile.writeAsBytes(response.bodyBytes);
    return localPath;
  }

  submitUpload() async {
    setLoading(true);
    var data = widget.params;
    String kycFront =
        await _download(Validators.urlDecrypt(data['customerFrontKycImg']));
    String kycBack =
        await _download(Validators.urlDecrypt(data['customerBackKycImg']));
    var request = {
      'kycFront': kycFront,
      'kycBack': kycBack,
      'canceledCheque': cancelCheque
    };
    kycService.cancelCheque(request).then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          setLoading(false);
          alertService.successPopup(
              context, 'Success', decodeData['responseMessage'], () {
            Navigator.pushNamed(context, 'profile');
          });
        } else {
          setLoading(false);
          alertService.failure(
              context, 'Failure', decodeData['responseMessage']);
        }
      } else {
        setLoading(false);
        alertService.failure(context, 'Failure', decodeData['message']);
      }
    });
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
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
      var newPath = result.path;

      final file1 = File(newPath);
      int sizeInBytes = file1.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);

      setState(() {
        if (sizeInMb < 1) {
          if (type == 'cancelCheque') {
            cancelCheque = newPath;
          }
        } else {
          alertService.failure(context, 'Failure', Constants.oneMbErrorMessage);
          if (type == 'cancelCheque') {
            cancelCheque = '';
          }
        }
      });
    }
  }
}
