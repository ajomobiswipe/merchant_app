import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sifr_latest/common_widgets/app_appbar.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';
import '../../config/config.dart';
import '../../config/constants.dart';
import '../../services/user_services.dart';
import '../../widgets/app/camera_image_picker.dart';

import 'package:badges/badges.dart' as badge;

import '../../widgets/widget.dart';
import 'model/product_deployment_requestmodel.dart';

// STATEFUL WIDGET
class DeviceDeploymentScreen extends StatefulWidget {
  final Map<String, dynamic>? deviceInfo;
  const DeviceDeploymentScreen({
    Key? key,
    this.deviceInfo,
  }) : super(key: key);

  @override
  State<DeviceDeploymentScreen> createState() => _DeviceDeploymentScreenState();
}

class _DeviceDeploymentScreenState extends State<DeviceDeploymentScreen> {
  final TextEditingController testTransactionChargeSlipImage =
      TextEditingController();
  final TextEditingController deviceAtStoreImage = TextEditingController();
  final TextEditingController deviceSerialNumberCntrl = TextEditingController();
  ProductDeploymentRequestmodel productDeploymentReq =
      ProductDeploymentRequestmodel();

  UserServices userServices = UserServices();
  bool isdevicedeploying = false;
  final AlertService alertWidget = AlertService();
  CustomAlert customAlert = CustomAlert();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }

  deviceDeployment() {
    productDeploymentReq.guid = widget.deviceInfo!["guid"];
    productDeploymentReq.merchantId = widget.deviceInfo!["merchantId"];
    productDeploymentReq.productId = widget.deviceInfo!["productId"];
    productDeploymentReq.packageId = widget.deviceInfo!["packageId"];
    productDeploymentReq.productSerialNo = deviceSerialNumberCntrl.text;
    // print(productDeploymentReq.toJson());
    userServices
        .deviceDeployment(productDeploymentReq, deviceAtStoreImage.text,
            testTransactionChargeSlipImage.text)
        .then((response) async {
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var decodeData = jsonDecode(response.body);

        if (decodeData['statusCode'].toString() == "200") {
          alertWidget.success(
            context,
            'Success',
            decodeData['errorMessage'],
          );
          setState(() {});
          Navigator.pushNamedAndRemoveUntil(
              context, 'myApplications', (route) => false);
        } else {
          alertWidget.failure(
            context,
            'failed',
            decodeData['errorMessage'],
          );

          setState(() {
            // _isLoading = false;
          });
          alertWidget.failure(context, 'Failure', decodeData['errorMessage']);
        }
      } else {
        alertWidget.failure(context, 'Failure', response.statusCode.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    //Global Background Pattern Widget
    return Scaffold(
      appBar: AppAppbar(
        closePressed: () {
          customAlert.displayDialogConfirm(
              context, "", "Do you want to quit Deployment ?", () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          });
        },
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: isdevicedeploying
          ? Container(
              color: AppColors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextWidget(
                        text: "Deplpying Device",
                        color: AppColors.kPrimaryColor,
                        size: 26),
                    CustomTextWidget(text: "Please wait...."),
                    CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    CustomTextWidget(text: "Deployment Details", size: 20),
                    const SizedBox(
                      height: 40.0,
                    ),
                    Text(widget.deviceInfo!["MerchantName"],
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.black)),
                    Text(widget.deviceInfo!["phoneNumber"],
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
                      title: widget.deviceInfo!["productName"],
                      hintText: "MAP Device Serial Number",
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
                        productDeploymentReq.productSerialNo = value;
                      },
                      onSaved: (value) {
                        productDeploymentReq.productSerialNo = value;
                      },
                      onFieldSubmitted: (value) {
                        // _lastNameController.text = value.trim();
                      },
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: RichText(
                              text: TextSpan(
                                text: 'Test Transaction Charge slip Image',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                // children: const [
                                //   TextSpan(
                                //       text: ' *',
                                //       style: TextStyle(
                                //           color: Colors.red,
                                //           decoration: TextDecoration.none))
                                // ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          testTransactionChargeSlipImage.text != ''
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      testTransactionChargeSlipImage.text = '';
                                    });
                                  },
                                  child: afterSelect(
                                      testTransactionChargeSlipImage.text),
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      cameraPhotoDialog(context,
                                          'testTransactionChargeSlipImage');
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: AppColors.kTileColor,
                                      ),
                                      width: double.maxFinite,
                                      height: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Icon(
                                              Icons.camera_sharp,
                                              size: 40,
                                              color: AppColors.kPrimaryColor,
                                            ),
                                            // Text(
                                            //   'Click the image of test transaction Chargeslip',
                                            //   textAlign: TextAlign.center,
                                            //   style: TextStyle(
                                            //       color: Theme.of(context)
                                            //           .primaryColor,
                                            //       fontWeight: FontWeight.bold),
                                            // ),
                                            // const SizedBox(
                                            //   height: 10,
                                            // ),
                                            // Text(
                                            //   'Valid File formats: JPG, PNG. Maximum size < 1 MB',
                                            //   style: TextStyle(
                                            //       color: Colors.grey.shade500,
                                            //       fontSize: 12),
                                            //   textAlign: TextAlign.center,
                                            // ),
                                            // Image.asset('assets/logo.jpg'),
                                          ],
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
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  children: const [
                                    TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                            color: Colors.red,
                                            decoration: TextDecoration.none))
                                  ]),
                            ),
                          ),
                          Container(
                            height: 15,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      cameraPhotoDialog(
                                          context, 'deviceAtStoreImage');
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: AppColors.kTileColor,
                                      ),
                                      width: double.maxFinite,
                                      height: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Icon(
                                              Icons.camera_sharp,
                                              size: 40,
                                              color: AppColors.kPrimaryColor,
                                            ),
                                            // Text(
                                            //   'Click the image of Device At Store',
                                            //   style: TextStyle(
                                            //       color: Theme.of(context)
                                            //           .primaryColor,
                                            //       fontWeight: FontWeight.bold),
                                            // ),
                                            // const SizedBox(
                                            //   height: 10,
                                            // ),
                                            // Text(
                                            //   'Valid File formats: JPG, PNG. Maximum size < 1 MB',
                                            //   style: TextStyle(
                                            //       color: Colors.grey.shade500,
                                            //       fontSize: 12),
                                            //   textAlign: TextAlign.center,
                                            // ),
                                            // Image.asset('assets/logo.jpg'),
                                          ],
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
                          print(widget.deviceInfo);
                          if (_formKey.currentState!.validate()) {
                            if (testTransactionChargeSlipImage.text != '' &&
                                deviceAtStoreImage.text != '') {
                              setState(() {
                                isdevicedeploying = true;
                              });
                              deviceDeployment();
                            } else {
                              alertWidget.failure(
                                  context, '', 'Please upload All images!');
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
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
            height: 120,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                File(path),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
