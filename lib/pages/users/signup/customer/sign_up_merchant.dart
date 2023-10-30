import 'dart:convert';
import 'dart:io';
import 'package:badges/badges.dart' as badge;
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sifr_latest/widgets/Forms/Business_info.dart';
import 'package:sifr_latest/widgets/Forms/document_uploads.dart';
import 'package:sifr_latest/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/config.dart';
import '../../../../models/models.dart';
import '../../../../providers/providers.dart';
import '../../../../services/services.dart';
import '../../../../widgets/Forms/kyc_form.dart';
import '../../../../widgets/Forms/security_form.dart';
import '../../../../widgets/widget.dart';
import 'terms_and_conditions.dart';

class MerchantSignup extends StatefulWidget {
  const MerchantSignup({Key? key}) : super(key: key);

  @override
  State<MerchantSignup> createState() => _MerchantSignupState();
}

class _MerchantSignupState extends State<MerchantSignup> {
  bool _isLoading = false;
  int position = 0;
  bool accept = false;
  final double _lat = 13.05186999479027;
  final double _lng = 80.22561586938588;
  FocusNode myFocusNode = FocusNode();

  AlertService alertWidget = AlertService();
  CustomAlert customAlert = CustomAlert();
  UserServices userServices = UserServices();
  MerchantRequestModel requestModel = MerchantRequestModel();

  // --------- FORM KEYs ------------
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> personalFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  /// PERSONAL INFORMATION
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _mobileCodeController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String profilePic = '';
  bool enabledLast = false;
  bool enabledNick = false;
  bool enabledMobile = false;
  bool enabledEmail = false;
  bool enabledDob = false;
  bool mobile = false;
  bool enabledCountry = false;
  bool enabledState = false;
  bool enabledcity = false;
  bool email = false;
  String emailCheck = '';
  String mobileNoCheck = '';
  String? mobileNoCheckMessage;
  TextStyle? style;
  String countryCode = 'AE';
  late Country _country =
      countries.firstWhere((element) => element.code == countryCode);
  List countryList = [];
  List stateList = [];
  List cityList = [];

  /// LOGIN INFORMATION
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cnfPasswordCtrl = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  String userCheck = '';
  bool showVerify = true;
  bool showVerify1 = true;
  bool emailVerify = false;

  bool hidePassword = true;
  bool hideCnfPassword = true;
  bool hidePin = true;
  bool hideCnfPin = true;
  bool enabledUsername = false;
  bool enabledPassword = false;
  bool enabledConfirmPass = false;
  bool enabledPin = false;
  bool enabledConfirmPin = false;
  late String userCheckMessage = '';
  bool userVerify = false;

  /// SECURITY QUESTION INFO
  final TextEditingController _answer1Controller = TextEditingController();
  final TextEditingController _answer2Controller = TextEditingController();
  final TextEditingController _answer3Controller = TextEditingController();
  List securityQuestionList = [];
  final TextEditingController selectedItem1 = TextEditingController();
  final TextEditingController selectedItem2 = TextEditingController();
  final TextEditingController selectedItem3 = TextEditingController();
  String selectedCountries = '';
  String selectedCity = '';
  String selectedState = '';
  final TextEditingController selectedMcc = TextEditingController();
  final TextEditingController selectedBusinessType = TextEditingController();

  List list = [];
  bool enabledSecurity2 = false;
  bool enabledSecurity3 = false;
  bool enabledAnswer1 = false;
  bool enabledAnswer2 = false;
  bool enabledAnswer3 = false;
  final Uri _url = Uri.parse('https://sifr.ae/contact.php');

  /// MERCHANT INFO
  late List mccList = [];
  final TextEditingController _merchantNameCtrl = TextEditingController();
  final TextEditingController _companyRegCtrl = TextEditingController();
  final TextEditingController _nationalIdCtrl = TextEditingController();
  final TextEditingController _nationalIdExpiryCtrl = TextEditingController();
  final TextEditingController _merchantZipCodeCtrl = TextEditingController();
  final TextEditingController _tradeLicenseCtrl = TextEditingController();
  final TextEditingController _tradeLicenseExpiryCtrl = TextEditingController();

  /// DOCUMENTS INFO
  final TextEditingController tradeLicense = TextEditingController();
  final TextEditingController nationalIdFront = TextEditingController();
  final TextEditingController nationalIdBack = TextEditingController();
  final TextEditingController cancelCheque = TextEditingController();

