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
import 'package:sifr_latest/common_widgets/app_appbar.dart';
import 'package:sifr_latest/models/merchant_requestmodel.dart';
import 'package:sifr_latest/pages/mechant_order/merchant_order_details.dart';
import 'package:sifr_latest/widgets/Forms/Business_info.dart';
import 'package:sifr_latest/widgets/Forms/document_uploads.dart';
import 'package:sifr_latest/widgets/Forms/merchant_store_form.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';
import 'package:sifr_latest/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common_widgets/custom_app_button.dart';
import '../../../../common_widgets/form_title_widget.dart';
import '../../../../common_widgets/icon_text_widget.dart';
import '../../../../config/config.dart';
import '../../../../helpers/addhaarvalidaters.dart';
import '../../../../helpers/pan_validateer.dart';
import '../../../../models/models.dart';
import '../../../../providers/providers.dart';
import '../../../../services/services.dart';
import '../../../../widgets/Forms/kyc_form.dart';
import '../../../../widgets/Forms/security_form.dart';
import '../../../../widgets/widget.dart';
import '../../../mechant_order/models/mechant_additionalingo_model.dart';
import 'terms_and_conditions.dart';

class MerchantSignup extends StatefulWidget {
  const MerchantSignup({Key? key}) : super(key: key);

  @override
  State<MerchantSignup> createState() => _MerchantSignupState();
}

class _MerchantSignupState extends State<MerchantSignup> {
  bool _isLoading = false;
  int position = 0;
  bool accept = true;
  final double _lat = 13.05186999479027;
  final double _lng = 80.22561586938588;
  FocusNode myFocusNode = FocusNode();

  AlertService alertWidget = AlertService();
  CustomAlert customAlert = CustomAlert();
  UserServices userServices = UserServices();
  MerchantRequestModel requestModel = MerchantRequestModel();
  MerchantRegPersonalReqModel merchantPersonalReq =
      MerchantRegPersonalReqModel();
  MerchantCompanyDetailsReqModel merchantCompanyDetailsReq =
      MerchantCompanyDetailsReqModel();
  MerchantAdditionalInfoRequestmodel merchantAdditionalInfoReq =
      MerchantAdditionalInfoRequestmodel(merchantProductDetails: [
    MerchantProductDetail(
        productName: "aadf",
        productId: 1,
        package: "package",
        packagetId: 2,
        qty: 5)
  ]);

  // --------- FORM KEYs ------------
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> personalFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final _textFieldKey = GlobalKey<FormFieldState<String>>();

  /// PERSONAL INFORMATION
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _mobileCodeController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _alternativeMobileCodeController =
      TextEditingController();
  final TextEditingController _altMobileNoController = TextEditingController();
  final TextEditingController _poaExiryController = TextEditingController();
  final TextEditingController _poaNumberController = TextEditingController();
  final TextEditingController _poiExpryController = TextEditingController();
  final TextEditingController _poINumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _currentAddressController =
      TextEditingController();
  final TextEditingController _currentZipCodeCtrl = TextEditingController();
  final TextEditingController _permanentAddressController =
      TextEditingController();

  final TextEditingController _permanentZipCodeCtrl = TextEditingController();

  // merchant store image
  final TextEditingController _merchantStoreFrontImageCtrl =
      TextEditingController();
  final TextEditingController _merchantStoreInsideImageCtrl =
      TextEditingController();

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
  String countryCode = 'IN';
  late Country _country =
      countries.firstWhere((element) => element.code == countryCode);
  List nationalityList =

      //  ['Europien', 'Emirates', 'American', 'Britan'];
      //     var aa =

      [
    {"value": "Europien", "label": "Europien"},
    {"value": "Emirates", "label": "Emirates"},
    {"value": "American", "label": "American"},
    {"value": "Britan", "label": "Britan"},
  ];

  List bankList =

      //  ['Europien', 'Emirates', 'American', 'Britan'];
      //     var aa =

      [
    {"value": "HDF1212", "label": "Hdfc"},
    {"value": "SBI5454", "label": "SBI"},
    {"value": "AXI5454", "label": "AXIS"},
    {"value": "ICI5445", "label": "ICICI"},
  ];

  List<Map<String, dynamic>> POIAList = [
    {"value": 1, "label": "PAN"},
    {"value": 2, "label": "Passport"},
  ];

  Map<String, int> countrysList = {
    "Europe": 141,
    "India": 356,
    "UK": 999,
    "USA": 340,
    "UAE": 784,
  };
  List statesList = ['Dubai', 'Abudhabi', 'Sharjah', 'Others'];
  List countryList = [];
  List acquirerList = [];
  List mmcGroupList = [];
  List tmsMasterCountriesList = [];
  List tmsMasterCitiesList = [];
  List tmsMasterCurrenciesList = [];
  List tmsProductMasterlist = [];
  List mmcTypeList = [];
  List stateList = [];
  List cityList = [];

  /// LOGIN INFORMATION
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cnfPasswordCtrl = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  // merchant id proof
  final TextEditingController _merchantPanController = TextEditingController();
  final TextEditingController _merchantAddharController =
      TextEditingController();

  String userCheck = '';
  String panOwnerName = '';
  String addhaarCheck = '';
  String accountCheck = '';
  bool showVerify = true;
  bool showaddharverify = true;
  bool addhaarOTPsent = false;
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
  bool accountVerify = true;

  /// SECURITY QUESTION INFO
  final TextEditingController _answer1Controller = TextEditingController();
  final TextEditingController _answer2Controller = TextEditingController();
  final TextEditingController _answer3Controller = TextEditingController();
  List securityQuestionList = [];
  final TextEditingController selectedItem1 = TextEditingController();
  final TextEditingController selectedItem2 = TextEditingController();
  final TextEditingController selectedItem3 = TextEditingController();
  String nationality = '';
  String selectedPOA = '';
  String selectedPOI = '';
  String selectedCountries = '';
  String selectedCity = '';
  String selectedState = '';
  String selectedCurrentState = '';
  String selectedPermenentState = '';
  String selectedCurrentCountry = '';
  String selectedPermenentCountry = '';
  final TextEditingController selectedMcc = TextEditingController();
  final TextEditingController selectedBusinessType = TextEditingController();
  final TextEditingController selectedBusinessTurnOverCtrl =
      TextEditingController();

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

  /// Bank detials
  String ifscCode = '';
  TextEditingController merchantAccountNumberCtrl = TextEditingController();
  TextEditingController merchantIfscCodeCtrl = TextEditingController();
  TextEditingController merchantBeneficiaryNamrCodeCtrl =
      TextEditingController();

// merchant Aggrement
  String mdrType = '';

  // Merchant company detials feilda
  TextEditingController merchantCommercialNameCtrl = TextEditingController();
  TextEditingController onwershipNameCtrl = TextEditingController();
  TextEditingController merchantIdCtrl = TextEditingController();
  TextEditingController merchantAddressCtrl = TextEditingController();
  TextEditingController merchantStreetNameCtrl = TextEditingController();
  TextEditingController merchantDescriptionCtrl = TextEditingController();
  TextEditingController merchantZipCodeCtrl = TextEditingController();
  TextEditingController acquirerNameCtrl = TextEditingController();
  TextEditingController acquirerApplicationIdCtrl = TextEditingController();
  TextEditingController selectedCountry = TextEditingController();
  TextEditingController selectedCityCtrl = TextEditingController();
  TextEditingController selectedGeoFencingRadius = TextEditingController();
  TextEditingController selectedCurrency = TextEditingController();
  TextEditingController vatValueCtrl = TextEditingController();
  TextEditingController VATRegistrationNumberCtrl = TextEditingController();
  TextEditingController shareholderPercentCtrl = TextEditingController();
  TextEditingController maxAuthAmountCtrl = TextEditingController();
  TextEditingController maxTerminalCountCtrl = TextEditingController();
  TextEditingController merchantPercentageAmountCtrl = TextEditingController();

