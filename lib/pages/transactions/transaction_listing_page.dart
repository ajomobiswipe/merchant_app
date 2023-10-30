import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/config/constants.dart';

import '../../models/TransactionRequest.dart';
import '../../services/transaction_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/loading.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late bool _isLoading = false;
  List transactionList = [];
  List searchList = [];
  late String customerId;
  List<Widget> listWidget = [];
  TransactionServices transactionServices = TransactionServices();
  TransactionRequest transactionRequest = TransactionRequest();
  AlertService alertWidget = AlertService();

  late TextEditingController contactSearchController;

  List<String> searchHintsList = [
    'Search...',
    'Search for a Amount',
    'Search for a Account Number',
    'Search for a Card Number',
  ];
  int currentSearchHintIndex = 0;
  Timer? _updateContactsSearchingHintTimer;

  @override
  void dispose() {
    _updateContactsSearchingHintTimer!.cancel();
    contactSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getLocalData();
    Future.delayed(Duration.zero, () {
      allTransactionList(100);
    });
    contactSearchController = TextEditingController();
    _updateContactsSearchingHintTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && contactSearchController.text.isEmpty) {
        setState(() {
          if (currentSearchHintIndex == searchHintsList.length - 1) {
            currentSearchHintIndex = 0;
          } else {
            currentSearchHintIndex++;
          }
        });
        //* search hint updated
      }
    });
    super.initState();
  }

  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    customerId = prefs.getString('custId')!;
    transactionRequest.custId = customerId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: "Transaction History",
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading ? const LoadingWidget() : mainWidget(),
    );
  }

  noData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            Constants.noDataFoundImage,
            height: 250,
          ),
          const Text("No Transaction Found"),
        ],
      ),
    );
  }

  mainWidget() {
    String currentSearchHint = searchHintsList[currentSearchHintIndex];
    Widget searchContacts = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextField(
            controller: contactSearchController,
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() {
                  transactionList = searchList;
                  //generateList();
                });
              } else {
                final suggest = searchList.where((element) {
                  final abc = element['accountNumber'].toLowerCase();
                  final amount = element['amount'].toLowerCase();
                  final input = value.toLowerCase();
                  return abc.contains(input) || amount.contains(input);
                }).toList();
                setState(() {
                  transactionList = suggest;
                  //generateList();
                });
              }
            },
            style:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(10),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor)),
                hintText: currentSearchHint,
                hintStyle: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.sort,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            getWidget();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              enableDrag: true,
              isDismissible: true,
              builder: (context) {
                return Wrap(
                  children: listWidget,
                );
              },
            );
          },
          highlightColor: Theme.of(context).primaryColor,
        )
      ],
    );
    return Column(
      children: [
        const SizedBox(
          height: 10.0,
        ),
        searchList.isEmpty
            ? Container()
            : Container(
                padding: const EdgeInsets.all(7),
                child: searchContacts,
              ),
        const SizedBox(
          height: 10.0,
        ),
        transactionList.isEmpty
            ? Expanded(
                child: noData(),
              )
            : Expanded(child: generate())
      ],
    );
  }

  getWidget() {
    List<Widget> listItems = [];
    List processFlag = [];
    for (var list1 in searchList) {
      processFlag.add(list1['processFlag']);
    }
    processFlag.add("All");
    for (var list in processFlag.toSet().toList()) {
      listItems.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: const Icon(Icons.money),
          iconColor: Theme.of(context).primaryColor,
          title: Text(
            list.toString(),
            style: GoogleFonts.poppins(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
          onTap: () {
            filter(list.toString());
            Navigator.pop(context);
          },
        ),
      ));
    }
    setState(() {
      listWidget = listItems;
    });
  }

  generate() {
    return ListView.builder(
      itemCount: transactionList.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Card(
            elevation: 5,
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'transactionDetails',
                    arguments: {'receipt': transactionList[index]});
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                leading: CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.8),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 25,
                    )),
                title: Text(
                  transactionList[index]['fundSource'].toString() == 'ACCOUNT'
                      ? transactionList[index]['accountNumber'].toString()
                      : transactionList[index]['cardReferenceNumber']
                          .toString(),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.normal, fontSize: 16),
                ),
                subtitle: Text(
                  "${transactionList[index]['responseMessage'].toString()}\n${transactionList[index]['tranDateTime'].toString()}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.normal, color: Colors.grey),
                ),
                isThreeLine: false,
                trailing: Text(
                  // transactionList[index]['processFlag'].toString() == "DEBIT"

                  //     ? "${transactionList[index]['currencyCodeId'].toString()} ${}"
                  //     : "${transactionList[index]['currencyCodeId'].toString()} ${transactionList[index]['amount'].toString()}",
                  transactionList[index]['processFlag'].toString() == 'DEBIT'
                      ? '-AED ${transactionList[index]['amount'].toString()}'
                      : '+AED ${transactionList[index]['amount'].toString()}',
                  style: transactionList[index]['processFlag'].toString() ==
                          'DEBIT'
                      ? Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.red)
                      : Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green),
                  // style: TextStyle(
                  //   fontSize: 15,
                  //   fontWeight: FontWeight.bold,
                  //   color: transactionList[index]['processFlag'].toString() ==
                  //           "DEBIT"
                  //       ? Colors.red[400]
                  //       : Theme.of(context).primaryColor,
                  // )
                ),
                // onTap: () => _viewTransactionReceipt(transaction),
              ),
            ));
      },
    );
  }

  Future<String> allTransactionList(size) async {
    setState(() {
      _isLoading = true;
    });
    transactionRequest.tranDateFrom = DateTime.now()
        .toUtc()
        .subtract(const Duration(days: 30))
        .toIso8601String();
    transactionRequest.tranDateTo = DateTime.now().toUtc().toIso8601String();
    transactionServices
        .loadAllTransaction(transactionRequest, size)
        .then((response) {
      setState(() {
        _isLoading = false;
      });
      var decodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        searchList = decodeData['content'];
        transactionList = decodeData['content'];
      } else {
        setState(() {
          _isLoading = false;
          transactionList = [];
          searchList = [];
        });
        alertWidget.failure(
            context, 'Failure', decodeData['message'].toString());
      }
    });
    return "success";
  }

  filter(String type) {
    if (type.toString() == 'All') {
      setState(() {
        transactionList = searchList;
      });
    } else {
      final suggest = searchList.where((element) {
        final flag = element['processFlag'].toLowerCase();
        final input = type.toLowerCase();
        return flag.contains(input);
      }).toList();
      setState(() {
        transactionList = suggest;
        //generateList();
      });
    }
  }
}
