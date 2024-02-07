import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:sifr_latest/common_widgets/app_appbar.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import 'package:sifr_latest/config/constants.dart';
import 'package:sifr_latest/services/user_services.dart';

import '../../common_widgets/form_title_widget.dart';
import '../../common_widgets/icon_text_widget.dart';
import '../../config/app_color.dart';
import '../../models/merchant_requestmodel.dart';
import '../app/alert_service.dart';
import '../app_widget/app_bar_widget.dart';
import '../app_widget/app_button.dart';
import '../form_field/custom_dropdown.dart';
import '../form_field/custom_mobile_field.dart';
import '../form_field/custom_text.dart';

// STATEFUL WIDGET
class BusinessInfo extends StatefulWidget {
  final MerchantCompanyDetailsReqModel merchantCompanyDetailsReq;

  final TextEditingController merchantLegalNameCtrl;
  final TextEditingController acquirerNameCtrl;
  final TextEditingController acquirerApplicationIdCtrl;
  final TextEditingController merchantCommercialNameCtrl;
  final TextEditingController onwershipNameCtrl;
  final TextEditingController merchantIdCtrl;
  final TextEditingController merchantAddressCtrl;
  final TextEditingController merchantStreetNameCtrl;
  final TextEditingController merchantZipCodeCtrl;
  final TextEditingController merchantDescriptionCtrl;
  final TextEditingController companyRegCtrl;
  final TextEditingController nationalIdCtrl;
  final TextEditingController nationalIdExpiryCtrl;
  final TextEditingController tradeLicenseCtrl;
  final TextEditingController tradeLicenseExpiryCtrl;
  final TextEditingController selectedBusinessType;
  final TextEditingController selectedMccGroup;
  final TextEditingController selectedBussinesTurnover;

  final TextEditingController selectedCountry;
  final TextEditingController selectedCityCtrl;
  final TextEditingController selectedGeoFencingRadius;
  final TextEditingController selectedCurrency;
  final TextEditingController vatValueCtrl;
  final TextEditingController VATRegistrationNumberCtrl;
  final TextEditingController shareholderPercentCtrl;
  final TextEditingController maxAuthAmountCtrl;
  final TextEditingController maxTerminalCountCtrl;
  final TextEditingController merchantPercentageAmountCtrl;
  final TextEditingController emailController;

  var tradeSelectedDt;
  var nationalSelectedDt;
  List mccList;
  List acquierList;
  List MCCGroupList;
  List MCCTypeList;

  Function previous;
  Function next;
  Function() nextfordev;

  BusinessInfo({
    Key? key,
    required this.nextfordev,
    required this.merchantCompanyDetailsReq,
    required this.previous,
    required this.acquirerNameCtrl,
    required this.acquirerApplicationIdCtrl,
    required this.next,
    required this.merchantLegalNameCtrl,
    required this.companyRegCtrl,
    required this.nationalIdCtrl,
    required this.nationalIdExpiryCtrl,
    required this.tradeLicenseCtrl,
    required this.tradeLicenseExpiryCtrl,
    required this.selectedMccGroup,
    required this.selectedBusinessType,
    this.nationalSelectedDt,
    this.tradeSelectedDt,
    required this.mccList,
    required this.acquierList,
    required this.MCCGroupList,
    required this.MCCTypeList,
    required this.merchantCommercialNameCtrl,
    required this.onwershipNameCtrl,
    required this.merchantIdCtrl,
    required this.merchantAddressCtrl,
    required this.merchantStreetNameCtrl,
    required this.merchantZipCodeCtrl,
    required this.merchantDescriptionCtrl,
    required this.selectedCountry,
    required this.selectedCityCtrl,
    required this.selectedGeoFencingRadius,
    required this.selectedCurrency,
    required this.vatValueCtrl,
    required this.VATRegistrationNumberCtrl,
    required this.shareholderPercentCtrl,
    required this.maxAuthAmountCtrl,
    required this.maxTerminalCountCtrl,
    required this.merchantPercentageAmountCtrl,
    required this.emailController,
    required this.selectedBussinesTurnover,
  }) : super(key: key);

  @override
  State<BusinessInfo> createState() => _BusinessInfoState();
}

