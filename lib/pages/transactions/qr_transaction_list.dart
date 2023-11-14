import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sifr_latest/storage/secure_storage.dart';
import 'package:sifr_latest/widgets/app_widget/app_bar_widget.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../config/global.dart';
import '../../models/TransactionRequest.dart';
import '../../services/transaction_services.dart';

class QRTransactionList extends StatefulWidget {
  const QRTransactionList({Key? key}) : super(key: key);

  @override
  State<QRTransactionList> createState() => _QRTransactionListState();
}

class _QRTransactionListState extends State<QRTransactionList> {
  TransactionServices transactionServices = TransactionServices();
  TransactionRequest transactionRequest = TransactionRequest();
  String customerId = '';
  int _page = 0;
  bool _isFirstLoadRunning = false;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  List _posts = [];
  late ScrollController _controller;
  List searchList = [];
  TextEditingController contactSearchController = TextEditingController();
  List<Widget> listWidget = [];

  @override
  void initState() {
    super.initState();
    getLocalData();
    _controller = ScrollController()..addListener(_loadMore);
  }

  getLocalData() async {
    BoxStorage boxStorage = BoxStorage();
    customerId = boxStorage.getCustomerId();
    transactionRequest.custId = customerId;
    _firstLoad();
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      _page += 1;

      try {
        setState(() {
          _isLoadMoreRunning = true;
        });
        var req = {"custId": customerId};
        transactionServices.getAllTransaction(req, _page).then((response) {
          if (response.statusCode == 200 || response.statusCode == 201) {
            var decodeData = json.decode(response.body);
            final List fetchedPosts = decodeData['content'];
            if (fetchedPosts.isNotEmpty) {
              setState(() {
                _posts.addAll(fetchedPosts);
                searchList.addAll(fetchedPosts);
                _isLoadMoreRunning = false;
              });
            } else {
              setState(() {
                _hasNextPage = false;
                _isLoadMoreRunning = false;
              });
            }
          } else {
            setState(() {
              _isLoadMoreRunning = false;
            });
          }
        });
      } catch (err) {
        setState(() {
          _isLoadMoreRunning = false;
        });
        if (kDebugMode) {
          // print('Something went wrong!');
        }
      }
    }
  }

  void _firstLoad() async {
    try {
      setState(() {
        _isFirstLoadRunning = true;
      });
      // var req = {"custId": customerId};
      var req = {"qrTransaction": true};
      transactionServices.getAllQRTransaction(req, _page).then((response) {
        print(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          var decodeData = json.decode(response.body);
          setState(() {
            _posts = decodeData['content'];
            searchList = decodeData['content'];
            _isFirstLoadRunning = false;
          });
        } else {
          setState(() {
            _posts = [];
            _isFirstLoadRunning = false;
          });
        }
      });
    } catch (err) {
      setState(() {
        _isFirstLoadRunning = false;
      });
      if (kDebugMode) {
        // print('Something went wrong');
      }
    }
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

  filter(String type) {
    if (type.toString() == 'All') {
      setState(() {
        _posts = searchList;
      });
    } else {
      final suggest = searchList.where((element) {
        final flag = element['processFlag'].toLowerCase();
        final input = type.toLowerCase();
        return flag.contains(input);
      }).toList();
      setState(() {
        _posts = suggest;
        //generateList();
      });
    }
  }

  Future _refund(String paymentId, String price) async {
    transactionServices.checkRefundStatus(paymentId).then((response) {
      var result = jsonDecode(response.body);
      if (result['status'] == "EFF") {
        final snackBar = SnackBar(
          content: Text('${result['responseMessage']}'),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }

      var refundObject = {
        "refund": {
          "amount": price,
          "currency": "AED",
          "reason": "wrong bill amount",
          "type": "DISBURSEMENT",
          "mobile": "+971837892848",
          "proxy": {"type": "email", "value": "john.wick@gmail.com"},
          "paymentTime": "2012-11-25T23:50:56.193",
          "shopId": "10001",
          "cashDeskId": "10000001",
          "categoryPurpose": "CCP"
        },
        "merchantTrxId": "123456"
      };

      transactionServices.refundAction(paymentId, refundObject).then((value) {
        var responseBody=jsonDecode(value.body);
        final snackBar = SnackBar(
          content: Text('${responseBody['responseMessage']}'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  _posts = searchList;
                });
              } else {
                final suggest = searchList.where((element) {
                  final acc = element['accountNumber'].toLowerCase();
                  final card = element['cardReferenceNumber'].toLowerCase();
                  final amount = element['amount'].toLowerCase();
                  final response = element['responseMessage'].toLowerCase();
                  final input = value.toLowerCase();
                  return acc.contains(input) ||
                      card.contains(input) ||
                      amount.contains(input) ||
                      response.contains(input);
                }).toList();
                setState(() {
                  _posts = suggest;
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
                hintText: "Search...",
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

    return Scaffold(
      appBar: const AppBarWidget(title: 'Transactions'),
      body: _isFirstLoadRunning
          ? const LoadingWidget()
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10.0),
                  searchList.isEmpty
                      ? Container()
                      : Container(
                          padding: const EdgeInsets.all(7),
                          child: searchContacts,
                        ),
                  const SizedBox(height: 10.0),
                  _posts.isEmpty
                      ? Global.noDataFound("Transactions")
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _posts.length,
                            controller: _controller,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            itemBuilder: (_, index) => Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(.2))),
                              child: Column(
                                children: [
                                  Card(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, 'transactionDetails',
                                            arguments: {
                                              'receipt': _posts[index]
                                            });
                                      },
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10),
                                        leading: CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.8),
                                            child: const Icon(
                                              Icons.receipt_long,
                                              color: Colors.white,
                                              size: 25,
                                            )),
                                        // title: Text(
                                        //   _posts[index]['fundSource'] ==
                                        //           'ACCOUNT'
                                        //       ? _posts[index]['accountNumber']
                                        //           .toString()
                                        //       : _posts[index]
                                        //               ['cardReferenceNumber']
                                        //           .toString(),
                                        //   style: Theme.of(context)
                                        //       .textTheme
                                        //       .titleLarge
                                        //       ?.copyWith(
                                        //           fontWeight: FontWeight.normal,
                                        //           fontSize: 16),
                                        // ),

                                        title: Text(
                                          _posts[index]['traceNumber']
                                              .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16),
                                        ),

                                        subtitle: Text(
                                          "${_posts[index]['terminalId'].toString()}\n${_posts[index]['tranDateTime'].toString()}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey),
                                        ),
                                        isThreeLine: false,
                                        trailing: Text(
                                          // transactionList[index]['processFlag'].toString() == "DEBIT"

                                          //     ? "${transactionList[index]['currencyCodeId'].toString()} ${}"
                                          //     : "${transactionList[index]['currencyCodeId'].toString()} ${transactionList[index]['amount'].toString()}",
                                          _posts[index]['processFlag']
                                                      .toString() ==
                                                  'DEBIT'
                                              ? 'AED ${_posts[index]['amount'].toString()}'
                                              : 'AED ${_posts[index]['amount'].toString()}',
                                          style: _posts[index]['processFlag']
                                                      .toString() ==
                                                  'DEBIT'
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.red)
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
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
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            _refund(
                                                _posts[index]['traceNumber'],
                                                _posts[index]['amount']);
                                          },
                                          child: const Text('Refund')),
                                      // TextButton(
                                      //     onPressed: () {},
                                      //     child: const Text('Delete')),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                  if (_isLoadMoreRunning == true)
                    const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 20),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
    );
  }
}
