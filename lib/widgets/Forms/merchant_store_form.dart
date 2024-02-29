import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sifr_latest/common_widgets/app_appbar.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import 'package:sifr_latest/pages/mechant_order/models/mechant_additionalingo_model.dart';
import 'package:sifr_latest/widgets/tabbar/tabbar.dart';
import 'package:sifr_latest/widgets/widget.dart';
import '../../common_widgets/icon_text_widget.dart';
import '../../config/config.dart';
import '../../config/constants.dart';
import '../../pages/users/signup/customer/models/merchant_store_info_requestmodel.dart';
import '../app/CustomDialogBox.dart';
import '../app/alert_service.dart';
import '../app/camera_image_picker.dart';
import '../app_widget/app_bar_widget.dart';
import '../app_widget/app_button.dart';
import 'package:badges/badges.dart' as badge;

import '../custom_text_widget.dart';

// STATEFUL WIDGET
class MerchantStoreImagesForm extends StatefulWidget {
  final MerchantStoreInfoRequestmodel merchantStoreInfoReq;
  final TextEditingController storeFrontImage;
  final TextEditingController insideStoreImage;
  final TextEditingController merchantStoreAddressController;
  final TextEditingController merchantBusinessAddressController;
  final TextEditingController selectedStoreState;
  final String selectedBusinessState;
  final String selectedBusinessCity;
  final TextEditingController selectedStoreCity;
  final TextEditingController storePinCodeCtrl;
  final TextEditingController businessAddressPinCodeCtrl;

  final List storeCitysList;
  final List storeStatesList;

  Function()? previous;
  Function next;

  MerchantStoreImagesForm(
      {Key? key,
      required this.previous,
      required this.next,
      required this.storeFrontImage,
      required this.insideStoreImage,
      required this.merchantStoreInfoReq,
      required this.merchantStoreAddressController,
      required this.storePinCodeCtrl,
      required this.storeCitysList,
      required this.storeStatesList,
      required this.selectedStoreState,
      required this.selectedStoreCity,
      required this.merchantBusinessAddressController,
      required this.businessAddressPinCodeCtrl,
      required this.selectedBusinessState,
      required this.selectedBusinessCity})
      : super(key: key);

  @override
  State<MerchantStoreImagesForm> createState() =>
      _MerchantStoreImagesFormState();
}

class _MerchantStoreImagesFormState extends State<MerchantStoreImagesForm> {
  Position? _currentPosition;
  AlertService alertWidget = AlertService();
  CustomAlert customAlert = CustomAlert();

  int currTabPosition = 3;
  final GlobalKey<FormState> storeFormKey = GlobalKey<FormState>();

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
      widget.merchantStoreInfoReq.latitude = position.latitude;
      widget.merchantStoreInfoReq.longitude = position.longitude;
      widget.merchantStoreInfoReq.currentCountry = "356";
      //_getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      // debugPrint(e);
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

