import 'dart:convert';

import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sifr_latest/pages/help/RecentComplaint.dart';

import '../../models/complaint_page.dart';
import '../../services/user_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/loading.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({Key? key}) : super(key: key);

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  bool transaction = true;
  bool withdraw = false;
  bool others = false;
  bool _isLoading = false;
  List data = [];
  String type = 'transaction';
  List searchList = [];
  List<String> searchHintsList = [
    'Search...',
  ];
  int currentSearchHintIndex = 0;

  TextEditingController contactSearchController = TextEditingController();

  ComplaintRequest complaintRequest = ComplaintRequest();
  UserServices userServices = UserServices();
  AlertService alertWidget = AlertService();

  List<String> options = ["Transactions", "Withdrawal", "Others"];
  String tag = "Transactions";

  @override
  void initState() {
    getComplaintDetails('transaction', 5);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, 'help');
        return true;
      },
      child: Scaffold(
        appBar: const AppBarWidget(
          title: "Complaint",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: !_isLoading
            ? const LoadingWidget()
            : SingleChildScrollView(
                child: oldWidget1(),
              ),
      ),
    );
  }

  Widget oldWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        //height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    )),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xffff8052),
                          child: Icon(
                            Icons.edit_note_sharp,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Complaint",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(decoration: TextDecoration.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'raiseComplaint');
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      )),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Create New",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none),
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Wrap(
                spacing: 4,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        getComplaintDetails('transaction', 5);
                        transaction = true;
                        withdraw = false;
                        others = false;
                        type = 'transaction';
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(transaction
                          ? Theme.of(context).primaryColor
                          : Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          side: BorderSide(
                              width: 5.0,
                              color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text("Transaction",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: transaction
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        )),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        transaction = false;
                        withdraw = true;
                        others = false;
                        getComplaintDetails('withdraw', 5);
                        type = 'withdraw';
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(withdraw
                          ? Theme.of(context).primaryColor
                          : Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          side: BorderSide(
                              width: 5.0,
                              color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text("Withdrawal",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: withdraw
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        )),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        transaction = false;
                        withdraw = false;
                        others = true;
                        getComplaintDetails('others', 5);
                        type = 'others';
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(others
                          ? Theme.of(context).primaryColor
                          : Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          side: BorderSide(
                              width: 5.0,
                              color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text("Others",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: others
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        )),
                  ),
                ],
              ),
            ),
            mainWidget(),
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Divider(
                    thickness: 1.0,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        getComplaintDetails(type, 100);
                      },
                      child: Text(
                        'View all request',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  newOne() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, 'raiseComplaint');
            },
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Create new complaint",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ChipsChoice.single(
            value: tag,
            wrapped: false,
            onChanged: (val) {
              setState(() => tag = val);
              type = val.toString().toLowerCase();
              getComplaintDetails(val.toString().toLowerCase(), 5);
            },
            choiceItems: C2Choice.listFrom<String, String>(
              source: options,
              value: (i, v) => v.toString(),
              label: (i, v) => v,
            ),
            choiceActiveStyle: C2ChoiceStyle(
              color: Colors.white,
              showCheckmark: false,
              backgroundColor: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            choiceStyle: C2ChoiceStyle(
              showCheckmark: false,
              color: Theme.of(context).primaryColor,
              backgroundColor: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget oldWidget1() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(12),
        //   color: Theme.of(context).cardColor,
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey.withOpacity(0.5),
        //       spreadRadius: 5,
        //       blurRadius: 7,
        //       offset: const Offset(0, 3),
        //     ),
        //   ],
        // ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'raiseComplaint');
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      )),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Create New",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none),
                            ),
                          ),
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Wrap(
                spacing: 4,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        getComplaintDetails('transaction', 5);
                        transaction = true;
                        withdraw = false;
                        others = false;
                        type = 'transaction';
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(transaction
                          ? Theme.of(context).primaryColor
                          : Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          side: BorderSide(
                              width: 5.0,
                              color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text("Transaction",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: transaction
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        )),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        transaction = false;
                        withdraw = true;
                        others = false;
                        getComplaintDetails('withdraw', 5);
                        type = 'withdraw';
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(withdraw
                          ? Theme.of(context).primaryColor
                          : Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          side: BorderSide(
                              width: 5.0,
                              color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text("Withdrawal",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: withdraw
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        )),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        transaction = false;
                        withdraw = false;
                        others = true;
                        getComplaintDetails('others', 5);
                        type = 'others';
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(others
                          ? Theme.of(context).primaryColor
                          : Colors.white),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          side: BorderSide(
                              width: 5.0,
                              color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text("Others",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: others
                              ? Colors.white
                              : Theme.of(context).primaryColor,
                        )),
                  ),
                ],
              ),
            ),
            mainWidget(),
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Divider(
                    thickness: 1.0,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        getComplaintDetails(type, 100);
                      },
                      child: Text(
                        'View all $type complaints',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getComplaintDetails(String type, int size) async {
    setLoading(false);
    userServices.getComplaintDetails(type, size).then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        data = decodeData['content'];
        searchList = decodeData['content'];
      } else {
        alertWidget.failure(context, 'Failure', decodeData['message']);
      }
      setLoading(true);
    });
  }

  mainWidget() {
    String currentSearchHint = searchHintsList[currentSearchHintIndex];
    Widget searchContacts = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: TextField(
            controller: contactSearchController,
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() {
                  data = searchList;
                  //generateList();
                });
              } else {
                final suggest = searchList.where((element) {
                  final abc = element['complaintMessage'].toLowerCase();
                  final amount = element['requestcompleted'].toString();
                  final input = value.toLowerCase();
                  return abc.contains(input) || amount.contains(input);
                }).toList();
                setState(() {
                  data = suggest;
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
    return Expanded(
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
          data.isEmpty
              ? Expanded(
                  child: noData(),
                )
              : Expanded(child: RecentComplaint(data))
        ],
      ),
    );
  }

  noData() {
    return const Center(
      child: Text("No Complaints Found"),
    );
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }
}
