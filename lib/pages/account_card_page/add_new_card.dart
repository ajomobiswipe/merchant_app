/* ===============================================================
| Project : SIFR
| Page    : ADD_NEW_CARD.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions

import 'dart:convert';
import 'dart:math' as math;

import 'package:awesome_card/credit_card.dart';
import 'package:awesome_card/style/card_background.dart';
import 'package:credit_card_scanner/credit_card_scanner.dart';
import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sifr_latest/config/constants.dart';
import 'package:sifr_latest/services/account_card_service.dart';
import 'package:sifr_latest/storage/secure_storage.dart';

import '../../config/validators.dart';
import '../../models/card_model.dart';
import '../../widgets/loading.dart';
import '../../widgets/widget.dart';

// STATEFUL WIDGET
class AddNewCard extends StatefulWidget {
  const AddNewCard({Key? key}) : super(key: key);

  @override
  State<AddNewCard> createState() => _AddNewCardState();
}

// Add New Card State Class
class _AddNewCardState extends State<AddNewCard> {
  // Import Models - Services - Secure Storage
  CardRequestModel cardRequestModel = CardRequestModel();
  CardDetails? _cardDetails;
  AccountCardService accountCardService = AccountCardService();
  AlertService alertService = AlertService();
  BoxStorage boxStorage = BoxStorage();
  // Credit Card Validators
  final CreditCardValidator _ccValidator = CreditCardValidator();
  // GLOBAL - LOADING LOCAL VARIABLE's
  late bool _isLoading = false;
  // FORM LOCAL VARIABLES
  IconData brandIcon = FontAwesome.credit_card;
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvv = '';
  bool showBack = false; // CC Backside show variable (BOOL)
  late FocusNode _focusNode; // FOCUS NODE FOR CVV.

  // Controllers - New Card Addition Form
  TextEditingController cardNumberCtrl = TextEditingController();
  TextEditingController cardHolderCtrl = TextEditingController();
  TextEditingController cardExpireCtrl = TextEditingController();
  TextEditingController cardCvvCtrl = TextEditingController();
  // New Card Addition Form Key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Init function for page Initialization
  @override
  void initState() {
    super.initState();
    getFocusCardIcon();
  }

  // DISPOSE function for page Initialization
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // This is the main Build Context.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Add New Card'),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading ? const LoadingWidget() : creditCardForm(),
    );
  }

  // CVV - form field show/hide function
  getFocusCardIcon() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _focusNode.hasFocus ? showBack = true : showBack = false;
      });
    });
  }

  // Card Scanner Option
  CardScanOptions scanOptions = const CardScanOptions(
    scanCardHolderName: true,
    enableDebugLogs: false,
    validCardsToScanBeforeFinishingScan: 5,
    possibleCardHolderNamePositions: [
      CardHolderNameScanPosition.belowCardNumber,
    ],
  );
  // Card Scanner Function
  Future<void> scanCard() async {
    final CardDetails? cardDetails =
        await CardScanner.scanCard(scanOptions: scanOptions);
    if (!mounted || cardDetails == null) return;

    final newCardNumber = cardDetails.cardNumber.trim();
    var newStr = '';
    const step = 4;
    for (var i = 0; i < newCardNumber.length; i += step) {
      newStr +=
          newCardNumber.substring(i, math.min(i + step, newCardNumber.length));
      if (i + step < newCardNumber.length) newStr += ' ';
    }
    setState(() {
      cardNumber = newStr;
    });

    setState(() {
      _cardDetails = cardDetails;
      cardNumberCtrl.text = cardNumber;
      cardExpireCtrl.text = _cardDetails!.expiryDate;
      cardHolderCtrl.text = _cardDetails!.cardHolderName;
      expiryDate = _cardDetails!.expiryDate;
      cardHolderName = _cardDetails!.cardHolderName;
    });
  }

  // Credit Card Widget - returns
  Widget creditCardWidget() {
    return CreditCard(
      cardNumber: cardNumber,
      cardExpiry: expiryDate,
      cardHolderName: cardHolderName,
      cvv: cvv,
      textExpDate: 'Expiry Date',
      showBackSide: showBack,
      frontBackground: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: Theme.of(context).primaryColor,
      ),
      backBackground: CardBackgrounds.custom(0xff9974c3),
      backTextColor: Colors.white,
      showShadow: true,
    );
  }

  // CREDIT CARD - FORM
  Widget creditCardForm() {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 20.0),
                        creditCardWidget(),
                        const SizedBox(height: 20.0),
                        cardHolderWidget(),
                        const SizedBox(height: 10.0),
                        cardNumberWidget(),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: cardExpireWidget(),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: cardCvvWidget(),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        AppButton(
                          title: 'Save Card',
                          onPressed: saveNewCard,
                        ),
                        const SizedBox(height: 20.0),
                      ]))),
        ));
  }

  // GET BRAND NAME USING USER GIVEN THE CARD NUMBER.
  void getBrandIcon(String brand) {
    if (brand == 'CreditCardType.visa') {
      brandIcon = FontAwesome.cc_visa;
    } else if (brand == 'CreditCardType.mastercard') {
      brandIcon = FontAwesome.cc_mastercard;
    } else if (brand == 'CreditCardType.amex') {
      brandIcon = FontAwesome.cc_amex;
    } else if (brand == 'CreditCardType.discover') {
      brandIcon = FontAwesome.cc_discover;
    } else if (brand == 'CreditCardType.jcb') {
      brandIcon = FontAwesome.cc_jcb;
    } else if (brand == 'CreditCardType.dinersclub') {
      brandIcon = FontAwesome.cc_diners_club;
    } else {
      brandIcon = FontAwesome.credit_card;
    }
  }

  // THIS WIDGET USED FOR SHOWING THE CARD UI
  Widget cardNumberWidget() {
    return CustomTextFormField(
      title: 'Card Number',
      controller: cardNumberCtrl,
      required: true,
      prefixIcon: brandIcon,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        CardNumberInputFormatter(),
      ],
      suffixIconTrue: true,
      // suffixIcon: LineAwesome.camera_solid,
      suffixIconOnPressed: scanCard,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Card Number is Mandatory!';
        }
        // if (_ccValidator.validateCCNum(value).isValid != true) {
        //   return 'Card Number is invalid!';
        // }
        return null;
      },
      onTap: () {
        cardHolderCtrl.text = cardHolderCtrl.text.trim();
      },
      onFieldSubmitted: (value) {
        setState(() {
          cardNumber = value;
        });
      },
      onChanged: (value) {
        setState(() {
          cardNumber = value;
        });
        var brand = _ccValidator.validateCCNum(cardNumber).ccType.toString();
        getBrandIcon(brand);
      },
    );
  }

  // THIS WIDGET SHOW THE CARD HOLDER NAME
  Widget cardHolderWidget() {
    return CustomTextFormField(
      title: 'Card Holder Name',
      controller: cardHolderCtrl,
      textCapitalization: TextCapitalization.words,
      required: true,
      maxLength: 26,
      /*  inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z_]'))
      ],*/
      prefixIcon: Icons.person,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Card Holder Name is Mandatory!';
        }
        // if (!isValidName(value)) {
        //   return 'Invalid Card Holder Name';
        // }
        if (!Validators.isAlphaNumeric(value)) {
          return 'Invalid Card Holder Name';
        }
        return null;
      },
      onSaved: (value) {
        // registerRequestModel.confirmMPin = value;
      },
      onFieldSubmitted: (value) {
        cardHolderCtrl.text = value.trim();
      },
      onChanged: (value) {
        setState(() {
          cardHolderName = value;
        });
      },
    );
  }

  // THIS WIDGET SHOW THE CARD EXPIRED DATE.
  Widget cardExpireWidget() {
    return CustomTextFormField(
      title: 'Expiry Date (MM/YY)',
      hintText: 'Expiry Date',
      required: true,
      keyboardType: TextInputType.datetime,
      maxLength: 5,
      controller: cardExpireCtrl,
      prefixIcon: Icons.credit_card,
      textInputAction: TextInputAction.next,
      inputFormatters: <TextInputFormatter>[
        // FilteringTextInputFormatter.digitsOnly
        FilteringTextInputFormatter.allow(RegExp(r'[\d/]'))
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Expiry Date is Mandatory!';
        }
        var expDateResults = _ccValidator.validateExpDate(value);
        if (!expDateResults.isValid) {
          return "Check Expiry Date!";
        }
        return null;
      },
      onChanged: (value) {
        var newDateValue = value.trim();
        final isPressingBackspace = expiryDate.length > newDateValue.length;
        final containsSlash = newDateValue.contains('/');
        if (newDateValue.length >= 2 &&
            !containsSlash &&
            !isPressingBackspace) {
          newDateValue =
              '${newDateValue.substring(0, 2)}/${newDateValue.substring(2)}';
        }
        setState(() {
          cardExpireCtrl.text = newDateValue;
          cardExpireCtrl.selection = TextSelection.fromPosition(
              TextPosition(offset: newDateValue.length));
          expiryDate = newDateValue;
        });
      },
      onSaved: (value) {},
    );
  }

  // THIS WIDGET SHOW THE CARD CVV.
  Widget cardCvvWidget() {
    return CustomTextFormField(
      title: 'CVV',
      required: true,
      controller: cardCvvCtrl,
      maxLength: 4,
      obscureText: true,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      obscuringCharacter: '*',
      focusNode: _focusNode,
      prefixIcon: Icons.credit_card,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'CVV is Mandatory!';
        }
        return null;
      },
      onSaved: (value) {},
      onChanged: (value) {
        setState(() {
          cvv = value;
        });
      },
    );
  }

  //
  saveNewCard() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String username = boxStorage.getUsername();

      cardRequestModel.cardNumber = cardNumber.replaceAll(' ', '');
      cardRequestModel.cvv = await Validators.encrypt(cvv.toString());
      cardRequestModel.cardNumber =
          await Validators.encrypt(cardRequestModel.cardNumber.toString());
      cardRequestModel.expiryDate =
          await Validators.encrypt(expiryDate.toString());
      cardRequestModel.cardHolderName = cardHolderName.trim();
      cardRequestModel.instId = Constants.instId;
      cardRequestModel.userName = username;
      // print(jsonEncode(cardRequestModel));

      accountCardService.saveAccountsCard(cardRequestModel).then((result) {
        setState(() {
          _isLoading = false;
        });
        var response = jsonDecode(result.body);
        if (result.statusCode == 200 || result.statusCode == 201) {
          if (response['responseCode'].toString() == '00') {
            alertService.success(context, "", response['responseMessage']);
            Navigator.pushNamed(context, 'cards');
          } else {
            alertService.failure(context, "", response['responseMessage']);
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          alertService.failure(context, "", response['message']);
        }
      });
    }
  }
}

bool isValidName(String input) => RegExp(
        r'^[-a-zA-Z0-9!@#$%^&*()_+=-\|{};:<>,/?.~`]+(\s[-a-zA-Z0-9!@#$%^&*()_+=-\|{};:<>,/?.~`]+)*$')
    .hasMatch(input);

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
