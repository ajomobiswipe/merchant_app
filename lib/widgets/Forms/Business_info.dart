import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import '../../config/global.dart';
import '../../models/register_model.dart';
import '../app/alert_service.dart';
import '../app_widget/app_bar_widget.dart';
import '../app_widget/app_button.dart';
import '../form_field/custom_dropdown.dart';
import '../form_field/custom_text.dart';

// STATEFUL WIDGET
class BusinessInfo extends StatefulWidget {
  final MerchantRequestModel requestModel;
  final TextEditingController merchantNameCtrl;
  final TextEditingController companyRegCtrl;
  final TextEditingController nationalIdCtrl;
  final TextEditingController nationalIdExpiryCtrl;
  final TextEditingController tradeLicenseCtrl;
  final TextEditingController tradeLicenseExpiryCtrl;
  final TextEditingController selectedBusinessType;
  final TextEditingController selectedMcc;
  var tradeSelectedDt;
  var nationalSelectedDt;
  List mccList;
  Function previous;
  Function next;

  BusinessInfo({
    Key? key,
    required this.previous,
    required this.next,
    required this.merchantNameCtrl,
    required this.companyRegCtrl,
    required this.nationalIdCtrl,
    required this.nationalIdExpiryCtrl,
    required this.tradeLicenseCtrl,
    required this.tradeLicenseExpiryCtrl,
    required this.selectedMcc,
    required this.selectedBusinessType,
    this.nationalSelectedDt,
    this.tradeSelectedDt,
    required this.requestModel,
    required this.mccList,
  }) : super(key: key);

  @override
  State<BusinessInfo> createState() => _BusinessInfoState();
}

