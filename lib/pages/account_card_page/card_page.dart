import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/config/constants.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/widget.dart';

class CardPage extends StatefulWidget {
  final String type;

  const CardPage({Key? key, required this.type}) : super(key: key);

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  String user = '';
  bool _isLoading = false;
  TransactionServices transactionServices = TransactionServices();
  TransactionRequest transactionRequest = TransactionRequest();
  AccountCardService accountCardService = AccountCardService();
  CardManageRequestModel cardManageRequestModel = CardManageRequestModel();
  AccountRequestModel accountRequestModel = AccountRequestModel();
  ViewBalance viewBalance = ViewBalance();
  final TextEditingController _mPinController = TextEditingController();
  dynamic customerId;
  List transactionList = [];
  List userAccountInfo = [];
  List userCardInfo = [];
  late String pageType;
  late String balance = 'View Balance';
  AlertService alertWidget = AlertService();
  @override
  void initState() {
    super.initState();
    setState(() {
      pageType = widget.type;
    });
    allTransactionList(5);
    loadAccountCard();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadAccountCard() async {
    isLoading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('userName')!;
    accountCardService.loadAccountAndCard(userName).then((response) {
      var decodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'] == '00') {
          isLoading(false);
          setState(() {
            userCardInfo = decodeData['userAccounts']['userCardInfo'];
            userAccountInfo = decodeData['userAccounts']?['userAccountInfo'];
          });
          if (userAccountInfo.toString() == 'null') {
            setState(() {
              userAccountInfo = [];
            });
          } else {}
          if (userCardInfo.toString() == 'null') {
            setState(() {
              userCardInfo = [];
            });
          } else {
            setState(() {
              userCardInfo.length != 1
                  ? userCardInfo.sort((a, b) => Comparable.compare(
                      b['primary'].toString(), a['primary'].toString()))
                  : '';
              userCardInfo.length != 1
                  ? userCardInfo.sort((a, b) => Comparable.compare(
                      b['linked'].toString(), a['linked'].toString()))
                  : '';
            });
          }
        } else {
          isLoading(false);
          setState(() {
            userAccountInfo = [];
            userCardInfo = [];
          });
        }
      } else {
        isLoading(false);
        setState(() {
          userAccountInfo = [];
          userCardInfo = [];
        });
      }
    });
  }

  isLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  allTransactionList(size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = prefs.getString('custId')!;
    isLoading(true);
    transactionRequest.tranDateFrom = DateTime.now()
        .subtract(const Duration(days: 30))
        .toUtc()
        .toIso8601String();
    transactionRequest.tranDateTo = DateTime.now().toUtc().toIso8601String();
    transactionRequest.custId = user;
    transactionServices
        .loadAllTransaction(transactionRequest, size)
        .then((response) {
      isLoading(false);

      var decodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        transactionList = decodeData['content'];
      } else {
        isLoading(false);
        transactionList = [];
      }
    });
  }

  Widget addNew(context) {
    var height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
          height:
              pageType == Constants.account ? height * 0.20 : height * 0.205,
          width: MediaQuery.of(context).size.width - 100,
          // color: Colors.white70,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LineAwesome.plus_circle_solid),
                Text("add new ${pageType.toLowerCase()}")
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pushNamed(context, 'myAccount');
          return true;
        },
        child: Scaffold(
          appBar: AppBarWidget(
            title: "My $pageType",
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: _isLoading
              ? const LoadingWidget()
              : Column(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    sideCardScroll(),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Transaction History"),
                          transactionList.isNotEmpty
                              ? TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, 'transactionListing');
                                  },
                                  child: Text(
                                    'View more',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            decoration:
                                                TextDecoration.underline,
                                            decorationThickness: 3,
                                            color:
                                                Theme.of(context).primaryColor),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: transactionList.isEmpty
                              ? SizedBox(
                                  height: 600,
                                  child: Center(
                                      child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/app/no-data.png',
                                        height: 300,
                                      ),
                                      const Text("No Transactions"),
                                    ],
                                  )),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: transactionList
                                      .map((list) => RecentTransactions(list))
                                      .toList(),
                                ),
                        ),
                      ),
                    )
                  ],
                ),
        ));
  }

  Widget sideCardScroll() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        const SizedBox(
          width: 10,
        ),
        // if ((pageType == Constants.account) && userAccountInfo.isNotEmpty)
        //   ...userAccountInfo
        //       .map((list) => _accountList(context, list))
        //       .toList(),
        if ((pageType == Constants.card) && userCardInfo.isNotEmpty)
          ...userCardInfo.map((list) => _cardList(context, list)).toList(),
        GestureDetector(
          onTap: () {
            if (pageType == Constants.card) {
              Navigator.pushNamed(context, 'addNewCard');
            } else {
              Navigator.pushNamed(context, 'addNewAccount');
            }
          },
          child: addNew(context),
        ),
      ]),
    );
  }

  Widget _cardList(BuildContext context, list) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Container(
              width: MediaQuery.of(context).size.width - 55,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: list['linked']
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade500,
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              child: GestureDetector(
                onTap: () {},
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(),
                        // Text(
                        //   list['primary'].toString() == 'true'
                        //       ? "Primary $pageType"
                        //       : '',
                        //   style: Theme.of(context)
                        //       .textTheme
                        //       .bodyMedium
                        //       ?.copyWith(
                        //           fontWeight: FontWeight.bold,
                        //           color: Colors.white),
                        // ),
                        list['primary']
                            ? Text(
                                "Primary $pageType",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                              )
                            : !list['linked']
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.white,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.link,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () {
                                        linkAccountCardApi(list);
                                      },
                                    ),
                                  )
                                : Container(),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Text(
                        list['maskingCardNumber'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.055,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Card Holder Name',
                          style: TextStyle(color: Colors.white70),
                        ),
                        Text(
                          'Expiry Date',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            list['cardHolderName'].toString().toUpperCase(),
                            softWrap: true,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                color: Colors.white),
                          ),
                        ),
                        Text(
                          list['expiryDate'].toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(
                      color: Colors.white,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (list['linked']) {
                              // Navigator.pushNamed(
                              //     context, 'transactionListing');
                              transactionRequest.tranDateFrom = DateTime.now()
                                  .toUtc()
                                  .subtract(const Duration(days: 30))
                                  .toIso8601String();
                              transactionRequest.tranDateTo =
                                  DateTime.now().toUtc().toIso8601String();
                              transactionRequest.cardReferenceNumber =
                                  list['cardReferenceNumber'].toString();
                              Navigator.pushNamed(context, 'statements',
                                  arguments: {'params': transactionRequest});
                            }
                          },
                          child: const Text(
                            'Statement',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const Text(
                          '|',
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            if ((list['balance'] == null) && list['linked']) {
                              _mPinVerification(context, list);
                            }
                          },
                          child: Text(
                            list['balance'] == null
                                ? 'View Balance'
                                : 'AED ${list['balance'].toString()}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const Text(
                          '|',
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            showMaterialModalBottomSheet(
                              expand: false,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => bottomSheet(list),
                            );
                          },
                          child: const Text(
                            'Manage',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ),
      ],
    );
  }

  Widget bottomSheet(list) {
    return Material(
        child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          !list['verified'] && list['linked']
              ? ListTile(
                  title: Text('Verify $pageType'),
                  leading: const Icon(Icons.security),
                  onTap: () {
                    Navigator.pop(context);
                    verifyAccountCardApi(list);
                  },
                )
              : Container(),
          !list['primary'] && list['linked'] && list['verified']
              ? ListTile(
                  leading: const Icon(FontAwesome.repeat),
                  title: Text(
                    "Set as Primary $pageType",
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    primaryCardSwap(list);
                  },
                )
              : Container(),
          !list['linked']
              ? ListTile(
                  leading: const Icon(Icons.link),
                  title: Text(
                    "Link $pageType",
                  ),
                  onTap: () {
                    // linkAccountCard(cardDetails);
                    Navigator.pop(context);
                    linkAccountCardApi(list);
                  },
                )
              : Container(),
          list['linked'] && !list['primary']
              ? ListTile(
                  leading: const Icon(Icons.link_off),
                  title: Text('De-Link $pageType'),
                  onTap: () {
                    Navigator.pop(context);
                    deLinkAccountCardApi(list);
                  },
                )
              : Container(),
          ListTile(
            title: const Text('Close'),
            leading: const Icon(Icons.close),
            onTap: () => Navigator.of(context).pop(),
          )
        ],
      ),
    ));
  }

  void responseAlert(result) {
    var response = jsonDecode(result.body);
    if (result.statusCode == 200 || result.statusCode == 201) {
      if (response['responseCode'].toString() == '00') {
        alertWidget.success(
            context, "Success", response['responseMessage'].toString());
      } else {
        alertWidget.success(
            context, "Failed", response['responseMessage'].toString());
      }
      loadAccountCard();
    } else {
      setState(() {
        _isLoading = false;
      });
      alertWidget.success(context, "Failed", response['message'].toString());
      loadAccountCard();
    }
  }

  verifyAccountCardApi(card) async {
    isLoading(true);
    SharedPreferences sp = await SharedPreferences.getInstance();
    var userName = sp.getString("userName");
    if (pageType == Constants.card) {
      cardManageRequestModel.instId = Constants.instId;
      cardManageRequestModel.userName = userName;
      cardManageRequestModel.cardReferenceNumber = card['cardReferenceNumber'];
      accountCardService
          .verifyAccountsCard(cardManageRequestModel)
          .then((response) {
        isLoading(false);
        responseAlert(response);
      });
    } else {
      accountRequestModel.instId = Constants.instId;
      accountRequestModel.userName = userName;
      accountRequestModel.accountNumber = card['accountNumber'];
      accountRequestModel.accountHolderName = card['accountHolderName'];
      accountCardService
          .verifyAccountsCard(accountRequestModel)
          .then((response) {
        isLoading(false);
        responseAlert(response);
      });
    }
  }

  deLinkAccountCardApi(card) async {
    isLoading(true);
    SharedPreferences sp = await SharedPreferences.getInstance();
    var userName = sp.getString("userName");
    if (pageType == Constants.card) {
      cardManageRequestModel.instId = Constants.instId;
      cardManageRequestModel.userName = userName;
      cardManageRequestModel.cardReferenceNumber = card['cardReferenceNumber'];
      accountCardService
          .deLinkAccountsCard(cardManageRequestModel)
          .then((response) {
        isLoading(false);
        responseAlert(response);
      });
    } else {
      accountRequestModel.instId = Constants.instId;
      accountRequestModel.userName = userName;
      accountRequestModel.accountNumber = card['accountNumber'];
      accountRequestModel.accountHolderName = card['accountHolderName'];
      accountCardService
          .deLinkAccountsCard(accountRequestModel)
          .then((response) {
        isLoading(false);
        responseAlert(response);
      });
    }
  }

  linkAccountCardApi(card) async {
    isLoading(true);
    SharedPreferences sp = await SharedPreferences.getInstance();
    var userName = sp.getString("userName");
    if (pageType == Constants.card) {
      cardManageRequestModel.instId = Constants.instId;
      cardManageRequestModel.userName = userName;
      cardManageRequestModel.cardReferenceNumber = card['cardReferenceNumber'];
      accountCardService
          .linkAccountsCard(cardManageRequestModel)
          .then((response) {
        isLoading(false);
        responseAlert(response);
      });
    } else {
      accountRequestModel.instId = Constants.instId;
      accountRequestModel.userName = userName;
      accountRequestModel.accountNumber = card['accountNumber'];
      accountRequestModel.accountHolderName = card['accountHolderName'];
      accountCardService.linkAccountsCard(accountRequestModel).then((response) {
        isLoading(false);
        responseAlert(response);
      });
    }
  }

  primaryCardSwap(card) async {
    isLoading(true);
    late List getPreviousPrimary;

    SharedPreferences sp = await SharedPreferences.getInstance();
    var userName = sp.getString("userName");
    if (pageType == Constants.card) {
      cardManageRequestModel.instId = Constants.instId;
      cardManageRequestModel.userName = userName;
      cardManageRequestModel.changeCardRefToPrimary =
          card['cardReferenceNumber'];
      getPreviousPrimary = userAccountInfo
          .where((element) => element['primary'] == true)
          .toList();
      if (getPreviousPrimary.isEmpty) {
        getPreviousPrimary = userCardInfo
            .where((element) => element['primary'] == true)
            .toList();
      }
      if (getPreviousPrimary[0].containsKey('accountNumber')) {
        debugPrint("---------------- ACCOUNT TO CARD ---------------------");
        cardManageRequestModel.primaryAccountNumber =
            getPreviousPrimary[0]['accountNumber'];
        accountCardService
            .swapAccountToCard(cardManageRequestModel)
            .then((response) {
          isLoading(false);
          responseAlert(response);
        });
      } else {
        debugPrint("------------------ CARD TO CARD ---------------------");
        cardManageRequestModel.primaryCardRefNumber =
            getPreviousPrimary[0]['cardReferenceNumber'];
        accountCardService
            .swapCardToCard(cardManageRequestModel)
            .then((response) {
          isLoading(false);
          responseAlert(response);
        });
      }
    } else {
      accountRequestModel.instId = Constants.instId;
      accountRequestModel.userName = userName;
      var getPreviousPrimary = userAccountInfo
          .where((element) => element['primary'] == true)
          .toList();
      if (getPreviousPrimary.isEmpty) {
        getPreviousPrimary = userCardInfo
            .where((element) => element['primary'] == true)
            .toList();
      }
      accountRequestModel.changeAccountToPrimary =
          card['accountNumber'].toString();

      if (getPreviousPrimary[0].containsKey('accountNumber')) {
        debugPrint("---------------- ACCOUNT TO ACCOUNT ---------------------");
        accountRequestModel.primaryAccountNumber =
            getPreviousPrimary[0]['accountNumber'];
        accountRequestModel.primaryCardRefNumber = null;
        accountCardService
            .swapAccountToAccount(accountRequestModel)
            .then((response) {
          isLoading(false);
          responseAlert(response);
        });
      } else {
        debugPrint("---------------- CARD TO ACCOUNT ---------------------");
        accountRequestModel.changeAccountToPrimary =
            card['accountNumber'].toString();
        accountRequestModel.primaryCardRefNumber =
            getPreviousPrimary[0]['cardReferenceNumber'];
        accountCardService
            .swapCardToAccount(accountRequestModel)
            .then((response) {
          isLoading(false);
          responseAlert(response);
        });
      }
    }
  }

  balanceCheck(list, mPin) async {
    isLoading(true);
    SharedPreferences sp = await SharedPreferences.getInstance();
    var customerId = sp.getString("custId");
    CardData1 cardData = CardData1();
    viewBalance.instId = Constants.instId;
    viewBalance.transaction = 'BALANCECHECK';
    viewBalance.fundSource = 'CARD';
    cardData.cardRefrenceNumber = list['cardReferenceNumber'];
    viewBalance.custId = customerId;
    viewBalance.cardData = cardData;
    viewBalance.mpin = mPin;
    _mPinController.clear();
    accountCardService.checkBalance(viewBalance).then((result) {
      var response = jsonDecode(result.body);
      if (result.statusCode == 200 || result.statusCode == 201) {
        isLoading(false);
        if (response['responseCode'].toString() == '00') {
          setState(() {
            list['balance'] = response['receipt']['availableBalance'];
          });
        } else {
          alertWidget.failure(
              context, "Failed", response['responseMessage'].toString());
        }
      } else {
        isLoading(false);
        alertWidget.failure(context, "Failed", response['message'].toString());
      }
    });
  }

  Future<void> _mPinVerification(BuildContext context, list) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Verify Your MPIN',
              textAlign: TextAlign.center,
            ),
            content: Padding(
              padding: const EdgeInsets.all(4),
              child: TextFormField(
                maxLength: 6,
                controller: _mPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                obscuringCharacter: '*',
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  hintText: 'Enter your MPIN',
                  counterText: '',
                  errorMaxLines: 2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                  prefixIcon:
                      Icon(Icons.pin, color: Theme.of(context).primaryColor),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'MPIN is Mandatory!';
                  }
                  return null;
                },
              ),
            ),
            actions: <Widget>[
              AppButton(
                title: 'Verify',
                onPressed: () {
                  Navigator.pop(context);
                  balanceCheck(list, _mPinController.text);
                },
              )
              // FlatButton(
              //   color: Colors.red,
              //   textColor: Colors.white,
              //   child: Text('CANCEL'),
              //   onPressed: () {
              //     setState(() {
              //       Navigator.pop(context);
              //     });
              //   },
              // ),
              // FlatButton(
              //   color: Colors.green,
              //   textColor: Colors.white,
              //   child: Text('OK'),
              //   onPressed: () {
              //     setState(() {
              //       codeDialog = valueText;
              //       Navigator.pop(context);
              //     });
              //   },
              // ),
            ],
          );
        });
  }
}
