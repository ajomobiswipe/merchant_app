import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../../config/config.dart';
import '../../../models/models.dart';
import '../../../services/services.dart';
import '../../../widgets/widget.dart';

class UpdatePersonalInfo extends StatefulWidget {
  const UpdatePersonalInfo({Key? key, this.params, required this.role})
      : super(key: key);
  final dynamic params;
  final String role;
  @override
  State<UpdatePersonalInfo> createState() => _UpdatePersonalInfoState();
}

class _UpdatePersonalInfoState extends State<UpdatePersonalInfo> {
  UserServices userServices = UserServices();
  AlertService alertWidget = AlertService();

  UpdatePersonalInfoModel requestModel = UpdatePersonalInfoModel();
  final GlobalKey<FormState> personalForm = GlobalKey<FormState>();
  final TextEditingController _zipCodeController = TextEditingController();

  List countryList = [];
  List stateList = [];
  List cityList = [];

  bool _isLoading = false;
  String role = '';
  @override
  void initState() {
    getUser();
    getCountry();
    super.initState();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role').toString();
    if (role == 'MERCHANT') {
      _zipCodeController.text = widget.params[0]['merchantZipCode'];
    } else {
      _zipCodeController.text = widget.params[0]['customer']['postalCode'];
    }
  }

  getCountry() {
    userServices.getCountry().then((response) async {
      if (response.statusCode == 200 || response.statusCode == 201) {
        var decodeData = jsonDecode(response.body);
        if (decodeData['responseType'] == "S") {
          setState(() {
            countryList = decodeData['responseValue']['list'];
            countryList.isEmpty
                ? null
                : getState(countryList[0]['id'].toString());
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
            if (stateList.isNotEmpty && widget.role == 'MERCHANT') {
              var result = stateList.firstWhere((element) =>
                  element['staName'].toString() ==
                  widget.params[0]['customer']['state'].toString());
              getCity(result['id'].toString());
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
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.params[0];
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Personal Info',
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: personalForm,
                  child: Column(children: [
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      title: 'Nick Name',
                      initialValue: data['customer']['nickName'] ?? '',
                      prefixIcon: LineAwesome.user_circle,
                      keyboardType: TextInputType.text,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\d\s]'))
                      ],
                      onSaved: (value) {
                        requestModel.nickName = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        if (!Validators.isValidName(value)) {
                          return 'Invalid Nick Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      title: 'Street Address',
                      initialValue: data['customer']['address'] ?? '',
                      prefixIcon: LineAwesome.map_signs_solid,
                      keyboardType: TextInputType.text,
                      onSaved: (value) {
                        requestModel.address = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        if (!RegExp(r'^[-a-zA-Z/\d]+(\s[-/a-zA-Z\d]+)*$')
                            .hasMatch(value)) {
                          return 'Invalid Address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown(
                      title: "Country",
                      required: widget.role == "MERCHANT" ? true : false,
                      selectedItem: data['customer']['country'],
                      itemList: countryList.map((e) => e['ctyName']).toList(),
                      prefixIcon: LineAwesome.map_marked_solid,
                      onChanged: (value) {
                        List selectedCountry = countryList
                            .where((element) => element['ctyName'] == value)
                            .toList();
                        String id = selectedCountry[0]['id'].toString();
                        String currencyCode =
                            selectedCountry[0]['currencyCode'];
                        getState(id);
                      },
                      onSaved: (value) {
                        requestModel.country = value;
                      },
                      validator: (value) {
                        if (widget.role == "MERCHANT") {
                          if (value.isEmpty) {
                            return 'Country is Mandatory!';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown(
                      title: "State",
                      required: widget.role == "MERCHANT" ? true : false,
                      selectedItem: data['customer']['state'],
                      itemList: stateList.map((e) => e['staName']).toList(),
                      prefixIcon: LineAwesome.map_marked_solid,
                      onChanged: (value) {
                        List state = stateList
                            .where((element) => element['staName'] == value)
                            .toList();
                        String id = state[0]['id'].toString();
                        getCity(id);
                      },
                      onSaved: (value) {
                        requestModel.state = value;
                      },
                      validator: (value) {
                        if (widget.role == "MERCHANT") {
                          if (value.isEmpty) {
                            return 'State is Mandatory!';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown(
                      title: "City",
                      required: widget.role == "MERCHANT" ? true : false,
                      selectedItem: data['customer']['city'],
                      itemList: cityList.map((e) => e['citName']).toList(),
                      prefixIcon: LineAwesome.map_marked_solid,
                      onSaved: (value) {
                        requestModel.city = value;
                      },
                      validator: (value) {
                        if (widget.role == "MERCHANT") {
                          if (value.isEmpty) {
                            return 'City is Mandatory!';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      title: 'Makani No',
                      maxLength: 10,
                      controller: _zipCodeController,
                      prefixIcon: LineAwesome.map_signs_solid,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'\d'))
                      ],
                      onSaved: (value) {
                        requestModel.merchZipCode = value;
                        requestModel.postalCode = value;
                      },
                      validator: (value) {
                        if (!value.isEmpty && value.length < 10) {
                          return 'Minimum 10 digits';
                        }
                        if (value.isEmpty) {
                          return null;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    AppButton(
                      title: "Update",
                      onPressed: () {
                        updateProfileInformation(data);
                      },
                    ),
                    const SizedBox(height: 10),
                  ]),
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

  updateProfileInformation(data) {
    if (personalForm.currentState!.validate()) {
      personalForm.currentState!.save();
      setLoading(true);
      requestModel.firstName = data['customer']['firstName'];
      requestModel.lastName = data['customer']['lastName'];
      userServices.updateUserDetails(requestModel).then((result) {
        var response = jsonDecode(result.body);
        setLoading(false);
        if (result.statusCode == 200 || result.statusCode == 201) {
          if (response['responseCode'] == '00') {
            Navigator.pushNamed(context, 'myAccount');
            alertWidget.success(
                context, 'Success', response['responseMessage']);
          } else {
            setLoading(false);
            alertWidget.failure(
                context, 'Failure', response['responseMessage']);
          }
        } else {
          setLoading(false);
          alertWidget.failure(context, 'Failure', response['message']);
        }
      });
    }
  }
}