class _BusinessInfoState extends State<BusinessInfo> {
  AlertService alertWidget = AlertService();
  bool enabledMcc = false;
  bool enabledBusinessType = false;
  bool enabledRegistrationNumber = false;
  bool enabledNationalId = false;
  bool enabledNationalDate = false;
  bool enabledLicence = false;
  bool enabledLicenceDate = false;
  final GlobalKey<FormState> businessFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWidget(
          action: false,
          title: 'Business Information',
          automaticallyImplyLeading: false,
        ),
        body: Form(
          key: businessFormKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                CustomTextFormField(
                    title: 'Merchant Name',
                    required: true,
                    controller: widget.merchantNameCtrl,
                    maxLength: 24,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.words,
                    prefixIcon: LineAwesome.store_alt_solid,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d\s]'))
                    ],
                    onSaved: (value) {
                      widget.requestModel.merchantName = value;
                    },
                    onChanged: (value) {
                      setState(() {
                        value.isEmpty ? enabledMcc = false : enabledMcc = true;
                      });
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
                CustomDropdown(
                  title: "MCC",
                  required: true,
                  enabled: widget.merchantNameCtrl.text.isNotEmpty
                      ? enabledMcc = true
                      : enabledMcc = false,
                  selectedItem: widget.selectedMcc.text != ''
                      ? widget.selectedMcc.text
                      : null,
                  prefixIcon: Icons.location_city_outlined,
                  itemList: widget.mccList
                      .map((e) => e['mccDescription'].toString())
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.selectedMcc.text = value;
                      widget.selectedMcc.text == ''
                          ? enabledBusinessType = false
                          : enabledBusinessType = true;
                    });
                  },
                  onSaved: (value) {
                    List state = widget.mccList
                        .where((element) => element['mccDescription'] == value)
                        .toList();
                    String id = state[0]['mccId'].toString();
                    widget.requestModel.mcc = id;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'MCC is Mandatory!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                CustomDropdown(
                  title: "Business Type",
                  required: true,
                  enabled: widget.selectedMcc.text == ''
                      ? enabledBusinessType = false
                      : enabledBusinessType = enabledMcc,
                  selectedItem: widget.selectedBusinessType.text != ''
                      ? widget.selectedBusinessType.text
                      : null,
                  prefixIcon: LineAwesome.business_time_solid,
                  itemList: Global.businessTypeList
                      .map((e) => e['label'].toString())
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.selectedBusinessType.text = value;
                      widget.requestModel.businessType = value;
                      widget.selectedBusinessType.text == ''
                          ? enabledRegistrationNumber = false
                          : enabledRegistrationNumber = true;
                    });
                  },
                  onSaved: (value) {
                    widget.requestModel.businessType = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Business Type is Mandatory!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                CustomTextFormField(
                    title: 'Company Registration Number',
                    enabled: widget.selectedBusinessType.text == ''
                        ? enabledRegistrationNumber = false
                        : enabledRegistrationNumber = enabledBusinessType,
                    required: true,
                    controller: widget.companyRegCtrl,
                    maxLength: 16,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d]'))
                    ],
                    prefixIcon: LineAwesome.building,
                    onSaved: (value) {
                      widget.requestModel.companyRegNumber = value;
                    },
                    onChanged: (value) {
                      setState(() {
                        value.isEmpty || value.length < 4
                            ? enabledNationalId = false
                            : enabledNationalId = true;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Company Register Name is Mandatory!';
                      }
                      if (value.length < 4) {
                        return 'Minimum 4 and Maximum 16 characters';
                      }
                      return null;
                    }),
                const SizedBox(height: 10.0),
                CustomTextFormField(
                  title: 'Nation ID/Emirates ID',
                  required: true,
                  enabled: widget.companyRegCtrl.text.isEmpty ||
                          widget.companyRegCtrl.text.length < 4
                      ? enabledNationalId = false
                      : enabledNationalId = enabledRegistrationNumber,
                  maxLength: 16,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d]'))
                  ],
                  controller: widget.nationalIdCtrl,
                  prefixIcon: LineAwesome.id_card_solid,
                  onSaved: (value) {
                    widget.requestModel.nationalId = value;
                  },
                  onChanged: (value) {
                    setState(() {
                      value.isEmpty || value.length < 4
                          ? enabledNationalDate = false
                          : enabledNationalDate = true;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nation ID/Emirates ID is Mandatory!';
                    }
                    if (value.length < 4) {
                      return 'Minimum 4 and Maximum 16 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                CustomTextFormField(
                    title: 'Nation ID/Emirates ID Expiry Date',
                    required: true,
                    enabled: widget.nationalIdCtrl.text.isEmpty ||
                            widget.nationalIdCtrl.text.length < 4
                        ? enabledNationalDate = false
                        : enabledNationalDate = enabledNationalId,
                    controller: widget.nationalIdExpiryCtrl,
                    prefixIcon: LineAwesome.calendar_alt_solid,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        initialDatePickerMode: DatePickerMode.day,
                        initialEntryMode: DatePickerEntryMode.calendarOnly,
                        context: context,
                        initialDate: widget.nationalSelectedDt,
                        firstDate: DateTime.now().add(const Duration(days: 0)),
                        lastDate: DateTime(DateTime.now().year + 10),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                        setState(() {
                          widget.nationalSelectedDt = pickedDate;
                          widget.requestModel.tradeLicenseExpiry =
                              formattedDate;
                          widget.nationalIdExpiryCtrl.text = formattedDate;
                          pickedDate != null
                              ? enabledLicence = true
                              : enabledLicence = false;
                        });
                      } else {}
                    },
                    onSaved: (value) {
                      widget.requestModel.nationalIdExpiry = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Expiry Date is Mandatory!';
                      }
                      return null;
                    }),
                const SizedBox(height: 10.0),
                CustomTextFormField(
                    title: 'Trade License Code',
                    required: true,
                    enabled: widget.nationalIdExpiryCtrl.text.isEmpty
                        ? enabledLicence = false
                        : enabledLicence = enabledNationalDate,
                    maxLength: 16,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d]'))
                    ],
                    controller: widget.tradeLicenseCtrl,
                    prefixIcon: LineAwesome.file,
                    onSaved: (value) {
                      widget.requestModel.tradeLicenseCode = value;
                    },
                    onChanged: (value) {
                      setState(() {
                        value.isEmpty || value.length < 4
                            ? enabledLicenceDate = false
                            : enabledLicenceDate = true;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Trade License Code is Mandatory!';
                      }
                      if (value.length < 4) {
                        return 'Minimum 4 and Maximum 16 characters';
                      }
                      return null;
                    }),
                const SizedBox(height: 10.0),
                CustomTextFormField(
                    title: 'Trade License Expiry Date',
                    required: true,
                    enabled: widget.tradeLicenseCtrl.text.isEmpty ||
                            widget.tradeLicenseCtrl.text.length < 4
                        ? enabledLicenceDate = false
                        : enabledLicenceDate = enabledLicence,
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
                        String formattedDate =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                        setState(() {
                          widget.tradeSelectedDt = pickedDate;
                          widget.requestModel.tradeLicenseExpiry =
                              formattedDate;
                          widget.tradeLicenseExpiryCtrl.text = formattedDate;
                        });
                      } else {}
                    },
                    onSaved: (value) {
                      widget.requestModel.tradeLicenseExpiry = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Expiry Date is Mandatory!';
                      }
                      return null;
                    }),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: AppButton(
                        title: 'Previous',
                        onPressed: () {
                          widget.previous();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: AppButton(
                        title: "Next",
                        onPressed: () {
                          if (businessFormKey.currentState!.validate()) {
                            businessFormKey.currentState!.save();
                            widget.next();
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
            ),
          ),
        ));
  }
}
