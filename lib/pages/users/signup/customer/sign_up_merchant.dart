import 'dart:async';
import 'dart:convert';

import 'dart:io';
import 'package:badges/badges.dart' as badge;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sifr_latest/common_widgets/app_appbar.dart';
import 'package:sifr_latest/helpers/default_height.dart';
import 'package:sifr_latest/pages/mechant_order/merchant_order_details.dart';
import 'package:sifr_latest/widgets/Forms/merchant_store_form.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';
import 'package:sifr_latest/widgets/loading.dart';
import 'package:sifr_latest/widgets/otp_verification_widgets/aadhaar_otp_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common_widgets/custom_app_button.dart';
import '../../../../common_widgets/form_title_widget.dart';
import '../../../../config/config.dart';
import '../../../../decurations/dropdownDecurations.dart';
import '../../../../helpers/pan_validateer.dart';
import '../../../../providers/providers.dart';
import '../../../../services/services.dart';
import '../../../../widgets/image_button/verifivation_success_button.dart';
import '../../../../widgets/otp_verification_widgets/email_otp_widget.dart';
import '../../../../widgets/pdf_viewer/pdf_viewer.dart';
import '../../../../widgets/tabbar/tabbar.dart';
import '../../../../widgets/widget.dart';
import 'models/business_id_proof_requestmodel.dart';
import 'models/company_detailsInfo_requestmodel.dart';
import 'models/merchant_agreement_requestmodel.dart';
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
  bool acceptTnc = false;
  bool acceptAggrement = false;
  FocusNode myFocusNode = FocusNode();

  AlertService alertWidget = AlertService();
  CustomAlert customAlert = CustomAlert();
  UserServices userServices = UserServices();

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

  late StreamController<int> _numberStreamController;

  // Merchant order Detials
  List<SelectedProduct> selectedItems = [];
  List<MechantKycDocument> selectedBusinessProofItems = [];

  bool isEditable = false;

// Merchant Detials stage 2
  final TextEditingController _merchantLegalNameController =
      TextEditingController();
  final TextEditingController _contactPersonNameController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool isEmailVerified = false;
  bool isEmailOtpSending = false;
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _whatsAppNumberController =
      TextEditingController();
  dynamic businessType;
  dynamic businessProofType;
  String? businessDocumentTypename;
  String? businessDocumentFileFullpath;
  String? businessDocumentTypeId;
  String emailHelperText = "Verify E-mail Address";

// Merchant Detials screen 3
  final TextEditingController _merchantDBANameController =
      TextEditingController();
  dynamic selectedBusinessCategory;

  int selectedBusinessStateId = 0;
  int selectedBusinessCityId = 0;

  int? selectedDocumentId;

  dynamic selectedBusinessSubCategory;

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
  final TextEditingController _merchantAddharController =
      TextEditingController();

  String gstHelperText = "click Verify";
  bool isAadhaarverified = false;
  String aadhaarHelperText = '';

  bool isPanIsverifying = false;
  bool isAadhaarotpSending = false;
  bool isPanNumberVerified = false;

  //merchant Bussines proof
  final TextEditingController documentExpiryController =
      TextEditingController();
  final TextEditingController businessProofDocumentCtrl =
      TextEditingController();
  var documentExpirySelectedDate;

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
  var accountInfoHelperText = "Click verify";

  String cancelledChequeImg = '';

  // bool enabledLast = false;
  // bool enabledNick = false;
  // bool enabledMobile = false;
  // bool enabledEmail = false;

  // bool mobile = false;
  // bool enabledCountry = false;
  // bool enabledState = false;
  // bool enabledcity = false;
  // bool email = false;
  // String emailCheck = '';
  // String mobileNoCheck = '';
  // String? mobileNoCheckMessage;
  TextStyle? style;
  String countryCode = 'IN';
  String merchantPanHelperText = "Click verify";
  String merchantFirmPanHelperText = "Click verify";

  List merchantBankList = [];
  List merchantProofDocumentList = [];

  // List countryList = [];
  // List acquirerList = [];

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

  // String panOwnerName = '';

  // String accountCheck = '';

  bool isFirmPanVerified = false;
  bool isFirmPanVerifying = false;
  bool isgstverified = false;
  bool isgstverifying = false;

  // bool showVerify1 = true;
  bool isaddhaarOTPsent = false;
  bool isOtpVerifird = false;
  bool emailVerify = false;

  // bool hidePassword = true;
  // bool hideCnfPassword = true;
  // bool hidePin = true;
  // bool hideCnfPin = true;
  // bool enabledUsername = false;
  // bool enabledPassword = false;
  // bool enabledConfirmPass = false;
  // bool enabledPin = false;
  // bool enabledConfirmPin = false;
  //late String userCheckMessage = '';
  // bool userVerify = false;
  bool isAccountInfoverified = false;
  bool isAccountInfoverifying = false;

  // List securityQuestionList = [];
  // final TextEditingController selectedItem1 = TextEditingController();
  // final TextEditingController selectedItem2 = TextEditingController();
  // final TextEditingController selectedItem3 = TextEditingController();
  // String nationality = '';

  // String selectedCountries = '';

  // String selectedPermenentState = '';

  String selectedBusinessState = '';

  String selectedPermenentCountry = '';

  // final TextEditingController selectedMcc = TextEditingController();
  //final TextEditingController selectedBusinessType = TextEditingController();
  // final TextEditingController selectedBusinessTurnOverCtrl =
  //     TextEditingController();

  // List list = [];
  // bool enabledSecurity2 = false;
  // bool enabledSecurity3 = false;
  // bool enabledAnswer1 = false;
  // bool enabledAnswer2 = false;
  // bool enabledAnswer3 = false;
  // final Uri _url = Uri.parse('https://sifr.ae/contact.php');

  /// DOCUMENTS INFO
  // final TextEditingController tradeLicense = TextEditingController();
  // final TextEditingController nationalIdFront = TextEditingController();
  // final TextEditingController nationalIdBack = TextEditingController();
  // final TextEditingController cancelCheque = TextEditingController();

  /// KYC INFORMATION
  // final TextEditingController kycFront = TextEditingController();
  // final TextEditingController kycBack = TextEditingController();

  /// Bank detials

  TextEditingController merchantAccountNumberCtrl = TextEditingController();
  TextEditingController merchantphoneNumberCtrl = TextEditingController();
  TextEditingController merchantIfscCodeCtrl = TextEditingController();
  TextEditingController merchantBeneficiaryNamrCodeCtrl =
      TextEditingController();
  int? selectedBankId;

  int _selectedOption = 0;

