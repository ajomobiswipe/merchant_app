import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sifr_latest/widgets/loading.dart';

import '../../config/global.dart';
import '../../services/services.dart';
import '../../widgets/widget.dart';

class Statements extends StatefulWidget {
  final dynamic params;
  const Statements({Key? key, this.params}) : super(key: key);

  @override
  State<Statements> createState() => _StatementsState();
}

class _StatementsState extends State<Statements> {
  TransactionServices transactionServices = TransactionServices();
  List statementList = [];
  List searchList = [];
  bool _isLoading = false;
  late TextEditingController contactSearchController;

  @override
  void dispose() {
    contactSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getStatementList(widget.params);
    contactSearchController = TextEditingController();
    super.initState();
  }

  isLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  getStatementList(params) {
    isLoading(true);
    transactionServices.getStatements(params, 0, 10).then((response) {
      var decodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoading(false);
        statementList = decodeData['content'];
        searchList = decodeData['content'];
      } else {
        isLoading(false);
        statementList = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: "Statements",
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading ? const LoadingWidget() : mainWidget(),
    );
  }

  mainWidget() {
    Widget searchContacts = SizedBox(
      // width: MediaQuery.of(context).size.width * 1,
      child: TextField(
        controller: contactSearchController,
        onChanged: (value) {
          if (value.isEmpty) {
            setState(() {
              statementList = searchList;
              //generateList();
            });
          } else {
            final suggest = searchList.where((element) {
              final abc = element['cardReferenceNumber'].toLowerCase();
              final amount = element['amount'].toLowerCase();
              final msg = element['responseMessage'].toLowerCase();
              final input = value.toLowerCase();
              return abc.contains(input) ||
                  amount.contains(input) ||
                  msg.contains(input);
            }).toList();
            setState(() {
              statementList = suggest;
            });
          }
        },
        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(10),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            hintText: "Search...",
            hintStyle: TextStyle(color: Theme.of(context).primaryColor)),
      ),
    );
    return Column(
      children: [
        const SizedBox(
          height: 10.0,
        ),
        searchList.isEmpty
            ? Container()
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: searchContacts,
              ),
        const SizedBox(
          height: 10.0,
        ),
        statementList.isEmpty
            ? Global.noDataFound("statement")
            : Expanded(child: getStatement()),
      ],
    );
  }

  Widget getStatement() {
    return Container(
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: statementList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Card(
                elevation: 5,
                // color: Theme.of(context).cardColor,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, 'transactionDetails',
                        arguments: {'receipt': statementList[index]});
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
                      statementList[index]['cardReferenceNumber'].toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    subtitle: Text(
                      "${statementList[index]['responseMessage'].toString()}\n${statementList[index]['tranDateTime'].toString()}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.normal),
                    ),
                    isThreeLine: false,
                    trailing: Text(
                      '${statementList[index]['currencyCodeId']} ${statementList[index]['amount'].toString()}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: statementList[index]['processFlag'].toString() ==
                                "DEBIT"
                            ? Colors.red[400]
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                    // onTap: () => _viewTransactionReceipt(transaction),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
