import 'dart:convert';

import 'dart:io';
import 'package:badges/badges.dart' as badge;
import 'package:email_validator/email_validator.dart';

// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sifr_latest/common_widgets/app_appbar.dart';
import 'package:sifr_latest/decurations/dropdownDecurations.dart';
import 'package:sifr_latest/helpers/default_height.dart';
import 'package:sifr_latest/models/merchant_requestmodel.dart';
import 'package:sifr_latest/pages/mechant_order/merchant_order_details.dart';
import 'package:sifr_latest/widgets/Forms/merchant_store_form.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';
import 'package:sifr_latest/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common_widgets/custom_app_button.dart';
import '../../../../common_widgets/form_title_widget.dart';
import '../../../../config/config.dart';
import '../../../../helpers/pan_validateer.dart';
import '../../../../models/models.dart';
import '../../../../providers/providers.dart';
import '../../../../services/services.dart';
import '../../../../widgets/image_button/verifivation_success_button.dart';
import '../../../../widgets/tabbar/tabbar.dart';
import '../../../../widgets/widget.dart';
import '../../../mechant_order/models/mechant_additionalingo_model.dart';
import 'models/business_id_proof_requestmodel.dart';
import 'models/businessproof_mode.dart';
import 'models/company_detailsInfo_requestmodel.dart';
import 'models/merchant_agreement_requestmodel.dart';
import 'models/merchant_bank_Info_requestmodel.dart';
import 'models/merchant_bank_Info_requestmodel.dart';
import 'models/merchant_id_proof_requestmodel.dart';
import 'models/merchant_store_info_requestmodel.dart';
import 'package:file_picker/file_picker.dart';

class MerchantSignup extends StatefulWidget {
  final TextEditingController verifiednumber;

  const MerchantSignup({Key? key, required this.verifiednumber})
      : super(key: key);

  @override
  State<MerchantSignup> createState() => _MerchantSignupState();
}

class _MerchantSignupState extends State<MerchantSignup> {
  bool _isLoading = false;
  int position = 0;
  bool acceptTnc = true;
  bool acceptAggrement = true;
  FocusNode myFocusNode = FocusNode();

  AlertService alertWidget = AlertService();
  CustomAlert customAlert = CustomAlert();
  UserServices userServices = UserServices();
  MerchantRequestModel requestModel = MerchantRequestModel();
  MerchantRegPersonalReqModel merchantPersonalReq =
      MerchantRegPersonalReqModel();
  MerchantCompanyDetailsReqModel merchantCompanyDetailsReq =
      MerchantCompanyDetailsReqModel();

  CompanyDetailsInfoRequestmodel companyDetailsInforeq =
      CompanyDetailsInfoRequestmodel();
  MerchantIdProofRequestmodel merchantIdProofReq =
      MerchantIdProofRequestmodel();

  BusinessIdProofRequestmodel businessIdProofReq =
      BusinessIdProofRequestmodel();

  MerchantStoreInfoRequestmodel merchantStoreInfoReq =
      MerchantStoreInfoRequestmodel();

  MerchantBankInfoRequestmodel merchantBankInfoReq =
      MerchantBankInfoRequestmodel();

  MerchantAgreeMentRequestmodel merchantAgreeMentReq =
      MerchantAgreeMentRequestmodel();

  // --------- FORM KEYs ------------
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> personalFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> documentFormkey = GlobalKey<FormState>();

  // Merchant order Detials
  TextEditingController canceledChequeControler = TextEditingController();
  List<SelectedProduct> selectedItems = [];
  List<SelectedBusinessProof> selectedBusinessProofItems = [];

  bool isEditable = false;

// Merchant Detials stage 2
  final TextEditingController _merchantLegalNameController =
      TextEditingController();
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _whatsAppNumberController =
      TextEditingController();
  dynamic businessType;
  dynamic businessProofType;
  String? businessDocumentTypename;
  String? businessDocumentTypeId;

  // List<Map<String, dynamic>> BusinessTypeList = [
  //   {"value": 1, "label": "Individual"},
  //   {"value": 2, "label": "Sole Proprietorship"},
  //   {"value": 3, "label": "Partnership Firm"},
  // ];

// Merchant Detials screen 3
  final TextEditingController _merchantDBANameController =
      TextEditingController();
  dynamic selectedBusinessCategory;

  int selectedBusinessStateId = 0;
  int selectedBusinessCityId = 0;

  int? selectedDocumentId;

  // List<Map<String, dynamic>> bussinesCatogeryList = [
  //   {"value": 1, "label": "Individual"},
  //   {"value": 2, "label": "Sole Proprietorship"},
  //   {"value": 3, "label": "Partnership Firm"},
  // ];
  dynamic selectedBusinessSubCategory;

  // List<Map<String, dynamic>> merchantBusinessSubList = [
  //   {"value": 1, "label": "CAT001"},
  //   {"value": 2, "label": "CAT002"},
  //   {"value": 3, "label": "CAT003"},
  // ];
  dynamic selectedBussinesTurnOver;

  List businessTurnoverList = [];

  final TextEditingController _merchantBusinessAddressController =
      TextEditingController();
  dynamic selectedState;
  String selectedCity = '';

  List citiesList = [];
  List statesList = [];

  final TextEditingController _PinCodeCtrl = TextEditingController();

  // merchant id proof  stage 4

  final TextEditingController _merchantPanController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _merchantAddharController =
      TextEditingController();
  String merchantPanHelpertext = "click Verify";
  String gstHelperText = "click Verify";

  //merchant Bussines proof
  final TextEditingController documentExpiryController =
      TextEditingController();
  final TextEditingController businessProofDocumentCtrl =
      TextEditingController();
  var tradeSelectedDate;

  String businessDocumentType = '';

  // merchant store image
  final TextEditingController _merchantStoreFrontImageCtrl =
      TextEditingController();
  final TextEditingController _merchantStoreInsideImageCtrl =
      TextEditingController();

  final TextEditingController _merchantStoreAddressController =
      TextEditingController();
  final TextEditingController selectedStoreState = TextEditingController();
  final TextEditingController selectedStoreCity = TextEditingController();

  final TextEditingController _storePinCodeCtrl = TextEditingController();

  /// merchsant  Merchant Bank Details

  String cancelledChequeImg = '';
  bool enabledLast = false;
  bool enabledNick = false;
  bool enabledMobile = false;
  bool enabledEmail = false;

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
  String merchantPanHelperText = "Click verify";

  List merchantBankList = [];
  List merchantProofDocumentList = [];

  List countryList = [];
  List acquirerList = [];

  List merchantBusinessTypeList = [];

  List tmsMasterCountriesList = [];
  List tmsMasterCitiesList = [];
  List tmsMasterCurrenciesList = [];
  List tmsProductMasterlist = [];

  List merchantBusinessSubCategory = [];
  List merchantBusinessCategory = [];

  List stateList = [];
  List cityList = [];

  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _firmPanController = TextEditingController();

  /// LOGIN INFORMATION
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cnfPasswordCtrl = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  String userCheck = '';
  String panOwnerName = '';
  String addhaarCheck = '';
  String accountCheck = '';
  bool showVerify = true;
  bool showaddharverify = true;
  bool showFirmPanVerify = true;
  bool isgstVerify = true;

  bool showVerify1 = true;
  bool isaddhaarOTPsent = false;
  bool isOtpVerifird = false;
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

  List securityQuestionList = [];
  final TextEditingController selectedItem1 = TextEditingController();
  final TextEditingController selectedItem2 = TextEditingController();
  final TextEditingController selectedItem3 = TextEditingController();
  String nationality = '';

  String selectedCountries = '';

  String selectedPermenentState = '';

  String selectedBusinessState = '';

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
  TextEditingController merchantphoneNumberCtrl = TextEditingController();
  TextEditingController merchantIfscCodeCtrl = TextEditingController();
  TextEditingController merchantBeneficiaryNamrCodeCtrl =
      TextEditingController();

// merchant Aggrement
  dynamic mdrType;

  List mdrTypeList = [];
  List mdrSummaryList = [];

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
    super.initState();

