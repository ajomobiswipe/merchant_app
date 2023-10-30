import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../services/user_services.dart';
import '../../../../widgets/loading.dart';
import '../../../../widgets/widget.dart';

class TermsAndConditionPage extends StatefulWidget {
  const TermsAndConditionPage({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionPage> createState() => _TermsAndConditionPageState();
}

class _TermsAndConditionPageState extends State<TermsAndConditionPage> {
  UserServices userServices = UserServices();
  String? heading;
  String? subHeading;
  String? content;
  bool _isLoading = false;
  bool accept = false;
  AlertService alertWidget = AlertService();

  @override
  void initState() {
    super.initState();
    getTermsAndCondition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Terms & Conditions"),
          centerTitle: true,
          automaticallyImplyLeading: true,
          elevation: 1,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoading
            ? SingleChildScrollView(
                child: SizedBox(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Image.asset('assets/logo/logo2.png',
                          height: 50, fit: BoxFit.fill),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        heading.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subHeading.toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          content.toString(),
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: AppButton(
                          title: 'Agree',
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            /*  setState(() {
                              accept = true;
                            });*/
                          },
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              )
            : const LoadingWidget());
  }

  void getTermsAndCondition() {
    setLoading(false);
    userServices.fetchTermsAndCondition('TC').then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseType'].toString() == "S") {
          heading = decodeData['responseValue']['list'][0]['heading'];
          subHeading = decodeData['responseValue']['list'][0]['subHeading'];
          content = decodeData['responseValue']['list'][0]['contentBody']
              .toString()
              .replaceAll(r'\n', '\n');
        } else {
          alertWidget.failure(
              context, 'Failure', decodeData['responseValue']['message']);
        }
      } else {
        alertWidget.failure(
            context, 'Failure', decodeData['responseValue']['message']);
      }
      setLoading(true);
    });
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }
}