  var dobSelectedDt = DateTime(
      DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);
  var nationalSelectedDt = DateTime.now();
  var tradeSelectedDt = DateTime.now();
  var poaExpiry = DateTime.now();
  var poiExpiry = DateTime.now();

  @override
  initState() {
    DevicePermission().checkPermission();
    getCurrentPosition();
    //getSecurityQuestions();
    //loadMcc();
    //getCountry();
    getDefaultMerchantValues();
    //userServices.getAcqApplicationid('1');

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

  int? getValueByLabel(List<Map<String, dynamic>> list, String? label) {
    for (var map in list) {
      if (map['label'] == label) {
        return map['value'];
      }
    }
    return null;
  }

  void getIntByKey(
      {required String countryKey, required Map<String, int> dataMap}) {
    int? countryValue = dataMap[countryKey];

    if (countryValue != null) {
      print('$countryKey: $countryValue');
    } else {
      print('Country not found');
    }
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
    Navigator.pushNamedAndRemoveUntil(
        context, 'MerchantNumVerify', (route) => false);
  }

  int currTabPosition = 1;
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

  items(int position) {
    if (position == 0) {
      return MerchantOrderDetails(
        orderNext: orderNext,
        tmsProductMaster: tmsProductMasterlist,
        merchantAdditionalInfoReq: merchantAdditionalInfoReq,
      );
    }
    if (position == 1) {
      return mainControl('Merchant Personal Information', personalInfo());
    }
    // else if (position == 2) {
    //   var isDarkMode = context.isDarkMode;
    //   return SecurityForm(
    //     selectedItem1: selectedItem1,
    //     selectedItem2: selectedItem2,
    //     selectedItem3: selectedItem3,
    //     registerRequestModel: requestModel,
    //     answer1: _answer1Controller,
    //     answer2: _answer2Controller,
    //     answer3: _answer3Controller,
    //     securityQuestionList: securityQuestionList,
    //     darkmode: isDarkMode,
    //     next: securityNext,
    //     previous: securityPrevious,
    //   );
    // }

    else if (position == 2) {
      return BusinessInfo(
        previous: businessPrevious,
        next: businessNext,
        merchantLegalNameCtrl: _merchantNameCtrl,
        MCCGroupList: mmcGroupList,
        MCCTypeList: mmcTypeList,
        merchantCommercialNameCtrl: merchantCommercialNameCtrl,
        onwershipNameCtrl: onwershipNameCtrl,
        merchantIdCtrl: merchantIdCtrl,
        merchantAddressCtrl: merchantAddressCtrl,
        merchantStreetNameCtrl: merchantStreetNameCtrl,
        merchantDescriptionCtrl: merchantDescriptionCtrl,
        merchantZipCodeCtrl: merchantZipCodeCtrl,
        acquirerNameCtrl: acquirerNameCtrl,
        acquirerApplicationIdCtrl: acquirerApplicationIdCtrl,
        selectedCountry: selectedCountry,
        selectedCityCtrl: selectedCityCtrl,
        selectedGeoFencingRadius: selectedGeoFencingRadius,
        selectedCurrency: selectedCurrency,
        vatValueCtrl: vatValueCtrl,
        VATRegistrationNumberCtrl: VATRegistrationNumberCtrl,
        shareholderPercentCtrl: shareholderPercentCtrl,
        maxAuthAmountCtrl: maxAuthAmountCtrl,
        maxTerminalCountCtrl: maxTerminalCountCtrl,
        merchantPercentageAmountCtrl: merchantPercentageAmountCtrl,
        companyRegCtrl: _companyRegCtrl,
        nationalIdCtrl: _nationalIdCtrl,
        nationalIdExpiryCtrl: _nationalIdExpiryCtrl,
        tradeLicenseCtrl: _tradeLicenseCtrl,
        tradeLicenseExpiryCtrl: _tradeLicenseExpiryCtrl,
        selectedMccGroup: selectedMcc,
        selectedBusinessType: selectedBusinessType,
        merchantCompanyDetailsReq: merchantCompanyDetailsReq,
        mccList: mccList,
        tradeSelectedDt: tradeSelectedDt,
        nationalSelectedDt: nationalSelectedDt,
        acquierList: acquirerList,
        emailController: _emailController,
        selectedBussinesTurnover: selectedBusinessTurnOverCtrl,
        nextfordev: () {
          setState(() {
            position = 4;
          });
        },
      );
    } else if (position == 3) {
      return mainControl('Merchant Id proof', merchantIdproof());
    } else if (position == 4) {
      return mainControl('Merchant Bank Details', merchantBankDetails());
    } else if (position == 5) {
      return MerchantStoreImagesForm(
        previous: storePrevious,
        next: storeNext,
        storeFrontImage: _merchantStoreFrontImageCtrl,
        insideStoreImage: _merchantStoreInsideImageCtrl,
        merchantAdditionalInfoReq: merchantAdditionalInfoReq,
      );
    } else if (position == 6) {
      return DocumentUploads(
          previous: documentPrevious,
          next: documentNext,
          tradeLicense: tradeLicense,
          nationalIdFront: nationalIdFront,
          cancelCheque: cancelCheque,
          nationalIdBack: nationalIdBack);
    }

    //  else if (position == 5) {
    //   return KYCForm(
    //       previous: kycPrevious,
    //       next: kycNext,
    //       kycFrontImage: kycFront,
    //       kycBackImage: kycBack);
    // }

    else if (position == 7) {
      return mainControl('Review', review());
    }
  }

  businessNext() {
    setState(() {
      position = 3; //default value 4
    });
  }

  businessPrevious() {
    setState(() {
      position = 1;
    });
  }

  securityNext() {
    setState(() {
      position = 3;
    });
  }

  orderNext() {
    setState(() {
      position = 1;
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
            appBar: AppAppbar(title: title),
            // AppBarWidget(
            //   action: false,
            //   title: title,
            //   automaticallyImplyLeading: false,
            // ),
            backgroundColor: Colors.white,
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
    var screenHeight = MediaQuery.of(context).size.height;
    return Form(
        key: personalFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
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
                      iconPath: 'assets/merchant_icons/merchant_detials.png',
                      title: "Merchant\nDetails"),
                  IconTextWidget(
                      screenHeight: screenHeight,
                      color: getIconColor(position: 2),
                      iconPath: 'assets/merchant_icons/id_proof_icon.png',
                      title: "Id\nProofs"),
                  IconTextWidget(
                      screenHeight: screenHeight,
                      color: getIconColor(position: 3),
                      iconPath: 'assets/merchant_icons/bussiness_proofs.png',
                      title: "Bussiness\nProofs"),
                  IconTextWidget(
                      screenHeight: screenHeight,
                      color: getIconColor(position: 4),
                      iconPath: 'assets/merchant_icons/bank_details.png',
                      title: "Bank\nDetails"),
                ],
              ),
            ),
            // Placeholder(
            //   child: Row(
            //     children: [
            //       ElevatedButton(
            //           onPressed: () {
            //             setState(() {
            //               currTabPosition = 1;
            //             });
            //           },
            //           child: Text('reset')),
            //       ElevatedButton(
            //           onPressed: () {
            //             setState(() {
            //               currTabPosition--;
            //             });
            //           },
            //           child: Text('back')),
            //       ElevatedButton(
            //           onPressed: () {
            //             setState(() {
            //               currTabPosition++;
            //             });
            //           },
            //           child: Text('next')),
            //     ],
            //   ),
            // ),
            const FormTitleWidget(subWord: 'Merchant Details'),
            const SizedBox(height: 35),
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
                      merchantPersonalReq.firstName = value;
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
                    // enabled: _firstNameController.text.isEmpty ||
                    //         _firstNameController.text.length < 3
                    //     ? enabledLast = false
                    //     : enabledLast = true,
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
                      merchantPersonalReq.lastName = value;
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
                // Expanded(
                //   child: CustomTextFormField(
                //     title: 'Nickname',
                //     enabled: _lastNameController.text.trim().isEmpty ||
                //             _lastNameController.text.trim().length < 3 ||
                //             !Validators.isValidName(
                //                 _lastNameController.text.trim())
                //         ? false
                //         : true,
                //     controller: _nickNameController,
                //     onTap: () {
                //       _lastNameController.text =
                //           _lastNameController.text.trim();
                //     },
                //     maxLength: 12,
                //     textCapitalization: TextCapitalization.words,
                //     prefixIcon: LineAwesome.user,
                //     validator: (value) {
                //       if (value == null || value.isEmpty) {
                //         return null;
                //       }
                //       if (!Validators.isValidName(value)) {
                //         return 'Invalid Nick Name';
                //       }
                //       return null;
                //     },
                //     onSaved: (value) {
                //       requestModel.nickName = value;
                //     },
                //   ),
                // ),
                Expanded(
                  child: CustomDropdown(
                    title: "Nationality",
                    // enabled: selectedState != '' && enabledState
                    //     ? enabledcity = true
                    //     : enabledcity = false,
                    required: true,
                    selectedItem: nationality != '' ? nationality : null,
                    prefixIcon: FontAwesome.map,
                    itemList: nationalityList
                        .map((map) => map['label'].toString())
                        .toList(),
                    //countryList.map((e) => e['ctyName']).toList(),
                    onChanged: (value) {
                      setState(() {
                        nationality = value;
                        // requestModel.city = value;
                      });
                    },
                    onSaved: (value) {
                      merchantPersonalReq.currentNationality = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nationality is Mandatory!';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomTextFormField(
                    key: _textFieldKey,
                    controller: _dateOfBirthController,
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
                      _dateOfBirthController.text =
                          _dateOfBirthController.text.trim();
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
                          _dateOfBirthController.text = formattedDate;
                        });
                      } else {}

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                                .format(pickedDate);
                        merchantPersonalReq.dob = formattedDate;
                        print('Formatted Date: ${formattedDate}Z');
                      }
                    },
                    // enabled: _lastNameController.text.trim().isEmpty ||
                    //         _lastNameController.text.trim().length < 3 ||
                    //         !Validators.isValidName(
                    //             _lastNameController.text.trim())
                    //     ? enabledDob = false
                    //     : enabledDob = enabledLast,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            CustomMobileField(
              enabled: true,
              controller: _mobileNoController,
              keyboardType: TextInputType.number,
              title: 'Mobile Number',
              // enabled: _dateController.text.isEmpty
              //     ? enabledMobile = false
              //     : enabledMobile = enabledDob,
              required: true,
              helperText: mobileNoCheckMessage,
              helperStyle: style,
              prefixIcon: FontAwesome.mobile,
              countryCode: countryCode,
              onChanged: (phone) {
                merchantPersonalReq.currentMobileNo =
                    phone.countryCode + phone.number;
              },
              onCountryChanged: (country) {
                setState(() {
                  countryCode = country.code;
                  _country = country;
                  _mobileNoController.text = countryCode;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CustomMobileField(
              enabled: true,
              controller: _altMobileNoController,
              keyboardType: TextInputType.number,
              title: 'WhatsApp Number',
              // enabled: _dateController.text.isEmpty
              //     ? enabledMobile = false
              //     : enabledMobile = enabledDob,
              required: true,
              helperText: mobileNoCheckMessage,
              helperStyle: style,
              prefixIcon: FontAwesome.mobile,
              countryCode: countryCode,
              onChanged: (phone) {
                merchantPersonalReq.currentAltMobNo =
                    phone.countryCode + phone.number;
              },
              onCountryChanged: (country) {
                setState(() {
                  countryCode = country.code;
                  _country = country;
                  _alternativeMobileCodeController.text = countryCode;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: CustomDropdown(
                    title: "POA Type",
                    required: true,
                    selectedItem: selectedPOA != '' ? selectedPOA : null,
                    prefixIcon: Icons.location_city_outlined,
                    itemList:
                        POIAList.map((map) => map['label'].toString()).toList(),
                    //countryList.map((e) => e['ctyName']).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPOA = value;
                        merchantPersonalReq.poaType =
                            getValueByLabel(POIAList, value);
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'POA Type is Mandatory!';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomTextFormField(
                    controller: _poaExiryController,
                    title: 'POA Expiry',
                    required: true,
                    readOnly: true,
                    errorMaxLines: 2,
                    maxLength: 26,
                    // helperText: Constants.dobMessage,
                    helperStyle: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).primaryColor),
                    prefixIcon: FontAwesome.calendar,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Poa Expiry is Mandatory!';
                      }
                      return null;
                    },
                    onTap: () async {
                      _poaExiryController.text =
                          _poaExiryController.text.trim();
                      DateTime? pickedDate = await showDatePicker(
                        initialDatePickerMode: DatePickerMode.day,
                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                        context: context,
                        initialDate: poaExpiry,
                        firstDate: DateTime.now().add(const Duration(days: 0)),
                        lastDate: DateTime(DateTime.now().year + 10),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                        setState(() {
                          poaExpiry = pickedDate;

                          _poaExiryController.text = formattedDate;
                        });
                      } else {}

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                                .format(pickedDate);
                        merchantPersonalReq.poaExpiryDate = formattedDate;
                        print('Formatted Date: ${formattedDate}Z');
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            CustomTextFormField(
              title: 'POA Number',
              controller: _poaNumberController,
              required: true,
              textCapitalization: TextCapitalization.words,
              // enabled: _firstNameController.text.isEmpty ||
              //         _firstNameController.text.length < 3
              //     ? enabledLast = false
              //     : enabledLast = true,
              prefixIcon: LineAwesome.user_circle,
              validator: (value) {
                value = value.trim();
                if (value == null || value.isEmpty) {
                  return 'POA Number Mandatory!';
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
                merchantPersonalReq.poaNumber = value;
              },
              onFieldSubmitted: (value) {
                _lastNameController.text = value.trim();
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: CustomDropdown(
                    title: "POI Type",
                    // enabled: selectedState != '' && enabledState
                    //     ? enabledcity = true
                    //     : enabledcity = false,
                    required: true,
                    selectedItem: selectedPOI != '' ? selectedPOI : null,
                    prefixIcon: Icons.location_city_outlined,
                    itemList:
                        POIAList.map((map) => map['label'].toString()).toList(),
                    // cityList.map((e) => e['citName']).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPOI = value;
                        merchantPersonalReq.poiType =
                            getValueByLabel(POIAList, value);
                      });
                    },
                    onSaved: (value) {
                      //merchantPersonalReq.poiType = value;
                      merchantPersonalReq.poiType =
                          getValueByLabel(POIAList, value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'City is Mandatory!';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomTextFormField(
                    controller: _poiExpryController,
                    title: 'POI Expiry',
                    required: true,
                    readOnly: true,
                    errorMaxLines: 2,
                    maxLength: 26,
                    // helperText: Constants.dobMessage,
                    helperStyle: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).primaryColor),
                    prefixIcon: FontAwesome.calendar,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'POI Expiry is Mandatory!';
                      }
                      return null;
                    },
                    onTap: () async {
                      _poiExpryController.text =
                          _poiExpryController.text.trim();
                      DateTime? pickedDate = await showDatePicker(
                        initialDatePickerMode: DatePickerMode.day,
                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                        context: context,
                        initialDate: poiExpiry,
                        firstDate: DateTime.now().add(const Duration(days: 0)),
                        lastDate: DateTime(DateTime.now().year + 10),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                        setState(() {
                          poiExpiry = pickedDate;
                          merchantPersonalReq.poiExpiryDate = formattedDate;
                          _poiExpryController.text = formattedDate;
                        });
                      } else {}

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                                .format(pickedDate);
                        merchantPersonalReq.poiExpiryDate = formattedDate;
                        print('Formatted Date: ${formattedDate}Z');
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            CustomTextFormField(
              title: 'POI Number',
              controller: _poINumberController,
              required: true,
              textCapitalization: TextCapitalization.words,
              // enabled: _firstNameController.text.isEmpty ||
              //         _firstNameController.text.length < 3
              //     ? enabledLast = false
              //     : enabledLast = true,
              prefixIcon: LineAwesome.user_circle,
              validator: (value) {
                value = value.trim();
                if (value == null || value.isEmpty) {
                  return 'POI Number is Mandatory!';
                }
                if (value.length < 10) {
                  return 'Minimum 10 characters';
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
                merchantPersonalReq.poiNumber = value;
              },
              onFieldSubmitted: (value) {
                _poINumberController.text = value.trim();
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            CustomTextFormField(
              title: 'Current Address',

              controller: _currentAddressController,
              prefixIcon: Icons.home,
              required: true,
              minLines: 2,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.words,
              enabled: true,
              // prefixIcon: LineAwesome.address_book,
              validator: (value) {
                value = value.trim();
                if (value == null || value.isEmpty) {
                  return 'Current Address is Mandatory!';
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
                merchantPersonalReq.currentAddress = value;
              },
              onFieldSubmitted: (value) {
                _currentAddressController.text = value.trim();
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: CustomDropdown(
                    title: "Current Country",
                    // enabled: selectedState != '' && enabledState
                    //     ? enabledcity = true
                    //     : enabledcity = false,
                    required: true,
                    selectedItem: selectedCurrentCountry != ''
                        ? selectedCurrentCountry
                        : null,
                    prefixIcon: Icons.location_city_outlined,
                    itemList: countrysList.keys.toList(),
                    //cityList.map((e) => e['citName']).toList(),
                    onChanged: (value) {
                      print(countrysList[value]);
                      setState(() {
                        selectedCurrentCountry = value;
                        merchantPersonalReq.currentCountry =
                            countrysList[value];
                      });
                    },
                    onSaved: (value) {
                      merchantPersonalReq.currentCountry = countrysList[value];
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Country is Mandatory!';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomDropdown(
                    title: "Current State",
                    // enabled: selectedState != '' && enabledState
                    //     ? enabledcity = true
                    //     : enabledcity = false,
                    required: true,
                    selectedItem: selectedCurrentState != ''
                        ? selectedCurrentState
                        : null,
                    prefixIcon: Icons.location_city_outlined,
                    itemList: statesList,
                    // cityList.map((e) => e['citName']).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCurrentState = value;
                        merchantPersonalReq.currentState = value;
                      });
                    },
                    onSaved: (value) {
                      merchantPersonalReq.currentState = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Current state is Mandatory!';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            CustomTextFormField(
              title: 'Current Zip Code',
              // enabled: selectedCity != '' && enabledcity ? true : false,
              maxLength: 6,
              required: true,

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Current Zip is Mandatory!';
                }
                if (!value.isEmpty && value.length < 6) {
                  return 'Minimum 6 digits';
                }
                return null;
              },
              controller: _currentZipCodeCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'\d'))
              ],
              prefixIcon: Icons.map_outlined,
              onSaved: (value) {
                merchantPersonalReq.currentZipCode = value;
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            CustomTextFormField(
              title: 'Permanent Address',
              minLines: 2,
              controller: _permanentAddressController,
              required: true,
              textCapitalization: TextCapitalization.words,
              enabled: true,
              keyboardType: TextInputType.multiline,
              prefixIcon: LineAwesome.home_solid,
              validator: (value) {
                value = value.trim();
                if (value == null || value.isEmpty) {
                  return 'Permanent Address is Mandatory!';
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
                merchantPersonalReq.permanentAddress = value;
              },
              onFieldSubmitted: (value) {
                _permanentAddressController.text = value.trim();
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: CustomDropdown(
                    title: "Permanent Country",
                    // enabled: selectedState != '' && enabledState
                    //     ? enabledcity = true
                    //     : enabledcity = false,
                    required: true,
                    selectedItem: selectedPermenentCountry != ''
                        ? selectedPermenentCountry
                        : null,
                    prefixIcon: Icons.location_city_outlined,
                    itemList: countrysList.keys.toList(),
                    //cityList.map((e) => e['citName']).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPermenentCountry = value;
                      });
                    },
                    onSaved: (value) {
                      merchantPersonalReq.permanentCountry =
                          countrysList[value];
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Permanent Country is Mandatory!';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomDropdown(
                    title: "Permanent State",
                    // enabled: selectedState != '' && enabledState
                    //     ? enabledcity = true
                    //     : enabledcity = false,
                    required: true,
                    selectedItem: selectedPermenentState != ''
                        ? selectedPermenentState
                        : null,
                    prefixIcon: Icons.location_city_outlined,
                    itemList:
                        statesList, // cityList.map((e) => e['citName']).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPermenentState = value;
                        merchantPersonalReq.permanentState = value;
                      });
                    },
                    onSaved: (value) {
                      merchantPersonalReq.permanentState = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Permanent State is Mandatory!';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            CustomTextFormField(
              title: 'Permanent Zip/Postal Code',
              // enabled: selectedCity != '' && enabledcity ? true : false,
              maxLength: 10,
              required: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Zip Code is Mandatory!';
                }
                if (!value.isEmpty && value.length < 6) {
                  return 'Minimum 6 digits';
                }
                return null;
              },
              controller: _permanentZipCodeCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'\d'))
              ],
              prefixIcon: Icons.map_outlined,
              onSaved: (value) {
                merchantPersonalReq.permanentZipCode = value;
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
            Placeholder(
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currTabPosition = 2;
                      position = 2;
                    });
                  },
                  child: Text('next')),
            ),
            Row(
              children: [
                CustomAppButton(
                  width: 0.4,
                  title: 'Back',
                  onPressed: () {
                    setState(() {
                      position = 0;
                    });
                  },
                ),
                Expanded(child: SizedBox()),
                CustomAppButton(
                  width: 0.4,
                  title: "Next",
                  onPressed: () async {
                    // // getCurrentPosition();

                    // if (personalFormKey.currentState!.validate()
                    //     //  &&
                    //     //     mobileNoCheck == 'false' &&
                    //     //     emailCheck == 'false' &&
                    //     //     email

                    //     ) {
                    // personalFormKey.currentState!.save();
                    // print(merchantPersonalReq.toJson());
                    // print(jsonEncode(merchantPersonalReq.toJson()));
                    // setState(() {
                    //   position = 3;
                    // });
                    // }
                    personalFormKey.currentState!.save();
                    if (personalFormKey.currentState!.validate()) {
                      print(jsonEncode(merchantPersonalReq.toJson()));
                      setState(() {
                        currTabPosition = 2;
                        position = 2;
                      });
                    }
                  },
                ),
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

  getDefaultMerchantValues() async {
    print("----default value called----");
    await userServices.GetMerchantOnboardingValues().then((response) async {
      final Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> acquirerDetails =
          data['data'][0]['acquirerAcquirerDetails'];
      List<dynamic> mccGroups = data['data'][0]['tmsMasterMccGroup'];
      List<dynamic> mccTypes = data['data'][0]['tmsMasterMccTypes'];
      List<dynamic> tmsMasterCountries = data['data'][0]['tmsMasterCountries'];
      List<dynamic> tmsMasterCities = data['data'][0]['tmsMasterCities'];
      List<dynamic> tmsMasterCurrencies =
          data['data'][0]['tmsMasterCurrencies'];
      List<dynamic> tmsProductMaster = data['data'][0]['tmsProductMaster'];

      //       var countries = List<String>.from(data['data'][0]['tmsMasterCountries']
      //     .map((item) => item['countryName']));
      // cities = List<String>.from(
      //     data['data'][0]['tmsMasterCities'].map((item) => item['cityName']));
      // currencies = List<String>.from(data['data'][0]['tmsMasterCurrencies']
      //     .map((item) => item['currencyDesc']));

      setState(() {
        acquirerList = acquirerDetails;
        mmcGroupList = mccGroups;
        mmcTypeList = mccTypes;
        tmsMasterCountriesList = tmsMasterCountries;
        tmsMasterCitiesList = tmsMasterCities;
        tmsMasterCurrenciesList = tmsMasterCurrencies;
        tmsProductMasterlist = tmsProductMaster;

        // countryList = decodeData['responseValue']['list'];
        // if (countryList.isNotEmpty) {
        //   selectedCountries = countryList[0]['ctyName'].toString();
        //   requestModel.country = selectedCountries;
        //   requestModel.currencyId =
        //       countryList[0]['currencyCode'].toString();
        //   getState(countryList[0]['id'].toString());
        // }
        //userServices.getAcqApplicationid('1');
      });

      for (var acquirer in acquirerDetails) {
        String acquirerName = acquirer['acquirerName'];
        print('Acquirer Name: $acquirerName');
      }

      for (var mccGroup in mccGroups) {
        String mccGroupId = mccGroup['mccGroupId'].toString();
        print('mccGroupId : $mccGroupId');
      }

      for (var mccType in mccTypes) {
        String acquirerName = mccType['mccTypeDesc'];
        print('mccTypeDesc: $acquirerName');
      }

      for (var products in tmsProductMaster) {
        String acquirerName = products['productName'];
        print('productName: $acquirerName');
      }
      print("length" + "${tmsProductMaster.length}");
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

  Widget merchantIdproof() {
    var screenHeight = MediaQuery.of(context).size.height;

    return Form(
        key: loginFormKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                        iconPath: 'assets/merchant_icons/merchant_detials.png',
                        title: "Merchant\nDetails"),
                    IconTextWidget(
                        screenHeight: screenHeight,
                        color: getIconColor(position: 2),
                        iconPath: 'assets/merchant_icons/id_proof_icon.png',
                        title: "Id\nProofs"),
                    IconTextWidget(
                        screenHeight: screenHeight,
                        color: getIconColor(position: 3),
                        iconPath: 'assets/merchant_icons/bussiness_proofs.png',
                        title: "Bussiness\nProofs"),
                    IconTextWidget(
                        screenHeight: screenHeight,
                        color: getIconColor(position: 4),
                        iconPath: 'assets/merchant_icons/bank_details.png',
                        title: "Bank\nDetails"),
                  ],
                ),
              ),

              const FormTitleWidget(subWord: 'Merchant ID proof'),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: _merchantPanController,
                title: 'Merchant Pan',
                required: true,
                prefixIcon: Icons.verified,
                onFieldSubmitted: (name) {
                  // getUser();
                  validatePan();
                },
                onChanged: (String value) {
                  setState(() {
                    if (value.isEmpty ||
                        !userVerify ||
                        userCheck.toString() == "true" ||
                        !RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                            .hasMatch(value)) {
                      enabledPassword = false;
                    } else {
                      enabledPassword = true;
                    }
                  });
                },
                suffixIconOnPressed: () {
                  if (_merchantPanController.text.length >= 10) {
                    setState(() {
                      if (!showVerify && userVerify) {
                        userVerify = false;
                      } else {
                        userVerify = true;
                      }
                    });
                    showVerify = true;
                    if (userVerify) {
                      validatePan();
                    }
                  }
                },
                suffixIconTrue: true,
                helperStyle: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).primaryColor),
                inputFormatters: <TextInputFormatter>[PanNumberFormatter()],
                suffixText: showVerify ? 'Verify' : 'Change',
                readOnly: !showVerify,
                helperText: customPanHelper(text: 'Merchant Pan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Merchant Pan is Mandatory!';
                  }
                  if (value.length < 10) {
                    return 'Minimum character length is 10';
                  }
                  if (userVerify && userCheck == "true") {
                    return Constants.userNameFailureMessage;
                  }
                  if (!RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                      .hasMatch(value)) {
                    return 'Invalid Merchant Pan Number!';
                  }
                  return null;
                },
                onSaved: (value) {
                  requestModel.userName = value;
                },
              ),
              // userNameWidget(),
              const SizedBox(height: 30.0),
              CustomTextFormField(
                keyboardType: TextInputType.number,
                controller: _merchantAddharController,
                title: 'Merchant Addhaar Number',
                required: true,
                prefixIcon: Icons.verified,
                onFieldSubmitted: (name) {
                  getUser();
                },
                onChanged: (String value) {
                  setState(() {
                    // if (value.isEmpty ||
                    //     !userVerify ||
                    //     userCheck.toString() == "true" ||
                    //     !RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                    //         .hasMatch(value)) {
                    //   enabledPassword = false;
                    // } else {
                    //   enabledPassword = true;
                    // }
                  });
                },
                suffixIconOnPressed: () {
                  if (_merchantAddharController.text.length >= 12) {
                    sendAddhaarOtp();
                  }
                },
                suffixIconTrue: true,
                helperStyle: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).primaryColor),
                inputFormatters: <TextInputFormatter>[AadhaarNumberFormatter()],
                suffixText: showaddharverify ? 'Send OTP' : 'Change',
                readOnly: !showaddharverify,
                helperText:
                    customAddhaarHelper(text: 'Merchant Addhaar Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Addhaar Numberis Mandatory!';
                  }
                  if (value.length < 12) {
                    return 'Minimum character length is 12';
                  }
                  // if (userVerify && userCheck == "true") {
                  //   return Constants.userNameFailureMessage;
                  // }
                  if (!RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                      .hasMatch(value)) {
                    return 'InvalidAddhaar Number!';
                  }
                  return null;
                },
                onSaved: (value) {
                  requestModel.userName = value;
                },
              ),
              // CustomTextFormField(
              //   minLines: 1,
              //   maxLines: 1,
              //   controller: _passwordController,
              //   title: 'Password',
              //   required: true,
              //   enabled: _userNameController.text.isEmpty ||
              //           userCheck == "true" ||
              //           !userVerify ||
              //           !RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
              //               .hasMatch(_userNameController.text)
              //       ? enabledPassword = false
              //       : enabledPassword = true,
              //   prefixIcon: _passwordController.text.isNotEmpty &&
              //           _passwordController.text == _cnfPasswordCtrl.text
              //       ? Icons.check_circle_outline
              //       : Icons.password,
              //   iconColor: _passwordController.text.isNotEmpty &&
              //           _passwordController.text == _cnfPasswordCtrl.text
              //       ? Colors.green
              //       : null,
              //   obscureText: hidePassword,
              //   textInputAction: TextInputAction.next,
              //   keyboardType: TextInputType.visiblePassword,
              //   suffixIconTrue: true,
              //   maxLength: 14,
              //   suffixIcon:
              //       hidePassword ? Icons.visibility : Icons.visibility_off,
              //   suffixIconOnPressed: () {
              //     setState(() {
              //       hidePassword = !hidePassword;
              //     });
              //   },
              //   onChanged: (String value) {
              //     setState(() {
              //       if (value.isEmpty || !Validators.isPassword(value)) {
              //         enabledConfirmPass = false;
              //       } else {
              //         enabledConfirmPass = enabledPassword;
              //       }
              //     });
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Password is Mandatory!';
              //     }
              //     if (!Validators.isPassword(value)) {
              //       return Constants.passwordError;
              //     }
              //     return null;
              //   },
              //   onSaved: (value) {
              //     requestModel.password = value;
              //   },
              // ),
              // const SizedBox(height: 10.0),
              // CustomTextFormField(
              //   minLines: 1,
              //   maxLines: 1,
              //   controller: _cnfPasswordCtrl,
              //   title: 'Confirm Password',
              //   required: true,
              //   maxLength: 14,
              //   enabled: _passwordController.text.isEmpty ||
              //           !Validators.isPassword(_passwordController.text)
              //       ? enabledConfirmPass = false
              //       : enabledConfirmPass = enabledPassword,
              //   prefixIcon: _passwordController.text.isNotEmpty &&
              //           _passwordController.text == _cnfPasswordCtrl.text
              //       ? Icons.check_circle_outline
              //       : Icons.password,
              //   iconColor: _passwordController.text.isNotEmpty &&
              //           _passwordController.text == _cnfPasswordCtrl.text
              //       ? Colors.green
              //       : null,
              //   obscureText: hideCnfPassword,
              //   textInputAction: TextInputAction.next,
              //   keyboardType: TextInputType.visiblePassword,
              //   onChanged: (String value) {
              //     setState(() {
              //       if (value.isEmpty || value != _passwordController.text) {
              //         enabledPin = false;
              //       } else {
              //         enabledPin = enabledConfirmPass;
              //       }
              //     });
              //   },
              //   suffixIconTrue: true,
              //   suffixIcon:
              //       hideCnfPassword ? Icons.visibility : Icons.visibility_off,
              //   suffixIconOnPressed: () {
              //     setState(() {
              //       hideCnfPassword = !hideCnfPassword;
              //     });
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Confirm Password is Mandatory!';
              //     }
              //     if (value != _passwordController.text) {
              //       return Constants.passwordMissMatch;
              //     }
              //     return null;
              //   },
              //   onSaved: (value) {
              //     requestModel.confirmPassword = value;
              //   },
              // ),
              // const SizedBox(
              //   height: 30.0,
              // ),
              // CustomTextFormField(
              //   minLines: 1,
              //   maxLines: 1,
              //   controller: _pinController,
              //   title: 'Login PIN',
              //   required: true,
              //   maxLength: 4,
              //   enabled: _cnfPasswordCtrl.text.isEmpty ||
              //           _cnfPasswordCtrl.text != _passwordController.text
              //       ? enabledPin = false
              //       : enabledPin = enabledConfirmPass,
              //   prefixIcon: _pinController.text.isNotEmpty &&
              //           _pinController.text == _confirmPinController.text
              //       ? Icons.check_circle_outline
              //       : Icons.pin,
              //   iconColor: _pinController.text.isNotEmpty &&
              //           _pinController.text == _confirmPinController.text
              //       ? Colors.green
              //       : null,
              //   //prefixIcon: Icons.pin,
              //   obscureText: hidePin,
              //   helperText:
              //       _pinController.text.isEmpty ? Constants.pinMessage : null,
              //   helperStyle: Theme.of(context)
              //       .textTheme
              //       .bodySmall
              //       ?.copyWith(color: Theme.of(context).primaryColor),
              //   textInputAction: TextInputAction.next,
              //   keyboardType: TextInputType.number,
              //   suffixIconTrue: true,
              //   inputFormatters: <TextInputFormatter>[
              //     FilteringTextInputFormatter.digitsOnly
              //   ],
              //   suffixIcon: hidePin ? Icons.visibility : Icons.visibility_off,
              //   suffixIconOnPressed: () {
              //     setState(() {
              //       hidePin = !hidePin;
              //     });
              //   },
              //   onChanged: (String value) {
              //     setState(() {
              //       if (value.isEmpty ||
              //           value.length != 4 ||
              //           Validators.isConsecutive(value) != -1) {
              //         enabledConfirmPin = false;
              //       } else {
              //         enabledConfirmPin = enabledPin;
              //       }
              //     });
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Login PIN is Mandatory!';
              //     }
              //     if (value.length != 4) {
              //       return 'Login PIN must be 4 digits';
              //     }
              //     if (Validators.isConsecutive(value) != -1) {
              //       return 'Login PIN should not be consecutive digits.';
              //     }

              //     return null;
              //   },
              //   onSaved: (value) {
              //     requestModel.pin = value;
              //   },
              // ),
              // const SizedBox(height: 10.0),
              // CustomTextFormField(
              //   minLines: 1,
              //   maxLines: 1,
              //   controller: _confirmPinController,
              //   title: 'Confirm Login PIN',
              //   required: true,
              //   maxLength: 4,
              //   //prefixIcon: Icons.pin,
              //   prefixIcon: _pinController.text.isNotEmpty &&
              //           _pinController.text == _confirmPinController.text
              //       ? Icons.check_circle_outline
              //       : Icons.pin,
              //   iconColor: _pinController.text.isNotEmpty &&
              //           _pinController.text == _confirmPinController.text
              //       ? Colors.green
              //       : null,
              //   inputFormatters: <TextInputFormatter>[
              //     FilteringTextInputFormatter.digitsOnly
              //   ],
              //   obscureText: hideCnfPin,
              //   enabled: _pinController.text.isEmpty ||
              //           _pinController.text.length != 4 ||
              //           Validators.isConsecutive(_pinController.text) != -1
              //       ? enabledConfirmPin = false
              //       : enabledConfirmPin = enabledPin,
              //   textInputAction: TextInputAction.next,
              //   keyboardType: TextInputType.number,
              //   suffixIconTrue: true,
              //   suffixIcon:
              //       hideCnfPin ? Icons.visibility : Icons.visibility_off,
              //   suffixIconOnPressed: () {
              //     setState(() {
              //       hideCnfPin = !hideCnfPin;
              //     });
              //   },
              //   onChanged: (String value) {
              //     setState(() {});
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Confirm Login PIN is Mandatory!';
              //     }
              //     if (value != _pinController.text) {
              //       return 'Login PIN & Confirm Login PIN do not match';
              //     }
              //     if (Validators.isConsecutive(value) != -1) {
              //       return 'Login PIN should not be consecutive digits.';
              //     }
              //     return null;
              //   },
              //   onSaved: (value) {
              //     requestModel.confirmPin = value;
              //   },
              // ),
              const SizedBox(
                height: 30.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 150,
                    child: CustomAppButton(
                      title: 'Previous',
                      onPressed: () {
                        // _userNameController.clear();
                        // _passwordController.clear();
                        // _cnfPasswordCtrl.clear();
                        // _pinController.clear();
                        // _confirmPinController.clear();
                        setState(() {
                          position = 2; //old 0
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: CustomAppButton(
                      title: 'Next',
                      width: 0.4,
                      onPressed: () {
                        if (loginFormKey.currentState!.validate()) {
                          loginFormKey.currentState!.save();
                          setState(() {
                            position = 4; //old 2
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

  Widget merchantBankDetails() {
    var screenHeight = MediaQuery.of(context).size.height;

    return Form(
        key: loginFormKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                        iconPath: 'assets/merchant_icons/merchant_detials.png',
                        title: "Merchant\nDetails"),
                    IconTextWidget(
                        screenHeight: screenHeight,
                        color: getIconColor(position: 2),
                        iconPath: 'assets/merchant_icons/id_proof_icon.png',
                        title: "Id\nProofs"),
                    IconTextWidget(
                        screenHeight: screenHeight,
                        color: getIconColor(position: 3),
                        iconPath: 'assets/merchant_icons/bussiness_proofs.png',
                        title: "Bussiness\nProofs"),
                    IconTextWidget(
                        screenHeight: screenHeight,
                        color: getIconColor(position: 4),
                        iconPath: 'assets/merchant_icons/bank_details.png',
                        title: "Bank\nDetails"),
                  ],
                ),
              ),

              const FormTitleWidget(subWord: 'Merchant Bank Details'),
              const SizedBox(height: 10),
              CustomTextWidget(text: 'Merchant Bank Account Details '),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: merchantAccountNumberCtrl,
                title: 'Merchant Account Number',
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
                        !RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                            .hasMatch(value)) {
                      enabledPassword = false;
                    } else {
                      enabledPassword = true;
                    }
                  });
                },
                // suffixIconOnPressed: () {
                //   if (merchantAccountNumberCtrl.text.length >= 10) {
                //     setState(() {
                //       if (!showVerify && userVerify) {
                //         userVerify = false;
                //       } else {
                //         userVerify = true;
                //       }
                //     });
                //     showVerify = true;
                //     if (userVerify) {
                //       getUser();
                //     }
                //   }
                // },
                // suffixIconTrue: true,
                helperStyle: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).primaryColor),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                // suffixText: showVerify ? 'Verify' : 'Change',
                keyboardType: TextInputType.number,
                maxLength: 18,
                readOnly: !accountVerify,
                // helperText: customHelperHelper(text: 'Account Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Account Number is Mandatory!';
                  }
                  if (value.length < 10) {
                    return 'Minimum character length is 10';
                  }
                  if (userVerify && userCheck == "true") {
                    return Constants.userNameFailureMessage;
                  }
                  if (!RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                      .hasMatch(value)) {
                    return 'Invalid Merchant Account Number!';
                  }
                  return null;
                },
                onSaved: (value) {
                  merchantAdditionalInfoReq.bankAccountNo = value;
                },
              ),
              // userNameWidget(),
              const SizedBox(height: 20.0),
              CustomTextFormField(
                controller: merchantIfscCodeCtrl,
                title: 'IFSC Code',
                required: true,
                prefixIcon: Icons.verified,
                onFieldSubmitted: (name) {
                  validateAccountNumber();
                },
                onChanged: (String value) {
                  setState(() {
                    // if (value.isEmpty ||
                    //     !userVerify ||
                    //     userCheck.toString() == "true" ||
                    //     !RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                    //         .hasMatch(value)) {
                    //   enabledPassword = false;
                    // } else {
                    //   enabledPassword = true;
                    // }
                  });
                },
                suffixIconOnPressed: () {
                  if (merchantIfscCodeCtrl.text.length >= 10) {
                    print("clicked");
                    if (accountVerify) {
                      print("validate");
                      validateAccountNumber();
                    } else {
                      print("change");

                      setState(() {
                        accountVerify = true;
                      });
                    }
                  }
                },
                suffixIconTrue: true,
                helperStyle: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).primaryColor),
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(11),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                suffixText: accountVerify ? 'Verify' : 'Change',
                readOnly: !accountVerify,
                helperText: customAccountHelper(text: 'Acc. No And IFSC '),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'IFSC Code Mandatory!';
                  }
                  if (value.length < 10) {
                    return 'Minimum character length is 12';
                  }
                  // if (userVerify && userCheck == "true") {
                  //   return Constants.userNameFailureMessage;
                  // }
                  if (!RegExp(r'^[a-zA-Z\d][a-zA-Z\d.]+[a-zA-Z\d]$')
                      .hasMatch(value)) {
                    return 'Invalid IFSC Code';
                  }
                  return null;
                },
                onSaved: (value) {
                  requestModel.userName = value;
                },
              ),
              const SizedBox(height: 20.0),
              CustomDropdown(
                title: "Select Bank",
                // enabled: selectedState != '' && enabledState
                //     ? enabledcity = true
                //     : enabledcity = false,
                required: true,
                selectedItem: ifscCode != '' ? ifscCode : null,
                prefixIcon: FontAwesome.building_columns,
                itemList:
                    bankList.map((map) => map['label'].toString()).toList(),
                //countryList.map((e) => e['ctyName']).toList(),
                onChanged: (value) {
                  setState(() {
                    ifscCode = value;
                    // requestModel.city = value;
                  });
                },
                onSaved: (value) {
                  // merchantPersonalReq.currentNationality = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'IFSC Code is Mandatory!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              CustomTextFormField(
                title: 'Beneficiary Name',
                required: true,
                controller: merchantBeneficiaryNamrCodeCtrl,
                maxLength: 24,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.words,
                prefixIcon: LineAwesome.store_alt_solid,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]'))
                ],
                onSaved: (value) {
                  merchantAdditionalInfoReq.beneficiaryName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'IFSC Code is Mandatory!';
                  }
                  return null;
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
                    child: CustomAppButton(
                      title: 'Previous',
                      onPressed: () {
                        // _userNameController.clear();
                        _passwordController.clear();
                        _cnfPasswordCtrl.clear();
                        _pinController.clear();
                        _confirmPinController.clear();
                        setState(() {
                          position = 3; //old 0
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: CustomAppButton(
                      title: 'Next',
                      width: 0.4,
                      onPressed: () {
                        if (loginFormKey.currentState!.validate()) {
                          loginFormKey.currentState!.save();
                          setState(() {
                            position = 5; //old 6//2
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
      position = 7;
    });
  }

  kycPrevious() {
    setState(() {
      position = 8;
    });
  }

  storePrevious() {
    setState(() {
      position = 4;
    });
  }

  storeNext() {
    setState(() {
      position = 6;
    });
  }

  documentNext() {
    setState(() {
      position = 7;
    });
  }

  documentPrevious() {
    setState(() {
      position = 5;
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
    var screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    iconPath: 'assets/merchant_icons/merchant_detials.png',
                    title: "Merchant\nDetails"),
                IconTextWidget(
                    screenHeight: screenHeight,
                    color: getIconColor(position: 2),
                    iconPath: 'assets/merchant_icons/id_proof_icon.png',
                    title: "Id\nProofs"),
                IconTextWidget(
                    screenHeight: screenHeight,
                    color: getIconColor(position: 3),
                    iconPath: 'assets/merchant_icons/bussiness_proofs.png',
                    title: "Bussiness\nProofs"),
                IconTextWidget(
                    screenHeight: screenHeight,
                    color: getIconColor(position: 4),
                    iconPath: 'assets/merchant_icons/bank_details.png',
                    title: "Bank\nDetails"),
              ],
            ),
          ),
          // Placeholder(
          //   child: Row(
          //     children: [
          //       ElevatedButton(
          //           onPressed: () {
          //             setState(() {
          //               currTabPosition = 1;
          //             });
          //           },
          //           child: Text('reset')),
          //       ElevatedButton(
          //           onPressed: () {
          //             setState(() {
          //               currTabPosition--;
          //             });
          //           },
          //           child: Text('back')),
          //       ElevatedButton(
          //           onPressed: () {
          //             setState(() {
          //               currTabPosition++;
          //             });
          //           },
          //           child: Text('next')),
          //     ],
          //   ),
          // ),
          const SizedBox(
            height: 30,
          ),
          CustomDropdown(
            title: "MDR Type",
            required: true,
            selectedItem: mdrType != '' ? mdrType : null,
            prefixIcon: FontAwesome.building_columns,
            itemList: [
              'Flat rate',
              'Tier based pricing',
              'Cost plus(Interchange)',
              'Blended',
              'Location based',
              'Fixed subscription-based'
            ],
            //countryList.map((e) => e['ctyName']).toList(),
            onChanged: (value) {
              setState(() {
                mdrType = value;
                // requestModel.city = value;
              });
            },
            onSaved: (value) {
              // merchantPersonalReq.currentNationality = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'MDR Type is Mandatory!';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 20,
          ),
          CustomTextWidget(text: "MDR Summary"),
          const SizedBox(
            height: 5,
          ),
          Container(
            color: AppColors.kTileColor,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomTextWidget(
                          text:
                              "UPI - 0% |  UPI (Credit) - 1.5%\nDebit Card - 0.4%  \nDebit Card(Rupay) - 0%\nCredit (Domestic - 1.99%)"),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    color: AppColors.kSelectedBackgroundColor,
                    child: ExpansionTile(
                      title: CustomTextWidget(
                        text: "View Complete MDR Summary",
                        color: Colors.grey.shade600,
                        size: 10,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text("content"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          const FormTitleWidget(
              subWord: 'Merchant Aggrement', mainWord: 'Acceptance of'),

          // Text(
          //   "You are in the final step of registration process. Please click on Get Started below to complete your registration",
          //   textAlign: TextAlign.center,
          //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
          // ),
          // const SizedBox(height: 20),
          // Card(
          //   elevation: 10,
          //   margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          //   child: ListTile(
          //     title: Text(
          //       'Name ',
          //       style: Theme.of(context)
          //           .textTheme
          //           .displaySmall
          //           ?.copyWith(fontWeight: FontWeight.bold),
          //     ),
          //     subtitle: Text(
          //       '',
          //       style: Theme.of(context).textTheme.bodyMedium,
          //     ),
          //   ),
          // ),
          // Card(
          //   elevation: 10,
          //   margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
          //   child: ListTile(
          //     title: Text(
          //       'Email ID',
          //       style: Theme.of(context)
          //           .textTheme
          //           .displaySmall
          //           ?.copyWith(fontWeight: FontWeight.bold),
          //     ),
          //     subtitle: Text(
          //       " merchantCompanyDetailsReq.emailId!",
          //       style: Theme.of(context).textTheme.bodyMedium,
          //     ),
          //   ),
          // ),
          // Card(
          //   elevation: 10,
          //   margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
          //   child: ListTile(
          //     title: Text(
          //       'Mobile Number',
          //       style: Theme.of(context)
          //           .textTheme
          //           .displaySmall
          //           ?.copyWith(fontWeight: FontWeight.bold),
          //     ),
          //     subtitle: Text("merchantCompanyDetailsReq.mobileNo!"),
          //   ),
          // ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: RichText(
              text: TextSpan(
                  text: "Note: ",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: Constants.aggrementMessage,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.normal),
                    )
                  ]),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: AppColors.kTileColor,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "Terms and conditionss",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                  ),
                ),
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
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            color: AppColors.kTileColor,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "Merchant Service Aggrement",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                  ),
                ),
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
              ],
            ),
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  position = 6;
                });
              },
              child: Text('back')),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: CustomAppButton(
              title: "Submit",
              onPressed: () {
                submitUserRegistration();
                // if (requestModel.acceptLicense == true) {
                //   submitUserRegistration();
                // } else {
                //   alertWidget.failure(
                //       context, '', 'Please accept our Terms and Conditions');
                // }
              },
            ),
          ),

          const SizedBox(height: 20),
          // Center(
          //   child: GestureDetector(
          //     onTap: () {
          //       _launchInBrowser(_url);
          //     },
          //     child: Container(
          //       width: MediaQuery.of(context).size.width * 0.85,
          //       decoration: BoxDecoration(
          //         boxShadow: [
          //           BoxShadow(
          //               color: Theme.of(context).primaryColor.withOpacity(0.5),
          //               blurRadius: 15),
          //         ],
          //       ),
          //       child: Image.network(
          //         '${EndPoints.baseApi8988}${EndPoints.slideUrl}/IMG_6.PNG',
          //         height: 85,
          //         width: MediaQuery.of(context).size.width,
          //         fit: BoxFit.fill,
          //       ),
          //     ),
          //   ),
          // ),
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
            merchantPersonalReq,
            merchantCompanyDetailsReq,
            profilePic,
            kycFront.text,
            kycBack.text,
            tradeLicense.text,
            nationalIdFront.text,
            nationalIdBack.text,
            cancelCheque.text)
        .then((response) {
      var decodeData = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['statusCode'].toString() == "00") {
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
          alertWidget.failure(context, 'Failure', decodeData['errorMessage']);
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

  customAddhaarHelper({required String text}) {
    if (addhaarCheck == false) {
      return "Click 'Send Opp' validate $text ";
    }
    if (addhaarOTPsent) {
      return 'Verify Using  Otp';
    }
  }

  customHelperHelper({required String text}) {
    if (userVerify == false) {
      return "Click 'Verify' to validate $text ";
    }
    if (userCheck.toString() == "VALID") {
      return 'Name $panOwnerName';
    }
    if (userCheck == "Loading...") {
      return "Please wait...";
    }
  }

  customAccountHelper({required String text}) {
    if (accountVerify) {
      return "Click 'Verify' to validate $text ";
    }
    if (!accountVerify) {
      return "Account Info Validated";
    }
    if (accountCheck == "Loading...") {
      return "Please wait...";
    }
  }

  customPanHelper({required String text}) {
    if (userVerify == false) {
      return "Click 'Verify' to validate $text ";
    }
    if (userCheck.toString() == "VALID") {
      return 'Name $panOwnerName';
    }
    if (userCheck == "Loading...") {
      return "Please wait...";
    }
  }

  validatePan() async {
    if (_merchantPanController.text.isNotEmpty) {
      debugPrint("Calling pan validation API");
      setState(() {
        userCheck = "Loading...";
      });
      var panNumber = _merchantPanController.text.toString();
      // var user = await Validators.encrypt(_merchantPanController.text.toString());
      userServices.panValidation(panNumber).then((response) async {
        print(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            Map<String, dynamic> jsonResponse = json.decode(response.body);
            String name = jsonResponse["kycResult"]["name"];
            String idStatus = jsonResponse["kycResult"]["idStatus"];
            //userCheck = response.body[];

            if (idStatus == 'VALID') {
              userCheck = 'VALID';
              panOwnerName = name;
              showVerify = false;

              print(name);
              userCheckMessage = Constants.userNameSuccessMessage;
              merchantAdditionalInfoReq.panNo = panNumber;
            } else {
              setState(() => showVerify = true);
            }
          });
        }
      });
    }
  }

  validateAccountNumber() async {
    if (merchantIfscCodeCtrl.text.isNotEmpty &&
        merchantAccountNumberCtrl.text.isNotEmpty) {
      debugPrint("Calling Accountvalidation API");
      setState(() {
        accountCheck = "Loading...";
      });
      var accNumber = merchantAccountNumberCtrl.text.toString();
      var ifscNumber = merchantIfscCodeCtrl.text.toString();
      print(accNumber);
      print(ifscNumber);
      // var user = await Validators.encrypt(_merchantPanController.text.toString());
      userServices
          .accountValidation(accNumber, ifscNumber)
          .then((response) async {
        print(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          print(response.statusCode);
          setState(() {
            accountCheck = 'VALID';

            merchantAdditionalInfoReq.bankIfscCode = merchantIfscCodeCtrl.text;
            merchantAdditionalInfoReq.bankAccountNo =
                merchantAccountNumberCtrl.text;
            accountVerify = false;
            // if (idStatus == 'VALID') {
            //   accountCheck = 'VALID';
            //   panOwnerName = name;
            //   showVerify = false;
            //   print(name);
            //   userCheckMessage = Constants.userNameSuccessMessage;
            // } else {
            //   setState(() => showVerify = true);
            // }
          });
        }
      });
    }
  }

  sendAddhaarOtp() async {
    if (_merchantAddharController.text.isNotEmpty) {
      debugPrint("Calling AddhaarOtp API");
      setState(() {
        addhaarCheck = "Loading...";
      });
      // var user =
      //     await Validators.encrypt(_merchantAddharController.text.toString());
      var addhaarNumber = _merchantAddharController.text.toString();
      userServices.sendAddhaarOtp(addhaarNumber).then((response) async {
        print(response.statusCode);
        if (response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode >= 200) {
          setState(() {
            addhaarOTPsent = true;
            showaddharverify = !showaddharverify;
            // if (addhaarCheck == 'false') {
            //   showaddharverify = false;
            //   userCheckMessage = Constants.userNameSuccessMessage;
            // } else {
            //   setState(() => showaddharverify = true);
            // }
          });
        }
      });
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