    _mobileNoController.text = widget.verifiednumber.text;
    DevicePermission().checkPermission();
    getCurrentPosition();
    //getSecurityQuestions();
    //loadMcc();
    //getCountry();
    getDefaultMerchantValues();
    //userServices.getAcqApplicationid('1');
  }

  // getToken() async {
  //   var token = await FirebaseMessaging.instance.getToken();
  //   if (token != null) {
  //   } else {
  //     token = '';
  //   }
  //   setState(() {
  //     requestModel.notificationToken = token;
  //   });
  // }

  int? getValueByLabel(List list, String? label) {
    for (var map in list) {
      if (map['label'] == label) {
        return map['value'];
      }
    }
    return null;
  }

  Future getMdrSummaryList(String mdrType) async {
    // int mdrId = (mdrTypeList
    //     .where((element) => element['mdrType'] == mdrType)
    //     .toList())[0]['mdrId'];

    // mdrSummaryList = mdrApiSummaryList
    //     .where((element) => element['mdrId'] == mdrId)
    //     .toList();

    var response = await userServices.getMdrSummary(
        mdrType,
        selectedBussinesTurnOver['turnoverAmount'],
        selectedBusinessCategory['mccGroupId']);

    final Map<String, dynamic> data = json.decode(response.body);

    setState(() {
      isEditable = false;

      mdrSummaryList = [];

      if (data['mmsMdrDetailsInfo'].length > 0) {
        for (var item in data['mmsMdrDetailsInfo']) {
          if (item['dcTxnAmount'] == null) {
            mdrSummaryList.add(item);
          }
        }
        for (var item in data['mmsMdrDetailsInfo']) {
          if (item['dcTxnAmount'] != null) {
            mdrSummaryList.add(item);
          }
        }
      }

      if (mdrType == "special") {
        isEditable = true;
      }

      // mdrSummaryList = data['mmsMdrDetailsInfo'];
    });
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
    print(tmsProductMasterlist);

    return PopScope(
      onPopInvoked: (didPop) => _onWillPop(context),
      child: Form(
        key: _formKey,
        child: tmsProductMasterlist.isEmpty
            ? Container(
                color: AppColors.white,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
              )
            : items(position),
      ),
    );
  }

  Future<bool?> _onWillPop(BuildContext context) async {
    customAlert.displayDialogConfirm(context, 'Please confirm',
        'Do you want to quit your registration?', onTapConfirm);
    return null;
    // return exitResult ?? false;
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
        selectedItems: selectedItems,
      );
    } else if (position == 1) {
      return mainControl(merchantDetialsPartOne());
    } else if (position == 2) {
      return mainControl(merchantDetialsPartTwo());
    } else if (position == 3) {
      return mainControl(merchantIdproof());
    } else if (position == 4) {
      return mainControl(merchantBusinessProof());
    } else if (position == 5) {
      return MerchantStoreImagesForm(
        previous: storePrevious,
        next: storeNext,
        storeFrontImage: _merchantStoreFrontImageCtrl,
        insideStoreImage: _merchantStoreInsideImageCtrl,
        merchantStoreInfoReq: merchantStoreInfoReq,
        merchantStoreAddressController: _merchantStoreAddressController,
        storePinCodeCtrl: _storePinCodeCtrl,
        storeCitysList: citiesList,
        storeStatesList: statesList,
        selectedStoreState: selectedStoreState,
        selectedStoreCity: selectedStoreCity,
        merchantBusinessAddressController: _merchantBusinessAddressController,
        businessAddressPinCodeCtrl: _PinCodeCtrl,
        selectedBusinessState: selectedBusinessState,
        selectedBusinessCity: selectedCity,
      );
    } else if (position == 6) {
      return mainControl(merchantBankDetails());
    } else if (position == 7) {
      return mainControl(review());
    }
  }

  businessNext() {
    setState(() {
      position = 3;
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

  Widget mainControl(Widget child) {
    return _isLoading
        ? const LoadingWidget()
        : Scaffold(
            appBar: AppAppbar(
              onPressed: () {
                if (position > 0) {
                  setState(() {
                    position--;
                  });
                } else {
                  print("else executed");
                  Navigator.pop(context);
                }
              },
              closePressed: () {
                customAlert.displayDialogConfirm(context, 'Please confirm',
                    'Do you want to quit your Onboarding?', onTapConfirm);
              },
            ),
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

  Widget merchantDetialsPartOne() {
    var screenHeight = MediaQuery.of(context).size.height;
    return Form(
        key: personalFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Row(
              children: [
                CustomTextWidget(
                  text: "Merchant KYC",
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 10),
            appTabbar(
              screenHeight: screenHeight,
              currTabPosition: currTabPosition,
            ),
            defaultHeight(30),
            const FormTitleWidget(subWord: 'Merchant Details'),
            defaultHeight(10),
            CustomTextFormField(
              hintText: "Enter Your Business Name",
              title: 'Merchant Legal name',
              controller: _merchantLegalNameController,
              required: true,
              maxLength: 26,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))
              ],
              prefixIcon: LineAwesome.user_circle,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Merchant Legal name is Mandatory!';
                }
                if (value.length < 3) {
                  return 'The minimum length 3 characters';
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
                companyDetailsInforeq.merchantName = value;
                //merchantPersonalReq.firstName = value;
              },
            ),
            CustomTextFormField(
              title: 'Contact Person name',
              hintText: "Enter Your Contact Person name",
              controller: _contactPersonNameController,
              required: true,
              textCapitalization: TextCapitalization.words,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z . ]'))
              ],
              prefixIcon: LineAwesome.user_circle,
              validator: (value) {
                value = value.trim();
                if (value == null || value.isEmpty) {
                  return 'Contact Person Name is Mandatory!';
                }
                if (value.length < 3) {
                  return 'The minimum length 3 characters';
                }
                if (!Validators.isValidName(value)) {
                  return 'Invalid  Name';
                }
                return null;
              },
              onSaved: (value) {
                companyDetailsInforeq.contactPerson = value;
              },
              onFieldSubmitted: (value) {
                _contactPersonNameController.text = value.trim();
              },
            ),
            CustomTextFormField(
              title: 'Email Address',
              hintText: "Enter Your Email Address",
              controller: _emailController,
              required: true,
              // textCapitalization: TextCapitalization.words,
              prefixIcon: Icons.email,
              validator: (value) {
                value = value.trim();
                if (value == null || value.isEmpty) {
                  return 'Email Address is Mandatory!';
                }

                if (!Validators.isValidEmail(value)) {
                  return 'Invalid  Email Format';
                }
                return null;
              },
              onChanged: (String value) {
                value = value.trim();
                setState(() {
                  value.isEmpty ||
                      value.length < 3 ||
                      !Validators.isValidName(value);
                });
              },
              onSaved: (value) {
                companyDetailsInforeq.emailId = value;
              },
              onFieldSubmitted: (value) {
                _emailController.text = value.trim();
              },
            ),
            CustomTextFormField(
              hintText: "Enter Your Mobile Number",
              prefixWidget: TextButton(
                  child: CustomTextWidget(
                      text: "+91", color: Colors.black.withOpacity(0.7)),
                  onPressed: () {}),
              controller: _mobileNoController,
              keyboardType: TextInputType.number,
              title: 'Phone Number',
              maxLength: 10,
              enabled: false,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
              ],
              required: true,
              helperText: mobileNoCheckMessage,
              helperStyle: style,
              prefixIcon: FontAwesome.mobile_solid,
              // suffixIcon: const Icon(
              //   Icons.edit_outlined,
              //   color: AppColors.kPrimaryColor,
              // ),
              // suffixIconTrue: true,
              onChanged: (phone) {
                merchantPersonalReq.currentMobileNo = phone;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone Number is Mandatory!';
                }
                if (value.length < 10) {
                  return 'The length should be exactly 10 digits.';
                }

                return null;
              },
              onSaved: (value) {
                companyDetailsInforeq.landlineNo = value;
              },
            ),
            CustomTextFormField(
              hintText: "Enter Your WhatsApp number",
              prefixWidget: TextButton(
                  child: CustomTextWidget(
                      text: "+91", color: Colors.black.withOpacity(0.7)),
                  onPressed: () {}),
              controller: _whatsAppNumberController,
              keyboardType: TextInputType.number,
              title: 'WhatsApp Number',
              required: true,
              helperText: mobileNoCheckMessage,
              helperStyle: style,
              maxLength: 10,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
              ],
              prefixIcon: FontAwesome.mobile_solid,
              onChanged: (phone) {},
              suffixIcon: const Icon(
                Icons.edit_outlined,
                color: AppColors.kPrimaryColor,
              ),
              onSaved: (value) {
                companyDetailsInforeq.mobileNo = value;
              },
              suffixIconTrue: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'WhatsApp Number is Mandatory!';
                }
                if (value.length < 10) {
                  return 'The length should be exactly 10 digits.';
                }

                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),

            const CustomDropdown(
              title: "Business Type",
              itemList: [],
              dropDownIsEnabled: false,
              required: true,
            ),

            DropdownButtonFormField(
              isDense: true,
              isExpanded: true,
              decoration: commonInputDecoration(Icons.maps_home_work_outlined,
                      hintText: "Select merchant business type")
                  .copyWith(
                      hintStyle: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.25))),
              value: businessType,
              items: merchantBusinessTypeList
                  .map<DropdownMenuItem>((dynamic value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value['businessName'],
                    style: TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  print(newValue['businessType'].runtimeType);
                  businessType = newValue;
                  companyDetailsInforeq.businessTypeId =
                      newValue['businessType'].runtimeType == String
                          ? int.parse(newValue['businessType'])
                          : newValue['businessType'];
                  // companyDetailsInforeq.businessTypeId = 1;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Select Business Type!';
                }

                return null;
              },
            ),

            // CustomDropdown(
            //   title: "Business Type",
            //   required: true,
            //   hintText: "Select merchant business type",
            //   selectedItem: businessType != '' ? businessType : null,
            //   prefixIcon: Icons.maps_home_work_outlined,
            //   itemList: merchantBusinessTypeList
            //       .map((map) => map['businessName'].toString())
            //       .toList(),
            //   //countryList.map((e) => e['ctyName']).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       businessType = value;
            //       merchantPersonalReq.poaType =
            //           getValueByLabel(merchantBusinessTypeList, value);
            //     });
            //   },
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Business Type is Mandatory!';
            //     }
            //     return null;
            //   },
            //   onSaved: (value) {
            //     //NeedChange
            //     companyDetailsInforeq.businessTypeId = 1;
            //   },
            // ),

            const SizedBox(
              height: 20.0,
            ),
            CustomAppButton(
              title: "Next",
              onPressed: () async {
                personalFormKey.currentState!.save();
                if (personalFormKey.currentState!.validate()) {
                  print(jsonEncode(merchantPersonalReq.toJson()));
                  setState(() {
                    position++;
                  });
                }
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
          ],
        ));
  }

  Widget merchantDetialsPartTwo() {
    var screenHeight = MediaQuery.of(context).size.height;
    return Form(
        key: personalFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            appTabbar(
              screenHeight: screenHeight,
              currTabPosition: currTabPosition,
            ),

            CustomTextFormField(
              title: 'Merchant DBA Name',
              hintText: "merchant DBA (Do Business As) name",
              controller: _merchantDBANameController,
              required: true,
              keyboardType: TextInputType.text,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9.]'))
              ],
              textCapitalization: TextCapitalization.words,
              // enabled: _firstNameController.text.isEmpty ||
              //         _firstNameController.text.length < 3
              //     ? enabledLast = false
              //     : enabledLast = true,
              prefixIcon: LineAwesome.user_circle,
              validator: (value) {
                value = value.trim();
                if (value == null || value.isEmpty) {
                  return 'Merchant DBA Name Mandatory!';
                }
                if (value.length < 2) {
                  return 'Minimum 2 characters';
                }

                return null;
              },

              onSaved: (value) {
                companyDetailsInforeq.commercialName = value;
              },
              onFieldSubmitted: (value) {
                _merchantDBANameController.text = value.trim();
              },
            ),
            const SizedBox(
              height: 20.0,
            ),

            const CustomDropdown(
              title: "Merchant Business category",
              itemList: [],
              dropDownIsEnabled: false,
              required: true,
            ),

            DropdownButtonFormField(
              isDense: true,
              isExpanded: true,
              decoration: commonInputDecoration(Icons.location_city_outlined,
                      hintText: "Merchant Business category")
                  .copyWith(
                      hintStyle: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.25))),
              value: selectedBusinessCategory,
              items: merchantBusinessCategory
                  .map<DropdownMenuItem>((dynamic value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value['description'],
                    style: const TextStyle(
                        fontSize: 13, overflow: TextOverflow.ellipsis),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedBusinessCategory = newValue;
                  print(selectedBusinessCategory['mccGroupId']);
                  selectedBusinessSubCategory = null;
                  print(selectedBusinessSubCategory);
                });
              },
            ),

            // SimpleDropDown(
            //
            //   dropDownList: merchantBusinessCategory
            //       .map<DropdownMenuItem>((dynamic value) {
            //     return DropdownMenuItem(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            //
            //     selectedItem:selectedBusinessCatogery,
            //     setSelectedItem: _setSelectedItem,
            //
            // ),

            // CustomDropdown(
            //   title: "Merchant Business category",
            //   hintText: "Select merchant business category",
            //   required: true,
            //
            //   selectedItem: selectedBusinessCatogery != null
            //       ? selectedBusinessCatogery['description']
            //       : null,
            //
            //   prefixIcon: Icons.location_city_outlined,
            //
            //   itemList: merchantBusinessCategory
            //       .map((item) => item['description'])
            //       .toList(),
            //
            //   // cityList.map((e) => e['citName']).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       selectedBusinessCatogery = value;
            //       // merchantPersonalReq.poiType =
            //       //     getValueByLabel(bussinesCatogeryList, value);
            //     });
            //   },
            //   onSaved: (value) {
            //     //merchantPersonalReq.poiType = value;
            //     merchantPersonalReq.poiType =
            //         getValueByLabel(merchantBusinessCategory, value);
            //   },
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Merchant Bussines catogery is Mandatory!';
            //     }
            //     return null;
            //   },
            // ),

            defaultHeight(10),

            const CustomDropdown(
              title: "Merchant Business Sub category",
              itemList: [],
              dropDownIsEnabled: false,
              required: true,
            ),

            DropdownButtonFormField(
              isDense: true,
              isExpanded: true,
              decoration: commonInputDecoration(Icons.location_city_outlined,
                      hintText: "Select merchant business sub category")
                  .copyWith(
                      hintStyle: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.25))),
              value: selectedBusinessSubCategory,
              items: selectedBusinessCategory != null
                  ? merchantBusinessSubCategory
                      .where((item) =>
                          item['mccGroupId']['mccGroupId'] ==
                          selectedBusinessCategory['mccGroupId'])
                      .map<DropdownMenuItem>((dynamic value) {
                      return DropdownMenuItem<dynamic>(
                        value: value,
                        child: Text(
                          value['mccTypeDesc'],
                          style: const TextStyle(
                              fontSize: 13, overflow: TextOverflow.ellipsis),
                        ),
                      );
                    }).toList()
                  : [],
              onChanged: (dynamic newValue) {
                setState(() {
                  selectedBusinessSubCategory = newValue;

                  companyDetailsInforeq.mccTypeCode = newValue["mccTypeId"];
                });
              },
              onSaved: (dynamic value) {
                if (value == null) return;
                companyDetailsInforeq.mccTypeCode = value["mccTypeId"];
              },
            ),

            // CustomDropdown(
            //   title: "Merchant Business Sub category",
            //   hintText: "Select merchant business sub category",
            //
            //   required: true,
            //   selectedItem: selectedBusinessSubCategory != null
            //       ? selectedBusinessSubCategory['mccTypeDesc']
            //       : null,
            //   prefixIcon: Icons.location_city_outlined,
            //
            //   // itemList: merchantBusinessSubCategory
            //   //     .map((map) => map['mccTypeDesc'].toString())
            //   //     .toList(),
            //
            //   itemList: merchantBusinessSubCategory
            //       .where((item) =>
            //           item['mccGroupId']['mccGroupId'] ==
            //           selectedBusinessCatogery['mccGroupId'])
            //       .toList(),
            //
            //   // itemList: merchantBusinessSubCategory.where((item) =>
            //   // item['mccGroupId']['mccGroupId'] ==
            //   //     selectedMccGroupid)
            //   //     .map<DropdownMenuItem<Map<String, dynamic>>>((item) {
            //   //   return DropdownMenuItem<Map<String, dynamic>>(
            //   //     value: item,
            //   //     child: Text(item['mccTypeDesc'].toString()),
            //   //   );
            //   // }),
            //
            //   // cityList.map((e) => e['citName']).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       selectedBusinessSubCategory = value;
            //       merchantPersonalReq.poiType =
            //           getValueByLabel(merchantBusinessSubCategory, value);
            //     });
            //   },
            //   onSaved: (value) {
            //     //merchantPersonalReq.poiType = value;
            //     // merchantPersonalReq.poiType = getValueByLabel(merchantBusinessSubList, value);
            //   },
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Merchant Business Sub is Mandatory!';
            //     }
            //     return null;
            //   },
            // ),

            defaultHeight(10),

            const CustomDropdown(
              title: "Merchant Annual Business Turnover",
              itemList: [],
              dropDownIsEnabled: false,
              required: true,
            ),

            DropdownButtonFormField(
              isDense: true,
              isExpanded: true,
              decoration: commonInputDecoration(Icons.location_city_outlined,
                      hintText: "Select Merchant Annual Business Turnover")
                  .copyWith(
                      hintStyle: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.25))),
              value: selectedBussinesTurnOver,
              items:
                  businessTurnoverList.map<DropdownMenuItem>((dynamic value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value['turnoverAmount'],
                    style: TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  setState(() {
                    selectedBussinesTurnOver = newValue;
                    companyDetailsInforeq.annualTurnOver =
                        newValue['turnoverAmount'];
                    print(companyDetailsInforeq.annualTurnOver);
                  });
                });
              },
            ),

            // CustomDropdown(
            //   hintText: "Select Merchant Annual Business Turnover",
            //   title: "Merchant Annual Business Turnover",
            //   required: true,
            //   selectedItem: selectedBussinesTurnOver != ''
            //       ? selectedBussinesTurnOver
            //       : null,
            //   prefixIcon: Icons.location_city_outlined,
            //   itemList: businessTurnoverList
            //       .map((map) => map['turnoverAmount'].toString())
            //       .toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       selectedBussinesTurnOver = value;
            //     });
            //   },
            //   onSaved: (value) {
            //     companyDetailsInforeq.annualTurnOver = value;
            //   },
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Business Turnover Mandatory!';
            //     }
            //     return null;
            //   },
            // ),

            CustomTextFormField(
              hintText: "Enter merchant business address",
              title: 'Merchant Business Address',

              controller: _merchantBusinessAddressController,
              prefixIcon: Icons.home,
              required: true,
              maxLength: 100,

              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                // Allow only letters and numbers
              ],

              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.words,
              enabled: true,
              // prefixIcon: LineAwesome.address_book,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Merchant Business Address is Mandatory!';
                }
                if (value.length < 10) {
                  return 'Minimum 10 characters';
                }

                return null;
              },
              onChanged: (String value) {},
              onSaved: (value) {
                print(value);
                companyDetailsInforeq.merchantAddress = value;
              },
              onFieldSubmitted: (value) {
                _merchantBusinessAddressController.text = value.trim();
              },
            ),

            const SizedBox(
              height: 15.0,
            ),

            // DropdownButtonFormField(
            //   isDense: true,
            //   isExpanded: true,
            //   decoration: commonInputDecoration(
            //       Icons.location_city_outlined,
            //       hintText: "Select State"
            //   ).copyWith(hintStyle: Theme.of(context)
            //       .textTheme
            //       .displaySmall
            //       ?.copyWith(fontWeight: FontWeight.normal, fontSize: 13,color: Colors.black.withOpacity(0.25))),
            //   value: selectedBusinessState,
            //   items: statesList
            //       .map<DropdownMenuItem>((dynamic value) {
            //     return DropdownMenuItem(
            //       value: value,
            //       child: Text(
            //         value['stateName'],
            //         style: TextStyle(fontSize: 13),
            //       ),
            //     );
            //   }).toList(),
            //   onChanged: (newValue) {
            //     setState(() {
            //       selectedBusinessState = newValue;
            //     });
            //   },
            // ),

            CustomDropdown(
              titleEnabled: false,
              hintText: "Select State",
              title: "Current State",
              // enabled: selectedState != '' && enabledState
              //     ? enabledcity = true
              //     : enabledcity = false,
              required: true,
              selectedItem:
                  selectedBusinessState != '' ? selectedBusinessState : null,
              prefixIcon: Icons.flag_circle_outlined,

              // itemList: statesList.map((item) => item['stateName']).toList(),
              itemList: statesList
                  .where((item) =>
                      item['tmsMasterCountry'] != null &&
                      item['tmsMasterCountry']['countryIsoNumId'] == 356)
                  .map((item) => item['stateName'])
                  .toList(),
// ((item) =>
//                           item['mccGroupId']['mccGroupId'] ==
//                           selectedBusinessCategory['mccGroupId'])
              // cityList.map((e) => e['citName']).toList(),
              onChanged: (value) {
                setState(() {
                  // selectedBusinessState = value;
                  selectedCity = '';
                  selectedBusinessState = value;
                  selectedBusinessStateId = (statesList
                      .where((element) => element['stateName'] == value)
                      .toList())[0]['stateId'];

                  print(selectedBusinessStateId);

                  companyDetailsInforeq.stateId = selectedBusinessStateId;

                  print(merchantPersonalReq.currentState);

                  // String stateString=;
                });
              },
              onSaved: (value) {
                companyDetailsInforeq.stateId = selectedBusinessStateId;
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
              titleEnabled: false,
              title: "Current City",
              hintText: "Select City",
              required: true,
              selectedItem: selectedCity != '' ? selectedCity : null,
              prefixIcon: Icons.location_city_outlined,

              // itemList: citiesList.map((item) => item['cityName']).toList(),

              itemList: citiesList
                  .where((item) => item['stateId'] == selectedBusinessStateId)
                  .map((item) => item['cityName'])
                  .toList(),

              // itemList= citiesList
              //     .map(
              //         (item) => item['stateId'] == selectedBusinessStateId)
              //     .map((item) => item['cityName']),

              // itemList:  citiesList
              //         .where(
              //             (item) => item['stateId'] == selectedBusinessStateId)
              //         .map<DropdownMenuItem>((dynamic value) {
              //         return DropdownMenuItem<dynamic>(
              //           value: value,
              //           child: Text(
              //             value['cityName'],
              //             style: const TextStyle(fontSize: 13),
              //           ),
              //         );
              //       }).toList()

              //cityList.map((e) => e['citName']).toList(),

              onChanged: (value) {
                print(value);
                setState(() {
                  selectedCity = value;

                  selectedBusinessCityId = (citiesList
                      .where((element) => element['cityName'] == value)
                      .toList())[0]['cityId'];

                  print(selectedBusinessCityId);

                  companyDetailsInforeq.cityCode = selectedBusinessCityId;

                  print(selectedBusinessCityId);
                });
              },

              onSaved: (value) {
                companyDetailsInforeq.cityCode = selectedBusinessCityId;
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
              controller: _PinCodeCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'\d'))
              ],
              prefixIcon: Icons.map_outlined,
              onSaved: (value) {
                companyDetailsInforeq.zipCode = value;
              },
            ),

            const SizedBox(
              height: 20.0,
            ),

            CustomAppButton(
              title: "Next",
              onPressed: () async {
                // setState(() {
                //   position++;
                //   currTabPosition = 2;
                // });

                personalFormKey.currentState!.save();
                if (personalFormKey.currentState!.validate()) {
                  print(companyDetailsInforeq.toJson());
                  setState(() {
                    position++;
                    currTabPosition = 2;
                  });
                }
              },
            ),
            const SizedBox(
              height: 20.0,
            ),
          ],
        ));
  }

  Widget merchantIdproof() {
    var screenHeight = MediaQuery.of(context).size.height;

    return Form(
      key: loginFormKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Row(
              children: [
                CustomTextWidget(
                  text: "Merchant KYC",
                  size: 18,
                ),
              ],
            ),

            const SizedBox(height: 10),
            appTabbar(
              screenHeight: screenHeight,
              currTabPosition: currTabPosition,
            ),

            const FormTitleWidget(subWord: 'Merchant ID proof'),
            const SizedBox(height: 10),
            CustomTextFormField(
              hintText: "Enter merchant PAN number",
              controller: _merchantPanController,
              title: 'Merchant PAN',
              required: true,
              prefixIcon: Icons.format_list_numbered,
              //iconColor: showVerify ? Colors.red : Colors.green,
              onFieldSubmitted: (name) {
                // getUser();
                // validatePan();
              },
              onChanged: (String value) {
                setState(() {
                  if (value.isEmpty ||
                      !userVerify ||
                      userCheck.toString() == "true" ||
                      !RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                          .hasMatch(value)) {
                  } else {}
                });
              },

              suffixIconTrue: true,
              suffixIcon: showVerify
                  ? TextButton(
                      onPressed: () {
                        if (_merchantPanController.text.length >= 10) {
                          print("clicked");
                          if (showVerify) {
                            validatePan();
                            print("validate");
                          } else {
                            print("change");

                            setState(() {
                              showVerify = true;
                            });
                          }
                        }
                      },
                      child: Text("Verify"))
                  : VerificationSuccessButton(),
              helperStyle: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).primaryColor),
              inputFormatters: <TextInputFormatter>[PanNumberFormatter()],
              // suffixText: showVerify ? 'Verify' : 'Change',
              readOnly: !showVerify,
              helperText: merchantPanHelperText,
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
                merchantIdProofReq.panNo = value;
              },
            ),
            // userNameWidget(),

            CustomTextFormField(
              hintText: "Enter merchant Aadhaar number",
              keyboardType: TextInputType.number,
              controller: _merchantAddharController,
              title: 'Merchant Aadhaar Number',
              required: true,
              prefixIcon: Icons.format_list_numbered,
              onFieldSubmitted: (name) {
                //getUser();
              },
              helperText: isOtpVerifird ? "Verified" : "",
              suffixIconOnPressed: () {
                if (_merchantAddharController.text.length >= 12) {
                  print("clicked");
                  if (showaddharverify) {
                    sendAddhaarOtp();
                    print("validate");
                  } else {
                    print("change");

                    setState(() {
                      showaddharverify = true;
                      isaddhaarOTPsent = false;
                      isOtpVerifird = false;
                    });
                  }
                }
              },
              suffixIcon: showaddharverify
                  ? TextButton(
                      onPressed: () {
                        if (_merchantAddharController.text.length >= 12) {
                          print("clicked");
                          if (showaddharverify) {
                            sendAddhaarOtp();
                            print("validate");
                          } else {
                            print("change");

                            setState(() {
                              showaddharverify = true;
                              isaddhaarOTPsent = false;
                              isOtpVerifird = false;
                            });
                          }
                        }
                      },
                      child: Text("Verify"))
                  : VerificationSuccessButton(),
              suffixIconTrue: true,
              helperStyle: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).primaryColor),
              suffixText: showaddharverify ? 'Send OTP' : 'Change',
              readOnly: !showaddharverify,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9]'))
              ],
              maxLength: 12,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Aadhaar Number is Mandatory!';
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
                merchantIdProofReq.aadharCardNo = value;
              },
            ),

            if (isaddhaarOTPsent)
              CustomTextFormField(
                keyboardType: TextInputType.number,
                controller: _otpController,
                title: 'Enter OTP',
                required: true,
                // prefixIcon: Icons.verified,
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
                  print("clicked");
                  print(_otpController.text.length);
                  if (_otpController.text.isNotEmpty) {
                    validateAddhaarOtp();
                  }
                },
                suffixIconTrue: true,
                helperStyle: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).primaryColor),

                suffixText: "Verify",
                helperText: "Click verify",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Otp is Mandatory!';
                  }
                  if (value.length < 6) {
                    return 'Minimum length is 6 digit';
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

            if (isaddhaarOTPsent) const SizedBox(height: 30.0),

            CustomAppButton(
              title: 'Next',
              onPressed: () {
                if (loginFormKey.currentState!.validate()) {
                  loginFormKey.currentState!.save();
                  print(merchantIdProofReq.toJson());

                  setState(() {
                    position++; //old 2
                    currTabPosition = 3;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
          ]),
    );
  }

  Widget merchantBusinessProof() {
    var screenHeight = MediaQuery.of(context).size.height;

    print('currTabPosition$currTabPosition');

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Form(
          key: personalFormKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Row(
                children: [
                  CustomTextWidget(
                    text: "Merchant KYC",
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              appTabbar(
                screenHeight: screenHeight,
                currTabPosition: currTabPosition,
              ),
              const SizedBox(height: 30.0),
              const FormTitleWidget(subWord: 'Merchant Business Proofs'),
              CustomTextFormField(
                keyboardType: TextInputType.text,
                controller: _gstController,
                title: 'Merchant GST Number',
                hintText: "Enter merchant GST number",
                required: true,
                maxLength: 15,
                prefixIcon: Icons.format_list_numbered,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
                ],
                onFieldSubmitted: (name) {
                  // getUser();
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
                  if (_gstController.text.length >= 15) {
                    print("clicked");
                    if (isgstVerify) {
                      validategst();
                      print("validate");
                      //validateAccountNumber();
                    } else {
                      print("change");

                      setState(() {
                        isgstVerify = true;
                      });
                    }
                  }

                  print("clicked");
                  // isgstVerify
                  // userServices.
                  // if (_gstController.text.length >= 15) {
                  //   // sendAddhaarOtp();
                  // }
                },
                suffixIconTrue: true,

                helperStyle: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).primaryColor),
                //inputFormatters: <TextInputFormatter>[AadhaarNumberFormatter()],
                suffixText: isgstVerify ? 'Verify' : 'Change',
                // readOnly: !isgstVerify,
                helperText: gstHelperText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Gst Number is Mandatory!';
                  }

                  // if (userVerify && userCheck == "true") {
                  //   return Constants.userNameFailureMessage;
                  // }
                  if (!RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                      .hasMatch(value)) {
                    return 'Invalid Gst Number!';
                  }
                  return null;
                },
                onSaved: (value) {
                  businessIdProofReq.gstnNo = value;
                },
              ),
              CustomTextFormField(
                controller: _firmPanController,
                title: 'Merchant Firm PAN Number',
                hintText: "Enter merchant PAN number",
                required: true,
                prefixIcon: Icons.format_list_numbered,
                inputFormatters: <TextInputFormatter>[PanNumberFormatter()],
                onFieldSubmitted: (name) {
                  //getUser();
                },
                suffixIconOnPressed: () {
                  if (_firmPanController.text.length >= 10) {
                    if (showFirmPanVerify) {
                      validateFirmPan();
                      print("validate");
                      //validateAccountNumber();
                    } else {
                      print("change");

                      setState(() {
                        showFirmPanVerify = true;
                      });
                    }
                  }
                },
                suffixIconTrue: true,
                helperStyle: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).primaryColor),
                suffixText: showFirmPanVerify ? 'verify' : 'Change',
                readOnly: !showFirmPanVerify,
                helperText: merchantPanHelpertext,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'FirmPan number Mandatory!';
                  }
                  if (value.length < 10) {
                    return 'Minimum character length is 10';
                  }
                  // if (userVerify && userCheck == "true") {
                  //   return Constants.userNameFailureMessage;
                  // }
                  if (!RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                      .hasMatch(value)) {
                    return 'Invalid pan Number!';
                  }
                  return null;
                },
                onSaved: (value) {
                  businessIdProofReq.firmPanNo = value;
                },
              ),
            ],
          ),
        ),
        Form(
          key: documentFormkey,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              // CustomDropdown(
              //   title: "Merchant Business Proof Document",
              //   titleEnabled: true,
              //   required: true,
              //   enabled: false,
              //   dropDownIsEnabled: false,
              //   hintText: "Select merchant business proof document",
              //   selectedItem:
              //       businessDocumentType != '' ? businessDocumentType : null,
              //   prefixIcon: Icons.maps_home_work_outlined,
              //   itemList: merchantProofDocumentList
              //       .map((map) => map['businessType'].toString())
              //       .toList(),
              //   //countryList.map((e) => e['ctyName']).toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       print(merchantProofDocumentList);

              //       businessDocumentType = value;
              //       merchantPersonalReq.poaType =
              //           getValueByLabel(merchantProofDocumentList, value);
              //     });
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'POA Type is Mandatory!';
              //     }
              //     return null;
              //   },
              //   onSaved: (newValue) {
              //     // businessIdProofReq.businessProofDocumntType = newValue;

              //     if (merchantProofDocumentList
              //             .where(
              //                 (element) => element['businessType'] == newValue)
              //             .toList()
              //             .length ==
              //         0) return;

              //     businessIdProofReq.businessProofDocumntType =
              //         (merchantProofDocumentList
              //             .where(
              //                 (element) => element['businessType'] == newValue)
              //             .toList())[0]['businessDocId'];

              //     // print(businessIdProofReq.businessProofDocumntType);
              //   },
              // ),
              Row(
                children: [
                  const CustomTextWidget(
                    text: "Merchant Business Proof Document",
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              DropdownButtonFormField(
                isDense: true,
                isExpanded: true,
                decoration: commonInputDecoration(Icons.maps_home_work_outlined,
                        hintText: "Select merchant business proof document")
                    .copyWith(
                        hintStyle: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                                color: Colors.black.withOpacity(0.25))),
                value: businessProofType,
                items: merchantProofDocumentList
                    .map<DropdownMenuItem>((dynamic value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value['businessType'],
                      style: TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    print(newValue);
                    businessProofType = newValue;
                    businessDocumentTypename = newValue["businessType"];
                    businessDocumentTypeId = newValue["businessDocId"];
                    print(newValue["businessType"]);
                    print(newValue["businessDocId"]);
                    // businessType = newValue;
                    // companyDetailsInforeq.businessTypeId =
                    //     newValue['businessType'].runtimeType == String
                    //         ? int.parse(newValue['businessType'])
                    //         : newValue['businessType'];
                    // // companyDetailsInforeq.businessTypeId = 1;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select Business Type!';
                  }

                  return null;
                },
              ),
              CustomTextFormField(
                onTap: _openFilePicker,
                title: 'Upload Business Proof Document',
                hintText:
                    "Upload selected business proof document\n(format : pdf)",
                controller: businessProofDocumentCtrl,
                required: true,
                enabled: true,
                readOnly: true,
                prefixIcon: LineAwesome.file,
                fromDocument: true,
                onSaved: (value) {},
                onFieldSubmitted: (value) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Business Proof Document is Mandatory!';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                fromDocument: true,
                title: 'Document Expiry Date',
                hintText:
                    "Please enter the uploaded document\nexpiry date (DD/MM/YY)",
                required: true,
                enabled: true,
                controller: documentExpiryController,
                prefixIcon: LineAwesome.calendar,
                readOnly: true,
                onTap: () async {
                  print('ontap');
                  DateTime? pickedDate = await showDatePicker(
                    initialDatePickerMode: DatePickerMode.day,
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                    context: context,
                    initialDate: tradeSelectedDate,
                    firstDate: DateTime.now().add(const Duration(days: 0)),
                    lastDate: DateTime(DateTime.now().year + 10),
                  );
                  if (pickedDate != null) {
                    String formattedDateUI =
                        DateFormat('dd/MM/yyyy').format(pickedDate);
                    setState(() {
                      tradeSelectedDate = pickedDate;

                      documentExpiryController.text = formattedDateUI;
                    });
                  } else {}
                  if (pickedDate != null) {
                    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                        .format(pickedDate);
                    businessIdProofReq.businessProofDocumtExpiry =
                        formattedDate;
                    print('Formatted Date: ${formattedDate}Z');
                  }
                },
                validator: (value) {
                  print('helloooo');

                  if (value == null || value.isEmpty) {
                    return 'Expiry Date is Mandatory!';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30.0,
              ),
            ],
          ),
        ),
        IconButton(
            onPressed: () async {
              print('validateAction');
              documentFormkey.currentState!.save();
              if (documentFormkey.currentState!.validate()) {
                setState(() {
                  selectedBusinessProofItems.add(SelectedBusinessProof(
                      businessProofDocumentExpiry:
                          documentExpiryController.text,
                      businessProofId: businessDocumentTypeId!,
                      businessProofName: businessDocumentTypename!,
                      businessProofFileName: businessProofDocumentCtrl.text));
                });

                businessProofDocumentCtrl.clear();
                documentExpiryController.clear();
                businessDocumentTypeId = "";
                businessProofType = null;
              } else {
                print("form not validated");
                // Reset validation state if form is not validated
              }
            },
            icon: Row(
              children: [
                Image.asset(
                  "assets/app_icons/add_icon.png",
                  height: 50,
                  color: AppColors.kPrimaryColor,
                ),
                defaultWidth(10),
                const CustomTextWidget(
                  text: 'Add Document',
                  color: AppColors.kLightGreen,
                  fontWeight: FontWeight.w500,
                  size: 16,
                )
              ],
            )),
        const SizedBox(
          height: 40.0,
        ),
        if (selectedBusinessProofItems.isNotEmpty)
          Container(
            color: AppColors.kTileColor,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                children: [
                  DataTable(
                    // headingRowHeight: 0,
                    columnSpacing: 8,
                    dataRowMinHeight: 20,
                    dataRowMaxHeight: 30,
                    columns: [
                      const DataColumn(label: Text('Name')),
                      const DataColumn(label: Text('Expy Date')),
                      const DataColumn(label: Text('')),
                    ],
                    rows: selectedBusinessProofItems.map((item) {
                      return DataRow(cells: [
                        DataCell(SizedBox(
                          width: 100,
                          child: CustomTextWidget(
                            text: item.businessProofName.toString(),
                            size: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        )),
                        // DataCell(CustomTextWidget(
                        //   text: "${item.productName}+ 1499+499",
                        //   size: 11,
                        //   fontWeight: FontWeight.w900,
                        // )),
                        DataCell(CustomTextWidget(
                          text: item.businessProofDocumentExpiry.toString(),
                          size: 12,
                          fontWeight: FontWeight.w900,
                        )),
                        DataCell(
                          IconButton(
                            icon: const Icon(
                              Icons.cancel_outlined,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                selectedBusinessProofItems.remove(item);
                              });
                            },
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                  defaultHeight(15),
                  Container(
                    color: AppColors.kSelectedBackgroundColor,
                    child: ExpansionTile(
                      title: CustomTextWidget(
                        text: "View Complete order Summary",
                        color: Colors.grey.shade600,
                        size: 10,
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("content"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        CustomAppButton(
          title: "Next",
          onPressed: () async {
            personalFormKey.currentState!.save();
            if (personalFormKey.currentState!.validate()) {
              if (selectedBusinessProofItems.isEmpty) {
                alertWidget.error("plese Add Document");
              } else {
                print(jsonEncode(businessIdProofReq.toJson()));
                setState(() {
                  currTabPosition = 2;
                  position++;
                });
              }
            }
          },
        ),
        const SizedBox(
          height: 20.0,
        ),
      ],
    );
  }

  Widget merchantBankDetails() {
    var screenHeight = MediaQuery.of(context).size.height;

    return Form(
        key: loginFormKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CustomTextWidget(
                    text: "Merchant KYC",
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              appTabbar(
                screenHeight: screenHeight,
                currTabPosition: currTabPosition,
              ),
              const FormTitleWidget(subWord: 'Merchant Bank Details'),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: merchantAccountNumberCtrl,
                title: 'Merchant Bank Account Details',
                hintText: "Enter merchant account number",
                required: true,
                prefixIcon: Icons.person,
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
                    } else {}
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
                    return 'Minimum digits length is 10';
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
                  merchantBankInfoReq.bankAccountNo = value;
                },
              ),
              CustomTextFormField(
                titleEneabled: false,
                controller: merchantIfscCodeCtrl,
                title: 'IFSC Code',
                hintText: "Enter IFSC code",
                required: true,
                prefixIcon: Icons.numbers,
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
                  merchantBankInfoReq.bankIfscCode = value;
                },
              ),
              CustomDropdown(
                title: "Select Bank",
                hintText: "Select bank",
                titleEnabled: false,
                required: true,
                //enabled: accountVerify,
                selectedItem: ifscCode != '' ? ifscCode : null,
                prefixIcon: FontAwesome.building_solid,
                itemList: merchantBankList
                    .map((map) => map['bankName'].toString())
                    .toList(),
                //countryList.map((e) => e['ctyName']).toList(),
                onChanged: (value) {
                  setState(() {
                    // print(merchantBankList);
                    ifscCode = value;

                    // requestModel.city = value;
                  });
                },
                onSaved: (value) {
                  // merchantBankInfoReq.bankNameId = value;
                  merchantBankInfoReq.bankNameId = (merchantBankList
                          .where((element) => element['bankName'] == value)
                          .toList())[0]['bankId']
                      .toString();
                  print(merchantBankInfoReq.bankNameId);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Select a Bank!';
                  }
                  return null;
                },
              ),
              CustomTextFormField(
                title: 'Beneficiary Name',
                hintText: "Beneficiary name",
                titleEneabled: false,
                required: true,
                // readOnly: !accountVerify,
                controller: merchantBeneficiaryNamrCodeCtrl,
                maxLength: 24,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.words,
                prefixIcon: LineAwesome.store_alt_solid,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]'))
                ],
                onSaved: (value) {
                  merchantBankInfoReq.beneficiaryName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Beneficiary Name Mandatory!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              CustomTextWidget(text: "Cheque Image"),
              cancelledChequeImg != ''
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          cancelledChequeImg = '';
                        });
                      },
                      child: afterSelect(cancelledChequeImg),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: () {
                          cameraPhotoDialog(context, 'cancelledChequeImg');
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    CustomTextWidget(
                                        text:
                                            "Click the image of a cancelled cheque",
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
              SizedBox(
                height: 30,
              ),
              CustomAppButton(
                title: 'Next',
                onPressed: () {
                  if (loginFormKey.currentState!.validate()) {
                    loginFormKey.currentState!.save();
                    setState(() {
                      position++;
                      currTabPosition = 5;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
            ]));
  }

  Widget review() {
    var screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Form(
        key: loginFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextWidget(text: "Merchant Agreement"),

            appTabbar(
              screenHeight: screenHeight,
              currTabPosition: currTabPosition,
            ),

            const CustomDropdown(
              hintText: "Select applicable MDR type",
              title: "MDR Type",
              itemList: [],
              dropDownIsEnabled: false,
              required: true,
            ),

            DropdownButtonFormField(
              isDense: true,
              isExpanded: true,
              decoration: commonInputDecoration(FontAwesome.building,
                      hintText: "Select applicable MDR type")
                  .copyWith(
                      hintStyle: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                              fontWeight: FontWeight.normal,
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.25))),
              value: mdrType,
              items: mdrTypeList.map<DropdownMenuItem>((dynamic value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value['mdrType'],
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  mdrType = newValue;
                  getMdrSummaryList(mdrType['mdrType']);

                  merchantAgreeMentReq.serviceAgreement = true;
                  merchantAgreeMentReq.termsCondition = true;

                  merchantAgreeMentReq.mdrType = mdrType['mdrId'];

                  // requestModel.city = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'MDR Type is Mandatory!';
                }
                return null;
              },
            ),

            // CustomDropdown(
            //   hintText: "Select applicable MDR type",
            //   title: "MDR Type",
            //   required: true,
            //   selectedItem: mdrType != '' ? mdrType : null,
            //   prefixIcon: FontAwesome.building,
            //   itemList: mdrTypeList
            //       .map((item) => item['mdrType'].toString())
            //       .toList(),
            //   //countryList.map((e) => e['ctyName']).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       mdrType = value;
            //       getMdrSummaryList(mdrType);
            //
            //       // requestModel.city = value;
            //     });
            //   },
            //   onSaved: (value) {
            //     // merchantAgreeMentReq.mdrType = 1;
            //     merchantAgreeMentReq.mdrType = (mdrTypeList
            //         .where((element) => element['mdrType'] == mdrType)
            //         .toList())[0]['mdrId'];
            //
            //     merchantAgreeMentReq.serviceAgreement = true;
            //     merchantAgreeMentReq.termsCondition = true;
            //   },
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'MDR Type is Mandatory!';
            //     }
            //     return null;
            //   },
            // ),

            const SizedBox(
              height: 20,
            ),
            const CustomTextWidget(text: "MDR Summary"),
            const SizedBox(
              height: 5,
            ),

            Container(
              color: AppColors.kTileColor,
              child: Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * .025),
                child: Column(
                  children: [
                    Wrap(children: [
                      for (var item in mdrSummaryList)
                        Container(
                          margin: EdgeInsets.only(
                              top: screenHeight * .015,
                              left: mdrSummaryList.indexOf(item) % 2 == 0 || item['dcTxnAmount'] != null
                                  ? 0
                                  : MediaQuery.of(context).size.width * .025),
                          width: item['dcTxnAmount'] == null?((MediaQuery.of(context).size.width) -
                              ((MediaQuery.of(context).size.width * .025) *
                                  3) -
                              30) /
                              2:double.infinity,
                          padding: item['dcTxnAmount'] != null?EdgeInsets.all(MediaQuery.of(context).size.width * .025):EdgeInsets.all(0),
                          // width:double.infinity,
                          color: item['dcTxnAmount'] != null
                              ? Colors.white
                              : Colors.transparent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: item['dcTxnAmount'] == null
                                    ? CrossAxisAlignment.center
                                    : CrossAxisAlignment.start,
                                children: [


                                  Expanded(
                                    child: CustomTextWidget(
                                      text:
                                      '${item['paymentName']} ${item['dcTxnAmount'] == null ? '-' : ''}',
                                      isBold: true,
                                      size: 11,
                                    ),
                                  ),

                                  if (item['dcTxnAmount'] == null && isEditable)
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  '${item['paymentName']}'),
                                              titleTextStyle: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontFamily: 'Mont'),
                                              content: Column(
                                                mainAxisSize:
                                                MainAxisSize.min,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                      'Please enter your value'),
                                                  SizedBox(
                                                      height: MediaQuery.of(
                                                          context)
                                                          .size
                                                          .height *
                                                          .01),
                                                  Container(
                                                    width: double.infinity,
                                                    height:
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                        .06,
                                                    padding: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                            context)
                                                            .size
                                                            .width *
                                                            .025),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .black
                                                                .withOpacity(
                                                                .1)),
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(5)),
                                                    child: TextFormField(
                                                      onChanged: (value) {
                                                        final double
                                                        parsedValue =
                                                            double.tryParse(
                                                                value) ??
                                                                0.0;

                                                        setState(() {
                                                          item['amount'] =
                                                              value;
                                                        });

                                                        if (parsedValue >
                                                            100) {
                                                          setState(() {
                                                            item['amount'] =
                                                            '100.00';
                                                          });
                                                        }

                                                        print(
                                                            mdrSummaryList[0]
                                                            ['amount']);
                                                      },
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(
                                                          RegExp(
                                                              r'^\d{0,3}(\.\d{0,2})?$'), // Allows up to 3 digits (0-100) and optional decimal with up to 2 digits
                                                        ),
                                                      ],
                                                      keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                      maxLength: 6,
                                                      enabled: true,
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                          Colors.black),
                                                      decoration:
                                                      const InputDecoration(
                                                        border:
                                                        InputBorder.none,
                                                        counterText: '',
                                                      ),
                                                      initialValue:
                                                      '${item['amount'] ?? item['dcTxnAmount']}',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width *
                                            .18,
                                        height:
                                        MediaQuery.of(context).size.height *
                                            .04,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .02),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                Colors.black.withOpacity(.1)),
                                            borderRadius:
                                            BorderRadius.circular(5)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [

                                            CustomTextWidget(
                                              text:
                                              '${item['amount'] ?? item['dcTxnAmount']}',
                                              isBold: true,
                                              size: 11,
                                            ),
                                            const Spacer(),
                                            // TextFormField(
                                            //   onChanged: (value) {
                                            //     final double parsedValue =
                                            //         double.tryParse(value) ?? 0.0;
                                            //
                                            //     TextEditingController(text: value);
                                            //
                                            //     // setState(() {
                                            //     //   item['amount'] = value;
                                            //     // });
                                            //     //
                                            //     // if (parsedValue > 100) {
                                            //     //   setState(() {
                                            //     //     item['amount'] = '100.00';
                                            //     //   });
                                            //     // }
                                            //   },
                                            //   inputFormatters: [
                                            //     FilteringTextInputFormatter.allow(
                                            //       RegExp(
                                            //           r'^\d{0,3}(\.\d{0,2})?$'), // Allows up to 3 digits (0-100) and optional decimal with up to 2 digits
                                            //     ),
                                            //   ],
                                            //   keyboardType: const TextInputType
                                            //       .numberWithOptions(decimal: true),
                                            //   maxLength: 6,
                                            //   enabled: false,
                                            //   style: const TextStyle(
                                            //       fontSize: 14, color: Colors.black),
                                            //   decoration: const InputDecoration(
                                            //     border: InputBorder.none,
                                            //     counterText: '',
                                            //   ),
                                            //   controller: TextEditingController(
                                            //       text:
                                            //       '${item['amount'] ?? item['dcTxnAmount']}'),
                                            // ),
                                            if (isEditable && item['dcTxnAmount'] == null)
                                             const Icon(
                                                  Icons.edit,
                                                  size: 15,
                                                ),


                                          ],
                                        ),
                                      ),
                                    ),

                                  if (item['dcTxnAmount'] == null &&
                                      !isEditable)
                                    Expanded(
                                      child: CustomTextWidget(
                                        text:
                                        '${item['amount'] ?? item['dcTxnAmount']}',
                                        isBold: true,
                                        size: 11,
                                      ),
                                    ),

                                  if (item['dcTxnAmount'] == null &&
                                      !isEditable)
                                    if (mdrSummaryList.indexOf(item) % 2 == 0)
                                      const Expanded(
                                        child: CustomTextWidget(
                                          text: '|',
                                          isBold: true,
                                          size: 11,
                                        ),
                                      ),



                                  // if (isEditable && item['dcTxnAmount'] == null)
                                  //   Padding(
                                  //     padding: const EdgeInsets.only(left: 8.0),
                                  //     child: GestureDetector(
                                  //       onTap: () {
                                  //         showDialog(
                                  //           context: context,
                                  //           builder: (BuildContext context) {
                                  //             return AlertDialog(
                                  //               title: Text(
                                  //                   '${item['paymentName']}'),
                                  //               titleTextStyle: const TextStyle(
                                  //                   color: Colors.black,
                                  //                   fontSize: 18,
                                  //                   fontFamily: 'Mont'),
                                  //               content: Column(
                                  //                 mainAxisSize:
                                  //                 MainAxisSize.min,
                                  //                 crossAxisAlignment:
                                  //                 CrossAxisAlignment.start,
                                  //                 children: [
                                  //                   const Text(
                                  //                       'Please enter your value'),
                                  //                   SizedBox(
                                  //                       height: MediaQuery.of(
                                  //                           context)
                                  //                           .size
                                  //                           .height *
                                  //                           .01),
                                  //                   Container(
                                  //                     width: double.infinity,
                                  //                     height:
                                  //                     MediaQuery.of(context)
                                  //                         .size
                                  //                         .height *
                                  //                         .06,
                                  //                     padding: EdgeInsets.only(
                                  //                         left: MediaQuery.of(
                                  //                             context)
                                  //                             .size
                                  //                             .width *
                                  //                             .025),
                                  //                     decoration: BoxDecoration(
                                  //                         border: Border.all(
                                  //                             color: Colors
                                  //                                 .black
                                  //                                 .withOpacity(
                                  //                                 .1)),
                                  //                         borderRadius:
                                  //                         BorderRadius
                                  //                             .circular(5)),
                                  //                     child: TextFormField(
                                  //                       onChanged: (value) {
                                  //                         final double
                                  //                         parsedValue =
                                  //                             double.tryParse(
                                  //                                 value) ??
                                  //                                 0.0;
                                  //
                                  //                         setState(() {
                                  //                           item['amount'] =
                                  //                               value;
                                  //                         });
                                  //
                                  //                         if (parsedValue >
                                  //                             100) {
                                  //                           setState(() {
                                  //                             item['amount'] =
                                  //                             '100.00';
                                  //                           });
                                  //                         }
                                  //
                                  //                         print(
                                  //                             mdrSummaryList[0]
                                  //                             ['amount']);
                                  //                       },
                                  //                       inputFormatters: [
                                  //                         FilteringTextInputFormatter
                                  //                             .allow(
                                  //                           RegExp(
                                  //                               r'^\d{0,3}(\.\d{0,2})?$'), // Allows up to 3 digits (0-100) and optional decimal with up to 2 digits
                                  //                         ),
                                  //                       ],
                                  //                       keyboardType:
                                  //                       const TextInputType
                                  //                           .numberWithOptions(
                                  //                           decimal: true),
                                  //                       maxLength: 6,
                                  //                       enabled: true,
                                  //                       style: const TextStyle(
                                  //                           fontSize: 14,
                                  //                           color:
                                  //                           Colors.black),
                                  //                       decoration:
                                  //                       const InputDecoration(
                                  //                         border:
                                  //                         InputBorder.none,
                                  //                         counterText: '',
                                  //                       ),
                                  //                       initialValue:
                                  //                       '${item['amount'] ?? item['dcTxnAmount']}',
                                  //                     ),
                                  //                   ),
                                  //                 ],
                                  //               ),
                                  //               actions: [
                                  //                 TextButton(
                                  //                   onPressed: () {
                                  //                     Navigator.of(context)
                                  //                         .pop(); // Close the dialog
                                  //                   },
                                  //                   child: Text('OK'),
                                  //                 ),
                                  //               ],
                                  //             );
                                  //           },
                                  //         );
                                  //       },
                                  //       child: const Icon(
                                  //         Icons.edit,
                                  //         size: 18,
                                  //       ),
                                  //     ),
                                  //   ),

                                  // CustomTextWidget(
                                  //     text: mdrSummaryList.indexOf(item) % 2 == 0
                                  //         ? '|'
                                  //         : ''),
                                ],
                              ),
                              if (item['dcTxnAmount'] != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [


                                    SizedBox(
                                      height: screenHeight * .01,
                                    ),
                                    Row(

                                      children: [
                                        Expanded(
                                          child: CustomTextWidget(
                                            text:
                                            'Amount less than ${item['dcTxnAmount']} (%)  ${!isEditable?'  -   ${item['amountLePercent']}':''} ',

                                            size: 11,
                                          ),
                                        ),


                                        if (isEditable)
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                      'amt LT ${item['dcTxnAmount']} (%)'),
                                                  titleTextStyle:
                                                  const TextStyle(
                                                      color:
                                                      Colors.black,
                                                      fontSize: 18,
                                                      fontFamily:
                                                      'Mont'),
                                                  content: Column(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      const Text(
                                                          'Please enter your value'),
                                                      SizedBox(
                                                          height: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .height *
                                                              .01),
                                                      Container(
                                                        width:
                                                        double.infinity,
                                                        height: MediaQuery.of(
                                                            context)
                                                            .size
                                                            .height *
                                                            .06,
                                                        padding: EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                context)
                                                                .size
                                                                .width *
                                                                .025),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                    .1)),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                5)),
                                                        child:
                                                        TextFormField(
                                                          onChanged:
                                                              (value) {
                                                            final double
                                                            parsedValue =
                                                                double.tryParse(
                                                                    value) ??
                                                                    0.0;

                                                            setState(() {
                                                              item['amountLePercent'] =
                                                                  value;
                                                            });

                                                            if (parsedValue >
                                                                100) {
                                                              setState(() {
                                                                item['amountLePercent'] =
                                                                '100.00';
                                                              });
                                                            }
                                                          },
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .allow(
                                                              RegExp(
                                                                  r'^\d{0,3}(\.\d{0,2})?$'), // Allows up to 3 digits (0-100) and optional decimal with up to 2 digits
                                                            ),
                                                          ],
                                                          keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal:
                                                              true),
                                                          maxLength: 6,
                                                          enabled: true,
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black),
                                                          decoration:
                                                          const InputDecoration(
                                                            border:
                                                            InputBorder
                                                                .none,
                                                            counterText: '',
                                                          ),
                                                          initialValue:
                                                          '${item['amountLePercent']}',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(
                                                            context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Container(

                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .18,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height *
                                                .04,

                                            padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    .025),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: isEditable?Colors.black
                                                        .withOpacity(.1):Colors.transparent),
                                                borderRadius:
                                                BorderRadius.circular(5)),
                                            child: Row(
                                              children: [


                                                CustomTextWidget(
                                                  text:
                                                  '${item['amountLePercent']}',
                                                  isBold: true,
                                                  size: 11,
                                                ),
                                                const Spacer(),

                                                // TextFormField(
                                                //   onChanged: (value) {
                                                //     final double parsedValue =
                                                //         double.tryParse(value) ?? 0.0;
                                                //
                                                //     TextEditingController(
                                                //         text: value);
                                                //
                                                //     // setState(() {
                                                //     //   item['amount'] = value;
                                                //     // });
                                                //     //
                                                //     // if (parsedValue > 100) {
                                                //     //   setState(() {
                                                //     //     item['amount'] = '100.00';
                                                //     //   });
                                                //     // }
                                                //   },
                                                //   inputFormatters: [
                                                //     FilteringTextInputFormatter.allow(
                                                //       RegExp(
                                                //           r'^\d{0,3}(\.\d{0,2})?$'), // Allows up to 3 digits (0-100) and optional decimal with up to 2 digits
                                                //     ),
                                                //   ],
                                                //   keyboardType: const TextInputType
                                                //       .numberWithOptions(
                                                //       decimal: true),
                                                //   maxLength: 6,
                                                //   enabled: false,
                                                //   style: const TextStyle(
                                                //       fontSize: 14,
                                                //       color: Colors.black),
                                                //   decoration: const InputDecoration(
                                                //     border: InputBorder.none,
                                                //     counterText: '',
                                                //   ),
                                                //   controller: TextEditingController(
                                                //       text:
                                                //       '${item['amountLePercent']}'),
                                                // ),
                                                if (isEditable )
                                                  const Icon(
                                                    Icons.edit,
                                                    size: 15,
                                                  ),

                                              ],
                                            ),
                                          ),
                                        ),


                                        // if (isEditable)
                                        //   Padding(
                                        //     padding: const EdgeInsets.only(
                                        //         left: 8.0),
                                        //     child: GestureDetector(
                                        //       onTap: () {
                                        //         showDialog(
                                        //           context: context,
                                        //           builder:
                                        //               (BuildContext context) {
                                        //             return AlertDialog(
                                        //               title: Text(
                                        //                   'amt LT ${item['dcTxnAmount']} (%)'),
                                        //               titleTextStyle:
                                        //               const TextStyle(
                                        //                   color:
                                        //                   Colors.black,
                                        //                   fontSize: 18,
                                        //                   fontFamily:
                                        //                   'Mont'),
                                        //               content: Column(
                                        //                 mainAxisSize:
                                        //                 MainAxisSize.min,
                                        //                 crossAxisAlignment:
                                        //                 CrossAxisAlignment
                                        //                     .start,
                                        //                 children: [
                                        //                   const Text(
                                        //                       'Please enter your value'),
                                        //                   SizedBox(
                                        //                       height: MediaQuery.of(
                                        //                           context)
                                        //                           .size
                                        //                           .height *
                                        //                           .01),
                                        //                   Container(
                                        //                     width:
                                        //                     double.infinity,
                                        //                     height: MediaQuery.of(
                                        //                         context)
                                        //                         .size
                                        //                         .height *
                                        //                         .06,
                                        //                     padding: EdgeInsets.only(
                                        //                         left: MediaQuery.of(
                                        //                             context)
                                        //                             .size
                                        //                             .width *
                                        //                             .025),
                                        //                     decoration: BoxDecoration(
                                        //                         border: Border.all(
                                        //                             color: Colors
                                        //                                 .black
                                        //                                 .withOpacity(
                                        //                                 .1)),
                                        //                         borderRadius:
                                        //                         BorderRadius
                                        //                             .circular(
                                        //                             5)),
                                        //                     child:
                                        //                     TextFormField(
                                        //                       onChanged:
                                        //                           (value) {
                                        //                         final double
                                        //                         parsedValue =
                                        //                             double.tryParse(
                                        //                                 value) ??
                                        //                                 0.0;
                                        //
                                        //                         setState(() {
                                        //                           item['amountLePercent'] =
                                        //                               value;
                                        //                         });
                                        //
                                        //                         if (parsedValue >
                                        //                             100) {
                                        //                           setState(() {
                                        //                             item['amountLePercent'] =
                                        //                             '100.00';
                                        //                           });
                                        //                         }
                                        //                       },
                                        //                       inputFormatters: [
                                        //                         FilteringTextInputFormatter
                                        //                             .allow(
                                        //                           RegExp(
                                        //                               r'^\d{0,3}(\.\d{0,2})?$'), // Allows up to 3 digits (0-100) and optional decimal with up to 2 digits
                                        //                         ),
                                        //                       ],
                                        //                       keyboardType:
                                        //                       const TextInputType
                                        //                           .numberWithOptions(
                                        //                           decimal:
                                        //                           true),
                                        //                       maxLength: 6,
                                        //                       enabled: true,
                                        //                       style: const TextStyle(
                                        //                           fontSize: 14,
                                        //                           color: Colors
                                        //                               .black),
                                        //                       decoration:
                                        //                       const InputDecoration(
                                        //                         border:
                                        //                         InputBorder
                                        //                             .none,
                                        //                         counterText: '',
                                        //                       ),
                                        //                       initialValue:
                                        //                       '${item['amountLePercent']}',
                                        //                     ),
                                        //                   ),
                                        //                 ],
                                        //               ),
                                        //               actions: [
                                        //                 TextButton(
                                        //                   onPressed: () {
                                        //                     Navigator.of(
                                        //                         context)
                                        //                         .pop(); // Close the dialog
                                        //                   },
                                        //                   child: Text('OK'),
                                        //                 ),
                                        //               ],
                                        //             );
                                        //           },
                                        //         );
                                        //       },
                                        //       child: const Icon(
                                        //         Icons.edit,
                                        //         size: 18,
                                        //       ),
                                        //     ),
                                        //   ),

                                      ],
                                    ),
                                    SizedBox(
                                      height: screenHeight * .01,
                                    ),
                                    Row(

                                      children: [
                                        Expanded(
                                          child: CustomTextWidget(
                                            text:
                                            'Amount greater than ${item['dcTxnAmount']} (%)  ${!isEditable?'  -   ${item['amountGtPercent']}':''} ',
                                            size: 11,
                                          ),
                                        ),

                                        if (isEditable)
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                      'amt GT ${item['dcTxnAmount']} (%)'),
                                                  titleTextStyle:
                                                  const TextStyle(
                                                      color:
                                                      Colors.black,
                                                      fontSize: 18,
                                                      fontFamily:
                                                      'Mont'),
                                                  content: Column(
                                                    mainAxisSize:
                                                    MainAxisSize.min,
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      const Text(
                                                          'Please enter your value'),
                                                      SizedBox(
                                                          height: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .height *
                                                              .01),
                                                      Container(
                                                        width:
                                                        double.infinity,
                                                        height: MediaQuery.of(
                                                            context)
                                                            .size
                                                            .height *
                                                            .06,
                                                        padding: EdgeInsets.only(
                                                            left: MediaQuery.of(
                                                                context)
                                                                .size
                                                                .width *
                                                                .025),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                    .1)),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                5)),
                                                        child:
                                                        TextFormField(
                                                          onChanged:
                                                              (value) {
                                                            final double
                                                            parsedValue =
                                                                double.tryParse(
                                                                    value) ??
                                                                    0.0;

                                                            setState(() {
                                                              item['amountGtPercent'] =
                                                                  value;
                                                            });

                                                            if (parsedValue >
                                                                100) {
                                                              setState(() {
                                                                item['amountGtPercent'] =
                                                                '100.00';
                                                              });
                                                            }
                                                          },
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .allow(
                                                              RegExp(
                                                                  r'^\d{0,3}(\.\d{0,2})?$'), // Allows up to 3 digits (0-100) and optional decimal with up to 2 digits
                                                            ),
                                                          ],
                                                          keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal:
                                                              true),
                                                          maxLength: 6,
                                                          enabled: true,
                                                          style: const TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black),
                                                          decoration:
                                                          const InputDecoration(
                                                            border:
                                                            InputBorder
                                                                .none,
                                                            counterText: '',
                                                          ),
                                                          initialValue:
                                                          '${item['amountGtPercent']}',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(
                                                            context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .18,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height *
                                                .04,
                                            padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    .025),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: isEditable?Colors.black
                                                        .withOpacity(.1):Colors.transparent),
                                                borderRadius:
                                                BorderRadius.circular(5)),
                                            child: Row(
                                              children: [

                                                CustomTextWidget(
                                                  text:
                                                  '${item['amountGtPercent']}',
                                                  isBold: true,
                                                  size: 11,
                                                ),
                                                const Spacer(),

                                                if (isEditable )
                                                  const Icon(
                                                    Icons.edit,
                                                    size: 15,
                                                  ),

                                                // TextFormField(
                                                //   onChanged: (value) {
                                                //     final double parsedValue =
                                                //         double.tryParse(value) ?? 0.0;
                                                //
                                                //     TextEditingController(
                                                //         text: value);
                                                //
                                                //     // setState(() {
                                                //     //   item['amount'] = value;
                                                //     // });
                                                //     //
                                                //     // if (parsedValue > 100) {
                                                //     //   setState(() {
                                                //     //     item['amount'] = '100.00';
                                                //     //   });
                                                //     // }
                                                //   },
                                                //   inputFormatters: [
                                                //     FilteringTextInputFormatter.allow(
                                                //       RegExp(
                                                //           r'^\d{0,3}(\.\d{0,2})?$'), // Allows up to 3 digits (0-100) and optional decimal with up to 2 digits
                                                //     ),
                                                //   ],
                                                //   keyboardType: const TextInputType
                                                //       .numberWithOptions(
                                                //       decimal: true),
                                                //   maxLength: 6,
                                                //   enabled: false,
                                                //   style: const TextStyle(
                                                //       fontSize: 14,
                                                //       color: Colors.black),
                                                //   decoration: const InputDecoration(
                                                //     border: InputBorder.none,
                                                //     counterText: '',
                                                //   ),
                                                //   controller: TextEditingController(
                                                //       text:
                                                //       '${item['amountGtPercent']}'),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // if (isEditable)
                                        //   Padding(
                                        //     padding: const EdgeInsets.only(
                                        //         left: 8.0),
                                        //     child: GestureDetector(
                                        //       onTap: () {
                                        //         showDialog(
                                        //           context: context,
                                        //           builder:
                                        //               (BuildContext context) {
                                        //             return AlertDialog(
                                        //               title: Text(
                                        //                   'amt GT ${item['dcTxnAmount']} (%)'),
                                        //               titleTextStyle:
                                        //               const TextStyle(
                                        //                   color:
                                        //                   Colors.black,
                                        //                   fontSize: 18,
                                        //                   fontFamily:
                                        //                   'Mont'),
                                        //               content: Column(
                                        //                 mainAxisSize:
                                        //                 MainAxisSize.min,
                                        //                 crossAxisAlignment:
                                        //                 CrossAxisAlignment
                                        //                     .start,
                                        //                 children: [
                                        //                   const Text(
                                        //                       'Please enter your value'),
                                        //                   SizedBox(
                                        //                       height: MediaQuery.of(
                                        //                           context)
                                        //                           .size
                                        //                           .height *
                                        //                           .01),
                                        //                   Container(
                                        //                     width:
                                        //                     double.infinity,
                                        //                     height: MediaQuery.of(
                                        //                         context)
                                        //                         .size
                                        //                         .height *
                                        //                         .06,
                                        //                     padding: EdgeInsets.only(
                                        //                         left: MediaQuery.of(
                                        //                             context)
                                        //                             .size
                                        //                             .width *
                                        //                             .025),
                                        //                     decoration: BoxDecoration(
                                        //                         border: Border.all(
                                        //                             color: Colors
                                        //                                 .black
                                        //                                 .withOpacity(
                                        //                                 .1)),
                                        //                         borderRadius:
                                        //                         BorderRadius
                                        //                             .circular(
                                        //                             5)),
                                        //                     child:
                                        //                     TextFormField(
                                        //                       onChanged:
                                        //                           (value) {
                                        //                         final double
                                        //                         parsedValue =
                                        //                             double.tryParse(
                                        //                                 value) ??
                                        //                                 0.0;
                                        //
                                        //                         setState(() {
                                        //                           item['amountGtPercent'] =
                                        //                               value;
                                        //                         });
                                        //
                                        //                         if (parsedValue >
                                        //                             100) {
                                        //                           setState(() {
                                        //                             item['amountGtPercent'] =
                                        //                             '100.00';
                                        //                           });
                                        //                         }
                                        //                       },
                                        //                       inputFormatters: [
                                        //                         FilteringTextInputFormatter
                                        //                             .allow(
                                        //                           RegExp(
                                        //                               r'^\d{0,3}(\.\d{0,2})?$'), // Allows up to 3 digits (0-100) and optional decimal with up to 2 digits
                                        //                         ),
                                        //                       ],
                                        //                       keyboardType:
                                        //                       const TextInputType
                                        //                           .numberWithOptions(
                                        //                           decimal:
                                        //                           true),
                                        //                       maxLength: 6,
                                        //                       enabled: true,
                                        //                       style: const TextStyle(
                                        //                           fontSize: 14,
                                        //                           color: Colors
                                        //                               .black),
                                        //                       decoration:
                                        //                       const InputDecoration(
                                        //                         border:
                                        //                         InputBorder
                                        //                             .none,
                                        //                         counterText: '',
                                        //                       ),
                                        //                       initialValue:
                                        //                       '${item['amountGtPercent']}',
                                        //                     ),
                                        //                   ),
                                        //                 ],
                                        //               ),
                                        //               actions: [
                                        //                 TextButton(
                                        //                   onPressed: () {
                                        //                     Navigator.of(
                                        //                         context)
                                        //                         .pop(); // Close the dialog
                                        //                   },
                                        //                   child: Text('OK'),
                                        //                 ),
                                        //               ],
                                        //             );
                                        //           },
                                        //         );
                                        //       },
                                        //       child: const Icon(
                                        //         Icons.edit,
                                        //         size: 18,
                                        //       ),
                                        //     ),
                                        //   ),
                                      ],
                                    ),
                                  ],
                                )
                            ],
                          ),
                        )
                    ]
                        // CustomTextWidget(
                        //     text:
                        //         "UPI - 0% |  UPI (Credit) - 1.5%\nDebit Card - 0.4%  \nDebit Card(Rupay) - 0%\nCredit (Domestic - 1.99%)",
                        //     isBold: false),

                        ),
                    const SizedBox(
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
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(16.0),
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
                subWord: 'Merchant Agreement', mainWord: 'Acceptance of'),

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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: AppColors.kTileColor,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "Terms and conditionss",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ),
                  ),
                  Checkbox(
                    value: acceptTnc,
                    checkColor: Colors.white,
                    activeColor: AppColors.kLightGreen,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    onChanged: (bool? newValue) async {
                      setState(() {
                        acceptTnc = newValue!;
                      });
                      merchantAgreeMentReq.termsCondition = newValue!;
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
                        text: "Merchant Service agreement",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ),
                  ),
                  Checkbox(
                    value: acceptAggrement,
                    checkColor: Colors.white,
                    activeColor: AppColors.kLightGreen,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    onChanged: (bool? newValue) async {
                      setState(() {
                        acceptAggrement = newValue!;
                      });
                      merchantAgreeMentReq.serviceAgreement = newValue!;

                      // if (!accept) {
                      //   var results =
                      //       await Navigator.of(context).push(MaterialPageRoute(
                      //           builder: (BuildContext context) {
                      //             return const TermsAndConditionPage();
                      //           },
                      //           fullscreenDialog: true));
                      //   setState(() {
                      //     if (results != null) {
                      //       accept = results;
                      //       requestModel.acceptLicense = accept;
                      //     }
                      //   });
                      // } else {
                      //   setState(() {
                      //     accept = false;
                      //     requestModel.acceptLicense = accept;
                      //   });
                      // }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomAppButton(
                title: "Submit",
                onPressed: () {
                  print("sbumit pressed");
                  if (loginFormKey.currentState!.validate()) {
                    loginFormKey.currentState!.save();
                    setState(() {
                      submitUserRegistration();
                    });
                  } else {
                    alertWidget.failure(context, '',
                        'Please accept our T&C or Select MDR Type');
                  }

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
      ),
    );
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
      // debugPrint(e);
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
            }
          });
        }
      }
    });
  }

  List mdrApiSummaryList = [];

  getDefaultMerchantValues() async {
    print("----default value called----");
    await userServices.GetMerchantOnboardingValues().then((response) async {
      final Map<String, dynamic> data = json.decode(response.body);

      // List<dynamic> acquirerDetails =
      //     data['data'][0]['acquirerAcquirerDetails'];

      merchantBusinessTypeList = data['data'][0]['mmsBusinessType'];
      merchantBankList = data['data'][0]['mmsBanks'];
      merchantProofDocumentList = data['data'][0]['mmsDocumentType'];

      mdrTypeList = data['data'][0]['mmsMdrType'];
      mdrApiSummaryList = data['data'][0]['mmsMdrDetails'];
      // mdrSummaryList = data['data'][0]['mmsMdrDetails'];

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
        // acquirerList = acquirerDetails;

        merchantBusinessCategory = mccGroups;
        merchantBusinessSubCategory = mccTypes;
        businessTurnoverList = data['data'][0]['mmsTurnOver'];

        citiesList = data['data'][0]['tmsMasterCities'];
        statesList = data['data'][0]['states'];

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

      // for (var acquirer in acquirerDetails) {
      //   String acquirerName = acquirer['acquirerName'];
      //   print('Acquirer Name: $acquirerName');
      // }

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

  storePrevious() {
    setState(() {
      position--;
    });
  }

  storeNext() {
    setState(() {
      position++;
      currTabPosition = 4;
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
          if (type == 'cancelledChequeImg') {
            cancelledChequeImg = result.path;
          }
        } else {
          if (type == 'cancelledChequeImg') {
            cancelledChequeImg = '';
          }
          alertWidget.failure(context, 'Failure', Constants.oneMbErrorMessage);
        }
      });
    }
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  filepaths() {
    print("file ");
  }

  submitUserRegistration() async {
    setState(() {
      _isLoading = true;
      // requestModel.role = "MERCHANT";
      // requestModel.currencyId = '784';
      // requestModel.latitude = _lat;
      // requestModel.longitude = _lng;
      // requestModel.deviceType = Constants.deviceType;
      // requestModel.instId = Constants.instId;
      // requestModel.kycType = 'E-KYC';
    });
    // requestModel.password =
    //     await Validators.encrypt(requestModel.password.toString());
    // requestModel.confirmPassword =
    //     await Validators.encrypt(requestModel.confirmPassword.toString());
    // requestModel.pin = await Validators.encrypt(requestModel.pin.toString());
    // requestModel.confirmPin =
    //     await Validators.encrypt(requestModel.confirmPin.toString());
    // requestModel.deviceId =
    //     await Validators.encrypt(await Global.getUniqueId());

    final List<Map<String, dynamic>> productList = selectedItems.map((product) {
      return {
        "productId": product.productId.toString(),
        "packageId": product.packagetId.toString(),
        "qty": product.quantity.toString(),
      };
    }).toList();

    // final Map<String, dynamic> mdrSummary = {
    //   "mdrSummary": json.encode(mdrSummaryList),
    // };

    print(mdrSummaryList);

    merchantAgreeMentReq.mdrSummary = json.encode(mdrSummaryList);

    print(merchantAgreeMentReq.mdrSummary);
    print(merchantAgreeMentReq.toJson());
    print('pkm');

    // print(jsonEncode(merchantAgreeMentReq.mdrSummary.toJson()));

    final Map<String, dynamic> merchantProductInfoReq = {
      "merchantProductDetails": productList,
    };

    final String jsonString = json.encode(merchantProductInfoReq);
    print(jsonString);

    print("Image kyc  ${_merchantStoreFrontImageCtrl.text}");
    print("Image kycBack  ${_merchantStoreInsideImageCtrl.text}");
    print("Image tradeLicense  ${tradeLicense.text}");
    print("Image nationalIdFront  ${nationalIdFront.text}");
    print("Image nationalIdBack  ${nationalIdBack.text}");
    print("Image cancelCheque  ${cancelCheque.text}");
    userServices
        .newMerchantSignup(
      merchantProductInfoReq,
      companyDetailsInforeq,
      merchantIdProofReq,
      businessIdProofReq,
      merchantStoreInfoReq,
      merchantAgreeMentReq,
      merchantBankInfoReq,
      _merchantStoreFrontImageCtrl.text,
      _merchantStoreInsideImageCtrl.text,
      cancelledChequeImg,
      // merchantPersonalReq,
      // merchantCompanyDetailsReq,
      // _merchantStoreFrontImageCtrl.text,
      // _merchantStoreInsideImageCtrl.text,
      // tradeLicense.text,
      // nationalIdFront.text,
      // nationalIdBack.text,
      // cancelCheque.text,
    )
        .then((response) {
      var decodeData = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['statusCode'].toString() == "200") {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushNamedAndRemoveUntil(
              context, 'SignUpSucessScreen', (route) => false);
          // alertWidget.successPopup(
          //     context, 'Success', decodeData['responseMessage'], () {

          // });
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
          } else {}
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
        merchantPanHelperText = "Loading...";
      });
      var panNumber = _merchantPanController.text.toString();
      // var user = await Validators.encrypt(_merchantPanController.text.toString());
      userServices.panValidation(panNumber).then((response) async {
        if (response.toString() == "true") {
          setState(() {
            merchantIdProofReq.panNumberVerifyStatus = true;
            merchantPanHelperText = "Verified";
            showVerify = false;
          });
          print("Pan Api response is true");
        } else {
          setState(() {
            print("Pan Api response is false");
            merchantPanHelperText = "Failed Try Again";
          });
        }
      });
    }
  }

  validateFirmPan() async {
    merchantPanHelpertext = "Loading...";
    if (_firmPanController.text.isNotEmpty) {
      debugPrint("Calling Firm pan validation API");
      setState(() {
        userCheck = "Loading...";
      });
      var panNumber = _firmPanController.text.toString();
      // var user = await Validators.encrypt(_merchantPanController.text.toString());
      userServices.panValidation(panNumber).then((response) async {
        if (response.toString() == "true") {
          setState(() {
            showFirmPanVerify = false;
            merchantPanHelpertext = "Verified";
            businessIdProofReq.firmPanNumberVerifyStatus = true;
          });
          print("body is true");
        } else {
          businessIdProofReq.firmPanNumberVerifyStatus = false;
          setState(() {
            merchantPanHelpertext = "Invalid Merchant Pan try Again";
          });
        }
      });
    }
  }

  validategst() async {
    if (_gstController.text.isNotEmpty && _gstController.text.length > 10) {
      debugPrint("Calling Gst API");
      setState(() {
        gstHelperText = "Loading....";
      });
      var gstnumber = _gstController.text.toString();

      print(gstnumber);

      // var user = await Validators.encrypt(_merchantPanController.text.toString());
      userServices.gstValidation(gstnumber).then((response) async {
        print("response in");
        print(response);
        if (response.toString() == "true") {
          setState(() {
            isgstVerify = false;
            gstHelperText = "Verifyed";
            // merchantAdditionalInfoReq.merchantBankVerifyStatus = true;
            // accountCheck = 'VALID';

            // merchantAdditionalInfoReq.bankIfscCode = merchantIfscCodeCtrl.text;
            // merchantAdditionalInfoReq.bankAccountNo =
            //     merchantAccountNumberCtrl.text;
            // merchantAdditionalInfoReq.beneficiaryName =
            //     merchantBeneficiaryNamrCodeCtrl.text;
            // merchantAdditionalInfoReq.bankAccountNo =
            //     merchantAccountNumberCtrl.text;
            // accountVerify = false;
            // // if (idStatus == 'VALID') {
            // //   accountCheck = 'VALID';
            // //   panOwnerName = name;
            // //   showVerify = false;
            // //   print(name);
            // //   userCheckMessage = Constants.userNameSuccessMessage;
            // // } else {
            // //   setState(() => showVerify = true);
            // // }
          });
          print("body is true");
        } else {
          setState(() {
            gstHelperText = "Failed try Again";
          });
        }
      });
    }
  }

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        businessProofDocumentCtrl.text = result.files.single.name;
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
        if (response.statusCode == 200 || response.statusCode == 201) {
          merchantBankInfoReq.merchantBankVerifyStatus = true;
          print(response.body);

          merchantBankInfoReq.bankIfscCode = merchantIfscCodeCtrl.text;
          merchantBankInfoReq.bankAccountNo = merchantAccountNumberCtrl.text;
          merchantBankInfoReq.beneficiaryName =
              merchantBeneficiaryNamrCodeCtrl.text;
          accountVerify = false;
          merchantBankInfoReq.merchantBankVerifyStatus = true;
        } else {
          alertWidget.error(response.body ?? "Null response");
          print("invalid ");
        }

        // print("response in");
        // print(response);
        // merchantBankInfoReq.merchantBankVerifyStatus = true;
      });
    }
  }

  sendAddhaarOtp() async {
    if (_merchantAddharController.text.isNotEmpty) {
      debugPrint("Calling AddhaarOtp API");
      //debugPrint(_merchantAddharController.text);
      setState(() {
        addhaarCheck = "Loading...";
      });
      // var user =
      //     await Validators.encrypt(_merchantAddharController.text.toString());
      var addhaarNumber = _merchantAddharController.text;
      print(addhaarNumber);
      userServices.sendAddhaarOtp(addhaarNumber).then((response) async {
        print("response in");
        print(response);
        if (response.toString() == "true") {
          setState(() {
            isaddhaarOTPsent = true;
            showaddharverify = false;
          });
          print("body is true");
        } else {
          print("body is false");
          isaddhaarOTPsent = false;
        }
      });
    }
  }

  validateAddhaarOtp() async {
    if (_merchantAddharController.text.isNotEmpty &&
        _otpController.text.isNotEmpty) {
      debugPrint("Calling AddhaarOtp validation API");
      setState(() {
        addhaarCheck = "Loading...";
      });
      // var user =
      //     await Validators.encrypt(_merchantAddharController.text.toString());
      var addhaarNumber = _merchantAddharController.text.toString();
      var addhaarOtp = _otpController.text.toString();
      userServices
          .validateAddhaarOtp(addhaarNumber, addhaarOtp)
          .then((response) async {
        print("response in");
        print(response);
        if (response.toString() == "true") {
          setState(() {
            isaddhaarOTPsent = false;
            showaddharverify = false;
            isOtpVerifird = true;
          });
          print("body is true");
        } else {
          print("body is false");
          isaddhaarOTPsent = false;
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
