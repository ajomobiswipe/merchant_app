import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../config/config.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../storage/secure_storage.dart';
import '../../widgets/m_pin_verify.dart';
import '../../widgets/widget.dart';

class AddMoneyToWallet extends StatefulWidget {
  const AddMoneyToWallet({Key? key}) : super(key: key);

  @override
  State<AddMoneyToWallet> createState() => _AddMoneyToWalletState();
}

class _AddMoneyToWalletState extends State<AddMoneyToWallet> {
  var tabIndex = 0;
  bool _isLoading = false;
  AddMoneyModel addMoneyModel = AddMoneyModel();
  CardData cardData = CardData();

  final listTabTitle = ["Account", "Card"];
  TextEditingController amountController = TextEditingController();
  static const fixedAmount = ['50', '100', '200', '400', '500', 'Others'];
  String tag = '0';
// LOCAL VARIABLES
  late String userName;
  late String customerId;
  List userAccountInfo = [];
  List userCardInfo = [];
  int selectedCardIndex = 0;
  int selectedAccountIndex = 0;
  AccountCardService accountCardService = AccountCardService();
  int value = 0;

  @override
  void initState() {
    getUser();
    Future.delayed(const Duration(seconds: 0), () {
      loadAccountAndCard();
    });
    super.initState();
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  loadAccountAndCard() async {
    setLoading(true);
    accountCardService.loadAccountAndCard(userName).then((response) {
      var jsonDecodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonDecodeData['responseCode'].toString() == "00") {
          setLoading(false);
          if (jsonDecodeData?['userAccounts']['userCardInfo'] == null) {
            setState(() {
              userCardInfo = [];
            });
          } else {
            userCardInfo = jsonDecodeData?['userAccounts']['userCardInfo'];
            var card = userCardInfo
                .where((element) => element['primary'] == true)
                .toList();
            // setState(() {
            tabIndex = card.isEmpty ? 0 : 1;
            userCardInfo.length != 1
                ? userCardInfo.sort((a, b) => Comparable.compare(
                    b['primary'].toString(), a['primary'].toString()))
                : '';
            // });
          }
          if (jsonDecodeData?['userAccounts']['userAccountInfo'] == null) {
            setState(() {
              userAccountInfo = [];
            });
          } else {
            userAccountInfo =
                jsonDecodeData?['userAccounts']['userAccountInfo'];
            var acc = userAccountInfo
                .where((element) => element['primary'] == true)
                .toList();
            // setState(() {
            tabIndex = acc.isEmpty ? 1 : 0;
            userAccountInfo.length != 1
                ? userAccountInfo.sort((a, b) => Comparable.compare(
                    b['primary'].toString(), a['primary'].toString()))
                : '';
            // });
          }
        } else {
          setLoading(false);
        }
      } else {
        setLoading(false);
        setState(() {
          userCardInfo = [];
          userAccountInfo = [];
        });
        if (userCardInfo.isEmpty && userAccountInfo.isEmpty) {
          AlertService().warn(context, '',
              'Please add your account/card details to proceed transaction');
          Navigator.pushNamed(context, 'myAccount');
        }
      }
    });
  }

  getUser() async {
    BoxStorage boxStorage = BoxStorage();
    userName = boxStorage.getUsername();
    customerId = boxStorage.getCustomerId();
  }

  Widget accounts() {
    return userAccountInfo.isEmpty
        ? const NoDataFound()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height - 600,
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: userAccountInfo.length,
                  itemBuilder: (BuildContext context, int position) {
                    return InkWell(
                      onTap: () {
                        setState(() => selectedAccountIndex = position);
                      },
                      child: Card(
                        color: userAccountInfo[position]['primary']
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColor.withOpacity(0.7),
                        child: ListTile(
                          isThreeLine: true,
                          leading: (selectedAccountIndex == position)
                              ? const Icon(
                                  LineAwesome.check_circle,
                                  color: Colors.white,
                                  size: 25,
                                )
                              : const Icon(
                                  LineAwesome.circle,
                                  color: Colors.white,
                                  size: 25,
                                ),
                          title: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                userAccountInfo[position]
                                        ['maskingAccountNumber']
                                    .toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: (selectedAccountIndex == position)
                                        ? Colors.white
                                        : Colors.white),
                              ),
                              const Spacer(),
                              userAccountInfo[position]['primary']
                                  ? Text(
                                      'Primary',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.white),
                                    )
                                  : Container(), // use Spacer
                            ],
                          ),
                          subtitle: Text(
                            "${userAccountInfo[position]['accountHolderName'].toString()}\n${userAccountInfo[position]['ibanNumber'].toString()}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white70),
                          ),
                          // trailing:
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          );
  }

  Widget cards() {
    return userCardInfo.isEmpty
        ? const NoDataFound()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height - 600,
                child: ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: userCardInfo.length,
                  itemBuilder: (BuildContext context, int position) {
                    return InkWell(
                      onTap: () => setState(() => selectedCardIndex = position),
                      child: SizedBox(
                        height: 150,
                        child: Card(
                            shape: (selectedCardIndex == position)
                                ? RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                  )
                                : null,
                            elevation: 5,
                            color: Theme.of(context).primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        userCardInfo[position]
                                                ['maskingCardNumber']
                                            .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                (selectedCardIndex == position)
                                                    ? Colors.white
                                                    : Colors.white),
                                      ),
                                      const Spacer(), // use Spacer
                                      userCardInfo[position]['primary']
                                          ? const Text(
                                              'Primary',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        userCardInfo[position]['cardHolderName']
                                            .toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const Spacer(), // use Spacer
                                      (selectedCardIndex == position)
                                          ? const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: Icon(
                                                LineAwesome.check_circle,
                                                color: Colors.white,
                                                size: 35,
                                              ),
                                            )
                                          : Container()
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          userCardInfo[position]['expiryDate']
                                              .toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        SizedBox(
                                          width: 70,
                                          height: 35,
                                          child: TextFormField(
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            style: const TextStyle(
                                                color: Colors.white),
                                            maxLength: 4,
                                            cursorColor: Colors.white,
                                            decoration: const InputDecoration(
                                              labelStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                              counterText: '',
                                              hintText: 'CVV',
                                              hintStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            textInputAction:
                                                TextInputAction.done,
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              setState(() {
                                                userCardInfo[position]['cvv'] =
                                                    value;
                                              });
                                            },
                                          ),
                                        ),
                                      ]),
                                ],
                              ),
                            )),
                      ),
                    );
                  },
                ),
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: "Add Money to Wallet",
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Choose Account or Card",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: FlutterToggleTab(
                        width: 60,
                        borderRadius: 50,
                        selectedIndex: tabIndex,
                        selectedBackgroundColors: [
                          Theme.of(context).primaryColor
                        ],
                        selectedTextStyle: const TextStyle(color: Colors.white),
                        unSelectedTextStyle: const TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.w500),
                        labels: listTabTitle,
                        selectedLabelIndex: (index) {
                          setState(() {
                            tabIndex = index;
                          });
                        },
                        marginSelected: const EdgeInsets.symmetric(
                            horizontal: 1, vertical: 1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    tabIndex == 0 ? accounts() : cards(),
                    const SizedBox(height: 10),
                    customCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Add Money to Wallet",
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                                style: const TextStyle(fontSize: 20),
                                controller: amountController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                maxLength: 6,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "Enter Amount",
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(fontSize: 20),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  prefix: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(
                                      "AED",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Amount is Mandatory';
                                  }
                                  return null;
                                }),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Choose Amount (AED)",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // ChipsChoice.single(
                            //   value: tag,
                            //   onChanged: (val) {
                            //     setState(() => tag = val.toString());
                            //     if (val != "Others") {
                            //       // value = int.parse(val) + value;
                            //       amountController.text = val.toString();
                            //     } else {
                            //       amountController.text = '';
                            //     }
                            //     amountController.selection =
                            //         TextSelection.fromPosition(TextPosition(
                            //             offset: amountController.text.length));
                            //   },
                            //   choiceItems: C2Choice.listFrom<String, String>(
                            //     source: fixedAmount,
                            //     value: (i, v) => v.toString(),
                            //     label: (i, v) {
                            //       if (v == 'Others') {
                            //         return v;
                            //       } else {
                            //         return "+$v";
                            //       }
                            //     },
                            //   ),
                            //   wrapped: true,
                            //   choiceActiveStyle: C2ChoiceStyle(
                            //     showCheckmark: false,
                            //     elevation: 2,
                            //     color: Colors.white,
                            //     borderColor: Theme.of(context).primaryColor,
                            //     backgroundColor: Theme.of(context).primaryColor,
                            //     padding:
                            //         const EdgeInsets.symmetric(horizontal: 10),
                            //     borderRadius:
                            //         const BorderRadius.all(Radius.circular(20)),
                            //   ),
                            //   choiceStyle: C2ChoiceStyle(
                            //     showCheckmark: false,
                            //     color: Theme.of(context).primaryColor,
                            //     borderColor: Colors.grey,
                            //     backgroundColor: Theme.of(context).cardColor,
                            //     padding:
                            //         const EdgeInsets.symmetric(horizontal: 10),
                            //     borderRadius:
                            //         const BorderRadius.all(Radius.circular(20)),
                            //   ),
                            // ),
                            const SizedBox(height: 20),
                            AppButton(
                              title: "Proceed to add",
                              onPressed: () async {
                                if (amountController.text == '' ||
                                    amountController.text.startsWith('0')) {
                                  AlertService().failure(
                                      context, '', 'Amount is Mandatory!');
                                } else {
                                  var results = await Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return const MPinVerify();
                                          },
                                          fullscreenDialog: true));
                                  if (results != null) {
                                    addMoneyToWallet(results);
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  addMoneyToWallet(mPIN) async {
    setLoading(true);
    addMoneyModel.mPin = await Validators.encrypt(mPIN.toString());
    addMoneyModel.custId = customerId;
    addMoneyModel.amount = amountController.text;
    addMoneyModel.transaction = "LOAD_BAL_TO_WALLET_ACCOUNT";
    addMoneyModel.instId = Constants.instId;
    addMoneyModel.description = "LOAD_BALANCE";
    addMoneyModel.fundSource = tabIndex == 0 ? "ACCOUNT" : "CARD";
    addMoneyModel.cardData = cardData;
    if (tabIndex == 0) {
      addMoneyModel.accountRefNumber = await Validators.encrypt(
          userAccountInfo[selectedAccountIndex]['accountReferenceNumber']);
    } else {
      cardData.cardRefrenceNumber = await Validators.encrypt(
          userCardInfo[selectedCardIndex]['cardReferenceNumber']);
      cardData.expDate1 = await Validators.encrypt(
          userCardInfo[selectedCardIndex]['expiryDate']);
      cardData.cvv = await Validators.encrypt(
          userCardInfo[selectedCardIndex]['cvv'].toString());
    }
    // print(jsonEncode(addMoneyModel));
    accountCardService.addMoneyToWallet(addMoneyModel).then((response) {
      var jsonDecodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonDecodeData['responseCode'].toString() == "00") {
          AlertService().success(
              context, '', jsonDecodeData['responseMessage'].toString());
          Navigator.pushReplacementNamed(context, 'wallet');
        } else {
          setLoading(false);
          AlertService().failure(
              context, '', jsonDecodeData['responseMessage'].toString());
        }
      } else {
        setLoading(false);
        AlertService()
            .failure(context, '', jsonDecodeData['message'].toString());
        // setState(() {
        //   userCardInfo = [];
        //   userAccountInfo = [];
        // });
        // if (userCardInfo.isEmpty && userAccountInfo.isEmpty) {
        //   AlertService().failure(context, '',
        //       'Please add your account/card details to proceed transaction');
        //   Navigator.pushNamed(context, 'home');
        // }
      }
    });
  }

  Widget customCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white70, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 10,
      shadowColor: Colors.black,
      child: child,
    );
  }
}