class _BusinessInfoState extends State<BusinessInfo> {
  List<Map<String, dynamic>> geoFencingRadiusList = [
    {"value": 5, "label": "5 KM"},
    {"value": 10, "label": "10 KM"},
    {"value": 15, "label": "15 KM"},
    {"value": 20, "label": "20 KM"},
    {"value": 25, "label": "25 KM"},
    {"value": 50, "label": "50 KM"},
  ];
  AlertService alertWidget = AlertService();
  UserServices userServices = UserServices();
  Map<String, String> acquierApplicationidList = {};

  final GlobalKey<FormState> businessFormKey = GlobalKey<FormState>();
  final _textFieldKey = GlobalKey<FormFieldState<String>>();
  TextStyle? style;
  final TextEditingController _mobileNoController = TextEditingController();
  String? mobileNoCheckMessage;
  String countryCode = 'IN';
  late Country _country =
      countries.firstWhere((element) => element.code == countryCode);
  final TextEditingController _mobileCodeController = TextEditingController();
  final TextEditingController _tradeLicenseExpController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  var seletedTradeExpy = DateTime.now();

  bool emailVerify = false;
  bool email = false;
  bool vatApplicable = true;
  bool holdFullPayment = true;
  bool DCCSupported = true;
  bool tipsAllowed = true;
  bool status = true;
  bool isAquirerselected = true;

  /// change to falseafter Api intergatrion
  @override
  void initState() {
    super.initState();
    setDefaultSwitchValues();
  }

  setDefaultSwitchValues() {
    widget.merchantCompanyDetailsReq.status = status;
    widget.merchantCompanyDetailsReq.isDccSupported = DCCSupported;
    widget.merchantCompanyDetailsReq.tipsAllowed = tipsAllowed;
    widget.merchantCompanyDetailsReq.holdFullPaymentAmount = holdFullPayment;
    widget.merchantCompanyDetailsReq.vatApplicable = vatApplicable;
  }

  int currTabPosition = 2;

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
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppAppbar(title: "Merchant Company Information"),

