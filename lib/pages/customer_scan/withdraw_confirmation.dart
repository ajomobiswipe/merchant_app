import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:sifr_latest/storage/secure_storage.dart';
import 'package:sifr_latest/widgets/app_widget/app_button.dart';

import '../../config/config.dart';
import '../../models/cash_at_pos.dart';
import '../../models/wallet_models.dart';
import '../../services/services.dart';
import '../../utilities/dataGenerator.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/m_pin_verify.dart';

class WithdrawConfirmation extends StatefulWidget {
  const WithdrawConfirmation({Key? key, this.scanData}) : super(key: key);

  final dynamic scanData;

  @override
  State<WithdrawConfirmation> createState() => _WithdrawConfirmationState();
}

class _WithdrawConfirmationState extends State<WithdrawConfirmation> {
  CashAtPosRequestModel cashAtPosRequestModel = CashAtPosRequestModel();
  BoxStorage boxStorage = BoxStorage();
  late bool _isLoading = false;
  TextEditingController description = TextEditingController();
  UserServices userServices = UserServices();
  late List receipt = [];
  BalanceCheck balanceCheck = BalanceCheck();
  AccountCardService accountCardService = AccountCardService();
  AlertService alertWidget = AlertService();

  SizedBox defaultPadding = const SizedBox(
    height: 20.0,
  );
  String currency = 'AED';

  String amount="1000";

  /// NEW
  String walletAccountNumber = '';

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getScannedData(widget.scanData);

