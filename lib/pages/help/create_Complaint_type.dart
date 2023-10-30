import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/complaint_page.dart';
import '../../services/user_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/app_widget/app_button.dart';
import '../../widgets/loading.dart';

class ComplaintPage2 extends StatefulWidget {
  final String? type;
  final dynamic receipt;
  const ComplaintPage2({Key? key, this.receipt, this.type}) : super(key: key);

  @override
  State<ComplaintPage2> createState() => _ComplaintPage2State();
}

class _ComplaintPage2State extends State<ComplaintPage2> {
  final defaultHeight = const SizedBox(
    height: 20,
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ComplaintRequest complaintRequest = ComplaintRequest();
  UserServices userServices = UserServices();
  AlertService alertWidget = AlertService();
  String complaintType = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Widget titleContent(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .displaySmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.receipt;
    return Scaffold(
        appBar: const AppBarWidget(
          title: "Transaction Details",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoading
            ? SafeArea(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          titleContent(
                              "Trace Number", data['traceNumber'] ?? 'NIL'),
                          const SizedBox(height: 5),
                          titleContent("Amount", data['amount'].toString()),
                          const SizedBox(height: 5),
                          titleContent("Description",
                              data['responseMessage'].toString()),
                          const SizedBox(height: 5),
                          titleContent("Reference No",
                              data['retrivalReferenceNumber'].toString()),
                          const SizedBox(height: 20),
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
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                              ),
                              onSaved: (value) {
                                complaintRequest.complaintMessage = value;
                                complaintType = 'transaction';
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
                        ],
                      ),
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
            widget.type == ''
                ? Navigator.pushNamed(context, 'complaint')
                : Navigator.pop(context);
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

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }
}
