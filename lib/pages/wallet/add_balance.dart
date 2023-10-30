import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../config/config.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/m_pin_verify.dart';
import '../../widgets/widget.dart';

class AddBalance extends StatefulWidget {
  const AddBalance({Key? key, required this.params}) : super(key: key);
  final dynamic params;

  @override
  State<AddBalance> createState() => _AddBalanceState();
}

class _AddBalanceState extends State<AddBalance> {
  AccountCardService accountCardService = AccountCardService();
  AddMoneyModel addMoneyModel = AddMoneyModel();
  CardData cardData = CardData();

  bool _isLoading = false;

  var tabIndex = 0;
  final listTabTitle = ["Account", "Card"];

  List userAccountInfo = [];
  List userCardInfo = [];
  int selectedCardIndex = 0;
  int selectedAccountIndex = 0;

  // LOCAL VARIABLES
  late String userName;
  late String customerId;
  @override
  void initState() {
    getUser();
    Future.delayed(const Duration(seconds: 0), () {
      loadAccountAndCard();
    });
    super.initState();
  }

  getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("userName").toString();
    customerId = prefs.getString("custId").toString();
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Add Balance',
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: FlutterToggleTab(
                        width: 60,
                        borderRadius: 10,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AppButton(
                        title: "Add Balance",
                        onPressed: () async {
                          var results = await Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const MPinVerify();
                                  },
                                  fullscreenDialog: true));
                          addMoneyToWallet(results);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  /// SPLIT WIDGETS
  Widget accounts() {
    return userAccountInfo.isEmpty
        ? const NoDataFound()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height - 300,
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
                        color: Theme.of(context).primaryColor,
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
                height: MediaQuery.of(context).size.height - 300,
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

  /// API CALL
  loadAccountAndCard() async {
    setLoading(true);
    accountCardService.loadAccountAndCard(userName).then((response) {
      var jsonDecodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonDecodeData['responseCode'].toString() == "00") {
          userAccountInfo = jsonDecodeData?['userAccounts']['userAccountInfo'];
          userCardInfo = jsonDecodeData?['userAccounts']['userCardInfo'];
          setLoading(false);
          if (userCardInfo.isEmpty) {
            setState(() {
              userCardInfo = [];
            });
          } else {
            setState(() {
              userCardInfo.length != 1
                  ? userCardInfo.sort((a, b) => Comparable.compare(
                      b['primary'].toString(), a['primary'].toString()))
                  : '';
            });
          }
          if (userAccountInfo.isEmpty) {
            setState(() {
              userAccountInfo = [];
            });
          } else {
            setState(() {
              userAccountInfo.length != 1
                  ? userAccountInfo.sort((a, b) => Comparable.compare(
                      b['primary'].toString(), a['primary'].toString()))
                  : '';
            });
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
          Navigator.pushNamed(context, 'home');
        }
      }
    });
  }

  addMoneyToWallet(mPIN) async {
    setState(() {
      addMoneyModel.custId = customerId;
      addMoneyModel.mPin = mPIN;
      addMoneyModel.amount = widget.params;
      addMoneyModel.transaction = "LOAD_BAL_TO_WALLET_ACCOUNT";
      addMoneyModel.instId = Constants.instId;
      addMoneyModel.description = "LOAD_BALANCE";
      addMoneyModel.fundSource = tabIndex == 0 ? "ACCOUNT" : "CARD";
      addMoneyModel.cardData = cardData;

      if (tabIndex == 0) {
        addMoneyModel.accountRefNumber =
            userAccountInfo[selectedAccountIndex]['accountReferenceNumber'];
      } else {
        cardData.cardRefrenceNumber =
            userCardInfo[selectedCardIndex]['cardReferenceNumber'];
        cardData.expDate1 = userCardInfo[selectedCardIndex]['expiryDate'];
        cardData.cvv = userCardInfo[selectedCardIndex]['cvv'];
      }
    });
    setLoading(true);
    accountCardService.addMoneyToWallet(addMoneyModel).then((response) {
      var jsonDecodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (jsonDecodeData['responseCode'].toString() == "00") {
          AlertService().success(
              context, '', jsonDecodeData['responseMessage'].toString());
          Navigator.pushNamedAndRemoveUntil(
              context, 'wallet', (route) => false);
        } else {
          setLoading(false);
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
}