  onTapConfirm() {
    Navigator.pushNamedAndRemoveUntil(
        context, 'MerchantNumVerify', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    //Global Background Pattern Widget
    return Scaffold(
      appBar: AppAppbar(
        onPressed: widget.previous,
        closePressed: () {
          customAlert.displayDialogConfirm(context, 'Please confirm',
              'Do you want to quit your registration?', onTapConfirm);
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: storeFormKey,
          autovalidateMode: null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  CustomTextWidget(
                    text: "Merchant KYC",
                    fontWeight: FontWeight.w500,
                    size: 18,
                  ),
                ],
              ),
              appTabbar(
                screenHeight: screenHeight,
                currTabPosition: currTabPosition,
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

              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: RichText(
                        text: TextSpan(
                            text: 'Merchant Store Image',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.black.withOpacity(0.7),
                                      fontWeight: FontWeight.bold,
                                      // decoration: TextDecoration.underline,
                                    ),
                            children: const [
                              TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      decoration: TextDecoration.none))
                            ]),
                      ),
                    ),
                    widget.storeFrontImage.text != ''
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.storeFrontImage.text = '';
                              });
                            },
                            child: afterSelect(widget.storeFrontImage.text),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: GestureDetector(
                              onTap: () {
                                cameraPhotoDialog(context, 'storeFrontImage');
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          CustomTextWidget(
                                              text:
                                                  "Click the front image of the store",
                                              color: Colors.grey),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      const Icon(
                                        Icons.camera_sharp,
                                        size: 40,
                                        color: AppColors.kPrimaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                    const SizedBox(height: 20),
                    widget.insideStoreImage.text != ''
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.insideStoreImage.text = '';
                              });
                            },
                            child: afterSelect(widget.insideStoreImage.text),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: GestureDetector(
                              onTap: () {
                                cameraPhotoDialog(context, 'insideStoreImage');
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          CustomTextWidget(
                                              text:
                                                  "Click the inside image of the store",
                                              color: Colors.grey),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Icon(
                                        Icons.camera_sharp,
                                        size: 40,
                                        color: AppColors.kPrimaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              Row(
                children: [
                  const CustomTextWidget(
                    text: "Merchant Store Address",
                    // color: AppColors.kPrimaryColor,
                  ),
                  Checkbox(
                    value: widget.merchantStoreInfoReq.isBusinessAddSameAsStore,
                    onChanged: (value) {
                      setState(() {
                        widget.merchantStoreInfoReq.isBusinessAddSameAsStore =
                            value!;
                      });
                    },
                  ),
                  const CustomTextWidget(
                    text: "Same as Business",
                    size: 10,
                  ),
                ],
              ),

              CustomTextFormField(
                titleEneabled: false,
                hintText: "Enter merchant Store address",
                title: '',
                maxLength: 100,
                enabled: !widget.merchantStoreInfoReq.isBusinessAddSameAsStore,
                controller: widget.merchantStoreInfoReq.isBusinessAddSameAsStore
                    ? widget.merchantBusinessAddressController
                    : widget.merchantStoreAddressController,
                prefixIcon: Icons.home,
                required: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(
                      r'[a-zA-Z0-9 ]')), // Allow only letters and numbers
                ],
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.words,

                // prefixIcon: LineAwesome.address_book,
                validator: (value) {
                  value = value.trim();
                  if (value == null || value.isEmpty) {
                    return 'Merchant Store Address is Mandatory!';
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
                  widget.merchantStoreInfoReq.currentAddress = value;
                  // merchantPersonalReq.currentAddress = value;
                },
                onFieldSubmitted: (value) {
                  // _merchantBusinessAddressController.text = value.trim();
                },
              ),
              const SizedBox(
                height: 15.0,
              ),

              CustomDropdown(
                titleEnabled: false,
                hintText: "Select State",
                title: "Current State",
                // enabled: selectedState != '' && enabledState
                //     ? enabledcity = true
                //     : enabledcity = false,
                required: true,
                enabled: !widget.merchantStoreInfoReq.isBusinessAddSameAsStore,
                selectedItem:
                    widget.merchantStoreInfoReq.isBusinessAddSameAsStore
                        ? widget.selectedBusinessState
                        : widget.selectedStoreState.text != ''
                            ? widget.selectedStoreState.text
                            : null,
                prefixIcon: Icons.flag_circle_outlined,
                // itemList: widget.storeStatesList
                //     .map((item) => item['stateName'])
                //     .toList(),

                itemList: widget.storeStatesList
                    .where((item) =>
                        item['tmsMasterCountry'] != null &&
                        item['tmsMasterCountry']['countryIsoNumId'] == 356)
                    .map((item) => item['stateName'])
                    .toList(),

                // cityList.map((e) => e['citName']).toList(),
                onChanged: (value) {
                  setState(() {
                    print(widget.storeStatesList);

                    widget.selectedStoreCity.text = '';
                    widget.selectedStoreState.text = value;

                    widget.merchantStoreInfoReq.currentState = (widget
                            .storeStatesList
                            .where((item) => item['stateName'] == value)
                            .toList())[0]['stateId']
                        .toString();

                    // merchantPersonalReq.currentState = value;
                  });
                },
                onSaved: (value) {
                  // widget.merchantStoreInfoReq.currentState = value;
                  // widget.merchantStoreInfoReq.currentState = (widget
                  //         .storeStatesList
                  //         .where((item) =>
                  //             item['tmsMasterCountry'] != null &&
                  //             item['tmsMasterCountry']['countryIsoNumId'] ==
                  //                 356)
                  //         .toList())[0]['stateId']
                  //     .toString();

                  print(widget.merchantStoreInfoReq.currentState);
                },
                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return 'Current state is Mandatory!';
                  }
                  return null;
                },
              ),

              const SizedBox(
                height: 15.0,
              ),

              CustomDropdown(
                enabled: !widget.merchantStoreInfoReq.isBusinessAddSameAsStore,
                titleEnabled: false,
                title: "Current City",
                hintText: "Select City",
                required: true,
                selectedItem:
                    widget.merchantStoreInfoReq.isBusinessAddSameAsStore
                        ? widget.selectedBusinessCity
                        : widget.selectedStoreCity.text != ''
                            ? widget.selectedStoreCity.text
                            : null,
                prefixIcon: Icons.location_city_outlined,

                // itemList: widget.storeCitysList
                //     .map((item) => item['cityName'])
                //     .toList(),

                itemList: widget.storeCitysList
                    .where((item) =>
                        item['stateId'].toString() ==
                        widget.merchantStoreInfoReq.currentState.toString())
                    .map((item) => item['cityName'])
                    .toList(),

                //cityList.map((e) => e['citName']).toList(),
                onChanged: (value) {
                  // print(citysList[value]);
                  setState(() {
                    print(widget.storeCitysList);
                    print(widget.merchantStoreInfoReq.currentState);

                    widget.selectedStoreCity.text = value;

                    // merchantPersonalReq.currentCountry = citysList[value];
                  });
                },
                onSaved: (value) {
                  // widget.merchantStoreInfoReq.currentCity = value;

                  if (widget.storeCitysList
                      .where((element) => element['cityName'] == value)
                      .toList()
                      .isEmpty) return;

                  widget.merchantStoreInfoReq.currentCity = (widget
                          .storeCitysList
                          .where((element) => element['cityName'] == value)
                          .toList())[0]['cityId']
                      .toString();

                  print(widget.merchantStoreInfoReq.currentCity);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Current City is Mandatory!';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 4,
              ),
              //padding added in textfeild
              CustomTextFormField(
                enabled: !widget.merchantStoreInfoReq.isBusinessAddSameAsStore,
                titleEneabled: false,
                title: 'Pin Code',
                hintText: 'Pin Code',
                // enabled: selectedCity != '' && enabledcity ? true : false,
                maxLength: 6,
                required: true,

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pin Code is Mandatory!';
                  }
                  if (!value.isEmpty && value.length < 6) {
                    return 'Minimum 6 digits';
                  }
                  return null;
                },
                controller: widget.merchantStoreInfoReq.isBusinessAddSameAsStore
                    ? widget.businessAddressPinCodeCtrl
                    : widget.storePinCodeCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'\d'))
                ],
                prefixIcon: Icons.map_outlined,
                onSaved: (value) {
                  widget.merchantStoreInfoReq.currentZipCode = value;
                },
              ),

              const SizedBox(height: 20.0),
              // SizedBox(
              //   child: CustomAppButton(
              //     title: 'Previous',
              //     onPressed: () {
              //       widget.previous();
              //     },
              //   ),
              // ),
              SizedBox(
                child: CustomAppButton(
                  title: "Next",
                  onPressed: () {
                    storeFormKey.currentState!.save();
                    if (storeFormKey.currentState!.validate()) {
                      if (widget.storeFrontImage.text == "" ||
                          widget.insideStoreImage.text == "") {
                        alertWidget.error("Please Upload all images");
                      } else {
                        setState(() {
                          widget.next();
                        });
                      }
                      print(jsonEncode(widget.merchantStoreInfoReq.toJson()));
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
          if (type == 'storeFrontImage') {
            widget.storeFrontImage.text = result.path;
          } else if (type == 'insideStoreImage') {
            widget.insideStoreImage.text = result.path;
          }
        } else {
          alertWidget.failure(context, 'Failure', Constants.oneMbErrorMessage);

          if (type == 'storeFrontImage') {
            widget.storeFrontImage.text = '';
          } else if (type == 'insideStoreImage') {
            widget.insideStoreImage.text = '';
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