        //  const AppBarWidget(
        //   action: false,
        //   title: 'Merchant Company Information',
        //   automaticallyImplyLeading: false,
        // ),
        body: Form(
          key: businessFormKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          iconPath:
                              'assets/merchant_icons/merchant_detials.png',
                          title: "Merchant\nDetails"),
                      IconTextWidget(
                          screenHeight: screenHeight,
                          color: getIconColor(position: 2),
                          iconPath: 'assets/merchant_icons/id_proof_icon.png',
                          title: "Id\nProofs"),
                      IconTextWidget(
                          screenHeight: screenHeight,
                          color: getIconColor(position: 3),
                          iconPath:
                              'assets/merchant_icons/bussiness_proofs.png',
                          title: "Bussiness\nProofs"),
                      IconTextWidget(
                          screenHeight: screenHeight,
                          color: getIconColor(position: 4),
                          iconPath: 'assets/merchant_icons/bank_details.png',
                          title: "Bank\nDetails"),
                    ],
                  ),
                ),
                const FormTitleWidget(subWord: 'Merchant Bussiness Details'),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown(
                        title: "Processor Name",
                        required: true,
                        enabled: true,
                        selectedItem: widget.acquirerNameCtrl.text != ''
                            ? widget.acquirerNameCtrl.text
                            : null,
                        prefixIcon: Icons.location_city_outlined,
                        itemList: ["Hitachi", "Axis", "WorldLine"],
                        onChanged: (value) {
                          setState(() {
                            // widget.acquirerApplicationIdCtrl.clear();
                            widget.acquirerNameCtrl.text = value;
                          });
                        },
                        onSaved: (value) {
                          // widget.merchantCompanyDetailsReq.ac = value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Processor Name Mandatory!';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: CustomDropdown(
                        title: "Processor Id",
                        required: true,
                        enabled: isAquirerselected,
                        selectedItem:
                            widget.acquirerApplicationIdCtrl.text != ''
                                ? widget.acquirerApplicationIdCtrl.text
                                : null,
                        prefixIcon: Icons.location_city_outlined,
                        itemList: [
                          "PPR002125",
                          "PPR0021654",
                          "PPR0021684",
                        ],
                        onChanged: (value) {
                          setState(() {
                            widget.acquirerApplicationIdCtrl.text = value;
                          });
                        },
                        onSaved: (value) {
                          widget.merchantCompanyDetailsReq.acquirerId =
                              "ADIBOMA0001";
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Application Id Mandatory!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                    title: 'Merchant Legal Name',
                    required: true,
                    controller: widget.merchantLegalNameCtrl,
                    maxLength: 24,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.store_alt_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]'))
                    ],
                    onSaved: (value) {
                      widget.merchantCompanyDetailsReq.merchantName = value;
                    },
                    onChanged: (value) {
                      widget.merchantCompanyDetailsReq.merchantName = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Merchant Name is Mandatory!';
                      }
                      if (!RegExp(r'^[-a-zA-Z0-9]+(\s[-a-zA-Z0-9]+)*$')
                          .hasMatch(value)) {
                        return 'Invalid Merchant Name';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 10.0,
                ),
                CustomTextFormField(
                    title: 'Merchant Commercial Name',
                    required: true,
                    controller: widget.merchantCommercialNameCtrl,
                    maxLength: 24,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.store_alt_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]'))
                    ],
                    onSaved: (value) {},
                    onChanged: (value) {
                      setState(() {
                        widget.merchantCompanyDetailsReq.commercialName = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Merchant Commercial Name is Mandatory!';
                      }
                      if (!RegExp(r'^[-a-zA-Z0-9]+(\s[-a-zA-Z0-9]+)*$')
                          .hasMatch(value)) {
                        return 'Invalid Merchant Commercial Name';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 10.0,
                ),
                CustomTextFormField(
                    title: 'Ownership',
                    required: true,
                    controller: widget.onwershipNameCtrl,
                    maxLength: 24,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.store_alt_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]'))
                    ],
                    onSaved: (value) {
                      widget.merchantCompanyDetailsReq.ownership = value;
                    },
                    onChanged: (value) {
                      setState(() {
                        widget.merchantCompanyDetailsReq.ownership = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ownership Mandatory!';
                      }
                      if (!RegExp(r'^[-a-zA-Z0-9]+(\s[-a-zA-Z0-9]+)*$')
                          .hasMatch(value)) {
                        return 'Invalid Ownership value';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15.0,
                ),
                CustomDropdown(
                  title: "Bussines Group",
                  required: true,
                  enabled: true,
                  selectedItem: widget.selectedMccGroup.text != ''
                      ? widget.selectedMccGroup.text
                      : null,
                  prefixIcon: Icons.location_city_outlined,
                  itemList: widget.MCCGroupList.map(
                      (e) => e['description'].toString()).toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.selectedMccGroup.text = value;
                    });
                  },
                  onSaved: (value) {
                    // widget.merchantCompanyDetailsReq.gronull = 555555;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'MCC Group is Mandatory!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                CustomDropdown(
                  title: "Bussines Type",
                  required: true,
                  enabled: true,
                  selectedItem: widget.selectedBusinessType.text != ''
                      ? widget.selectedBusinessType.text
                      : null,
                  prefixIcon: LineAwesome.business_time_solid,
                  itemList:
                      widget.MCCTypeList.map((e) => e['mccTypeDesc']).toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.selectedBusinessType.text = value;
                      widget.merchantCompanyDetailsReq.mccTypeCode = 1;
                    });
                  },
                  onSaved: (value) {
                    widget.merchantCompanyDetailsReq.mccTypeCode = 1;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'MCC Type is  Mandatory!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                CustomDropdown(
                  title: "Annual Bussines Turnover",
                  required: true,
                  enabled: true,
                  selectedItem: widget.selectedBussinesTurnover.text != ''
                      ? widget.selectedBussinesTurnover.text
                      : null,
                  prefixIcon: Icons.location_city_outlined,
                  itemList: [
                    'Up to 5 CR',
                    '6 to 10 CR',
                    '11 to 20 CR',
                    '21 to 50 CR'
                  ],
                  onChanged: (value) {
                    setState(() {
                      widget.selectedBussinesTurnover.text = value;
                    });
                  },
                  onSaved: (value) {
                    // widget.merchantCompanyDetailsReq.gronull = 555555;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'MCC Group is Mandatory!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15.0),
                CustomTextFormField(
                    title: 'Merchant Id',
                    required: true,
                    controller: widget.merchantIdCtrl,
                    maxLength: 24,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.store_alt_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]'))
                    ],
                    onSaved: (value) {
                      widget.merchantCompanyDetailsReq.merchantId = value;
                    },
                    onChanged: (value) {
                      setState(() {
                        widget.merchantCompanyDetailsReq.merchantId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Merchant Id is Mandatory!';
                      }
                      if (!RegExp(r'^[-a-zA-Z0-9]+(\s[-a-zA-Z0-9]+)*$')
                          .hasMatch(value)) {
                        return 'Invalid Merchant Id';
                      }
                      return null;
                    }),
                const SizedBox(height: 15.0),
                CustomTextFormField(
                    title: 'Merchant Address',
                    required: true,
                    controller: widget.merchantAddressCtrl,
                    minLines: 2,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.home_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]'))
                    ],
                    onSaved: (value) {
                      widget.merchantCompanyDetailsReq.merchantAddress = value;
                    },
                    onChanged: (value) {
                      setState(() {
                        widget.merchantCompanyDetailsReq.merchantAddress =
                            value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Merchant Address is Mandatory!';
                      }
                      if (!RegExp(r'^[-a-zA-Z0-9]+(\s[-a-zA-Z0-9]+)*$')
                          .hasMatch(value)) {
                        return 'Invalid Merchant Address';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                    title: 'Street Name',
                    required: true,
                    controller: widget.merchantStreetNameCtrl,
                    maxLength: 24,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.store_alt_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]'))
                    ],
                    onSaved: (value) {
                      widget.merchantCompanyDetailsReq.merchantAddr2 = value;
                    },
                    onChanged: (value) {
                      setState(() {
                        widget.merchantCompanyDetailsReq.merchantAddr2 = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Street Name is Mandatory!';
                      }
                      if (!RegExp(r'^[-a-zA-Z0-9]+(\s[-a-zA-Z0-9]+)*$')
                          .hasMatch(value)) {
                        return 'Invalid Street Name';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown(
                        title: "Country",
                        required: true,
                        enabled: true,
                        selectedItem: widget.selectedCountry.text != ''
                            ? widget.selectedCountry.text
                            : null,
                        prefixIcon: Icons.location_city_outlined,
                        itemList: const [
                          "India",
                        ],
                        // widget.mccList
                        //     .map((e) => e['mccDescription'].toString())
                        //     .toList(),
                        onChanged: (value) {
                          setState(() {
                            widget.selectedCountry.text = value;
                            widget.merchantCompanyDetailsReq.countryId = 784;
                          });
                        },
                        onSaved: (value) {
                          widget.merchantCompanyDetailsReq.countryId = 784;
                          // List state = widget.mccList
                          //     .where((element) =>
                          //         element['mccDescription'] == value)
                          //     .toList();
                          // String id = state[0]['mccId'].toString();
                          //widget.requestModel.mcc = id;
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
                      width: 20,
                    ),
                    Expanded(
                      child: CustomDropdown(
                        title: "City Name",
                        required: true,
                        enabled: true,
                        selectedItem: widget.selectedCityCtrl.text != ''
                            ? widget.selectedCityCtrl.text
                            : null,
                        prefixIcon: Icons.location_city_outlined,
                        itemList: [
                          'Chennai',
                          "Hyderabad ",
                          "Bangalore ",
                          "Pune "
                        ],

                        // widget.mccList
                        //     .map((e) => e['mccDescription'].toString())
                        //     .toList(),
                        onChanged: (value) {
                          setState(() {
                            widget.merchantCompanyDetailsReq.cityCode = 1;
                            widget.selectedCityCtrl.text = value;
                          });
                        },
                        onSaved: (value) {
                          widget.merchantCompanyDetailsReq.cityCode = 1;
                          // List state = widget.mccList
                          //     .where((element) =>
                          //         element['mccDescription'] == value)
                          //     .toList();
                          // String id = state[0]['mccId'].toString();
                          // widget.requestModel.mcc = id;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'City Name Mandatory!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomDropdown(
                  title: "Currency",
                  required: true,
                  enabled: true,
                  selectedItem: widget.selectedCurrency.text != ''
                      ? widget.selectedCurrency.text
                      : null,
                  prefixIcon: Icons.location_city_outlined,
                  itemList: ['INR'],
                  // widget.MCCGroupList.map((e) => e['mccGroupId'].toString())
                  //     .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.selectedCurrency.text = value;
                      widget.merchantCompanyDetailsReq.currency = 356;
                    });
                  },
                  onSaved: (value) {
                    widget.merchantCompanyDetailsReq.currency = 356;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Currency is Mandatory!';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                    title: 'Merchant Description',
                    required: true,
                    controller: widget.merchantDescriptionCtrl,
                    maxLength: 24,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.store_alt_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]'))
                    ],
                    onSaved: (value) {
                      widget.merchantCompanyDetailsReq.description = value;
                    },
                    onChanged: (value) {
                      setState(() {
                        widget.merchantCompanyDetailsReq.description = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Merchant Description is Mandatory!';
                      }
                      if (!RegExp(r'^[-a-zA-Z0-9]+(\s[-a-zA-Z0-9]+)*$')
                          .hasMatch(value)) {
                        return 'Invalid Merchant Description';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                    title: 'Zip Code',
                    required: true,
                    controller: widget.merchantZipCodeCtrl,
                    maxLength: 6,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.store_alt_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onSaved: (value) {
                      widget.merchantCompanyDetailsReq.zipCode = value;
                    },
                    onChanged: (value) {
                      setState(() {
                        widget.merchantCompanyDetailsReq.zipCode = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Zip Code is Mandatory!';
                      }
                      if (!RegExp(r'^[-a-zA-Z0-9]+(\s[-a-zA-Z0-9]+)*$')
                          .hasMatch(value)) {
                        return 'Invalid Zip Code';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15,
                ),
                CustomMobileField(
                  controller: _mobileNoController,
                  keyboardType: TextInputType.number,
                  title: 'Mobile Number',
                  enabled: true,
                  required: true,
                  helperText: mobileNoCheckMessage,
                  helperStyle: style,
                  prefixIcon: FontAwesome.mobile,
                  countryCode: countryCode,
                  onChanged: (phone) {
                    setState(() {
                      widget.merchantCompanyDetailsReq.mobileNo =
                          phone.completeNumber;
                      // if (phone.number.isNotEmpty &&
                      //     (phone.number.length >= _country.minLength &&
                      //         phone.number.length <= _country.maxLength)) {
                      //   //getEmailIdOrMobileNo('mobileNumber', phone.number);
                      // } else {
                      //   // mobile = false;
                      //   // enabledEmail = false;
                      // }
                    });
                  },
                  onSaved: (phone) {
                    // print(phone.completeNumber+'onsavedfromphonenumber');
                    widget.merchantCompanyDetailsReq.mobileNo =
                        phone.completeNumber;
                  },
                  onCountryChanged: (country) {
                    setState(() {});
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                emailWidget(),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text('GST Applicable'),
                        Switch(
                            activeColor: AppColors.kLightGreen,
                            inactiveThumbColor: AppColors.white,
                            inactiveTrackColor: AppColors.kRedColor,
                            value: vatApplicable,
                            onChanged: (value) {
                              widget.merchantCompanyDetailsReq.vatApplicable =
                                  value;
                              setState(() {
                                vatApplicable = value;
                                if (!value) {
                                  widget.vatValueCtrl.clear();
                                  widget.VATRegistrationNumberCtrl.clear();
                                }
                                //                                 vatApplicable
                                // ? widget.vatValueCtrl.text = value
                                // : widget.vatValueCtrl.text='';
                              });
                            }),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),

                const SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                    title: 'Shareholder Percent',
                    required: true,
                    controller: widget.shareholderPercentCtrl,
                    maxLength: 3,
                    keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.store_alt_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onSaved: (value) {
                      widget.merchantCompanyDetailsReq.shareholderPercent =
                          value;
                    },
                    onChanged: (value) {
                      setState(() {
                        widget.merchantCompanyDetailsReq.shareholderPercent =
                            value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Shareholder Percent is Mandatory!';
                      }
                      if (int.parse(value) > 100) {
                        return 'invalid percent';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15,
                ),
                CustomDropdown(
                  title: "Geofencing Radious",
                  required: true,
                  enabled: true,
                  selectedItem: widget.selectedGeoFencingRadius.text != ''
                      ? widget.selectedGeoFencingRadius.text
                      : null,
                  prefixIcon: Icons.location_city_outlined,
                  itemList: geoFencingRadiusList
                      .map((map) => map['label'].toString())
                      .toList(),
                  // widget.mccList
                  //     .map((e) => e['mccDescription'].toString())
                  //     .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.selectedGeoFencingRadius.text = value;

                      widget.merchantCompanyDetailsReq.geofenceRadius =
                          getValueByLabel(geoFencingRadiusList, value);
                    });
                  },
                  onSaved: (value) {
                    // List state = widget.mccList
                    //     .where((element) => element['mccDescription'] == value)
                    //     .toList();
                    // String id = state[0]['mccId'].toString();
                    // widget.requestModel.mcc = id;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'MCC is Mandatory!';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                    title: 'Max Auth Amount',
                    required: true,
                    controller: widget.maxAuthAmountCtrl,
                    maxLength: 20,
                    keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.store_alt_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onSaved: (value) {
                      widget.merchantCompanyDetailsReq.maxAuthAmount = value;
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Max Auth Amount is Mandatory!';
                      }
                      if (!RegExp(r'^[-a-zA-Z0-9]+(\s[-a-zA-Z0-9]+)*$')
                          .hasMatch(value)) {
                        return 'Invalid Max Auth Amount';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                    title: 'Max Terminal Count',
                    required: true,
                    controller: widget.maxTerminalCountCtrl,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.none,
                    prefixIcon: LineAwesome.store_alt_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    onSaved: (value) {
                      widget.merchantCompanyDetailsReq.maxTerminalCount = value;
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Max Terminal Count is Mandatory!';
                      }
                      if (!RegExp(r'^[-a-zA-Z0-9]+(\s[-a-zA-Z0-9]+)*$')
                          .hasMatch(value)) {
                        return 'Invalid Terminal Count';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(height: 10.0),
                CustomTextFormField(
                    title: 'Trade License Number',
                    required: true,
                    enabled: true,
                    maxLength: 16,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d]'))
                    ],
                    controller: widget.tradeLicenseCtrl,
                    prefixIcon: LineAwesome.file,
                    onSaved: (value) {
                      widget.merchantCompanyDetailsReq.tradeLicenseNumber =
                          value;
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Trade License Number is Mandatory!';
                      }
                      if (value.length < 8) {
                        return 'Minimum 4 and Maximum 16 characters';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                    title: 'Trade License Expiry Date',
                    required: true,
                    enabled: true,
                    controller: widget.tradeLicenseExpiryCtrl,
                    prefixIcon: LineAwesome.calendar_alt_solid,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        initialDatePickerMode: DatePickerMode.day,
                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                        context: context,
                        initialDate: widget.tradeSelectedDt,
                        firstDate: DateTime.now().add(const Duration(days: 0)),
                        lastDate: DateTime(DateTime.now().year + 10),
                      );
                      if (pickedDate != null) {
                        String formattedDateUI =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                        setState(() {
                          widget.tradeSelectedDt = pickedDate;

                          widget.tradeLicenseExpiryCtrl.text = formattedDateUI;
                        });
                      } else {}
                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat("yyyy-MM-ddTHH:mm:ss.SSS")
                                .format(pickedDate);
                        widget.merchantCompanyDetailsReq
                            .tradeLicenseExpiryDate = formattedDate;
                        print('Formatted Date: ${formattedDate}Z');
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Expiry Date is Mandatory!';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15,
                ),
                CustomTextFormField(
                  title: 'Merchant percentage Amount',
                  required: true,
                  enabled: true,
                  maxLength: 3,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                  ],
                  controller: widget.merchantPercentageAmountCtrl,
                  prefixIcon: LineAwesome.id_card_solid,
                  onSaved: (value) {
                    widget.merchantCompanyDetailsReq.relationshipManagerId =
                        100;
                    widget.merchantCompanyDetailsReq.merchantLogoImage =
                        'abc.png';
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Merchant percentage Amount is Mandatory!';
                    }
                    if (int.parse(value) > 100) {
                      return 'invalid percent';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          children: [
                            Text('T + 1'),
                            Switch(
                                activeColor: AppColors.kLightGreen,
                                inactiveThumbColor: AppColors.white,
                                inactiveTrackColor: AppColors.kRedColor,
                                value: holdFullPayment,
                                onChanged: (value) {
                                  setState(() {
                                    holdFullPayment = value;
                                    widget.merchantCompanyDetailsReq
                                            .holdFullPaymentAmount =
                                        holdFullPayment;
                                  });
                                }),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          children: [
                            const Text('DCC Supported ?'),
                            Switch(
                                activeColor: AppColors.kLightGreen,
                                inactiveThumbColor: AppColors.white,
                                inactiveTrackColor: AppColors.kRedColor,
                                value: DCCSupported,
                                onChanged: (value) {
                                  setState(() {
                                    DCCSupported = value;
                                    widget.merchantCompanyDetailsReq
                                        .isDccSupported = DCCSupported;
                                  });
                                }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          children: [
                            Text('Tips Allowed ?'),
                            Switch(
                                activeColor: AppColors.kLightGreen,
                                inactiveThumbColor: AppColors.white,
                                inactiveTrackColor: AppColors.kRedColor,
                                value: tipsAllowed,
                                onChanged: (value) {
                                  setState(() {
                                    tipsAllowed = value;
                                    widget.merchantCompanyDetailsReq
                                        .tipsAllowed = tipsAllowed;
                                  });
                                }),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          children: [
                            Text('Status ?'),
                            Switch(
                                activeColor: AppColors.kLightGreen,
                                inactiveThumbColor: AppColors.white,
                                inactiveTrackColor: AppColors.kRedColor,
                                value: status,
                                onChanged: (value) {
                                  setState(() {
                                    status = value;

                                    widget.merchantCompanyDetailsReq.status =
                                        status;
                                  });
                                }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomAppButton(
                        title: '< Back',
                        onPressed: () {
                          widget.previous();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      flex: 4,
                      child: CustomAppButton(
                        title: "Next",
                        onPressed: () {
                          if (businessFormKey.currentState!.validate()) {
                            businessFormKey.currentState!.save();
                            print(jsonEncode(
                                widget.merchantCompanyDetailsReq.toJson()));

                            widget.next();
                          }
                        },
                      ),
                    )
                  ],
                ),
                // Placeholder(
                //   child: ElevatedButton(
                //       onPressed: () {
                //         widget.next();
                //       },
                //       child: Text('next')),
                // ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ));
  }

  getAcqApplicationid(String guid) {
    userServices.getAcqApplicationid(guid).then((acqApplications) async {
      setState(() {
        for (var acqApplication in acqApplications) {
          String acquirerName = acqApplication['description'];
          String acquirerId = acqApplication['acquirerId'];
          acquierApplicationidList[acquirerName] = acquirerId;

          print(acqApplication['acquirerId']);
        }

        isAquirerselected = true;
        // for (var acquirer in acquirerDetails) {
        //   String acquirerName = acquirer['description'];
        //   print('Acquirer Name: $acquirerName');
        // }

        //     print('length  : ${acqApplicationId.length}');
        // for (var acquirer in acqApplicationId) {
        //   String acquirerName = acquirer['description'];
        //   print('Acquirer Application id: $acquirerName');
        // }
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
    });
  }

  emailWidget() {
    return CustomTextFormField(
      controller: emailController,
      required: true,
      textInputAction: TextInputAction.done,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[a-z_A-Z\d.@]'))
      ],
      keyboardType: TextInputType.emailAddress,
      enabled: true,
      prefixIcon: Icons.alternate_email,
      //helperText: emailHelper(),
      helperStyle: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: Theme.of(context).primaryColor),
      title: 'Email ID',

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email ID is Mandatory! ';
        } else {
          final bool isValid = EmailValidator.validate(value);
          if (!isValid) {
            return Constants.emailError;
          }
          // if (emailCheck == 'true') {
          //   return Constants.emailIdFailureMessage;
          // }
        }

        return null;
      },
      onSaved: (value) {
        widget.merchantCompanyDetailsReq.emailId = value;
      },
    );
  }

  int? getValueByLabel(List<Map<String, dynamic>> list, String label) {
    for (var map in list) {
      if (map['label'] == label) {
        return map['value'];
      }
    }
    return null;
  }
}
