import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../../config/config.dart';
import '../../../models/user_model.dart';
import '../../../services/services.dart';
import '../../../widgets/widget.dart';
import 'view_document.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String customerId = '';
  String role = '';
  List data = [];
  List mDetails = [];
  bool _isLoading = true;
  UserServices apiService = UserServices();
  final TextEditingController _dateController = TextEditingController();
  bool update = false;
  UpdateDetails updateDetails = UpdateDetails();
  AlertService alertWidget = AlertService();
  PickedFile? image;
  String profileImage = '';
  @override
  void initState() {
    getUser();
    getCustomerData();
    super.initState();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role').toString();
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  Widget profilePicture() {
    return profileImage != ''
        ? Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2,
                        color: Theme.of(context).scaffoldBackgroundColor),
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 10))
                    ],
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: FileImage(
                        File(profileImage),
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 4,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          cameraPhotoDialog();
                          // _showChoiceDialog(context);
                        },
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    )),
              ],
            ),
          )
        : Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 4,
                        color: Theme.of(context).scaffoldBackgroundColor),
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 10))
                    ],
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: data[0]['profilePicture'] == null
                          ? const AssetImage(Constants.emptyProfileImage)
                              as ImageProvider
                          : NetworkImage(
                              Validators.urlDecrypt(data[0]['profilePicture'])),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 4,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          cameraPhotoDialog();
                          // _showChoiceDialog(context);
                        },
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    )),
              ],
            ),
          );
  }

  cameraPhotoDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogBox(onCameraBTNPressed: () {
          uploadAction(ImageSource.camera);
        }, onGalleryBTNPressed: () {
          uploadAction(ImageSource.gallery);
        });
      },
    );
  }

  uploadAction(ImageSource src) async {
    final ImagePicker picker = ImagePicker();
    XFile? photo = await picker.pickImage(source: src);
    if (photo != null) {
      _cropImage(File(photo.path));
    }
  }

  _cropImage(pickedFile) async {
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
      compress(File(path));
    }
  }

  compress(File file) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.path}.jpg',
      quality: 60,
    );
    if (result != null) {
      setState(() {
        profileImage = result.path;
      });
      updateProfile(profileImage);
    }
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
          title: 'Profile',
        ),
        body: _isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      profilePicture(),
                      const SizedBox(height: 15),
                      Text("${data[0]['firstName']} ${data[0]['lastName']}"),
                      const SizedBox(height: 5),
                      Text(
                          "${data[0]['mobileCountryCode'] + data[0]['mobileNumber']}"),
                      const SizedBox(height: 5),
                      Text("${data[0]['emailId']}"),
                      customDivider(),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Profile Settings"),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, 'updatePersonalInfo',
                              arguments: {'params': mDetails, 'role': role});
                        },
                        child: ListTile(
                          dense: true,
                          title: Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                        ),
                      ),
                      // customDivider(),
                      if (role == "MERCHANT")
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, 'updateMerchantInfo',
                                arguments: {'params': mDetails});
                          },
                          child: ListTile(
                            title: Text(
                              'Merchant Information',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            trailing: const Icon(Icons.keyboard_arrow_right),
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, 'updateKycInfo',
                              arguments: {'params': data[0]});
                        },
                        child: ListTile(
                          title: Text(
                            'KYC Information',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          trailing: data[0]['customerFrontKycImg'] == null ||
                                  data[0]['customerBackKycImg'] == null
                              ? const Text(
                                  'Add',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                )
                              : const Text(
                                  'Preview',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                ),
                        ),
                      ),
                      customDivider(),
                      if (role == "MERCHANT") ...merchant().toList(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  viewDoc(image, String title) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) {
          return ViewDocument(
            title: title,
            params: image,
          );
        },
        fullscreenDialog: true));
  }

  List<Widget> merchant() {
    var du = mDetails[0];
    var docArray = Validators.urlDecrypt(du['merchantDocs']).split(',');
    // print(docArray);
    return [
      const Align(
        alignment: Alignment.centerLeft,
        child: Text("Uploaded Documents"),
      ),
      GestureDetector(
        onTap: () {
          viewDoc(du, 'National ID');
        },
        child: ListTile(
          title: Text(
            'National ID',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          trailing: const Text(
            'Preview',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          viewDoc(du, 'Trade License');
        },
        child: ListTile(
          title: Text(
            'Trade License',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          trailing: const Text(
            'Preview',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          if (!docArray.asMap().containsKey(3)) {
            Navigator.pushNamed(context, 'documentReUploads', arguments: {
              'params': {
                "key": "Cancelled Cheque",
                "content": du['merchantDocs'],
                "customerFrontKycImg": du['customer']['customerFrontKycImg'],
                "customerBackKycImg": du['customer']['customerBackKycImg'],
              }
            });
          } else {
            viewDoc(du, 'Cancelled Cheque');
          }
        },
        child: ListTile(
          title: Text(
            'Cancelled Cheque',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          trailing: Text(
            !docArray.asMap().containsKey(3) ? "Upload" : "Preview",
            style: const TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, 'updateLocation',
              arguments: {'params': mDetails});
        },
        child: ListTile(
          title: Text(
            'Update Location',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
        ),
      ),
      // customDivider(),
    ];
  }

  Widget listWidget(title, desc) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      subtitle: Text(
        desc,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget customDivider() {
    return const Divider(
      indent: 10,
      endIndent: 10,
    );
  }

  getCustomerData() async {
    setLoading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    customerId = prefs.getString('custId').toString();
    apiService.getUserDetails(customerId).then((result) {
      var response = jsonDecode(result.body);
      if (result.statusCode == 200 || result.statusCode == 201) {
        setState(() {
          data.clear();
          data = [response['customer']];
          mDetails = [response];
          if (data[0]['dob'] != null) {
            var a = DateFormat('yyyy-MM-dd').parse(data[0]['dob'].toString());
            _dateController.text = DateFormat('dd-MM-yyyy').format(a);
          }
          setLoading(false);
        });
      } else {
        setLoading(false);
        setState(() {
          data = [];
        });
      }
    });
  }

  updateProfile(image) async {
    //TODO: FILE SIZE IN GLOBALLY
    final file = File(image);
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb < 1) {
      setLoading(true);
      apiService.uploadProfileImage(image).then((response) {
        var decodeData = jsonDecode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (decodeData['responseCode'].toString() == "00") {
            setLoading(false);
            alertWidget.success(
                context, 'Success', decodeData['responseMessage']);
            Navigator.pushNamed(context, 'myAccount');
          } else {
            setLoading(false);
            alertWidget.failure(context, 'Failure', decodeData['message']);
          }
        } else {
          setLoading(false);
          alertWidget.failure(context, 'Failure', decodeData['message']);
        }
      });
    } else {
      setState(() {
        profileImage = '';
      });
      alertWidget.failure(context, 'Failure', Constants.oneMbErrorMessage);
    }
  }
}
