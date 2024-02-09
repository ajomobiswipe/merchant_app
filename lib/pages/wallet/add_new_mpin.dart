import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/loading.dart';
import '../../widgets/widget.dart';

class AddNewMpin extends StatefulWidget {
  const AddNewMpin({Key? key}) : super(key: key);

  @override
  State<AddNewMpin> createState() => _AddNewMpinState();
}

class _AddNewMpinState extends State<AddNewMpin> {
  bool _isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  MPINRequest requestModel = MPINRequest();
  WalletService walletService = WalletService();
  AlertService alertService = AlertService();
  bool isIcon = false;
  bool hidePin = true;
  bool hideConfirmPin = true;

  TextEditingController mpinController = TextEditingController();
  TextEditingController confirmMpinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Add New MPIN',
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        "Transaction MPIN",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor),
                      ),
                      Text(
                        "MPIN only applicable for withdrawal.",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        title: "MPIN",
                        required: true,
                        obscureText: hidePin,
                        controller: mpinController,
                        autofocus: false,
                        maxLength: 6,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        prefixIcon:
                            isIcon ? Icons.check_circle_outline : Icons.pin,
                        iconColor: isIcon ? Colors.green : null,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        suffixIconTrue: true,
                        // suffixIcon:
                        //     hidePin ? Icons.visibility : Icons.visibility_off,
                        suffixIconOnPressed: () {
                          setState(() {
                            hidePin = !hidePin;
                          });
                        },
                        onChanged: (value) {
                          if (mpinController.text.isNotEmpty &&
                              mpinController.text ==
                                  confirmMpinController.text) {
                            setState(() {
                              isIcon = true;
                            });
                          } else {
                            setState(() {
                              isIcon = false;
                            });
                          }
                        },
                        toolbarOptions: const ToolbarOptions(
                            copy: false,
                            paste: false,
                            cut: false,
                            selectAll: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'MPIN is Mandatory!';
                          }
                          if (value.length != 6) {
                            return 'MPIN must be 6 digits';
                          }
                          if (Validators.isConsecutive(value) != -1) {
                            return 'MPIN should not be consecutive digits.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                            requestModel.newMpin = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextFormField(
                        title: "Confirm MPIN",
                        required: true,
                        obscureText: hideConfirmPin,
                        controller: confirmMpinController,
                        maxLength: 6,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        prefixIcon:
                            isIcon ? Icons.check_circle_outline : Icons.pin,
                        iconColor: isIcon ? Colors.green : null,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        suffixIconTrue: true,
                        // suffixIcon: hideConfirmPin
                        //     ? Icons.visibility
                        //     : Icons.visibility_off,
                        suffixIconOnPressed: () {
                          setState(() {
                            hideConfirmPin = !hideConfirmPin;
                          });
                        },
                        onChanged: (value) {
                          if (mpinController.text.isNotEmpty &&
                              mpinController.text ==
                                  confirmMpinController.text) {
                            setState(() {
                              isIcon = true;
                            });
                          } else {
                            setState(() {
                              isIcon = false;
                            });
                          }
                        },
                        toolbarOptions: const ToolbarOptions(
                          copy: false,
                          paste: false,
                          cut: false,
                          selectAll: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm MPIN is Mandatory!';
                          }
                          if (value.length != 6) {
                            return 'Confirm MPIN must be 6 digits';
                          }
                          if (Validators.isConsecutive(value) != -1) {
                            return 'Confirm MPIN should not be consecutive digits.';
                          }
                          if (value != mpinController.text) {
                            return 'MPIN & Confirm  MPIN do not match';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          setState(() {
                            requestModel.confirmNewMpin = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      AppButton(title: "Submit", onPressed: saveMpin),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  saveMpin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerId = prefs.getString('custId')!;
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setLoading(true);
      requestModel.instId = Constants.instId;
      requestModel.requestType = "addMpin";
      requestModel.custId = customerId;
      requestModel.newMpin =
          await Validators.encrypt(requestModel.newMpin.toString());
      requestModel.confirmNewMpin =
          await Validators.encrypt(requestModel.confirmNewMpin.toString());
      walletService.mPin(requestModel).then((response) {
        var decodeData = jsonDecode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          setLoading(false);
          if (decodeData['responseCode'].toString() == "00") {
            alertService.success(context, '', decodeData['responseMessage']);
            Navigator.pushNamed(context, 'home');
          } else {
            setLoading(false);
            alertService.failure(context, '', decodeData['responseMessage']);
          }
        } else {
          setLoading(false);
          alertService.failure(context, '', decodeData['message']);
        }
      });
    }
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }
}
