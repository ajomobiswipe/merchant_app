import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

import '../../../config/config.dart';
import '../../../models/models.dart';
import '../../../services/services.dart';
import '../../../widgets/loading.dart';
import '../../../widgets/widget.dart';

class UpdateMerchantInfo extends StatefulWidget {
  const UpdateMerchantInfo({Key? key, this.params}) : super(key: key);
  final dynamic params;

  @override
  State<UpdateMerchantInfo> createState() => _UpdateMerchantInfoState();
}

class _UpdateMerchantInfoState extends State<UpdateMerchantInfo> {
  UserServices userServices = UserServices();
  AlertService alertWidget = AlertService();
  MerchantUpdate requestModel = MerchantUpdate();
  bool _isLoading = false;

  /// MERCHANT INFO
  late List mccList = [];
  String selectedMcc = '';
  final TextEditingController _nationalIdExpiryCtrl = TextEditingController();
  final TextEditingController _tradeLicenseExpiryCtrl = TextEditingController();
  final GlobalKey<FormState> merchantForm = GlobalKey<FormState>();

  var nationalSelectedDt = DateTime.now();
  var tradeSelectedDt = DateTime.now();

  @override
  void initState() {
    loadMcc();
    setDateFields();
    super.initState();
  }

  setDateFields() {
    var data = widget.params[0];
    var dt = DateFormat('yyyy-MM-dd');
    var a = dt.parse(data['nationalIdExpiry'].toString());
    var b = dt.parse(data['tradeLicenseExpiry'].toString());
    _nationalIdExpiryCtrl.text = DateFormat('dd-MM-yyyy').format(a);
    _tradeLicenseExpiryCtrl.text = DateFormat('dd-MM-yyyy').format(b);
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.params[0];
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Merchant Info',
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: merchantForm,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      CustomTextFormField(
                          title: 'Merchant Name',
                          required: true,
                          initialValue: data['merchantName'],
                          // controller: _merchantNameCtrl,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\d\s]'))
                          ],
                          maxLength: 24,
                          textCapitalization: TextCapitalization.words,
                          prefixIcon: LineAwesome.store_alt_solid,
                          onSaved: (value) {
                            requestModel.merchName = value;
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
                        selectedItem: selectedMcc,
                        prefixIcon: Icons.location_city_outlined,
                        itemList: mccList
                            .map((e) => e['mccDescription'].toString())
                            .toList(),
                        onChanged: (value) {},
                        onSaved: (value) {
                          List state = mccList
                              .where((element) =>
                                  element['mccDescription'] == value)
                              .toList();
                          String id = state[0]['mccId'].toString();
                          requestModel.mcc = id;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      CustomDropdown(
                        title: "Business Type",
                        required: true,
                        selectedItem: data['businessType'],
                        prefixIcon: LineAwesome.business_time_solid,
                        itemList: Global.businessTypeList
                            .map((e) => e['label'].toString())
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            requestModel.businessType = value;
                          });
                        },
                        onSaved: (value) {
                          requestModel.businessType = value;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      CustomTextFormField(
                          title: 'Company Registration Number',
                          required: true,
                          initialValue: data['companyRegNumber'],
                          // controller: _companyRegCtrl,
                          maxLength: 16,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\d]'))
                          ],
                          prefixIcon: LineAwesome.building,
                          onSaved: (value) {
                            requestModel.companyRegNumber = value;
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
                          maxLength: 16,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\d]'))
                          ],
                          initialValue: data['nationalId'],
                          // controller: _nationalIdCtrl,
                          prefixIcon: LineAwesome.id_card_solid,
                          onSaved: (value) {
                            requestModel.nationalId = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nation ID/Emirates ID is Mandatory!';
                            }
                            if (value.length < 4) {
                              return 'Minimum 4 and Maximum 16 characters';
                            }
                            return null;
                          }),
                      const SizedBox(height: 10.0),
                      CustomTextFormField(
                          title: 'Nation ID/Emirates ID Expiry Date',
                          required: true,
                          controller: _nationalIdExpiryCtrl,
                          // initialValue: data['nationalIdExpiry'],
                          prefixIcon: LineAwesome.calendar_alt_solid,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              initialDatePickerMode: DatePickerMode.day,
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              context: context,
                              initialDate: nationalSelectedDt,
                              firstDate:
                                  DateTime.now().add(const Duration(days: 0)),
                              lastDate: DateTime(DateTime.now().year + 10),
                            );
                            if (pickedDate != null) {
                              nationalSelectedDt = pickedDate;
                              String formattedDate =
                                  DateFormat('dd-MM-yyyy').format(pickedDate);
                              setState(() {
                                requestModel.tradeLicenseExpiry = formattedDate;
                                _nationalIdExpiryCtrl.text = formattedDate;
                              });
                            } else {}
                          },
                          onSaved: (value) {
                            requestModel.nationalIdExpiry = value;
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
                          maxLength: 16,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\d]'))
                          ],
                          // controller: _tradeLicenseCtrl,
                          initialValue: data['tradeLicenseCode'],
                          prefixIcon: LineAwesome.file,
                          onSaved: (value) {
                            requestModel.tradeLicenseCode = value;
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
                          controller: _tradeLicenseExpiryCtrl,
                          prefixIcon: LineAwesome.calendar_alt_solid,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              initialDatePickerMode: DatePickerMode.day,
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              context: context,
                              // initialDate:
                              //     DateTime.now().add(const Duration(days: 0)),
                              initialDate: tradeSelectedDt,
                              firstDate:
                                  DateTime.now().add(const Duration(days: 0)),
                              lastDate: DateTime(DateTime.now().year + 10),
                            );
                            if (pickedDate != null) {
                              tradeSelectedDt = pickedDate;
                              String formattedDate =
                                  DateFormat('dd-MM-yyyy').format(pickedDate);
                              setState(() {
                                requestModel.tradeLicenseExpiry = formattedDate;
                                _tradeLicenseExpiryCtrl.text = formattedDate;
                                // if (_nationalIdExpiryCtrl.text.isEmpty) {
                                //   enabledMobile = false;
                                // } else {
                                //   enabledMobile = enabledDob;
                                // }
                              });
                            } else {}
                          },
                          onSaved: (value) {
                            requestModel.tradeLicenseExpiry = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Expiry Date is Mandatory!';
                            }
                            return null;
                          }),
                      const SizedBox(height: 20.0),
                      AppButton(
                        title: "Update",
                        onPressed: () {
                          updateMerchantInfoSubmit(data);
                        },
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  loadMcc() {
    setLoading(true);

    userServices.getMCC().then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'] == "00") {
          var data = widget.params[0];
          setLoading(false);
          setState(() {
            mccList = decodeData['tmsMasterMccInfo'];
            var mcc = mccList
                .where((element) => element['mccId'] == data['mcc'])
                .toList();
            setState(() {
              selectedMcc = mcc[0]['mccDescription'];
              requestModel.mcc = mcc[0]['mccId'].toString();
            });
          });
        } else {
          setLoading(false);

          setState(() {
            mccList = [];
          });
        }
      } else {
        setLoading(false);

        setState(() {
          mccList = [];
        });
      }
    });
  }

  updateMerchantInfoSubmit(data) {
    setLoading(true);
    if (merchantForm.currentState!.validate()) {
      merchantForm.currentState!.save();
    }
    requestModel.firstName = data['customer']['firstName'];
    requestModel.lastName = data['customer']['lastName'];
    requestModel.merchantZipCode = data['customer']['postalCode'];
    requestModel.currencyId = data['currencyId'].toString();
    // requestModel.latitude = '';

    userServices.updateUserDetails(requestModel).then((result) {
      var response = jsonDecode(result.body);
      setLoading(false);
      if (result.statusCode == 200 || result.statusCode == 201) {
        if (response['responseCode'] == '00') {
          Navigator.pushNamed(context, 'myAccount');
          alertWidget.success(context, 'Success', response['responseMessage']);
        } else {
          setLoading(false);
          alertWidget.failure(context, 'Failure', response['responseMessage']);
        }
      } else {
        setLoading(false);
        alertWidget.failure(context, 'Failure', response['message']);
      }
    });
  }
}
