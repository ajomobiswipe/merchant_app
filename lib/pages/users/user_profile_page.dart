import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/services/user_services.dart';
import 'package:sifr_latest/widgets/app_widget/app_button.dart';

import '../../models/user_model.dart';
import '../../widgets/app/CustomDialogBox.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/form_field/custom_text.dart';
import '../../widgets/loading.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  List data = [];
  late String customerId;
  late bool _isLoading = true;
  bool update = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UpdateDetails updateDetails = UpdateDetails();
  UserServices apiService = UserServices();
  final TextEditingController _dateController = TextEditingController();
  AlertService alertWidget = AlertService();
  PickedFile? image;

  @override
  void initState() {
    getCustomerData();
    super.initState();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWidget(
          title: "Update Profile",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                child: SafeArea(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('PERSONAL DETAILS',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  )),
                            ),
                            update
                                ? const Text("")
                                : Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            update = true;
                                          });
                                        },
                                        child: Text('Update',
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationThickness: 2,
                                              fontSize: 14.0,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ))),
                                  ),
                          ],
                        ),
                        image != null
                            ? Center(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 130,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 4,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor),
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              offset: const Offset(0, 10))
                                        ],
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image:
                                                FileImage(File(image!.path))),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              width: 4,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                            ),
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              _showChoiceDialog(context);
                                            },
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
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
                                      width: 130,
                                      height: 130,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 4,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor),
                                        boxShadow: [
                                          BoxShadow(
                                              spreadRadius: 2,
                                              blurRadius: 10,
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              offset: const Offset(0, 10))
                                        ],
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: data[0]['profilePicture'] ==
                                                  null
                                              ? const AssetImage(Constants
                                                      .emptyProfileImage)
                                                  as ImageProvider
                                              : NetworkImage(
                                                  data[0]['profilePicture']),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              width: 4,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                            ),
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              _showChoiceDialog(context);
                                            },
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 10),
                        firstName(),
                        nickName(),
                        mobileNumber(),
                        emailId(),
                        dob(),
                        address(),
                        country(),
                        city(),
                        const SizedBox(height: 10),
                        update
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: AppButton(
                                  title: 'Update',
                                  onPressed: () {
                                    submit();
                                  },
                                ),
                              )
                            : Container(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              )));
  }

  firstName() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: CustomTextFormField(
              title: 'First Name',
              initialValue: data[0]['firstName'],
              required: true,
              prefixIcon: LineAwesome.user_circle,
              enabled: false,
              keyboardType: TextInputType.text,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'First Name is Mandatory!';
                }
                return null;
              },
              onSaved: (value) {
                updateDetails.firstName = value;
              },
              onFieldSubmitted: (value) {
                //updateDetails.firstName = value;
              },
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: CustomTextFormField(
              title: 'Last Name',
              initialValue: data[0]['lastName'],
              required: true,
              prefixIcon: LineAwesome.user_circle,
              enabled: false,
              keyboardType: TextInputType.text,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Last Name is Mandatory!';
                }
                return null;
              },
              onSaved: (value) {
                updateDetails.lastName = value;
              },
              onFieldSubmitted: (value) {
                // updateDetails.lastName = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  mobileNumber() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CustomTextFormField(
        title: 'Mobile Number',
        initialValue: data[0]['mobileCountryCode'] + data[0]['mobileNumber'],
        required: false,
        prefixIcon: FontAwesome.mobile_solid,
        enabled: false,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          updateDetails.mobileNumber = value;
        },
        onFieldSubmitted: (value) {
          //updateDetails.mobileNumber = value;
        },
      ),
    );
  }

  emailId() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CustomTextFormField(
        title: 'Email ID',
        initialValue: data[0]['emailId'],
        required: false,
        prefixIcon: Icons.alternate_email,
        enabled: false,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          updateDetails.emailId = value;
        },
        onFieldSubmitted: (value) {
          //updateDetails.emailId = value;
        },
      ),
    );
  }

  dob() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: CustomTextFormField(
          controller: _dateController,
          title: 'Date of Birth',
          required: false,
          enabled: false,
          readOnly: true,
          prefixIcon: FontAwesome.calendar,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              initialDatePickerMode: DatePickerMode.day,
              initialEntryMode: DatePickerEntryMode.calendarOnly,
              context: context,
              initialDate: DateTime(DateTime.now().year - 18,
                  DateTime.now().month, DateTime.now().day),
              firstDate: DateTime(DateTime.now().year - 118),
              lastDate: DateTime(DateTime.now().year - 18, DateTime.now().month,
                  DateTime.now().day),
            );
            if (pickedDate != null) {
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(pickedDate);
              setState(() {
                updateDetails.dob = formattedDate;
                _dateController.text = formattedDate;
              });
            } else {}
          },
        ));
  }

  nickName() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CustomTextFormField(
        title: 'Nick Name',
        initialValue: data[0]['nickName'],
        required: false,
        prefixIcon: LineAwesome.user_circle,
        enabled: update ? true : false,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          updateDetails.nickName = value;
        },
        onFieldSubmitted: (value) {
          //updateDetails.address = value;
        },
      ),
    );
  }

  address() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CustomTextFormField(
        title: 'Street Address',
        initialValue: data[0]['address'],
        required: false,
        prefixIcon: Icons.location_city,
        enabled: update ? true : false,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          updateDetails.address = value;
        },
        onFieldSubmitted: (value) {
          //updateDetails.address = value;
        },
      ),
    );
  }

  country() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: CustomTextFormField(
              title: 'City',
              initialValue: data[0]['city'],
              required: false,
              prefixIcon: Icons.location_city,
              enabled: update ? true : false,
              keyboardType: TextInputType.text,
              onSaved: (value) {
                updateDetails.city = value;
              },
              onFieldSubmitted: (value) {
                // updateDetails.city = value;
              },
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: CustomTextFormField(
              title: 'State',
              initialValue: data[0]['state'],
              required: false,
              prefixIcon: Icons.location_city,
              enabled: update ? true : false,
              keyboardType: TextInputType.text,
              onSaved: (value) {
                updateDetails.state = value;
              },
              onFieldSubmitted: (value) {
                //updateDetails.state = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  city() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: CustomTextFormField(
              title: 'Country',
              initialValue: data[0]['country'],
              required: false,
              prefixIcon: Icons.location_city,
              enabled: update ? true : false,
              keyboardType: TextInputType.text,
              onSaved: (value) {
                updateDetails.country = value;
              },
              onFieldSubmitted: (value) {
                //updateDetails.country = value;
              },
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: CustomTextFormField(
              title: 'Makani No',
              initialValue: data[0]['postalCode'],
              required: false,
              maxLength: 6,
              prefixIcon: Icons.location_on,
              enabled: update ? true : false,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              keyboardType: TextInputType.number,
              onSaved: (value) {
                updateDetails.postalCode = value;
              },
              onFieldSubmitted: (value) {
                //updateDetails.postalCode = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  getCustomerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    customerId = prefs.getString('custId')!;
    apiService.getUserDetails(customerId).then((result) {
      var response = jsonDecode(result.body);
      setLoading(true);
      if (result.statusCode == 200 || result.statusCode == 201) {
        setState(() {
          data.clear();
          data = [response['customer']];
          if (data[0]['dob'] != null) {
            var a = DateFormat('yyyy-MM-dd').parse(data[0]['dob'].toString());
            _dateController.text = DateFormat('dd-MM-yyyy').format(a);
          }
          setLoading(false);
        });
      } else {
        setState(() {
          data = [];
        });
      }
    });
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setLoading(true);
      apiService.updateUserDetails(updateDetails).then((result) {
        var response = jsonDecode(result.body);
        setLoading(false);
        if (result.statusCode == 200 || result.statusCode == 201) {
          if (response['responseCode'] == '00') {
            Navigator.pushNamed(context, 'myAccount');
            alertWidget.success(
                context, 'Success', response['responseMessage']);
          } else {
            alertWidget.failure(
                context, 'Failure', response['responseMessage']);
          }
        } else {
          alertWidget.failure(context, 'Failure', response['message']);
        }
      });
    }
  }

  Future<void> _showChoiceDialog(BuildContext context1) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(onCameraBTNPressed: () {
            _openCamera(context1, ImageSource.camera);
          }, onGalleryBTNPressed: () {
            _openGallery(context1, ImageSource.gallery);
          });
        });
  }

  void _openCamera(BuildContext context, ImageSource camera) async {
    final pickedFile = await ImagePicker()
        .pickImage(source: camera, maxHeight: 480, maxWidth: 640);
    if (pickedFile != null) {
      setState(() {
        image = pickedFile as PickedFile?;
      });
      updateProfile();
    }
  }

  void _openGallery(BuildContext context, ImageSource gallery) async {
    final pickedFile = await ImagePicker().pickImage(
      source: gallery,
    );
    setState(() {
      image = pickedFile as PickedFile?;
    });
    updateProfile();
  }

  updateProfile() async {
    apiService.uploadProfileImage(image!.path).then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
        } else {
          //alertWidget.failure(context, 'Failure', decodeData['message']);
        }
      } else {
        //alertWidget.failure(context, 'Failure', decodeData['message']);
      }
    });
  }
}