  /// KYC INFORMATION
  final TextEditingController kycFront = TextEditingController();
  final TextEditingController kycBack = TextEditingController();

  var dobSelectedDt = DateTime(
      DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);
  var tradeSelectedDt = DateTime.now();
  var nationalSelectedDt = DateTime.now();

  @override
  void initState() {
    DevicePermission().checkPermission();
    getCurrentPosition();
    getSecurityQuestions();
    loadMcc();
    getCountry();
    getToken();
    super.initState();
  }

  getToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
    } else {
      token = '';
    }
    setState(() {
      requestModel.notificationToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Form(
        key: _formKey,
        child: items(position),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool? exitResult = customAlert.displayDialogConfirm(
        context,
        'Please confirm',
        'Do you want to quit your registration?',
        onTapConfirm);
    return exitResult ?? false;
  }

  onTapConfirm() {
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  }

  items(int position) {
    if (position == 0) {
      return mainControl('Personal Information', personalInfo());
    } else if (position == 1) {
      return mainControl('Login Information', loginInfo());
    } else if (position == 2) {
      var isDarkMode = context.isDarkMode;
      return SecurityForm(
        selectedItem1: selectedItem1,
        selectedItem2: selectedItem2,
        selectedItem3: selectedItem3,
        registerRequestModel: requestModel,
        answer1: _answer1Controller,
        answer2: _answer2Controller,
        answer3: _answer3Controller,
        securityQuestionList: securityQuestionList,
        darkmode: isDarkMode,
        next: securityNext,
        previous: securityPrevious,
      );
    } else if (position == 3) {
      return BusinessInfo(
          previous: businessPrevious,
          next: businessNext,
          merchantNameCtrl: _merchantNameCtrl,
          companyRegCtrl: _companyRegCtrl,
          nationalIdCtrl: _nationalIdCtrl,
          nationalIdExpiryCtrl: _nationalIdExpiryCtrl,
          tradeLicenseCtrl: _tradeLicenseCtrl,
          tradeLicenseExpiryCtrl: _tradeLicenseExpiryCtrl,
          selectedMcc: selectedMcc,
          selectedBusinessType: selectedBusinessType,
          requestModel: requestModel,
          mccList: mccList,
          tradeSelectedDt: tradeSelectedDt,
          nationalSelectedDt: nationalSelectedDt);
    } else if (position == 4) {
      return DocumentUploads(
          previous: documentPrevious,
          next: documentNext,
          tradeLicense: tradeLicense,
          nationalIdFront: nationalIdFront,
          cancelCheque: cancelCheque,
          nationalIdBack: nationalIdBack);
    } else if (position == 5) {
      return KYCForm(
          previous: kycPrevious,
          next: kycNext,
          kycFrontImage: kycFront,
          kycBackImage: kycBack);
    } else if (position == 6) {
      return mainControl('Review', review());
    }
  }

  businessNext() {
    setState(() {
      position = 4;
    });
  }

  businessPrevious() {
    setState(() {
      position = 2;
    });
  }

  securityNext() {
    setState(() {
      position = 3;
    });
  }

  securityPrevious() {
    setState(() {
      _passwordController.clear();
      _cnfPasswordCtrl.clear();
      _pinController.clear();
      _confirmPinController.clear();
      position = 1;
    });
  }

  Widget mainControl(String title, Widget child) {
    return _isLoading
        ? const LoadingWidget()
        : Scaffold(
            appBar: AppBarWidget(
              action: false,
              title: title,
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: child,
              ),
            ),
          );
  }

  /// PERSONAL INFORMATION
  Widget personalInfo() {
    return Form(
        key: personalFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            profilePicture(),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: CustomTextFormField(
                    title: 'First Name',
                    controller: _firstNameController,
                    required: true,
                    maxLength: 26,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))
                    ],
                    prefixIcon: LineAwesome.user_circle,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First Name is Mandatory!';
                      }
                      if (value.length < 3) {
                        return 'Minimum 3 characters';
                      }
                      return null;
                    },
                    onChanged: (String value) {
                      if (value.isEmpty || value.length < 3) {
                        setState(() {
                          enabledLast = false;
                        });
                      } else {
                        setState(() {
                          enabledLast = true;
                        });
                      }
                    },
                    onSaved: (value) {
                      requestModel.firstName = value;
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomTextFormField(
                    title: 'Last Name',
                    controller: _lastNameController,
                    required: true,
                    textCapitalization: TextCapitalization.words,
                    enabled: _firstNameController.text.isEmpty ||
                            _firstNameController.text.length < 3
                        ? enabledLast = false
                        : enabledLast = true,
                    prefixIcon: LineAwesome.user_circle,
                    validator: (value) {
                      value = value.trim();
                      if (value == null || value.isEmpty) {
                        return 'Last Name is Mandatory!';
                      }
                      if (value.length < 3) {
                        return 'Minimum 3 characters';
                      }
                      if (!Validators.isValidName(value)) {
                        return 'Invalid Last Name';
                      }
                      return null;
                    },
                    onChanged: (String value) {
                      value = value.trim();
                      setState(() {
                        value.isEmpty ||
                                value.length < 3 ||
                                !Validators.isValidName(value)
                            ? enabledDob = false
                            : enabledDob = enabledLast;
                      });
                    },
                    onSaved: (value) {
                      requestModel.lastName = value;
                    },
                    onFieldSubmitted: (value) {
                      _lastNameController.text = value.trim();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: CustomTextFormField(
                    title: 'Nickname',
                    enabled: _lastNameController.text.trim().isEmpty ||
                            _lastNameController.text.trim().length < 3 ||
                            !Validators.isValidName(
                                _lastNameController.text.trim())
                        ? false
                        : true,
                    controller: _nickNameController,
                    onTap: () {
                      _lastNameController.text =
                          _lastNameController.text.trim();
                    },
                    maxLength: 12,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.user,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      if (!Validators.isValidName(value)) {
                        return 'Invalid Nick Name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      requestModel.nickName = value;
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomTextFormField(
                    controller: _dateController,
                    title: 'Date of Birth',
                    required: true,
                    readOnly: true,
                    errorMaxLines: 2,
                    maxLength: 26,
                    helperText: Constants.dobMessage,
                    helperStyle: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).primaryColor),
                    prefixIcon: FontAwesome.calendar,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Date of Birth is Mandatory!';
                      }
                      return null;
                    },
                    onTap: () async {
                      _lastNameController.text =
                          _lastNameController.text.trim();
                      DateTime? pickedDate = await showDatePicker(
                        initialDatePickerMode: DatePickerMode.day,
                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                        context: context,
                        initialDate: dobSelectedDt,
                        firstDate: DateTime(DateTime.now().year - 118),
                        lastDate: DateTime(DateTime.now().year - 18,
                            DateTime.now().month, DateTime.now().day),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                        setState(() {
                          dobSelectedDt = pickedDate;
                          requestModel.dob = formattedDate;
                          _dateController.text = formattedDate;
                          if (_dateController.text.isEmpty) {
                            enabledMobile = false;
                          } else {
                            enabledMobile = enabledDob;
                          }
                        });
                      } else {}
                    },
                    enabled: _lastNameController.text.trim().isEmpty ||
                            _lastNameController.text.trim().length < 3 ||
                            !Validators.isValidName(
                                _lastNameController.text.trim())
                        ? enabledDob = false
                        : enabledDob = enabledLast,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            CustomMobileField(
              controller: _mobileNoController,
              keyboardType: TextInputType.number,
              title: 'Mobile Number',
              enabled: _dateController.text.isEmpty
                  ? enabledMobile = false
                  : enabledMobile = enabledDob,
              required: true,
              helperText: mobileNoCheckMessage,
              helperStyle: style,
              prefixIcon: FontAwesome.mobile,
              countryCode: countryCode,
              onChanged: (phone) {
                requestModel.mobileNumber = phone.number;
                requestModel.mobileCountryCode = phone.countryCode;
                setState(() {
                  if (phone.number.isNotEmpty &&
                      (phone.number.length >= _country.minLength &&
                          phone.number.length <= _country.maxLength)) {
                    getEmailIdOrMobileNo('mobileNumber', phone.number);
                  } else {
                    mobile = false;
                    enabledEmail = false;
                  }
                });
              },
              onCountryChanged: (country) {
                setState(() {
                  countryCode = country.code;
                  _country = country;
                  _mobileCodeController.text = countryCode;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            emailWidget(),
            const SizedBox(
              height: 10.0,
            ),
            CustomDropdown(
              title: "Country",
              required: true,
              enabled: email &&
                      enabledEmail &&
                      _emailController.text.isNotEmpty &&
                      Validators.isValidEmail(_emailController.text)
                  ? enabledCountry = true
                  : enabledCountry = false,
              selectedItem: selectedCountries != '' ? selectedCountries : null,
              prefixIcon: Icons.location_city_outlined,
              itemList: countryList.map((e) => e['ctyName']).toList(),
              onChanged: (value) {
                List selectedCountry = countryList
                    .where((element) => element['ctyName'] == value)
                    .toList();
                String id = selectedCountry[0]['id'].toString();
                String currencyCode = selectedCountry[0]['currencyCode'];
                getState(id);
                setState(() {
                  selectedCountries = value;
                  requestModel.country = value;
                  requestModel.currencyId = currencyCode;
                });
              },
              onSaved: (value) {
                requestModel.country = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Country is Mandatory!';
                }
                return null;
              },
            ),
            const SizedBox(height: 10.0),
            CustomDropdown(
              title: "State",
              required: true,
              enabled: selectedCountries != '' && enabledCountry
                  ? enabledState = true
                  : enabledState = false,
              selectedItem: selectedState != '' ? selectedState : null,
              prefixIcon: Icons.location_city_outlined,
              itemList: stateList.map((e) => e['staName']).toList(),
              onChanged: (value) {
                List state = stateList
                    .where((element) => element['staName'] == value)
                    .toList();
                String id = state[0]['id'].toString();
                getCity(id);
                setState(() {
                  selectedState = value;
                  requestModel.state = value;
                });
              },
              onSaved: (value) {
                requestModel.state = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'State is Mandatory!';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            CustomDropdown(
              title: "City",
              enabled: selectedState != '' && enabledState
                  ? enabledcity = true
                  : enabledcity = false,
              required: true,
              selectedItem: selectedCity != '' ? selectedCity : null,
              prefixIcon: Icons.location_city_outlined,
              itemList: cityList.map((e) => e['citName']).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                  requestModel.city = value;
                });
              },
              onSaved: (value) {
                requestModel.city = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'City is Mandatory!';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            CustomTextFormField(
              title: 'Makani No',
              enabled: selectedCity != '' && enabledcity ? true : false,
              maxLength: 10,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Makani No is Mandatory!';
                }
                if (!value.isEmpty && value.length < 10) {
                  return 'Minimum 10 digits';
                }
                return null;
              },
              controller: _merchantZipCodeCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'\d'))
              ],
              prefixIcon: Icons.map_outlined,
              onSaved: (value) {
                requestModel.merchantZipCode = value;
                requestModel.zipCode = value;
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                SizedBox(
                  width: 150,
                  child: AppButton(
                    title: "Next",
                    onPressed: () async {
                      getCurrentPosition();
                      if (personalFormKey.currentState!.validate() &&
                          mobileNoCheck == 'false' &&
                          emailCheck == 'false' &&
                          email) {
                        personalFormKey.currentState!.save();
                        setState(() {
                          position = 1;
                        });
                      }
                    },
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
          ],
        ));
  }

  handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Geolocator.openLocationSettings();
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        openAppSettings();
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      openAppSettings();
      return false;
    }
    return true;
  }

  getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        requestModel.latitude = position.latitude;
        requestModel.longitude = position.longitude;
      });
      return position;
    }).catchError((e) {
      debugPrint(e);
    });
  }

  getCountry() {
    userServices.getCountry().then((response) async {
      if (response.statusCode == 200 || response.statusCode == 201) {
        var decodeData = jsonDecode(response.body);
        if (decodeData['responseType'] == "S") {
          setState(() {
            countryList = decodeData['responseValue']['list'];
            if (countryList.isNotEmpty) {
              selectedCountries = countryList[0]['ctyName'].toString();
              requestModel.country = selectedCountries;
              requestModel.currencyId =
                  countryList[0]['currencyCode'].toString();
              getState(countryList[0]['id'].toString());
            }
          });
        }
      }
    });
  }

  getState(countryId) {
    userServices.getState(countryId).then((response) async {
      if (response.statusCode == 200 || response.statusCode == 201) {
        var decodeData = jsonDecode(response.body);
        if (decodeData['responseType'] == "S") {
          setState(() {
            stateList = decodeData['responseValue']['list'];
            if (stateList.isNotEmpty) {
              selectedState = stateList[0]['staName'].toString();
              requestModel.state = selectedState;
              getCity(stateList[0]['id'].toString());
            }
          });
        }
      }
    });
  }

  getCity(stateId) {
    userServices.getCity(stateId).then((response) async {
      if (response.statusCode == 200 || response.statusCode == 201) {
        var decodeData = jsonDecode(response.body);
        if (decodeData['responseType'] == "S") {
          setState(() {
            cityList = decodeData['responseValue']['list'];
            if (cityList.isNotEmpty) {
              selectedCity = cityList[0]['citName'].toString();
              requestModel.city = selectedCity;
            }
          });
        }
      }
    });
  }

  profilePicture() {
    return Center(
      child: Stack(
        children: [
          ClipOval(
            child: profilePic == ''
                ? Image.asset(
                    "assets/screen/default-1.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  )
                : Image.file(
                    File(profilePic),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: buildEditIcon(Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 5,
          child: GestureDetector(
            child: const Icon(
              Icons.add_a_photo,
              color: Colors.white,
              size: 20,
            ),
            onTap: () async {
              cameraPhotoDialog(context, 'profilePic');
            },
          ),
        ),
      );

  Widget loginInfo() {
    return Form(
        key: loginFormKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              userNameWidget(),
              const SizedBox(height: 30.0),
              CustomTextFormField(
                controller: _passwordController,
                title: 'Password',
                required: true,
                enabled: _userNameController.text.isEmpty ||
                        userCheck == "true" ||
                        !userVerify ||
                        !RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                            .hasMatch(_userNameController.text)
                    ? enabledPassword = false
                    : enabledPassword = true,
                prefixIcon: _passwordController.text.isNotEmpty &&
                        _passwordController.text == _cnfPasswordCtrl.text
                    ? Icons.check_circle_outline
                    : Icons.password,
                iconColor: _passwordController.text.isNotEmpty &&
                        _passwordController.text == _cnfPasswordCtrl.text
                    ? Colors.green
                    : null,
                obscureText: hidePassword,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.visiblePassword,
                suffixIconTrue: true,
                maxLength: 14,
                suffixIcon:
                    hidePassword ? Icons.visibility : Icons.visibility_off,
                suffixIconOnPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                onChanged: (String value) {
                  setState(() {
                    if (value.isEmpty || !Validators.isPassword(value)) {
                      enabledConfirmPass = false;
                    } else {
                      enabledConfirmPass = enabledPassword;
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is Mandatory!';
                  }
                  if (!Validators.isPassword(value)) {
                    return Constants.passwordError;
                  }
                  return null;
                },
                onSaved: (value) {
                  requestModel.password = value;
                },
              ),
              const SizedBox(height: 10.0),
              CustomTextFormField(
                controller: _cnfPasswordCtrl,
                title: 'Confirm Password',
                required: true,
                maxLength: 14,
                enabled: _passwordController.text.isEmpty ||
                        !Validators.isPassword(_passwordController.text)
                    ? enabledConfirmPass = false
                    : enabledConfirmPass = enabledPassword,
                prefixIcon: _passwordController.text.isNotEmpty &&
                        _passwordController.text == _cnfPasswordCtrl.text
                    ? Icons.check_circle_outline
                    : Icons.password,
                iconColor: _passwordController.text.isNotEmpty &&
                        _passwordController.text == _cnfPasswordCtrl.text
                    ? Colors.green
                    : null,
                obscureText: hideCnfPassword,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.visiblePassword,
                onChanged: (String value) {
                  setState(() {
                    if (value.isEmpty || value != _passwordController.text) {
                      enabledPin = false;
                    } else {
                      enabledPin = enabledConfirmPass;
                    }
                  });
                },
                suffixIconTrue: true,
                suffixIcon:
                    hideCnfPassword ? Icons.visibility : Icons.visibility_off,
                suffixIconOnPressed: () {
                  setState(() {
                    hideCnfPassword = !hideCnfPassword;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm Password is Mandatory!';
                  }
                  if (value != _passwordController.text) {
                    return Constants.passwordMissMatch;
                  }
                  return null;
                },
                onSaved: (value) {
                  requestModel.confirmPassword = value;
                },
              ),
              const SizedBox(
                height: 30.0,
              ),
              CustomTextFormField(
                controller: _pinController,
                title: 'Login PIN',
                required: true,
                maxLength: 4,
                enabled: _cnfPasswordCtrl.text.isEmpty ||
                        _cnfPasswordCtrl.text != _passwordController.text
                    ? enabledPin = false
                    : enabledPin = enabledConfirmPass,
                prefixIcon: _pinController.text.isNotEmpty &&
                        _pinController.text == _confirmPinController.text
                    ? Icons.check_circle_outline
                    : Icons.pin,
                iconColor: _pinController.text.isNotEmpty &&
                        _pinController.text == _confirmPinController.text
                    ? Colors.green
                    : null,
                //prefixIcon: Icons.pin,
                obscureText: hidePin,
                helperText:
                    _pinController.text.isEmpty ? Constants.pinMessage : null,
                helperStyle: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).primaryColor),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                suffixIconTrue: true,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                suffixIcon: hidePin ? Icons.visibility : Icons.visibility_off,
                suffixIconOnPressed: () {
                  setState(() {
                    hidePin = !hidePin;
                  });
                },
                onChanged: (String value) {
                  setState(() {
                    if (value.isEmpty ||
                        value.length != 4 ||
                        Validators.isConsecutive(value) != -1) {
                      enabledConfirmPin = false;
                    } else {
                      enabledConfirmPin = enabledPin;
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Login PIN is Mandatory!';
                  }
                  if (value.length != 4) {
                    return 'Login PIN must be 4 digits';
                  }
                  if (Validators.isConsecutive(value) != -1) {
                    return 'Login PIN should not be consecutive digits.';
                  }

                  return null;
                },
                onSaved: (value) {
                  requestModel.pin = value;
                },
              ),
              const SizedBox(height: 10.0),
              CustomTextFormField(
                controller: _confirmPinController,
                title: 'Confirm Login PIN',
                required: true,
                maxLength: 4,
                //prefixIcon: Icons.pin,
                prefixIcon: _pinController.text.isNotEmpty &&
                        _pinController.text == _confirmPinController.text
                    ? Icons.check_circle_outline
                    : Icons.pin,
                iconColor: _pinController.text.isNotEmpty &&
                        _pinController.text == _confirmPinController.text
                    ? Colors.green
                    : null,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                obscureText: hideCnfPin,
                enabled: _pinController.text.isEmpty ||
                        _pinController.text.length != 4 ||
                        Validators.isConsecutive(_pinController.text) != -1
                    ? enabledConfirmPin = false
                    : enabledConfirmPin = enabledPin,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                suffixIconTrue: true,
                suffixIcon:
                    hideCnfPin ? Icons.visibility : Icons.visibility_off,
                suffixIconOnPressed: () {
                  setState(() {
                    hideCnfPin = !hideCnfPin;
                  });
                },
                onChanged: (String value) {
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm Login PIN is Mandatory!';
                  }
                  if (value != _pinController.text) {
                    return 'Login PIN & Confirm Login PIN do not match';
                  }
                  if (Validators.isConsecutive(value) != -1) {
                    return 'Login PIN should not be consecutive digits.';
                  }
                  return null;
                },
                onSaved: (value) {
                  requestModel.confirmPin = value;
                },
              ),
              const SizedBox(
                height: 30.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    child: AppButton(
                      title: 'Previous',
                      onPressed: () {
                        // _userNameController.clear();
                        _passwordController.clear();
                        _cnfPasswordCtrl.clear();
                        _pinController.clear();
                        _confirmPinController.clear();
                        setState(() {
                          position = 0;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: AppButton(
                      title: 'Next',
                      width: 0.4,
                      onPressed: () {
                        if (loginFormKey.currentState!.validate()) {
                          loginFormKey.currentState!.save();
                          setState(() {
                            position = 2;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ]));
  }

  getSecurityQuestions() {
    userServices.fetchSecurity().then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseType'].toString() == "S") {
          int? length = decodeData['responseValue']['list'].length;
          for (var i = 0; i < length!; i++) {
            securityQuestionList
                .add(decodeData['responseValue']['list'][i]['question']);
          }
        } else {
          alertWidget.failure(
              context, 'Failure', decodeData['responseValue']['message']);
        }
      } else {
        alertWidget.failure(
            context, 'Failure', decodeData['responseValue']['message']);
      }
    });
  }

  loadMcc() {
    userServices.getMCC().then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'] == "00") {
          setState(() {
            mccList = decodeData['tmsMasterMccInfo'];
          });
        } else {
          setState(() {
            mccList = [];
          });
        }
      } else {
        setState(() {
          mccList = [];
        });
      }
    });
  }

  kycNext() {
    setState(() {
      position = 6;
    });
  }

  kycPrevious() {
    setState(() {
      position = 4;
    });
  }

  documentNext() {
    setState(() {
      position = 5;
    });
  }

  documentPrevious() {
    setState(() {
      position = 3;
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
      final file1 = File(result.path);
      int sizeInBytes = file1.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      setState(() {
        if (sizeInMb < 1) {
          if (type == 'profilePic') {
            profilePic = result.path;
          }
        } else {
          if (type == 'profilePic') {
            profilePic = '';
          }
          alertWidget.failure(context, 'Failure', Constants.oneMbErrorMessage);
        }
      });
    }
  }

  Widget review() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "You are in the final step of registration process. Please click on Get Started below to complete your registration",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 10,
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
            child: ListTile(
              title: Text(
                'Username',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _userNameController.text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Card(
            elevation: 10,
            margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
            child: ListTile(
              title: Text(
                'Email ID',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _emailController.text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Card(
            elevation: 10,
            margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
            child: ListTile(
              title: Text(
                'Mobile Number',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${requestModel.mobileCountryCode} ${_mobileNoController.text}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
            child: Row(
              children: <Widget>[
                Checkbox(
                  value: accept,
                  checkColor: Colors.white,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  onChanged: (bool? newValue) async {
                    if (!accept) {
                      var results =
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                                return const TermsAndConditionPage();
                              },
                              fullscreenDialog: true));
                      setState(() {
                        if (results != null) {
                          accept = results;
                          requestModel.acceptLicense = accept;
                        }
                      });
                    } else {
                      setState(() {
                        accept = false;
                        requestModel.acceptLicense = accept;
                      });
                    }
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text:
                          "By continuing, you agree to our Terms and Conditions",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.normal, fontSize: 10),
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: AppButton(
              title: "Get Started",
              onPressed: () {
                if (requestModel.acceptLicense == true) {
                  submitUserRegistration();
                } else {
                  alertWidget.failure(
                      context, '', 'Please accept our Terms and Conditions');
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: RichText(
              text: TextSpan(
                  text: "Note: ",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: Constants.reviewNotes,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.normal),
                    )
                  ]),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () {
                _launchInBrowser(_url);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        blurRadius: 15),
                  ],
                ),
                child: Image.network(
                  '${EndPoints.baseApi8988}${EndPoints.slideUrl}/IMG_6.PNG',
                  height: 85,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  submitUserRegistration() async {
    setState(() {
      _isLoading = true;
      requestModel.role = "MERCHANT";
      requestModel.currencyId = '784';
      requestModel.latitude = _lat;
      requestModel.longitude = _lng;
      requestModel.deviceType = Constants.deviceType;
      requestModel.instId = Constants.instId;
      requestModel.kycType = 'E-KYC';
    });
    requestModel.password =
        await Validators.encrypt(requestModel.password.toString());
    requestModel.confirmPassword =
        await Validators.encrypt(requestModel.confirmPassword.toString());
    requestModel.pin = await Validators.encrypt(requestModel.pin.toString());
    requestModel.confirmPin =
        await Validators.encrypt(requestModel.confirmPin.toString());
    requestModel.deviceId =
        await Validators.encrypt(await Global.getUniqueId());
    userServices
        .newMerchantSignup(
            requestModel,
            profilePic,
            kycFront.text,
            kycBack.text,
            tradeLicense.text,
            nationalIdFront.text,
            nationalIdBack.text,
            cancelCheque.text)
        .then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          setState(() {
            _isLoading = false;
          });
          alertWidget.successPopup(
              context, 'Success', decodeData['responseMessage'], () {
            Navigator.pushNamedAndRemoveUntil(
                context, 'login', (route) => false);
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
        if (decodeData['message']
            .toString()
            .contains('User is already Onborded')) {
          _passwordController.clear();
          _cnfPasswordCtrl.clear();
          _pinController.clear();
          _confirmPinController.clear();
          setState(() {
            position = 1;
          });
        }
        alertWidget.failure(context, 'Failure',
            decodeData['message'] ?? Constants.somethingWrong);
      }
    });
  }

  userNameWidget() {
    return CustomTextFormField(
      controller: _userNameController,
      title: 'Username',
      required: true,
      prefixIcon: Icons.verified,
      onFieldSubmitted: (name) {
        getUser();
      },
      onChanged: (String value) {
        setState(() {
          if (value.isEmpty ||
              !userVerify ||
              userCheck.toString() == "true" ||
              !RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$').hasMatch(value)) {
            enabledPassword = false;
          } else {
            enabledPassword = true;
          }
        });
      },
      suffixIconOnPressed: () {
        if (_userNameController.text.length >= 3) {
          setState(() {
            if (!showVerify && userVerify) {
              userVerify = false;
            } else {
              userVerify = true;
            }
          });
          showVerify = true;
          if (userVerify) {
            getUser();
          }
        }
      },
      suffixIconTrue: true,
      helperStyle: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: Theme.of(context).primaryColor),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'\w'))
      ],
      suffixText: showVerify ? 'Verify' : 'Change',
      readOnly: !showVerify,
      helperText: userHelper(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'UserName is Mandatory!';
        }
        if (value.length < 3) {
          return 'Minimum character length is 3';
        }
        if (userVerify && userCheck == "true") {
          return Constants.userNameFailureMessage;
        }
        if (!RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$').hasMatch(value)) {
          return 'Invalid username!';
        }
        return null;
      },
      onSaved: (value) {
        requestModel.userName = value;
      },
    );
  }

  userHelper() {
    if (userVerify == false) {
      return "Click 'Verify' to check if Username is available";
    }
    if (userCheck.toString() == "false") {
      return Constants.userNameSuccessMessage;
    }
    if (userCheck == "Loading...") {
      return "Please wait...";
    }
  }

  getUser() async {
    if (_userNameController.text.isNotEmpty) {
      debugPrint("Calling API");
      setState(() {
        userCheck = "Loading...";
      });
      var user = await Validators.encrypt(_userNameController.text.toString());
      userServices.userCheck(user).then((response) async {
        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            userCheck = response.body;
            if (userCheck == 'false') {
              showVerify = false;
              userCheckMessage = Constants.userNameSuccessMessage;
            } else {
              setState(() => showVerify = true);
            }
          });
        }
      });
    }
  }

  emailWidget() {
    return CustomTextFormField(
      controller: _emailController,
      required: true,
      textInputAction: TextInputAction.done,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[a-z_A-Z\d.@]'))
      ],
      keyboardType: TextInputType.emailAddress,
      enabled: enabledMobile &&
              mobile &&
              mobileNoCheck == 'false' &&
              _mobileNoController.text.isNotEmpty
          ? enabledEmail = true
          : enabledEmail = false,
      prefixIcon: Icons.alternate_email,
      helperText: emailHelper(),
      helperStyle: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: Theme.of(context).primaryColor),
      title: 'Email ID',
      suffixText: showVerify1 ? 'Verify' : 'Change',
      suffixIconOnPressed: () {
        print('Button Pressed');
        setState(() {
          if (!showVerify1 && emailVerify) {
            emailVerify = false;
            email = false;
          } else {
            emailVerify = true;
          }
        });
        showVerify1 = true;
        if (emailVerify) {
          if (EmailValidator.validate(_emailController.text)) {
            getEmailIdOrMobileNo('emailId', _emailController.text);
          } else {
            email = false;
            enabledCountry = false;
          }
        }
      },
      readOnly: !showVerify1,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email ID is Mandatory! ';
        } else {
          final bool isValid = EmailValidator.validate(value);
          if (!isValid) {
            return Constants.emailError;
          }
          if (emailCheck == 'true') {
            return Constants.emailIdFailureMessage;
          }
        }

        return null;
      },
      onSaved: (value) {
        requestModel.emailId = value;
      },
    );
  }

  emailHelper() {
    if (emailVerify == false) {
      return "Click 'Verify' to check if Email is available";
    }
    if (emailCheck.toString() == "false") {
      return Constants.emailIdSuccessMessage;
    }
    if (emailCheck == "Loading...") {
      return "Please wait...";
    }
  }

  getEmailIdOrMobileNo(String type, String request) async {
    debugPrint("Calling API");
    setState(() {
      emailCheck = "Loading...";
    });
    request = await Validators.encrypt(request);
    userServices.emailMobileCheck(type, request).then((response) async {
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (type == 'emailId') {
          setState(() {
            emailCheck = response.body;
            if (emailCheck == 'true') {
              email = false;
              enabledCountry = false;
            } else {
              showVerify1 = false;
              email = true;
              enabledCountry = enabledEmail;
            }
          });
        } else {
          setState(() {
            mobileNoCheck = response.body;
            if (mobileNoCheck == 'true') {
              mobile = false;
              enabledEmail = false;
              mobileNoCheckMessage = Constants.mobileNoFailureMessage;
              style = Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.red);
            } else {
              mobile = true;
              enabledEmail = enabledMobile;
              mobileNoCheckMessage = Constants.mobileNoSuccessMessage;
              style = Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).primaryColor);
            }
          });
        }
      }
    });
  }
}
