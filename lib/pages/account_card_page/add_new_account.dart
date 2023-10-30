/* ===============================================================
| Project : SIFR
| Page    : ADD_NEW_ACCOUNT.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/storage/secure_storage.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widget.dart';

// STATEFUL WIDGET
class AddNewAccount extends StatefulWidget {
  const AddNewAccount({Key? key}) : super(key: key);

  @override
  State<AddNewAccount> createState() => _AddNewAccountState();
}

// Add New Account State Class
class _AddNewAccountState extends State<AddNewAccount> {
  // Import MODES - SERVICES - STORAGE
  AccountRequestModel accountRequestModel = AccountRequestModel();
  AccountCardService accountCardService = AccountCardService();
  AlertService alertService = AlertService();
  BoxStorage boxStorage = BoxStorage();

  // ACCOUNT ADDITION FORM KEY
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Default Widget of Height
  final Widget defaultSize = const SizedBox(
    height: 20,
  );
  late bool _isLoading = false; // Loading - Local Variable

  TextEditingController accountHolderName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Add New Account'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    defaultSize,
                    CustomTextFormField(
                      title: 'Account Holder Name',
                      required: true,
                      maxLength: 26,
                      controller: accountHolderName,
                      textCapitalization: TextCapitalization.words,
                      prefixIcon: FontAwesome.circle_user,
                      validator: (val) {
                        var value = val.trim();
                        if (value == null || value.isEmpty) {
                          return 'Account Holder Name is Mandatory!';
                        }
                        if (!Validators.isAlphaNumeric(value)) {
                          return 'Invalid Account Holder Name';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) {
                        accountHolderName.text = value.trim();
                      },
                      onSaved: (value) {
                        setState(() {
                          accountRequestModel.accountHolderName = value.trim();
                        });
                      },
                    ),
                    defaultSize,
                    CustomTextFormField(
                      title: 'Account Number',
                      required: true,
                      keyboardType: TextInputType.text,
                      prefixIcon: LineAwesome.keyboard,
                      maxLength: 26,
                      onTap: () {
                        accountHolderName.text = accountHolderName.text.trim();
                      },
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z-\d]'))
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Account Number is Mandatory!';
                        }
                        if (value.length < 8) {
                          return 'Minimum character length is 8';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() {
                          accountRequestModel.accountNumber = value;
                        });
                      },
                    ),
                    defaultSize,
                    CustomTextFormField(
                      title: 'IBAN Number',
                      required: true,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 23,
                      prefixIcon: Bootstrap.bank,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\d]'))
                      ],
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'IBAN is Mandatory!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() {
                          accountRequestModel.ibanNumber = value;
                        });
                      },
                    ),
                    defaultSize,
                    AppButton(
                      title: 'Save Account',
                      onPressed: buttonSubmit,
                    ),
                  ],
                ),
              ),
            )),
    );
  }

  // SET LOADING VARIABLE DYNAMIC FUNCTION
  isLoading(value) {
    setState(() {
      _isLoading = value;
    });
  }

  // VALIDATE ACCOUNT NAME
  bool isValidName(String input) => RegExp(
          r'^[-a-zA-Z0-9!@#$%^&*()_+=-\|{};:<>,/?.~`]+(\s[-a-zA-Z0-9!@#$%^&*()_+=-\|{};:<>,/?.~`]+)*$')
      .hasMatch(input);

  // ADDING ACCOUNT - SUBMIT FUNCTION
  void buttonSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      isLoading(true);
      accountRequestModel.instId = Constants.instId;
      accountRequestModel.accountNumber = await Validators.encrypt(
          accountRequestModel.accountNumber.toString());
      accountRequestModel.userName = boxStorage.getUsername();
      accountCardService.saveAccountsCard(accountRequestModel).then((result) {
        isLoading(false);
        var response = jsonDecode(result.body);
        if (result.statusCode == 200 || result.statusCode == 201) {
          if (response['responseCode'].toString() == '00') {
            alertService.success(context, "", response['responseMessage']);
            Navigator.pushNamed(context, 'accounts',
                arguments: {'type': Constants.account});
          } else {
            alertService.failure(context, "", response['responseMessage']);
          }
        } else {
          isLoading(false);
          alertService.failure(context, "", response['message']);
        }
      });
    }
  }
}