// merchant Aggrement
  dynamic mdrType;

  List mdrTypeList = [];
  List mdrSummaryList = [];

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

    _numberStreamController = StreamController<int>.broadcast();

    DevicePermission().checkPermission();
    getCurrentPosition();
    getDefaultMerchantValues();
  }

  // Timer? _debounce;

  bool isTermsWaiting = false;
  bool isServiceWaiting = false;

  Future _sendTermsAndConditionsToMail() async {
    if (kDebugMode) print(acceptAggrement);
    setState(() {
      isTermsWaiting = true;
    });

    var response = await userServices.sendTermsAndConditions(
        companyDetailsInforeq.emailId, "TERMS_AND_CONDITION");

    final data = json.decode(response.body);

    if (kDebugMode) print(data);

    if (data['responseCode'] != '00') {
      return;
    }

    if (kDebugMode) print(data);

    // _debounce = Timer(const Duration(milliseconds: 1000), () {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('Terms and conditions have sent to registered mail'),
    //     duration: Duration(seconds: 2),
    //   ),
    // );

    checkForTermsAcceptance(0);
    // });
  }

  Future _sendServiceAgreementsToMail() async {
    if (kDebugMode) print(acceptTnc);

    // if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      isServiceWaiting = true;
    });

    var response = await userServices.sendTermsAndConditions(
        companyDetailsInforeq.emailId, "SERVICE_AGREEMENT");

    final data = json.decode(response.body);

    if (data['responseCode'] != '00') {
      return;
    }

    // _debounce = Timer(const Duration(milliseconds: 1000), () {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content:
    //           Text('Merchant Service Agreement have sent to registered mail'),
    //       duration: Duration(seconds: 2),
    //     ),
    //   );

    checkForServiceAcceptance(0);
    // });
  }

  void setTnCWaitingFalse() {
    setState(() {
      isTermsWaiting = false;
    });
  }

  Future checkForTermsAcceptance(int count) async {
    var response = await userServices
        .getTcAndAgreementStatus(companyDetailsInforeq.emailId);

    final data = json.decode(response.body);

    if (data['statusCode'] != 200) {
      if (count == 10) {
        setTnCWaitingFalse();
        return;
      }
      Future.delayed(const Duration(seconds: 10), () {
        checkForTermsAcceptance(count + 1);
      });
    }

    if (data['data'] == null) {
      setTnCWaitingFalse();
      return;
    }

    if (data['data'][0]['termsAndConditionsRead'] != null) {
      if (!data['data'][0]['termsAndConditionsRead']) {
        if (count == 10) {
          setTnCWaitingFalse();
          return;
        }
        Future.delayed(const Duration(seconds: 10), () {
          checkForTermsAcceptance(count + 1);
        });
      }
    } else {
      if (count == 10) {
        setTnCWaitingFalse();
        return;
      }
      Future.delayed(const Duration(seconds: 10), () {
        checkForTermsAcceptance(count + 1);
      });
    }

    if (data['data'][0]['termsAndConditionsRead']) {
      setState(() {
        acceptTnc = true;
        merchantAgreeMentReq.termsCondition = true!;
      });
    }

    // _timerForTerms = Timer.periodic(const Duration(seconds: 10), (timer) {
    //   // Perform your action here
    //
    //  if(kDebugMode)print('hit');
    // });
  }

  void setServiceWaitingFalse() {
    setState(() {
      isServiceWaiting = false;
    });
  }

  Future checkForServiceAcceptance(int count) async {
    var response = await userServices
        .getTcAndAgreementStatus(companyDetailsInforeq.emailId);

    final data = json.decode(response.body);

    if (data['statusCode'] != 200) {
      if (count == 10) {
        setServiceWaitingFalse();
        return;
      }

      Future.delayed(const Duration(seconds: 10), () {
        if (kDebugMode) print('hellooo');
        checkForServiceAcceptance(count + 1);
      });
    }

    if (data['data'] == null) {
      setServiceWaitingFalse();
      return;
    }

    if (data['data'][0]['aggrementRead'] != null) {
      if (!data['data'][0]['aggrementRead']) {
        if (count == 10) {
          setServiceWaitingFalse();
          return;
        }
        Future.delayed(const Duration(seconds: 10), () {
          checkForServiceAcceptance(count + 1);
        });
      }
    } else {
      if (count == 10) {
        setServiceWaitingFalse();
        return;
      }
      Future.delayed(const Duration(seconds: 10), () {
        checkForServiceAcceptance(count + 1);
      });
    }

    if (data['data'][0]['aggrementRead']) {
      setState(() {
        acceptAggrement = true;
        merchantAgreeMentReq.serviceAgreement = true;
      });
    }

    // _timerForService = Timer.periodic(const Duration(seconds: 10), (timer) {
    //   // Perform your action here
    //   checkForServiceAcceptance(count + 1);
    // });
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
        selectedBussinesTurnOver['turnoverType'],
        selectedBusinessCategory['mccGroupId']);

    final Map<String, dynamic> data = json.decode(response.body);

    isEditable = false;

    mdrSummaryList = [];

    if (data['mmsMdrDetailsInfo'].length > 0) {
      for (var item in data['mmsMdrDetailsInfo']) {
        if (item['dcTxnAmount'] != null) {
          mdrSummaryList.add(item);
        }
      }

      for (var item in data['mmsMdrDetailsInfo']) {
        if (item['dcTxnAmount'] == null) {
          mdrSummaryList.add(item);
        }
      }
    }

    if (mdrType == "special") {
      isEditable = true;
    }

    setState(() {});

    // mdrSummaryList = data['mmsMdrDetailsInfo'];
  }

  void getIntByKey(
      {required String countryKey, required Map<String, int> dataMap}) {
    int? countryValue = dataMap[countryKey];

    if (countryValue != null) {
      if (kDebugMode) print('$countryKey: $countryValue');
    } else {
      if (kDebugMode) print('Country not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
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

  _onWillPop(BuildContext context) {
    try {
      customAlert.displayDialogConfirm(context, 'Please confirm',
          'Do you want to quit your registration?', onTapConfirm);
    } catch (_) {}

    // return null;
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
      return mainControl(merchantDetailsPartOne());
    } else if (position == 2) {
      return mainControl(merchantDetailsPartTwo());
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
        merchantCompanyDetailsReq: companyDetailsInforeq,
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
    final List<Map<String, dynamic>> productList = selectedItems.map((product) {
      return {
        "productId": product.productId.toString(),
        "packageId": product.packagetId.toString(),
        "qty": product.quantity.toString(),
      };
    }).toList();

    final Map<String, dynamic> merchantProductInfoReq = {
      "merchantProductDetails": productList,
    };

    final String jsonString = json.encode(merchantProductInfoReq);
    if (kDebugMode) print(jsonString);
    setState(() {
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
                  if (kDebugMode) print("else executed");
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

  Widget merchantDetailsPartOne() {
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
              readOnly: isEmailVerified,
              //enabled: !isEmailVerified,
              // textCapitalization: TextCapitalization.words,
              prefixIcon: Icons.email,
              onChanged: (value) {
                setState(() {
                  emailHelperText = "";
                });
              },
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
              suffixIcon: isEmailOtpSending
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: AppColors.kLightGreen,
                        strokeWidth: 2,
                      ),
                    )
                  : isEmailVerified
                      ? TextButton(
                          onPressed: () {
                            changeVerifiedEmail();
                          },
                          child: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.kPrimaryColor,
                          ))
                      : TextButton(
                          onPressed: () {
                            if (Validators.isValidEmail(
                                _emailController.text)) {
                              sendEmailOtp(emailId: _emailController.text);
                            } else {
                              alertWidget.error("Enter a valid email");
                            }
                          },
                          child: const CustomTextWidget(
                            text: "Send OTP",
                            color: AppColors.kPrimaryColor,
                            size: 12,
                          )),
              suffixIconTrue: true,
              helperText: emailHelperText,
              helperStyle: TextStyle(
                  color: isEmailVerified
                      ? AppColors.kLightGreen
                      : AppColors.kPrimaryColor),

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
                  child: const CustomTextWidget(
                      text: "+91", color: AppColors.kPrimaryColor),
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

              helperStyle: style,
              prefixIcon: FontAwesome.mobile_solid,
              // suffixIcon: const Icon(
              //   Icons.edit_outlined,
              //   color: AppColors.kPrimaryColor,
              // ),
              // suffixIconTrue: true,
              onChanged: (value) {
                companyDetailsInforeq.landlineNo = value;
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
                  child: const CustomTextWidget(
                      text: "+91", color: AppColors.kPrimaryColor),
                  onPressed: () {}),
              controller: _whatsAppNumberController,
              keyboardType: TextInputType.number,
              title: 'WhatsApp Number',
              required: true,
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
                required: true),

            DropdownButtonFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              isDense: true,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.kPrimaryColor),
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
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  if (kDebugMode) print(newValue['businessType'].runtimeType);
                  businessType = newValue;
                  companyDetailsInforeq.businessTypeId =
                      newValue['businessType'].runtimeType == String
                          ? int.parse(newValue['businessType'])
                          : newValue['businessType'];
                  // companyDetailsInforeq.businessTypeId = 1;
                  selectedBusinessProofItems.clear();

                  businessProofType = null;
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
                  if (!isEmailVerified) {
                    alertWidget.error("please verify your Email ");
                  } else {
                    setState(() {
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
        ));
  }

  Widget merchantDetailsPartTwo() {
    var screenHeight = MediaQuery.of(context).size.height;
    return Form(
        key: personalFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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

            CustomTextFormField(
              title: 'Merchant DBA Name',
              hintText: "merchant DBA (Do Business As) name",
              controller: _merchantDBANameController,
              required: true,
              keyboardType: TextInputType.text,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9. ]'))
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              isDense: true,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.kPrimaryColor),
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
                  if (kDebugMode) print(selectedBusinessCategory['mccGroupId']);
                  selectedBusinessSubCategory = null;
                  if (kDebugMode) print(selectedBusinessSubCategory);
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Merchant Business category is Mandatory!';
                }
                return null;
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.kPrimaryColor),
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
              validator: (value) {
                if (value == null) {
                  return 'Merchant Business Sub is Mandatory!';
                }
                return null;
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.kPrimaryColor),
              items:
                  businessTurnoverList.map<DropdownMenuItem>((dynamic value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value['turnoverAmount'],
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedBussinesTurnOver = newValue;

                  companyDetailsInforeq.annualTurnOverId =
                      newValue['turnoverId'];

                  companyDetailsInforeq.gstApplicable =
                      newValue['gstApplicable'] ?? false;

                  mdrType = null;
                  mdrSummaryList = [];

                  if (kDebugMode) print(companyDetailsInforeq.annualTurnOverId);
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Business Turnover is Mandatory!';
                }
                return null;
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
                if (kDebugMode) print(value);
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

                  if (kDebugMode) print(selectedBusinessStateId);

                  companyDetailsInforeq.stateId = selectedBusinessStateId;

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
                if (kDebugMode) print(value);
                setState(() {
                  selectedCity = value;

                  selectedBusinessCityId = (citiesList
                      .where((element) => element['cityName'] == value)
                      .toList())[0]['cityId'];

                  if (kDebugMode) print(selectedBusinessCityId);

                  companyDetailsInforeq.cityCode = selectedBusinessCityId;

                  if (kDebugMode) print(selectedBusinessCityId);
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
                  if (kDebugMode) print(companyDetailsInforeq.toJson());
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
            const SizedBox(height: 10),

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

              suffixIconTrue: true,
              suffixIcon: isPanIsverifying
                  ? const CircularProgressIndicator(
                      color: AppColors.kLightGreen,
                    )
                  : isPanNumberVerified
                      ? const VerificationSuccessButton()
                      : TextButton(
                          onPressed: () {
                            if (_merchantPanController.text.length >= 10) {
                              validatePan();
                            }
                          },
                          child: const CustomTextWidget(
                            text: "Verify",
                            color: AppColors.kRedColor,
                          )),
              helperStyle: TextStyle(
                  color: isPanNumberVerified
                      ? AppColors.kLightGreen
                      : AppColors.kPrimaryColor),
              inputFormatters: <TextInputFormatter>[PanNumberFormatter()],
              // suffixText: showVerify ? 'Verify' : 'Change',
              enabled: !isPanNumberVerified,
              helperText: merchantPanHelperText,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Merchant Pan is Mandatory!';
                }
                if (value.length < 10) {
                  return 'Minimum character length is 10';
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
              enabled: !isAadhaarverified,
              prefixIcon: Icons.format_list_numbered,
              onFieldSubmitted: (name) {
                //getUser();
              },
              helperText: aadhaarHelperText,

              // suffixIconOnPressed: () {
              //   if (_merchantAddharController.text.length >= 12) {
              //    if(kDebugMode)print("clicked");
              //     if (showaddharverify) {
              //       sendAddhaarOtp();
              //      if(kDebugMode)print("validate");
              //     } else {
              //      if(kDebugMode)print("change");

              //       setState(() {
              //         showaddharverify = true;
              //         isaddhaarOTPsent = false;
              //         isOtpVerifird = false;
              //       });
              //     }
              //   }
              // },
              // suffixIcon: isAadhaarverified
              //     ? VerificationSuccessButton()
              //     : IconButton(
              //         icon: Text("data"),
              //         onPressed: () {

              //         }),
              // suffixIcon: showaddharverify
              //     ? TextButton(
              //         onPressed: () {
              //           if (_merchantAddharController.text.length >= 12) {
              //            if(kDebugMode)print("clicked");
              //             if (showaddharverify) {
              //               sendAddhaarOtp();
              //              if(kDebugMode)print("validate");
              //             } else {
              //              if(kDebugMode)print("change");

              //               setState(() {
              //                 showaddharverify = true;
              //                 isaddhaarOTPsent = false;
              //                 isOtpVerifird = false;
              //               });
              //             }
              //           }
              //         },
              //         child: Text("Verify"))
              //     : VerificationSuccessButton(),

              suffixIcon: StreamBuilder<int>(
                stream: _numberStreamController.stream,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.hasData && snapshot.data != 0) {
                    return CustomTextWidget(
                      text: "wait for ${snapshot.data}",
                      color: AppColors.kPrimaryColor,
                      size: 12,
                    );
                  }

                  return isAadhaarotpSending
                      ? const CircularProgressIndicator(
                          color: AppColors.kLightGreen,
                          strokeWidth: 3,
                        )
                      : isAadhaarverified
                          ? const VerificationSuccessButton()
                          : TextButton(
                              onPressed: () {
                                if (_merchantAddharController.text.length ==
                                    12) {
                                  sendAddhaarOtp();
                                } else {
                                  alertWidget
                                      .error("Enter 12 digit aadhaar number");
                                }
                              },
                              child: const CustomTextWidget(
                                text: "Send OTP",
                                color: AppColors.kPrimaryColor,
                                size: 12,
                              ));
                },
              ),

              suffixIconTrue: true,
              helperStyle: TextStyle(
                  color: isAadhaarverified
                      ? AppColors.kLightGreen
                      : AppColors.kPrimaryColor),
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
            const SizedBox(
              height: 100,
            ),
            CustomAppButton(
              title: 'Next',
              onPressed: () {
                if (loginFormKey.currentState!.validate()) {
                  loginFormKey.currentState!.save();
                  if (kDebugMode) print(merchantIdProofReq.toJson());

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

    if (kDebugMode) print('currTabPosition$currTabPosition');
    if (kDebugMode) {
      print(
          'companyDetailsInforeq.gstApplicable${selectedBussinesTurnOver['gstApplicable']}');
    }

    if (selectedBussinesTurnOver['gstApplicable'] == null) {
      selectedBussinesTurnOver['gstApplicable'] = false;
    }

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
                starEnabled:
                    selectedBussinesTurnOver['gstApplicable'] ? true : false,
                keyboardType: TextInputType.text,
                controller: _gstController,
                title: selectedBussinesTurnOver['gstApplicable']
                    ? 'Merchant GST Number'
                    : 'Merchant GST Number (Optional)',
                hintText: "Enter merchant GST number",
                required: true,
                maxLength: 15,
                enabled: !isgstverified,
                prefixIcon: Icons.format_list_numbered,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
                ],
                onFieldSubmitted: (name) {
                  // getUser();
                },
                onChanged: (text) {
                  print(text);
                  _gstController.value = _gstController.value.copyWith(
                    text: text.toUpperCase(),
                    selection: TextSelection.collapsed(offset: text.length),
                  );
                },
                suffixIcon: isgstverifying
                    ? const CircularProgressIndicator(
                        color: AppColors.kLightGreen,
                      )
                    : isgstverified
                        ? const VerificationSuccessButton()
                        : TextButton(
                            onPressed: () {
                              if (_gstController.text.length >= 15) {
                                if (kDebugMode) print("clicked");
                                validategst();
                              } else {
                                alertWidget.error("Enter a valid GST number");
                              }
                            },
                            child: const CustomTextWidget(
                              text: "Verify",
                              color: AppColors.kRedColor,
                              size: 12,
                            )),
                suffixIconTrue: true,
                helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isgstverified
                        ? AppColors.kLightGreen
                        : AppColors.kPrimaryColor),
                helperText: gstHelperText,
                validator: (value) {
                  if (selectedBussinesTurnOver['gstApplicable']) {
                    if (value == null || value.isEmpty) {
                      return 'Gst Number is Mandatory!';
                    }
                    if (!RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                        .hasMatch(value)) {
                      return 'Invalid Gst Number!';
                    }
                  } else {
                    if (value.length != 0) {
                      if (value.length != 15) {
                        return "Enter Valid Gst Number!";
                      }
                    }
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
                suffixIcon: isFirmPanVerifying
                    ? const CircularProgressIndicator(
                        color: AppColors.kLightGreen,
                      )
                    : isFirmPanVerified
                        ? const VerificationSuccessButton()
                        : TextButton(
                            onPressed: () {
                              if (_firmPanController.text.length == 10) {
                                if (kDebugMode) print("clicked");
                                validateFirmPan();
                              } else {
                                alertWidget
                                    .error("Enter a valid Firm Pan number");
                              }
                            },
                            child: const CustomTextWidget(
                              text: "Verify",
                              color: AppColors.kRedColor,
                              size: 12,
                            )),
                suffixIconTrue: true,
                helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isFirmPanVerified
                        ? AppColors.kLightGreen
                        : AppColors.kPrimaryColor),
                enabled: !isFirmPanVerified,
                helperText: merchantFirmPanHelperText,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Firm Pan number Mandatory!';
                  }
                  if (value.length < 10) {
                    return 'Minimum character length is 10';
                  }
                  // if (userVerify && userCheck == "true") {
                  //   return Constants.userNameFailureMessage;
                  // }
                  if (!RegExp(r'^[a-zA-Z\d][a-zA-Z\d_.]+[a-zA-Z\d]$')
                      .hasMatch(value)) {
                    if (kDebugMode) print("object");
                    if (kDebugMode) print("dsdd");
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
              const SizedBox(
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
              //      if(kDebugMode)print(merchantProofDocumentList);

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

              //     //if(kDebugMode)print(businessIdProofReq.businessProofDocumntType);
              //   },
              // ),
              const Row(
                children: [
                  CustomTextWidget(
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
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.kPrimaryColor),
                items: merchantProofDocumentList.where((value) {
                  List<String> stringDocumentTypeIdList =
                      selectedBusinessProofItems
                          .map((doc) => doc.documentTypeId!.toString())
                          .toList();

                  return !stringDocumentTypeIdList
                              .contains(value['businessDocId']) &&
                          value['businessTypeId'] ==
                              companyDetailsInforeq.businessTypeId.toString()
                      // for business type based filteringS
                      ;
                }).map<DropdownMenuItem>((dynamic value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value['businessType'],
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    if (kDebugMode) print(newValue);
                    businessProofType = newValue;
                    businessDocumentTypename = newValue["businessType"];
                    businessDocumentTypeId = newValue["businessDocId"];
                    if (kDebugMode) print(newValue["businessType"]);
                    if (kDebugMode) print(newValue["businessDocId"]);
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
                // onTap: _openFilePicker,
                onTap: () {
                  selectPdfDialog(context);
                },
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
                  if (kDebugMode) print('ontap');
                  DateTime? pickedDate = await showDatePicker(
                    initialDatePickerMode: DatePickerMode.day,
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                    context: context,
                    initialDate: documentExpirySelectedDate,
                    firstDate: DateTime.now().add(const Duration(days: 1)),
                    lastDate: DateTime(DateTime.now().year + 10),
                  );
                  if (pickedDate != null) {
                    String formattedDateUI =
                        DateFormat('dd/MM/yyyy').format(pickedDate);
                    setState(() {
                      documentExpirySelectedDate = pickedDate;

                      documentExpiryController.text = formattedDateUI;
                    });
                  } else {}
                  if (pickedDate != null) {
                    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                        .format(pickedDate);
                    //  selected=
                    //       formattedDate;
                    if (kDebugMode) print('Formatted Date: ${formattedDate}Z');
                  }
                },
                validator: (value) {
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
              if (kDebugMode) print('validateAction');

              documentFormkey.currentState!.save();
              if (documentFormkey.currentState!.validate()) {
                setState(() {
                  selectedBusinessProofItems.add(MechantKycDocument(
                      fileFullPath: businessDocumentFileFullpath,
                      documentExpiry: documentExpiryController.text,
                      documentTypeId: int.parse(businessDocumentTypeId!),
                      documentTypeName: businessDocumentTypename!,
                      fileName: businessProofDocumentCtrl.text));
                });

                businessProofDocumentCtrl.clear();
                documentExpiryController.clear();
                businessDocumentTypeId = "";
                businessDocumentFileFullpath = "";
                businessProofType = null;
              } else {
                if (kDebugMode) print("form not validated");
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
            // color: AppColors.kTileColor,
            child: Column(
              children: [
                // DataTable(
                //   // headingRowHeight: 0,
                //   columnSpacing: 8,
                //   dataRowMinHeight: 20,
                //   dataRowMaxHeight: 30,
                //   columns: [
                //     const DataColumn(label: Text('Name')),
                //     const DataColumn(label: Text('Expy Date')),
                //     const DataColumn(label: Text('')),
                //   ],
                //   rows: selectedBusinessProofItems.map((item) {
                //     return DataRow(cells: [
                //       DataCell(SizedBox(
                //         width: 100,
                //         child: CustomTextWidget(
                //           text: item.documentTypeName.toString(),
                //           size: 11,
                //           fontWeight: FontWeight.w900,
                //         ),
                //       )),
                //       // DataCell(CustomTextWidget(
                //       //   text: "${item.productName}+ 1499+499",
                //       //   size: 11,
                //       //   fontWeight: FontWeight.w900,
                //       // )),
                //       DataCell(CustomTextWidget(
                //         text: item.documentExpiry.toString(),
                //         size: 12,
                //         fontWeight: FontWeight.w900,
                //       )),
                //       DataCell(
                //         IconButton(
                //           icon: const Icon(
                //             Icons.cancel_outlined,
                //             color: Colors.red,
                //           ),
                //           onPressed: () {
                //             setState(() {
                //               selectedBusinessProofItems.remove(item);
                //             });
                //           },
                //         ),
                //       ),
                //     ]);
                //   }).toList(),
                // ),
                // defaultHeight(15),
                Container(
                  color: AppColors.kSelectedBackgroundColor,
                  child: Theme(
                    data: ThemeData().copyWith(
                        dividerColor: Colors.transparent,
                        listTileTheme: const ListTileThemeData(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10))),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: CustomTextWidget(
                        text: "View Complete document Summary",
                        color: Colors.grey.shade600,
                        size: 10,
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .3,
                                      child: const CustomTextWidget(
                                        text: 'Name',
                                        size: 13,
                                      )),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .3,
                                      child: const CustomTextWidget(
                                        text: 'Expiry',
                                        size: 13,
                                      )),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .1,
                                      child: const CustomTextWidget(
                                        text: '',
                                        size: 13,
                                      )),
                                ],
                              ),
                              const Divider(),
                              for (var item in selectedBusinessProofItems)
                                Row(children: [
                                  Expanded(
                                    child: SizedBox(
                                      child: CustomTextWidget(
                                        text: item.documentTypeName.toString(),
                                        size: 11,
                                        isBold: false,
                                      ),
                                    ),
                                  ),
                                  // DataCell(CustomTextWidget(
                                  //   text: "${item.productName}+ 1499+499",
                                  //   size: 11,
                                  //   fontWeight: FontWeight.w900,
                                  // )),

                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .3,
                                    child: CustomTextWidget(
                                      text: item.documentExpiry.toString(),
                                      isBold: false,
                                      size: 12,
                                    ),
                                  ),

                                  InkWell(
                                    onTap: () {
                                      pdfViewer(
                                          filePath:
                                              item.fileFullPath.toString(),
                                          context: context);
                                      // item.fileFullPath.toString();
                                      // _pdfViewerKey.currentState
                                      //     ?.openBookmarkView();
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .15,
                                      // padding: const EdgeInsets.symmetric(
                                      //     vertical: 10.0, horizontal: 10.0),
                                      decoration: BoxDecoration(
                                        color: AppColors.kLightGreen,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        child: Center(
                                          child: CustomTextWidget(
                                            text: "View",
                                            size: 12,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                 ),),

                                  // const Spacer(),



                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .02),
                                  GestureDetector(
                                    child: const Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.red,
                                    ),
                                    onTap: () {
                                      setState(() {
                                        selectedBusinessProofItems.remove(item);
                                      });
                                    },
                                  ),
                                ])
                            ],
                          ),
                        ),

                        // DataTable(
                        //   // headingRowHeight: 0,
                        //   columnSpacing: 8,
                        //   dataRowMinHeight: 20,
                        //   dataRowMaxHeight: 30,
                        //   columns: const [
                        //     DataColumn(label: Text('Name')),
                        //     DataColumn(label: Text('Expy Date')),
                        //     DataColumn(label: Text('')),
                        //   ],
                        //   rows: selectedBusinessProofItems.map((item) {
                        //     return DataRow(cells: [
                        //       DataCell(SizedBox(
                        //         width: 100,
                        //         child: CustomTextWidget(
                        //           text: item.documentTypeName.toString(),
                        //           size: 11,
                        //           fontWeight: FontWeight.w900,
                        //         ),
                        //       )),
                        //       // DataCell(CustomTextWidget(
                        //       //   text: "${item.productName}+ 1499+499",
                        //       //   size: 11,
                        //       //   fontWeight: FontWeight.w900,
                        //       // )),
                        //       DataCell(CustomTextWidget(
                        //         text: item.documentExpiry.toString(),
                        //         size: 12,
                        //         fontWeight: FontWeight.w900,
                        //       )),
                        //       DataCell(
                        //         IconButton(
                        //           icon: const Icon(
                        //             Icons.cancel_outlined,
                        //             color: Colors.red,
                        //           ),
                        //           onPressed: () {
                        //             setState(() {
                        //               selectedBusinessProofItems.remove(item);
                        //             });
                        //           },
                        //         ),
                        //       ),
                        //     ]);
                        //   }).toList(),
                        // ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        const SizedBox(
          height: 20.0,
        ),
        CustomAppButton(
          title: "Next",
          onPressed: () async {
            personalFormKey.currentState!.save();
            if (personalFormKey.currentState!.validate()) {
              if (selectedBusinessProofItems.isEmpty) {
                alertWidget.error("please Add Document");
              } else {
                businessIdProofReq.mechantKycDocuments =
                    selectedBusinessProofItems;
                for (var item in selectedBusinessProofItems) {
                  if (kDebugMode) print(item.fileFullPath);
                }
                if (kDebugMode) print(jsonEncode(businessIdProofReq.toJson()));
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
              const SizedBox(height: 20.0),
              const CustomTextWidget(
                  text: "Merchant Bank Account Details*",
                  fontWeight: FontWeight.w200,
                  size: 14),
              const SizedBox(height: 20.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.kTileColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 10, left: 15),
                    //   child: CustomTextWidget(
                    //       text: "Please choose account type.",
                    //       fontWeight: FontWeight.w200,
                    //       color: Colors.grey,
                    //       size: 14),
                    // ),
                    Row(
                      children: <Widget>[
                        // CustomTextWidget(text: "Account Type"),
                        // Spacer(),
                        Radio(
                          activeColor: AppColors.kPrimaryColor,
                          value: 0,
                          groupValue: _selectedOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value!;
                              merchantBankInfoReq.accountType = value;
                            });
                          },
                        ),
                        const CustomTextWidget(
                            text: 'Current',
                            color: Colors.black,
                            isBold: false),

                        Radio(
                          activeColor: AppColors.kPrimaryColor,
                          value: 1,
                          groupValue: _selectedOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value!;
                              merchantBankInfoReq.accountType = value;
                            });
                          },
                        ),
                        const CustomTextWidget(
                            text: 'Savings',
                            color: Colors.black,
                            isBold: false),
                      ],
                    ),
                  ],
                ),
              ),
              CustomTextFormField(
                titleEneabled: false,
                controller: merchantAccountNumberCtrl,
                title: 'Merchant Bank Account Details',
                hintText: "Enter merchant account number",
                required: true,
                prefixIcon: Icons.numbers,

                suffixIcon: isAccountInfoverifying
                    ? const CircularProgressIndicator(
                        color: AppColors.kLightGreen,
                      )
                    : isAccountInfoverified
                        ? const VerificationSuccessButton()
                        : null,
                suffixIconTrue: true,
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
                enabled: !isAccountInfoverified,

                // helperText: customHelperHelper(text: 'Account Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Account Number is Mandatory!';
                  }
                  if (value.length < 10) {
                    return 'Minimum digits length is 10';
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
                onFieldSubmitted: (name) {},
                onChanged: (text) {
                  merchantIfscCodeCtrl.value =
                      merchantIfscCodeCtrl.value.copyWith(
                    text: text.toUpperCase(),
                    selection: TextSelection.collapsed(offset: text.length),
                  );
                },
                suffixIconTrue: true,
                suffixIcon: isAccountInfoverifying
                    ? const CircularProgressIndicator(
                        color: AppColors.kLightGreen,
                      )
                    : isAccountInfoverified
                        ? const VerificationSuccessButton()
                        : TextButton(
                            onPressed: () {
                              if (kDebugMode) print(isAccountInfoverified);
                              if (kDebugMode) print("clicked verify from ifsc");
                              if (merchantIfscCodeCtrl.text.length >= 10 &&
                                  merchantAccountNumberCtrl.text.length >= 10) {
                                validateAccountNumber();
                              } else {
                                alertWidget
                                    .error("Enter valid Bank Account info");
                              }
                            },
                            child: const CustomTextWidget(
                              text: "verify",
                              color: AppColors.kRedColor,
                            )),
                helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isAccountInfoverified
                        ? AppColors.kLightGreen
                        : AppColors.kPrimaryColor),
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(11),
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                helperText: accountInfoHelperText,
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
              DropdownButtonFormField<int>(
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontFamily: 'Mont-regular'),
                value: selectedBankId,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.kPrimaryColor,
                ),
                hint: const Text(
                  'Select Bank',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                items: merchantBankList
                    .asMap()
                    .entries
                    .map<DropdownMenuItem<int>>((entry) {
                  Map<String, dynamic> product = entry.value;
                  return DropdownMenuItem<int>(
                    value: product['bankId'],
                    child: Text(product['bankName'].toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedBankId = value;
                  merchantBankInfoReq.bankNameId = value.toString();
                  print("Selected Bank id  " + value.toString());
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please Select a Bank!';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  merchantBankInfoReq.bankNameId = newValue.toString();
                },
                decoration: dropdownDecoration(context),
              ),
              CustomTextFormField(
                title: 'Beneficiary Name',
                hintText: "Beneficiary name",
                titleEneabled: false,
                required: true,
                enabled: !isAccountInfoverified,
                controller: merchantBeneficiaryNamrCodeCtrl,
                maxLength: 24,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.words,
                prefixIcon: Icons.person,
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
              const CustomTextWidget(text: "Cheque Image"),
              const SizedBox(height: 10.0),
              cancelledChequeImg != ''
                  ? afterSelect(cancelledChequeImg, () {
                      setState(() {
                        cancelledChequeImg = '';
                      });
                    })
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: () {
                          cameraPhotoDialog(context, 'cancelledChequeImg');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.kTileColor,
                          ),
                          width: double.maxFinite,
                          height: screenHeight / 6,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomTextWidget(
                                    text:
                                        "Click the image of a cancelled cheque",
                                    color: Colors.grey),
                                SizedBox(
                                  height: 10,
                                ),
                                Icon(
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
              const SizedBox(
                height: 30,
              ),
              CustomAppButton(
                title: 'Next',
                onPressed: () {
                  if (loginFormKey.currentState!.validate()) {
                    loginFormKey.currentState!.save();

                    if (kDebugMode) print(merchantBankInfoReq.toJson());

                    if (cancelledChequeImg == '') {
                      alertWidget.error("Please Upload the check image");
                    } else {
                      setState(() {
                        position++;
                        currTabPosition = 5;
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
            ]));
  }

  Widget review() {
    var screenHeight = MediaQuery.of(context).size.height;

    if (kDebugMode) print(acceptAggrement);
    if (kDebugMode) print(acceptTnc);

    return SingleChildScrollView(
      child: Form(
        key: loginFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomTextWidget(
              text: "Merchant Agreement",
              size: 18,
            ),

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
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.kPrimaryColor),
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
                });

                getMdrSummaryList(mdrType['mdrType']);

                // merchantAgreeMentReq.serviceAgreement = true;
                // merchantAgreeMentReq.termsCondition = true;

                merchantAgreeMentReq.mdrType = mdrType['mdrId'];

                // requestModel.city = value;
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: AppColors.kTileColor,
              ),
              child: Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * .025),
                child: Column(
                  children: [
                    // CustomTextWidget(
                    //     text:
                    //         "UPI - 0% |  UPI (Credit) - 1.5%\nDebit Card - 0.4%  \nDebit Card(Rupay) - 0%\nCredit (Domestic - 1.99%)",
                    //     isBold: false),

                    const SizedBox(
                      height: 15,
                    ),
                    // Container(
                    // color: AppColors.kSelectedBackgroundColor,
                    Theme(
                      data: ThemeData()
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: CustomTextWidget(
                          text: "View Complete MDR Summary",
                          color: Colors.grey.shade600,
                          size: 10,
                        ),
                        children: [
                          Wrap(children: [
                            for (var item in mdrSummaryList)
                              Container(
                                margin: EdgeInsets.only(
                                  top: screenHeight * .015,
                                ),
                                width: double.infinity,
                                // width:
                                //     item['dcTxnAmount'] == null && !isEditable
                                //         ? ((MediaQuery.of(context).size.width) -
                                //                 ((MediaQuery.of(context)
                                //                             .size
                                //                             .width *
                                //                         .02) *
                                //                     3) -
                                //                 30) /
                                //             2
                                //         : double.infinity,
                                // padding: item['dcTxnAmount'] != null
                                //     ? EdgeInsets.all(
                                //         MediaQuery.of(context).size.width * .02)
                                //     : const EdgeInsets.all(0),
                                padding:
                                    // item['dcTxnAmount'] != null
                                    //     ?
                                    EdgeInsets.all(
                                        MediaQuery.of(context).size.width * .02)
                                // : const EdgeInsets.all(0)
                                ,
                                // width:double.infinity,
                                color: Colors.white,
                                // color: item['dcTxnAmount'] != null
                                //     ? Colors.white
                                //     : Colors.transparent,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          item['dcTxnAmount'] == null
                                              ? CrossAxisAlignment.center
                                              : CrossAxisAlignment.start,
                                      children: [
                                        CustomTextWidget(
                                          text: '${item['paymentName']}',
                                          isBold: true,
                                          size: 12,
                                        ),

                                        // if (item['dcTxnAmount'] == null &&
                                        //     !isEditable)
                                        //   if (mdrSummaryList.indexOf(item) % 2 == 0)
                                        //     const CustomTextWidget(
                                        //       text: '|',
                                        //       isBold: true,
                                        //       size: 11,
                                        //     ),

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
                                        //                        if(kDebugMode)print(
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: screenHeight * .01,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: CustomTextWidget(
                                                  text:
                                                      'Amount less than ${item['dcTxnAmount']}  ${!isEditable ? '  -   ${item['amountLePercent']} %' : ''} ',
                                                  size: 11,
                                                  isBold: false,
                                                ),
                                              ),

                                              if (isEditable)
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Amount less than ${item['dcTxnAmount']}'),
                                                          titleTextStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Mont'),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
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
                                                                width: double
                                                                    .infinity,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    .06,
                                                                padding: EdgeInsets.only(
                                                                    left: MediaQuery.of(context)
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
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                child:
                                                                    TextFormField(
                                                                  onChanged:
                                                                      (value) {
                                                                    final double
                                                                        parsedValue =
                                                                        double.tryParse(value) ??
                                                                            0.0;

                                                                    setState(
                                                                        () {
                                                                      item['amountLePercent'] =
                                                                          value;
                                                                    });

                                                                    if (parsedValue >
                                                                        100) {
                                                                      setState(
                                                                          () {
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
                                                                  keyboardType: const TextInputType
                                                                      .numberWithOptions(
                                                                      decimal:
                                                                          true),
                                                                  maxLength: 6,
                                                                  enabled: true,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black),
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    counterText:
                                                                        '',
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
                                                              child: const Text(
                                                                  'OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .18,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .04,
                                                    padding: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .025),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: isEditable
                                                                ? Colors.black
                                                                    .withOpacity(
                                                                        .1)
                                                                : Colors
                                                                    .transparent),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Row(
                                                      children: [
                                                        CustomTextWidget(
                                                          text:
                                                              '${item['amountLePercent']}',
                                                          isBold: false,
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
                                                        if (isEditable)
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
                                            height: screenHeight * .005,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: CustomTextWidget(
                                                  text:
                                                      'Amount greater than ${item['dcTxnAmount']}  ${!isEditable ? '  -   ${item['amountGtPercent']} %' : ''} ',
                                                  size: 11,
                                                  isBold: false,
                                                ),
                                              ),

                                              if (isEditable)
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Amount greater than ${item['dcTxnAmount']}'),
                                                          titleTextStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      'Mont'),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
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
                                                                width: double
                                                                    .infinity,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    .06,
                                                                padding: EdgeInsets.only(
                                                                    left: MediaQuery.of(context)
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
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                child:
                                                                    TextFormField(
                                                                  onChanged:
                                                                      (value) {
                                                                    final double
                                                                        parsedValue =
                                                                        double.tryParse(value) ??
                                                                            0.0;

                                                                    setState(
                                                                        () {
                                                                      item['amountGtPercent'] =
                                                                          value;
                                                                    });

                                                                    if (parsedValue >
                                                                        100) {
                                                                      setState(
                                                                          () {
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
                                                                  keyboardType: const TextInputType
                                                                      .numberWithOptions(
                                                                      decimal:
                                                                          true),
                                                                  maxLength: 6,
                                                                  enabled: true,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black),
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    counterText:
                                                                        '',
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
                                                              child: const Text(
                                                                  'OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .18,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .04,
                                                    padding: EdgeInsets.only(
                                                        left: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .025),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: isEditable
                                                                ? Colors.black
                                                                    .withOpacity(
                                                                        .1)
                                                                : Colors
                                                                    .transparent),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Row(
                                                      children: [
                                                        CustomTextWidget(
                                                          text:
                                                              '${item['amountGtPercent']}',
                                                          isBold: false,
                                                          size: 11,
                                                        ),
                                                        const Spacer(),

                                                        if (isEditable)
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
                                      ),
                                    if (item['dcTxnAmount'] == null)
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: screenHeight * .01,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: CustomTextWidget(
                                                  text:
                                                      '${item['paymentName']} Amount ${!isEditable ? '  -   ${item['amount']} %' : ''}',
                                                  size: 11,
                                                  isBold: false,
                                                ),
                                              ),
                                              if (isEditable)
                                                GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              '${item['paymentName']}'),
                                                          titleTextStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      'Mont'),
                                                          content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
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
                                                                width: double
                                                                    .infinity,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    .06,
                                                                padding: EdgeInsets.only(
                                                                    left: MediaQuery.of(context)
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
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                child:
                                                                    TextFormField(
                                                                  onChanged:
                                                                      (value) {
                                                                    final double
                                                                        parsedValue =
                                                                        double.tryParse(value) ??
                                                                            0.0;

                                                                    setState(
                                                                        () {
                                                                      item['amount'] =
                                                                          value;
                                                                    });

                                                                    if (parsedValue >
                                                                        100) {
                                                                      setState(
                                                                          () {
                                                                        item['amount'] =
                                                                            '100.00';
                                                                      });
                                                                    }

                                                                    if (kDebugMode) {
                                                                      print(mdrSummaryList[
                                                                              0]
                                                                          [
                                                                          'amount']);
                                                                    }
                                                                  },
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter
                                                                        .allow(
                                                                      RegExp(
                                                                          r'^\d{0,3}(\.\d{0,2})?$'), // Allows up to 3 digits (0-100) and optional decimal with up to 2 digits
                                                                    ),
                                                                  ],
                                                                  keyboardType: const TextInputType
                                                                      .numberWithOptions(
                                                                      decimal:
                                                                          true),
                                                                  maxLength: 6,
                                                                  enabled: true,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black),
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    counterText:
                                                                        '',
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
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Close the dialog
                                                              },
                                                              child: const Text(
                                                                  'OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .18,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .04,
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .02),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    .1)),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        CustomTextWidget(
                                                          text:
                                                              '${item['amount'] ?? item['dcTxnAmount']}',
                                                          isBold: false,
                                                          size: 10,
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
                                                        if (isEditable &&
                                                            item['dcTxnAmount'] ==
                                                                null)
                                                          const Icon(
                                                            Icons.edit,
                                                            size: 15,
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              // if (!isEditable)
                                              //   CustomTextWidget(
                                              //     text: '${item['amount']} %',
                                              //     isBold: false,
                                              //     size: 11,
                                              //   ),
                                            ],
                                          )
                                        ],
                                      )
                                  ],
                                ),
                              )
                          ])
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    // )
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
                        text: Constants.agreementMessage,
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
              height: MediaQuery.of(context).size.height * .05,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  color: AppColors.kTileColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "Terms and Conditions",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Mont'),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ),
                  ),
                  if (!acceptTnc)
                    GestureDetector(
                      onTap: () {
                        if (!isTermsWaiting) {
                          _sendTermsAndConditionsToMail();
                        }
                      },
                      child: !isTermsWaiting
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * .035),
                              height: MediaQuery.of(context).size.height * .03,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white),
                              child: const Center(
                                  child: CustomTextWidget(
                                      text: 'View', size: 13, isBold: false)))
                          : Text(
                              'Waiting...',
                              style: TextStyle(
                                  color: AppColors.getMaterialColorFromColor(
                                      AppColors.kPrimaryColor),
                                  fontSize: 13),
                            ),
                    ),
                  if (acceptTnc)
                    Checkbox(
                      value: true,
                      checkColor: Colors.white,
                      activeColor: AppColors.kLightGreen,
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      onChanged: (bool? newValue) async {
                        // setState(() {
                        //   acceptTnc = newValue!;
                        // });
                        // merchantAgreeMentReq.termsCondition = newValue!;
                      },
                    ),
                ],
              ),
            ),

            if (!acceptTnc)
              if (isTermsWaiting)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomTextWidget(
                      text: 'T&C sent to Mail, Please check Mail',
                      size: 12,
                      maxLines: 2,
                      color: Colors.black.withOpacity(.7),
                      isBold: false,
                    ),
                  ],
                ),

            const SizedBox(
              height: 15,
            ),

            Container(
              height: MediaQuery.of(context).size.height * .05,
              decoration: BoxDecoration(
                  color: AppColors.kTileColor,
                  borderRadius: BorderRadius.circular(5)),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "Merchant Service agreement",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Mont'),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ),
                  ),
                  if (!acceptAggrement)
                    GestureDetector(
                      onTap: () {
                        if (!isServiceWaiting) {
                          _sendServiceAgreementsToMail();
                        }
                      },
                      child: !isServiceWaiting
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * .035),
                              height: MediaQuery.of(context).size.height * .03,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white),
                              child: const Center(
                                  child: CustomTextWidget(
                                      text: 'View', size: 13, isBold: false)))
                          : Text('Waiting...',
                              style: TextStyle(
                                  color: AppColors.getMaterialColorFromColor(
                                      AppColors.kPrimaryColor),
                                  fontSize: 13)),
                    ),
                  if (acceptAggrement)
                    Checkbox(
                      value: true,
                      checkColor: Colors.white,
                      activeColor: AppColors.kLightGreen,
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      onChanged: (bool? newValue) async {
                        // setState(() {
                        //   acceptAggrement = newValue!;
                        // });
                        // merchantAgreeMentReq.serviceAgreement = newValue!;

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

            if (!acceptAggrement)
              if (isServiceWaiting)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomTextWidget(
                      text: 'Service Agreement sent to mail.Please check Mail',
                      size: 12,
                      maxLines: 2,
                      color: Colors.black.withOpacity(.7),
                      isBold: false,
                    ),
                  ],
                ),

            const SizedBox(
              height: 30,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CustomAppButton(
                title: "Submit",
                onPressed: () {
                  if (loginFormKey.currentState!.validate()) {
                    if (acceptAggrement && acceptTnc) {
                      loginFormKey.currentState!.save();
                      setState(() {
                        submitUserRegistration();
                      });
                    } else {
                      alertWidget.failure(context, '', 'Please accept our T&C');
                    }
                  } else {
                    alertWidget.failure(context, '', 'Please Select MDR Type');
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
        // requestModel.latitude = position.latitude;
        // requestModel.longitude = position.longitude;
      });
      return position;
    }).catchError((e) {
      //if(kDebugMode)print(e);
    });
  }

  List mdrApiSummaryList = [];

  getDefaultMerchantValues() async {
    if (kDebugMode) print("----default value called----");
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
      //  if(kDebugMode)print('Acquirer Name: $acquirerName');
      // }

      // for (var mccGroup in mccGroups) {
      //   String mccGroupId = mccGroup['mccGroupId'].toString();
      //   // if (kDebugMode) print('mccGroupId : $mccGroupId');
      // }

      // for (var mccType in mccTypes) {
      //   String acquirerName = mccType['mccTypeDesc'];
      //   // if (kDebugMode) print('mccTypeDesc: $acquirerName');
      // }

      // for (var products in tmsProductMaster) {
      //   String acquirerName = products['productName'];
      //   // if (kDebugMode) print('productName: $acquirerName');
      // }
      // if (kDebugMode) print("length" + "${tmsProductMaster.length}");
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

  Widget afterSelect(path, Function()? onTap) {
    var screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        badge.Badge(
          badgeStyle: const badge.BadgeStyle(
            badgeColor: Colors.white,
          ),
          badgeContent: const CircleAvatar(
            backgroundColor: Colors.white,
            child: VerificationSuccessButton(iconSize: 30),
          ),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.kTileColor),
            width: double.maxFinite,
            height: screenHeight * .2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(path),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: onTap,
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade400,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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

  selectPdfDialog(
    BuildContext context,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            //height: MediaQuery.of(context).size.height / 8,
            padding:
                const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 20),
            margin: const EdgeInsets.only(top: 45),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 10),
                      blurRadius: 10),
                ]),
            child: InkWell(
              splashColor: Theme.of(context).primaryColor,
              onTap: () {
                Navigator.pop(context);
                _openFilePicker();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    FontAwesome.file_pdf,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text(
                    "Pdf Max Size 500 KB",
                  ), // <-- Text
                ],
              ),
            ),
          ),
        );
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
    if (kDebugMode) print("file ");
  }

  submitUserRegistration() async {
    setState(() {
      _isLoading = true;
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

    if (kDebugMode) print(mdrSummaryList);

    merchantAgreeMentReq.mdrSummary = json.encode(mdrSummaryList);

    if (kDebugMode) print(merchantAgreeMentReq.mdrSummary);
    if (kDebugMode) print(merchantAgreeMentReq.toJson());
    if (kDebugMode) print('pkm');

    //if(kDebugMode)print(jsonEncode(merchantAgreeMentReq.mdrSummary.toJson()));

    final Map<String, dynamic> merchantProductInfoReq = {
      "merchantProductDetails": productList,
    };

    if (kDebugMode) print('merchantProductInfoReq$merchantProductInfoReq');

    final String jsonString = json.encode(merchantProductInfoReq);
    if (kDebugMode) print(jsonString);

    if (kDebugMode) print("Image kyc  ${_merchantStoreFrontImageCtrl.text}");
    if (kDebugMode) {
      print("Image kycBack  ${_merchantStoreInsideImageCtrl.text}");
    }

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
    )
        .then((response) {
      var decodeData = jsonDecode(response.body);
      if (kDebugMode) print(response.body);
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

        alertWidget.failure(context, 'Failure',
            decodeData['errorMessage'] ?? Constants.somethingWrong);
      }
    });
  }

  validatePan() async {
    if (_merchantPanController.text.isNotEmpty) {
      if (kDebugMode) print("Calling pan validation API");
      setState(() {
        merchantPanHelperText = "Verifying...";
        isPanIsverifying = true;
      });
      var panNumber = _merchantPanController.text.toString();
      // var user = await Validators.encrypt(_merchantPanController.text.toString());
      userServices.panValidation(panNumber).then((response) async {
        if (response == 'ERROR') {
          alertWidget.error("Something Went Wrong");
          return;
        }
        if (response.toString() == "true") {
          setState(() {
            merchantIdProofReq.panNumberVerifyStatus = true;
            merchantPanHelperText = "Verified";
            isPanIsverifying = false;
            isPanNumberVerified = true;
          });
          if (kDebugMode) print("Pan Api response is true");
        } else {
          setState(() {
            isPanIsverifying = false;
            if (kDebugMode) print("Pan Api response is false");
            merchantPanHelperText = "Failed try again with valid pan number";
          });
        }
      });
    }
  }

  validateFirmPan() async {
    if (_firmPanController.text.isNotEmpty) {
      if (kDebugMode) print("Calling Firm pan validation API");
      setState(() {
        isFirmPanVerifying = true;
        merchantFirmPanHelperText = "verifying...";
      });
      var panNumber = _firmPanController.text.toString();
      // var user = await Validators.encrypt(_merchantPanController.text.toString());
      userServices.panValidation(panNumber).then((response) async {
        if (response.toString() == "true") {
          setState(() {
            isFirmPanVerified = true;
            isFirmPanVerifying = false;
            merchantFirmPanHelperText = "Verified";
            businessIdProofReq.firmPanNumberVerifyStatus = true;
            businessIdProofReq.firmPanNo = panNumber;
            _firmPanController.text = panNumber;
          });
          if (kDebugMode) print("body is true");
        } else {
          businessIdProofReq.firmPanNumberVerifyStatus = false;
          setState(() {
            isFirmPanVerifying = false;
            merchantFirmPanHelperText =
                "Failed try again with valid Merchant pan number";
          });
        }
      });
    }
  }

  validategst() async {
    if (_gstController.text.isNotEmpty && _gstController.text.length >= 15) {
      if (kDebugMode) print("Calling Gst API");
      setState(() {
        isgstverifying = true;
        gstHelperText = "Verifying....";
      });
      var gstnumber = _gstController.text.toString();

      if (kDebugMode) print(gstnumber);

      // var user = await Validators.encrypt(_merchantPanController.text.toString());
      userServices.gstValidation(gstnumber).then((response) async {
        if (kDebugMode) print("response in");
        if (kDebugMode) print(response);
        if (response.toString() == "true") {
          setState(() {
            isgstverifying = false;
            isgstverified = true;
            gstHelperText = "verified";
            businessIdProofReq.gstnVerifyStatus = true;
          });
          if (kDebugMode) print("body is true");
        } else {
          if (kDebugMode) print("gst valodation response is not true");
          setState(() {
            isgstverifying = false;
            businessIdProofReq.gstnVerifyStatus = false;
            alertWidget.error("Failed try Again with valid Gst!");
            gstHelperText = "Failed try Again with valid Gst!";
          });
        }
      });
    }
  }

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final File file = File(result.files.first.path!);
      int fileSize = await file.length();
      double fileSizeInKB = fileSize / 1024;

      if (fileSizeInKB > 500) {
        alertWidget.error(
            "Oops! The selected file is too large.\n Please choose a file under 500 KB.");

        if (kDebugMode) print('File size exceeds 500 KB limit');
      } else {
        if (kDebugMode) print(result.files.first.path);
        setState(() {
          businessDocumentFileFullpath = result.files.first.path;
          businessProofDocumentCtrl.text = result.files.single.name;
        });
      }
    }
  }

  validateAccountNumber() async {
    if (merchantIfscCodeCtrl.text.isNotEmpty &&
        merchantAccountNumberCtrl.text.isNotEmpty) {
      if (kDebugMode) print("Calling Accountvalidation API");
      setState(() {
        isAccountInfoverifying = true;
        accountInfoHelperText = "Verifying...";
      });
      var accNumber = merchantAccountNumberCtrl.text.toString();
      var ifscNumber = merchantIfscCodeCtrl.text.toString();

      if (kDebugMode) print(accNumber);
      if (kDebugMode) print(ifscNumber);

      userServices
          .accountValidation(accNumber, ifscNumber)
          .then((response) async {
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (kDebugMode) print(response.body);

          accountInfoHelperText = " Account Info Verified";
          var decodedData = json.decode(response.body);
          String beneficiaryName =
              decodedData['result']['bankTransfer']['beneName'];

          merchantBeneficiaryNamrCodeCtrl.text = beneficiaryName;
          merchantBankInfoReq.beneficiaryName = beneficiaryName;
          merchantBankInfoReq.bankIfscCode = merchantIfscCodeCtrl.text;
          merchantBankInfoReq.bankAccountNo = merchantAccountNumberCtrl.text;
          setState(() {
            isAccountInfoverifying = false;
            isAccountInfoverified = true;
            merchantBankInfoReq.merchantBankVerifyStatus = true;
          });
        } else {
          setState(() {
            accountInfoHelperText = "Failed ";
            isAccountInfoverifying = false;
          });

          alertWidget.error("invalid bank account details");
          if (kDebugMode) print("invalid bank account details");
        }

        //if(kDebugMode)print("response in");
        //if(kDebugMode)print(response);
        // merchantBankInfoReq.merchantBankVerifyStatus = true;
      });
    }
  }

  _counterMethod(int number) {
    int count = number - 1;

    _numberStreamController.sink.add(count);

    if (count == 1) {
      Future.delayed(const Duration(seconds: 1), () {
        _numberStreamController.sink.add(0);
      });
      return;
    }

    Future.delayed(const Duration(seconds: 1), () {
      _counterMethod(count);
    });
  }

  sendAddhaarOtp() async {
    if (_merchantAddharController.text.length >= 12) {
      if (kDebugMode) print("Calling AddhaarOtp API");
      //debugPrint(_merchantAddharController.text);
      setState(() {
        isAadhaarotpSending = true;
        aadhaarHelperText = "Sending Otp..";
      });
      // var user =
      //     await Validators.encrypt(_merchantAddharController.text.toString());
      var addhaarNumber = _merchantAddharController.text;
      if (kDebugMode) print(addhaarNumber);
      userServices.sendAddhaarOtp(addhaarNumber).then((response) async {
        if (kDebugMode) print("response in");
        if (kDebugMode) print(response);

        var responseBody = json.decode(response);

        if (responseBody['statusCode'] == 200) {
          aadhaarOtpWidget(
              context: context,
              requestId: responseBody['data']['requestId'],
              aadhaarNumber: addhaarNumber,
              onSubmit: (isSvalidated, message, {int? statusCode}) {
                if (statusCode != null) {
                  _numberStreamController = StreamController<int>.broadcast();
                  _counterMethod(60);
                }

                setState(() {
                  isAadhaarotpSending = false;
                  isAadhaarverified = isSvalidated;
                  merchantIdProofReq.aadhaarNumberVerifyStatus = isSvalidated;
                  aadhaarHelperText = message;
                });
              });
          setState(() {
            aadhaarHelperText = "Otp sent";
            isaddhaarOTPsent = true;
            // showaddharverify = false;
          });
          if (kDebugMode) print("body is true");
        } else {
          merchantIdProofReq.aadhaarNumberVerifyStatus = false;
          setState(() {
            isAadhaarotpSending = false;
            isaddhaarOTPsent = false;
            aadhaarHelperText = "OTP Generation Failed.Try after some time";
          });
          alertWidget.error("aadhaarOtp sent failed");
          if (kDebugMode) print("body is false");
        }
      });
    } else {
      alertWidget.error("Enter 12 digit aadhaar number");
    }
  }

  // validateAddhaarOtp() async {
  //   if (_merchantAddharController.text.isNotEmpty &&
  //       _otpController.text.isNotEmpty) {
  //    if(kDebugMode)print("Calling AddhaarOtp validation API");
  //     setState(() {});
  //     // var user =
  //     //     await Validators.encrypt(_merchantAddharController.text.toString());
  //     var addhaarNumber = _merchantAddharController.text.toString();
  //     var addhaarOtp = _otpController.text.toString();
  //     userServices
  //         .validateAddhaarOtp(addhaarNumber, addhaarOtp)
  //         .then((response) async {
  //      if(kDebugMode)print("response in");
  //      if(kDebugMode)print(response);
  //       if (response.toString() == "true") {
  //         setState(() {
  //           isaddhaarOTPsent = false;
  //           // showaddharverify = false;
  //           isOtpVerifird = true;
  //         });
  //        if(kDebugMode)print("body is true");
  //       } else {
  //        if(kDebugMode)print("body is false");
  //         isaddhaarOTPsent = false;
  //       }
  //     });
  //   }
  // }

  // emailWidget() {
  //   return CustomTextFormField(
  //     controller: _emailController,
  //     required: true,
  //     textInputAction: TextInputAction.done,
  //     inputFormatters: <TextInputFormatter>[
  //       FilteringTextInputFormatter.allow(RegExp(r'[a-z_A-Z\d.@]'))
  //     ],
  //     keyboardType: TextInputType.emailAddress,

  //     prefixIcon: Icons.alternate_email,
  //    // helperText: emailHelper(),
  //     helperStyle: Theme.of(context)
  //         .textTheme
  //         .bodySmall
  //         ?.copyWith(color: Theme.of(context).primaryColor),
  //     title: 'Email ID',
  //     suffixText: showVerify1 ? 'Verify' : 'Change',
  //     suffixIconOnPressed: () {
  //       if (kDebugMode) print('Button Pressed');
  //       setState(() {
  //         if (!showVerify1 && emailVerify) {
  //           emailVerify = false;
  //          // email = false;
  //         } else {
  //           emailVerify = true;
  //         }
  //       });
  //       showVerify1 = true;
  //       if (emailVerify) {
  //         if (EmailValidator.validate(_emailController.text)) {
  //          // getEmailIdOrMobileNo('emailId', _emailController.text);
  //         } else {
  //           // email = false;
  //           // enabledCountry = false;
  //         }
  //       }
  //     },
  //     readOnly: !showVerify1,
  //     validator: (value) {
  //       if (value == null || value.isEmpty) {
  //         return 'Email ID is Mandatory! ';
  //       } else {
  //         final bool isValid = EmailValidator.validate(value);
  //         if (!isValid) {
  //           return Constants.emailError;
  //         }
  //         // if (emailCheck == 'true') {
  //         //   return Constants.emailIdFailureMessage;
  //         // }
  //       }

  //       return null;
  //     },
  //     onSaved: (value) {
  //       // requestModel.emailId = value;
  //     },
  //   );
  // }

  // emailHelper() {
  //   if (emailVerify == false) {
  //     return "Click 'Verify' to check if Email is available";
  //   }
  //   if (emailCheck.toString() == "false") {
  //     return Constants.emailIdSuccessMessage;
  //   }
  //   if (emailCheck == "Loading...") {
  //     return "Please wait...";
  //   }
  // }

  // getEmailIdOrMobileNo(String type, String request) async {
  //   if (kDebugMode) print("Calling API");
  //   setState(() {
  //   //  emailCheck = "Loading...";
  //   });
  //   request = await Validators.encrypt(request);
  //   userServices.emailMobileCheck(type, request).then((response) async {
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       if (type == 'emailId') {
  //         setState(() {
  //           emailCheck = response.body;
  //           if (emailCheck == 'true') {
  //             email = false;
  //             enabledCountry = false;
  //           } else {
  //             showVerify1 = false;
  //             email = true;
  //             enabledCountry = enabledEmail;
  //           }
  //         });
  //       } else {
  //         setState(() {
  //           mobileNoCheck = response.body;
  //           if (mobileNoCheck == 'true') {
  //             mobile = false;
  //             enabledEmail = false;
  //             mobileNoCheckMessage = Constants.mobileNoFailureMessage;
  //             style = Theme.of(context)
  //                 .textTheme
  //                 .bodySmall
  //                 ?.copyWith(color: Colors.red);
  //           } else {
  //             mobile = true;
  //             enabledEmail = enabledMobile;
  //             mobileNoCheckMessage = Constants.mobileNoSuccessMessage;
  //             style = Theme.of(context)
  //                 .textTheme
  //                 .bodySmall
  //                 ?.copyWith(color: Theme.of(context).primaryColor);
  //           }
  //         });
  //       }
  //     }
  //   });
  // }

  changeVerifiedEmail() {
    setState(() {
      emailHelperText = "Verify the E-mail";
      isEmailVerified = false;
    });
  }

  sendEmailOtp({required String emailId}) async {
    if (kDebugMode) print("Calling Email otp Send API");
    setState(() {
      isEmailOtpSending = true;
      emailHelperText = "Loading...";
    });
    // request = await Validators.encrypt(request);
    userServices.sendEmailOtp(emailId: emailId).then((response) async {
      if (kDebugMode) print(response.body);

      emailHelperText = "OTP sent";
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) print(response.body);
        var decodedData = jsonDecode(response.body);

        emailOtpWidget(
          emailId: emailId,
          context: context,
          title: decodedData["responseMessage"],
          validator: (dd) {},
          onSubmit: (emailVerified, messge) {
            if (kDebugMode) print("submit callback called");
            setState(() {
              isEmailOtpSending = false;
              emailHelperText = messge;
              isEmailVerified = emailVerified;
            });
          },
        );
      } else {
        var decodedData = jsonDecode(response.body);
        String errorString = decodedData['message'] ?? "Error sending otp";

        setState(() {
          isEmailOtpSending = false;
          emailHelperText = errorString;
        });

        alertWidget.error(errorString);
      }
    });
  }
}
