import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/storage/secure_storage.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../models/models.dart';
import '../../services/services.dart';
import '../../widgets/m_pin_verify.dart';
import '../../widgets/widget.dart';

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  UserServices apiService = UserServices();
  BoxStorage boxStorage = BoxStorage();
  TransactionServices transactionServices = TransactionServices();
  AccountCardService accountCardService = AccountCardService();
  WalletService walletService = WalletService();
  AlertService alertWidget = AlertService();
  TransactionRequest transactionRequest = TransactionRequest();
  BalanceCheck balanceCheck = BalanceCheck();

  bool _isLoading = false;
  TextEditingController amountController = TextEditingController();
  late List userDetails = [];
  late List receipt = [];
  List statementList = [];
  String customerId = '';

  @override
  void initState() {
    getCustomerData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, 'home');
        return true;
      },
      child: Scaffold(
        appBar: const AppBarWidget(
          title: 'SIFR Wallet',
        ),
        body: _isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    ...topContent(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Recent Transactions"),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                              onPressed: () {
                                var params = {
                                  "accountNumber": userDetails[0]
                                      ['walletAccountNumber'],
                                };
                                Navigator.pushNamed(context, 'statements',
                                    arguments: {'params': params});
                              },
                              child: const Text(
                                "View all",
                                style: TextStyle(
                                    decoration: TextDecoration.underline),
                              )),
                        ),
                      ],
                    ),
                    if (statementList.isEmpty)
                      Global.noDataFound("transactions"),
                    if (statementList.isNotEmpty)
                      ...statementList
                          .map((e) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 2),
                                child: Card(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, 'transactionDetails',
                                          arguments: {'receipt': e});
                                    },
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 15),
                                      title: Text(
                                        e['fundSource'].toString() == "ACCOUNT"
                                            ? e['accountNumber'].toString()
                                            : e['cardReferenceNumber']
                                                .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      subtitle: Text(
                                        "${e['responseMessage'].toString()}\n${e['tranDateTime'].toString()}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.normal),
                                      ),
                                      isThreeLine: true,
                                      trailing: Text(
                                          '${e['currencyCodeId']} ${e['amount'].toString()}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                e['processFlag'].toString() ==
                                                        "DEBIT"
                                                    ? Colors.red[400]
                                                    : Theme.of(context)
                                                        .primaryColor,
                                          )),
                                      // onTap: () => _viewTransactionReceipt(transaction),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                  ],
                ),
              ),
      ),
    );
  }

  topContent() {
    return [
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Card(
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white70, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 10,
          shadowColor: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset('assets/logo/logo2-white.png',
                    height: 30, fit: BoxFit.fill),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  "Wallet Account Number",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 16, color: Colors.white),
                ),
              ),
              if (userDetails.isNotEmpty)
                Center(
                  child: Text(
                    userDetails[0]['walletAccountNumber'],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              /*const SizedBox(height: 5),*/
              viewBalanceWidget(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      customCard(
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, 'addMoneyToWallet');
          },
          child: ListTile(
            leading: Icon(
              Icons.add_card_outlined,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text("Add Money to Wallet"),
            trailing: const Icon(LineAwesome.angle_right_solid),
          ),
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  Widget getStatement() {
    return Container(
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: statementList.length,
          itemBuilder: (context, index) {
            return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: Card(
                    elevation: 5,
                    color: Theme.of(context).cardColor,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, 'transactionDetails',
                            arguments: {'receipt': statementList[index]});
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(right: 10),
                        leading: CircleAvatar(
                            radius: 38,
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.8),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Colors.white,
                              size: 30,
                            )),
                        title: Text(
                          statementList[index]['destAccountNumber'] ??
                              "Merchant Name",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        subtitle: Text(
                          "${statementList[index]['tranType'].toString()}\n${statementList[index]['tranDateTime'].toString()}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        isThreeLine: true,
                        trailing: Text(
                            'AED ${statementList[index]['amount'].toString()}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: statementList[index]['processFlag']
                                          .toString() ==
                                      "DEBIT"
                                  ? Colors.red[400]
                                  : Theme.of(context).primaryColor,
                            )),
                        // onTap: () => _viewTransactionReceipt(transaction),
                      ),
                    )));
          }),
    );
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

  Widget viewBalanceWidget() {
    return Center(
      child: receipt.isEmpty
          ? TextButton(
              onPressed: () async {
                var results =
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const MPinVerify();
                        },
                        fullscreenDialog: true));
                if (results != null) {
                  viewBalance(results);
                }
              },
              child: _buildChip('View Balance'),
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  receipt = [];
                });
              },
              child: Text(
                "${receipt[0]['currencyCode']} ${receipt[0]['availableBalance']}",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 22,
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  viewBalance(mPIN) async {
    setLoading(true);
    String customerId = boxStorage.getCustomerId();
    balanceCheck.instId = Constants.instId;
    balanceCheck.custId = customerId;
    balanceCheck.fundSource = Constants.wallet;
    balanceCheck.transaction = Constants.balanceCheck;
    balanceCheck.mpin = await Validators.encrypt(mPIN.toString());
    balanceCheck.accountNumber = await Validators.encrypt(
        userDetails[0]['walletAccountNumber'].toString());
    accountCardService.checkBalance(balanceCheck).then((result) {
      var response = jsonDecode(result.body);
      if (result.statusCode == 200 || result.statusCode == 201) {
        if (response['responseCode'] == "00") {
          setState(() {
            _isLoading = false;
            receipt = [response['receipt']];
          });
        } else {
          setState(() {
            _isLoading = false;
            receipt = [];
          });
        }
      } else {
        alertWidget.failure(context, 'Failure', response['message'].toString());
        setState(() {
          _isLoading = false;
          receipt = [];
        });
      }
    });
  }

  Widget _buildChip(String label) {
    return Chip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 5),
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      backgroundColor: Colors.white70,
      elevation: 8.0,
      shadowColor: Colors.grey[60],
      padding: const EdgeInsets.all(8.0),
    );
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  getCustomerData() async {
    setLoading(true);
    customerId = boxStorage.getCustomerId();
    try {
      apiService.getUserDetails(customerId).then((result) {
        var response = jsonDecode(result.body);
        if (result.statusCode == 200 || result.statusCode == 201) {
          var code = response['responseCode'];
          if (code == "00" || code == "000") {
            userDetails = [response];
            getStatementList();
            setLoading(false);
          } else {
            setLoading(false);
          }
        } else {
          setLoading(false);
          alertWidget.failure(context, '', response['error']);
          setState(() {
            userDetails = [];
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        alertWidget.failure(context, '', Constants.somethingWrong);
      });
    }
  }

  isLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  getStatementList() {
    isLoading(true);
    var params = {
      "accountNumber": userDetails[0]['walletAccountNumber'],
    };
    transactionServices.getStatements(params, 0, 5).then((response) {
      var decodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoading(false);
        statementList = decodeData['content'];
      } else {
        isLoading(false);
        statementList = [];
      }
    });
  }
}
