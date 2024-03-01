import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../config/config.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../storage/secure_storage.dart';
import '../../widgets/loading.dart';
import '../../widgets/widget.dart';

class ViewMyAccount extends StatefulWidget {
  const ViewMyAccount({Key? key}) : super(key: key);

  @override
  State<ViewMyAccount> createState() => _ViewMyAccountState();
}

class _ViewMyAccountState extends State<ViewMyAccount> {
  bool _isLoading = false;
  AccountCardService accountCardService = AccountCardService();
  AlertService alertWidget = AlertService();
  TransactionServices transactionServices = TransactionServices();
  TransactionRequest transactionRequest = TransactionRequest();
  CardManageRequestModel cardManageRequestModel = CardManageRequestModel();
  AccountRequestModel accountRequestModel = AccountRequestModel();
  List userAccountInfo = [];
  var userCardInfo = [];
  BoxStorage boxStorage = BoxStorage();
  String userName = '';

  @override
  void initState() {
    loadAccounts();
    userName = boxStorage.getUsername();
    super.initState();
  }

  @override
  void dispose() {
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
          title: "My Account",
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
                              Navigator.pushNamed(context, 'addNewAccount');
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
                                    text: 'Add New Account',
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
                    userAccountInfo.isNotEmpty
                        ? verticalList()
                        : Global.noDataFound('account'),
                  ],
                ),
              ),
      ),
    );
  }

  isLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Widget verticalList() {
    return Column(
      children: [
        ...userAccountInfo.map((list) => _accountList(context, list)).toList(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _accountList(BuildContext context, list) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
          child: Container(
              width: MediaQuery.of(context).size.width - 40,
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
                                "Primary Account",
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
                                        'Do you want to link account?',
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
                    const SizedBox(height: 10),
                    Center(
                        child: Text(
                      list['accountHolderName'].toString().toUpperCase(),
                      softWrap: true,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.white),
                    )),
                    Center(
                      child: Text(
                        list['maskingAccountNumber'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          list['ibanNumber'].toString().toUpperCase(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
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
                  title: const Text('Verify Account'),
                  leading: const Icon(Icons.security),
                  onTap: () {
                    Navigator.pop(context);
                    verifyAccountCardApi(list);
                  },
                )
              : Container(),
          !list['primary'] && list['linked'] && list['verified']
              ? ListTile(
                  leading: const Icon(FontAwesome.repeat_solid),
                  title: const Text(
                    "Set as Primary Account",
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    displayDialogConfirm(
                        context,
                        'Do you want to set as primary account?',
                        list,
                        'primary');
                  },
                )
              : Container(),
          !list['linked']
              ? ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text(
                    "Link Account",
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    displayDialogConfirm(
                        context, 'Do you want to link account?', list, 'link');
                  },
                )
              : Container(),
          list['linked'] && !list['primary']
              ? ListTile(
                  leading: const Icon(Icons.link_off),
                  title: const Text('De-Link Account'),
                  onTap: () {
                    Navigator.pop(context);
                    displayDialogConfirm(context,
                        'Do you want to de-link account?', list, 'de link');
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

  loadAccounts() async {
    isLoading(true);

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
          }
          if (decodeData['userAccounts']['userAccountInfo'] == null) {
            userAccountInfo = [];
          } else {
            userAccountInfo = decodeData['userAccounts']?['userAccountInfo'];
            userAccountInfo.length != 1
                ? userAccountInfo.sort((a, b) => Comparable.compare(
                    b['primary'].toString(), a['primary'].toString()))
                : '';
            userAccountInfo.length != 1
                ? userAccountInfo.sort((a, b) => Comparable.compare(
                    b['linked'].toString(), a['linked'].toString()))
                : '';
          }
        } else {
          isLoading(false);
          setState(() {
            userAccountInfo = [];
          });
        }
      } else {
        isLoading(false);
        setState(() {
          userAccountInfo = [];
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
      loadAccounts();
    } else {
      setState(() {
        _isLoading = false;
      });
      alertWidget.failure(context, "Failed", response['message'].toString());
      loadAccounts();
    }
  }

  verifyAccountCardApi(card) async {
    isLoading(true);
    accountRequestModel.instId = Constants.instId;
    accountRequestModel.userName = userName;
    accountRequestModel.accountReferenceNumber =
        await Validators.encrypt(card['accountReferenceNumber']);
    accountRequestModel.accountHolderName = card['accountHolderName'];
    accountCardService.verifyAccountsCard(accountRequestModel).then((response) {
      isLoading(false);
      responseAlert(response);
    });
  }

  deLinkAccountCardApi(card) async {
    isLoading(true);
    accountRequestModel.instId = Constants.instId;
    accountRequestModel.userName = userName;
    accountRequestModel.accountReferenceNumber =
        await Validators.encrypt(card['accountReferenceNumber']);
    accountRequestModel.accountHolderName = card['accountHolderName'];
    accountCardService.deLinkAccountsCard(accountRequestModel).then((response) {
      isLoading(false);
      responseAlert(response);
    });
  }

  linkAccountCardApi(card) async {
    isLoading(true);
    accountRequestModel.instId = Constants.instId;
    accountRequestModel.userName = userName;
    accountRequestModel.accountReferenceNumber =
        await Validators.encrypt(card['accountReferenceNumber']);
    accountRequestModel.accountHolderName = card['accountHolderName'];
    accountCardService.linkAccountsCard(accountRequestModel).then((response) {
      isLoading(false);
      responseAlert(response);
    });
  }

  primaryCardSwap(card) async {
    isLoading(true);
    late List getPreviousPrimary;
    accountRequestModel.instId = Constants.instId;
    accountRequestModel.userName = userName;
    getPreviousPrimary =
        userAccountInfo.where((element) => element['primary'] == true).toList();
    if (getPreviousPrimary.isEmpty) {
      getPreviousPrimary =
          userCardInfo.where((element) => element['primary'] == true).toList();
    }
    accountRequestModel.changeAccountRefToPrimary =
        await Validators.encrypt(card['accountReferenceNumber'].toString());
    if (getPreviousPrimary[0].containsKey('accountReferenceNumber')) {
      if (kDebugMode)
        print("---------------- ACCOUNT TO ACCOUNT ---------------------");
      accountRequestModel.primaryAccountRefNumber = await Validators.encrypt(
          getPreviousPrimary[0]['accountReferenceNumber']);
      accountRequestModel.primaryCardRefNumber = null;
      accountCardService
          .swapAccountToAccount(accountRequestModel)
          .then((response) {
        isLoading(false);
        responseAlert(response);
      });
    } else {
      if (kDebugMode)
        print("---------------- CARD TO ACCOUNT ---------------------");
      accountRequestModel.changeAccountToPrimary =
          await Validators.encrypt(card['accountReferenceNumber'].toString());
      accountRequestModel.primaryCardRefNumber = await Validators.encrypt(
          getPreviousPrimary[0]['cardReferenceNumber']);
      accountCardService
          .swapCardToAccount(accountRequestModel)
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
