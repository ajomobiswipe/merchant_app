import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/constants.dart';
import '../../models/TransactionRequest.dart';
import '../../models/complaint_page.dart';
import '../../services/transaction_services.dart';
import '../../services/user_services.dart';
import '../../storage/secure_storage.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/app_widget/app_button.dart';
import '../../widgets/loading.dart';

class Complaint extends StatefulWidget {
  const Complaint({Key? key}) : super(key: key);

  @override
  State<Complaint> createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  bool transaction = true;
  bool others = false;
  bool _isLoading = true;
  ComplaintRequest complaintRequest = ComplaintRequest();
  UserServices userServices = UserServices();
  AlertService alertWidget = AlertService();
  String complaintType = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TransactionServices transactionServices = TransactionServices();
  TransactionRequest transactionRequest = TransactionRequest();
  List transactionList = [];
  List searchList = [];
  late String customerId;
  TextEditingController contactSearchController = TextEditingController();
  List processFlag = [];
  bool other = false;
  List<String> searchHintsList = [
    'Search...',
    'Search for a Amount',
    'Search for a Account Number',
    'Search for a Card Number',
  ];
  int currentSearchHintIndex = 0;
  final List _hasBeenPressed = [];
  BoxStorage boxStorage = BoxStorage();

  @override
  void initState() {
    transactionRequest.custId = boxStorage.getCustomerId();
    allTransactionList(50);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWidget(
          title: "New Complaint",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoading
            ? Container(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text('Choose your type of complaint',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor)),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 18.0, right: 18.0),
                          child: Wrap(
                            runSpacing: 4.0,
                            spacing: 4.0,
                            children: getWidget(),
                          ),
                        ),
                        other
                            ? Column(
                                children: othersWidget(),
                              )
                            : Container(),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: other ? Container() : mainWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const LoadingWidget());
  }

  void submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setLoading(false);
      userServices
          .saveComplaintDetails(complaintRequest, complaintType)
          .then((response) {
        var decodeData = jsonDecode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (decodeData['responseCode'].toString() == '00') {
            alertWidget.success(
                context, 'Success', decodeData['responseMessage']);
            Navigator.pushNamed(context, 'complaint');
            //getComplaintDetails(type);
          } else {
            alertWidget.failure(
                context, 'Failure', decodeData['responseMessage']);
          }
        } else {
          alertWidget.failure(context, 'Failure', decodeData['message']);
        }
        setLoading(true);
      });
    }
  }

  Future<String> allTransactionList(size) async {
    setState(() {
      _isLoading = false;
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
        _isLoading = true;
      });
      var decodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        transactionList = decodeData['content'];
        searchList = decodeData['content'];
        getType();
        filter(processFlag[0].toString());
      } else {
        setState(() {
          _isLoading = true;
          transactionList = [];
          searchList = [];
        });
        alertWidget.failure(
            context, 'Failure', decodeData['message'].toString());
      }
    });
    return "success";
  }

  List<Widget> othersWidget() {
    return [
      const SizedBox(
        height: 20,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: RichText(
            text: TextSpan(
                text: "Raise a Complaint",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          minLines: 4,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Description is Mandatory!";
            }
            return null;
          },
          keyboardType: TextInputType.multiline,
          maxLines: 8,
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            /* labelText: 'Description',
            labelStyle: TextStyle(
              color: Theme.of(context).primaryColor,
            ),*/
            hintText: 'Description',
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          onSaved: (value) {
            complaintRequest.complaintMessage = value;
          },
        ),
      ),
      const SizedBox(
        height: 30,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: AppButton(
          title: "RAISE A COMPLAINT",
          onPressed: () {
            submit();
          },
        ),
      ),
      const SizedBox(
        height: 30,
      ),
    ];
  }

  mainWidget() {
    String currentSearchHint = searchHintsList[currentSearchHintIndex];
    Widget searchContacts = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
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
            : Expanded(child: itemWidget())
      ],
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
          const Text("No Transaction"),
        ],
      ),
    );
  }

  itemWidget() {
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
                Navigator.pushNamed(context, 'complaintTypeDetails',
                    arguments: {'receipt': transactionList[index], 'type': ''});
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
                  'AED ${transactionList[index]['amount'].toString()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            ));
      },
    );
  }

  getType() {
    processFlag.clear();
    for (var list1 in searchList) {
      if (processFlag.contains(list1['processFlag'])) {
      } else {
        _hasBeenPressed.add(false);
        processFlag.add(list1['processFlag']);
      }
    }
    _hasBeenPressed.add(false);
    _hasBeenPressed[0] = true;
    processFlag.add("Others");
  }

  getWidget() {
    List<Widget> listItems = [];
    for (var i = 0; i < processFlag.length; i++) {
      listItems.add(
        OutlinedButton(
          onPressed: () {
            contactSearchController.clear();
            filter(processFlag[i].toString());
            for (var j = 0; j < _hasBeenPressed.length; j++) {
              if (i == j) {
                setState(() {
                  _hasBeenPressed[j] = true;
                });
              } else {
                setState(() {
                  _hasBeenPressed[j] = false;
                });
              }
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(_hasBeenPressed[i]
                ? Theme.of(context).primaryColor
                : Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                side: BorderSide(
                    width: 5.0, color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: Text(processFlag[i].toString().toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _hasBeenPressed[i]
                    ? Colors.white
                    : Theme.of(context).primaryColor,
              )),
        ),
      );
    }
    return listItems;
  }

  filter(String type) {
    if (type.toString() == 'Others') {
      setState(() {
        other = true;
        transactionList = [];
        complaintType = 'others';
      });
    } else {
      other = false;
      final suggest = searchList.where((element) {
        final flag = element['processFlag'].toLowerCase();
        final input = type.toLowerCase();
        return flag.contains(input);
      }).toList();
      setState(() {
        transactionList = suggest;
      });
    }
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }
}