    // var scanData = jsonDecode(widget.scanData);
    // print(scanData.runtimeType);
    // print('scanData$scanData');
    // if (scanData.runtimeType == "String") {
    //   alertWidget.failure(context, "Error", "Invalid QR Code!");
    //   Navigator.pushReplacementNamed(context, 'home');
    // }
    // setState(() {
    //   print("-----------------");
    //   print(scanData);
    //   print("-----------------");
    //   if (scanData['qrData'].toString() != null) {
    //     description.text = scanData['transaction'].toString();
    //     currency = scanData['qrData'].toString().split('#')[4];
    //   } else {
    //     alertWidget.failure(context, "Error", "Invalid QR Code!");
    //     Navigator.pushReplacementNamed(context, 'home');
    //   }
    // });
  }

  Future getScannedData(String? scanData) async {
    print(scanData);
    var requestBody = await getDataFromScanData(scanData);

    // var requestBody = {
    //   "payment": {
    //     "paymentId": "123456",
    //     "amount": "70",
    //     "currency": "AED",
    //     "reason": "Soccer shoes",
    //     "shopId": "10001",
    //     "cashDeskId": "10000001"
    //   }
    // };

    var response = await userServices.finalisePayment(requestBody['requestBody']);



    var responseBody = jsonDecode(response.body);
    print('responseValue$responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        // if (scanData['qrData'].toString() != null) {
        description.text = responseBody['payment']['reason'].toString();
        currency = responseBody['payment']['currency'];
        amount = responseBody['payment']['amount']!=null?responseBody['payment']['amount'].toString():"1000";
        // } else {
        // alertWidget.failure(context, "Error", "Invalid QR Code!");
        // Navigator.pushReplacementNamed(context, 'home');
        // }
      });

      //     {
      //       "payment": {
      //   "amount": 70.0,
      //   "currency": "AED",
      //   "reason": "Soccer shoes ",
      //   "shopId": "10001",
      //   "cashDeskId": "10000001",
      //   "paymentId": "123456"
      // }
      // }
    }

    // setState(() {
    //   print("-----------------");
    //   print(scanData);
    //   print("-----------------");
    //
    //   if (scanData['qrData'].toString() != null) {
    //     description.text = scanData['transaction'].toString();
    //     currency = scanData['qrData'].toString().split('#')[4];
    //   } else {
    //     alertWidget.failure(context, "Error", "Invalid QR Code!");
    //     Navigator.pushReplacementNamed(context, 'home');
    //   }
    // });
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  getUserDetails() async {
    setLoading(true);
    var customerId = boxStorage.getCustomerId();
    userServices.getUserDetails(customerId).then((result) {
      var response = jsonDecode(result.body);
      if (result.statusCode == 200 || result.statusCode == 201) {
        setState(() {
          walletAccountNumber = response['walletAccountNumber'];
        });
        setLoading(false);
      } else {
        setState(() {
          walletAccountNumber = '';
        });
        setLoading(false);
      }
    });
  }

  Widget merchantInfo() {
    // var scanData = jsonDecode(widget.scanData);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        CircleAvatar(
          backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.7),
          radius: 20,
          child: const Icon(
            LineAwesome.store_solid,
            size: 25,
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Merchant Name",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  "Type of Trans.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  "Date & Time",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "sarmerchant",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              "transaction",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              DateFormat("dd-MM-yyyy hh:mm:ss a").format(DateTime.now()),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        )
      ],
    );
  }

  Widget amountInfo(amount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      // decoration: BoxDecoration(
      //   border: Border.all(),
      // ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5.0),
              width: MediaQuery.of(context).size.width * 0.4,
              child: Center(
                child: Text(
                  "Withdraw \n Amount",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const VerticalDivider(
              width: 20,
              indent: 5,
              endIndent: 5,
              thickness: 1,
              color: Colors.black54,
            ),
          ],
        ),
        title: Center(
          child: Text(
            '$currency $amount',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget desc() {
    return TextFormField(
        keyboardType: TextInputType.text,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: description,
        decoration: InputDecoration(
          labelText: "Description",
          labelStyle: TextStyle(color: Theme.of(context).primaryColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        ),
        onSaved: (value) {
          description.text = value!;
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Description is mandatory!';
          }
          return null;
        });
  }

  goToPin(request) async {

    // var qrData = request['qrData'].toString().split('#')[5];\
    var qrData = request;
    var customerId = boxStorage.getCustomerId();
    // cashAtPosRequestModel.transaction = request['transaction'];
    cashAtPosRequestModel.transaction = 'Transaction';

    cashAtPosRequestModel.instId = Constants.instId;
    cashAtPosRequestModel.custId = customerId;
    cashAtPosRequestModel.description = description.text;
    cashAtPosRequestModel.qrData = qrData;
    cashAtPosRequestModel.fundSource = 'WALLET';
    cashAtPosRequestModel.accountNumber =
        await Validators.encrypt(walletAccountNumber.toString());
    Navigator.pushNamed(context, "mPinVerification",
        arguments: {'payment': jsonEncode(cashAtPosRequestModel)});
  }

  @override
  Widget build(BuildContext context) {
    // var scanData = jsonDecode(widget.scanData);
    return Scaffold(
      appBar: const AppBarWidget(
        title: "Withdraw Confirmation",
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 20),
              merchantInfo(),
              const SizedBox(height: 30),
              amountInfo(amount),
              const SizedBox(height: 40),
              Text("Please use your Wallet to proceed with the transaction.",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 16)),
              Card(
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColorDark.withOpacity(0.8),
                    child: const Icon(
                      Icons.wallet,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    "Wallet Account Number",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.normal),
                  ),
                  subtitle: Text(
                    walletAccountNumber.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(
                    LineAwesome.check_circle,
                    color: Colors.white,
                  ),
                ),
              ),
              viewBalanceWidget(),
              const SizedBox(height: 20),
              desc(),
              const SizedBox(height: 30),
              AppButton(
                title: 'Next',
                onPressed: () {
                  goToPin(widget.scanData);
                },
              ),
              defaultPadding,
            ],
          ),
        ),
      ),
    );
  }

  Widget viewBalanceWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      receipt.isEmpty
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
              child: Text('View Balance',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline)),
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  receipt = [];
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "${receipt[0]['currencyCode']} ${receipt[0]['availableBalance']}",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
              ),
            ),
    ]);
  }

  viewBalance(mPIN) async {
    String customerId = boxStorage.getCustomerId();
    balanceCheck.mpin = await Validators.encrypt(mPIN.toString());
    balanceCheck.accountNumber =
        await Validators.encrypt(walletAccountNumber.toString());

    setState(() {
      balanceCheck.custId = customerId;
      balanceCheck.instId = Constants.instId;
      balanceCheck.fundSource = Constants.wallet;
      balanceCheck.transaction = Constants.balanceCheck;
      _isLoading = true;
    });
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
}
