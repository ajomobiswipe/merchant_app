import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sifr_latest/storage/secure_storage.dart';

import '../../config/config.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/loading.dart';
import '../../widgets/widget.dart';

class ViewMyCard extends StatefulWidget {
  const ViewMyCard({Key? key}) : super(key: key);

  @override
  State<ViewMyCard> createState() => _ViewMyCardState();
}

class _ViewMyCardState extends State<ViewMyCard> {
  bool _isLoading = false;
  AccountCardService accountCardService = AccountCardService();
  AlertService alertWidget = AlertService();
  TransactionServices transactionServices = TransactionServices();
  TransactionRequest transactionRequest = TransactionRequest();
  CardManageRequestModel cardManageRequestModel = CardManageRequestModel();
  AccountRequestModel accountRequestModel = AccountRequestModel();
  List userAccountInfo = [];
  List userCardInfo = [];

  @override
  void initState() {
    // TODO: implement initState
    loadCards();
    super.initState();
  }

  isLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, 'myAccount');
        return true;
      },
      child: Scaffold(
        appBar: const AppBarWidget(
          title: "My Cards",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, 'addNewCard');
                            },
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 1, right: 2),
                                      child: Icon(Icons.add_circle_outline,
                                          size: 20,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Add New Card',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            decoration: TextDecoration.none,
                                            decorationThickness: 3,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                    userCardInfo.isNotEmpty
                        ? verticalList()
                        : Global.noDataFound('account'),
                  ],
                ),
              ),
      ),
    );
  }

  Widget verticalList() {
    return Column(
      children: [
        ...userCardInfo.map((list) => _accountList(context, list)).toList(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _accountList(BuildContext context, list) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Container(
              // color: Theme.of(context).primaryColor.withOpacity(0.5),
              width: MediaQuery.of(context).size.width - 55,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: list['linked']
                      ? list['primary'].toString() == 'true'
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.5)
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
                        list['primary'].toString() == 'true'
                            ? Text(
                                "Primary Card",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                              )
                            : Container(),
                        list['linked'].toString() == 'false'
                            ? CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add_link,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    displayDialogConfirm(
                                        context,
                                        'Do you want to link card?',
                                        list,
                                        'link');
                                  },
                                ),
                              )
                            : CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.manage_accounts_outlined,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    showBottomSheet(
                                      // expand: false,
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => bottomSheet(list),
                                    );
                                    // linkAccountCardApi(list);
                                  },
                                ),
                              ),
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Container(),
                    //     list['primary']
                    //         ? Text(
                    //             "Primary Card",
                    //             style: Theme.of(context)
                    //                 .textTheme
                    //                 .bodyMedium
                    //                 ?.copyWith(
                    //                     fontWeight: FontWeight.bold,
                    //                     color: Colors.white),
                    //           )
                    //         : !list['linked']
                    //             ? CircleAvatar(
                    //                 radius: 20,
                    //                 backgroundColor: Colors.white,
                    //                 child: IconButton(
                    //                   icon: Icon(
                    //                     Icons.link,
                    //                     color: Theme.of(context).primaryColor,
                    //                   ),
                    //                   onPressed: () {
                    //                     linkAccountCardApi(list);
                    //                   },
                    //                 ),
                    //               )
                    //             : Container(),
                    //   ],
                    // ),
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
                  ],
                ),
              )),
        ),
        const SizedBox(
          height: 10.0,
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
                  title: const Text('Verify Card'),
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
                  title: const Text(
                    "Set as Primary Card",
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    displayDialogConfirm(context,
                        'Do you want to set as primary card?', list, 'primary');
                  },
                )
              : Container(),
          !list['linked']
              ? ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text(
                    "Link Card",
                  ),
                  onTap: () {
                    // linkAccountCard(cardDetails);
                    Navigator.pop(context);
                    displayDialogConfirm(
                        context, 'Do you want to link card?', list, 'link');
                  },
                )
              : Container(),
          list['linked'] && !list['primary']
              ? ListTile(
                  leading: const Icon(Icons.link_off),
                  title: const Text('De-Link Card'),
                  onTap: () {
                    Navigator.pop(context);
                    displayDialogConfirm(context,
                        'Do you want to de-link card?', list, 'de link');
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

  loadCards() async {
    isLoading(true);
    BoxStorage boxStorage = BoxStorage();
    var userName = boxStorage.getUsername();
    accountCardService.loadAccountAndCard(userName).then((response) {
      var decodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'] == '00') {
          isLoading(false);
          if (decodeData['userAccounts']['userCardInfo'] == null) {
            userCardInfo = [];
          } else {
            userCardInfo = decodeData['userAccounts']['userCardInfo'];
            userCardInfo.length != 1
                ? userCardInfo.sort((a, b) => Comparable.compare(
                    b['primary'].toString(), a['primary'].toString()))
                : '';
            userCardInfo.length != 1
                ? userCardInfo.sort((a, b) => Comparable.compare(
                    b['linked'].toString(), a['linked'].toString()))
                : '';
          }
          if (decodeData['userAccounts']['userAccountInfo'] == null) {
            userAccountInfo = [];
          } else {
            userAccountInfo = decodeData['userAccounts']?['userAccountInfo'];
          }
        } else {
          isLoading(false);
          setState(() {
            userCardInfo = [];
          });
        }
      } else {
        isLoading(false);
        setState(() {
          userCardInfo = [];
        });
      }
    });
  }

  void responseAlert(result) {
    var response = jsonDecode(result.body);
    if (result.statusCode == 200 || result.statusCode == 201) {
      if (response['responseCode'].toString() == '00') {
        alertWidget.success(
            context, "Success", response['responseMessage'].toString());
      } else {
        alertWidget.failure(
            context, "Failed", response['responseMessage'].toString());
      }
      loadCards();
    } else {
      setState(() {
        _isLoading = false;
      });
      alertWidget.failure(context, "Failed", response['message'].toString());
      loadCards();
    }
  }

  verifyAccountCardApi(card) async {
    isLoading(true);
    BoxStorage boxStorage = BoxStorage();
    var userName = boxStorage.getUsername();
    cardManageRequestModel.instId = Constants.instId;
    cardManageRequestModel.userName = userName;
    cardManageRequestModel.cardReferenceNumber =
        await Validators.encrypt(card['cardReferenceNumber'].toString());
    accountCardService
        .verifyAccountsCard(cardManageRequestModel)
        .then((response) {
      isLoading(false);
      responseAlert(response);
    });
  }

  deLinkAccountCardApi(card) async {
    isLoading(true);
    BoxStorage boxStorage = BoxStorage();
    var userName = boxStorage.getUsername();
    cardManageRequestModel.instId = Constants.instId;
    cardManageRequestModel.userName = userName;
    cardManageRequestModel.cardReferenceNumber =
        await Validators.encrypt(card['cardReferenceNumber']);
    accountCardService
        .deLinkAccountsCard(cardManageRequestModel)
        .then((response) {
      isLoading(false);
      responseAlert(response);
    });
  }

  linkAccountCardApi(card) async {
    isLoading(true);
    BoxStorage boxStorage = BoxStorage();
    var userName = boxStorage.getUsername();
    cardManageRequestModel.instId = Constants.instId;
    cardManageRequestModel.userName = userName;
    cardManageRequestModel.cardReferenceNumber =
        await Validators.encrypt(card['cardReferenceNumber']);
    accountCardService
        .linkAccountsCard(cardManageRequestModel)
        .then((response) {
      isLoading(false);
      responseAlert(response);
    });
  }

  primaryCardSwap(card) async {
    isLoading(true);
    late List getPreviousPrimary;
    BoxStorage boxStorage = BoxStorage();
    var userName = boxStorage.getUsername();
    cardManageRequestModel.instId = Constants.instId;
    cardManageRequestModel.userName = userName;
    cardManageRequestModel.changeCardRefToPrimary =
        await Validators.encrypt(card['cardReferenceNumber']);
    getPreviousPrimary =
        userAccountInfo.where((element) => element['primary'] == true).toList();
    if (getPreviousPrimary.isEmpty) {
      getPreviousPrimary =
          userCardInfo.where((element) => element['primary'] == true).toList();
    }
    if (getPreviousPrimary[0].containsKey('accountReferenceNumber')) {
      debugPrint("---------------- ACCOUNT TO CARD ---------------------");
      cardManageRequestModel.primaryAccountRefNumber = await Validators.encrypt(
          getPreviousPrimary[0]['accountReferenceNumber']);
      accountCardService
          .swapAccountToCard(cardManageRequestModel)
          .then((response) {
        isLoading(false);
        responseAlert(response);
      });
    } else {
      debugPrint("------------------ CARD TO CARD ---------------------");
      cardManageRequestModel.changeAccountRefToPrimary =
          await Validators.encrypt(card['cardReferenceNumber'].toString());
      cardManageRequestModel.primaryCardRefNumber = await Validators.encrypt(
          getPreviousPrimary[0]['cardReferenceNumber']);
      accountCardService
          .swapCardToCard(cardManageRequestModel)
          .then((response) {
        isLoading(false);
        responseAlert(response);
      });
    }
  }

  displayDialogConfirm(
      BuildContext context, String message, list, String type) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text(
              'Alert',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.white70, width: 2), //<-- SEE HERE
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'No',
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.white70, width: 2), //<-- SEE HERE
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          if (type == 'link') {
                            linkAccountCardApi(list);
                          } else if (type == 'primary') {
                            primaryCardSwap(list);
                          } else {
                            deLinkAccountCardApi(list);
                          }
                        },
                        child: const Text(
                          'Yes',
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                ],
              )
            ],
          );
        });
  }
}
