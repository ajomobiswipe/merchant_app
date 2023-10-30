import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/user_services.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/loading.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  UserServices userServices = UserServices();
  String? heading;
  String? subHeading;
  String? content;
  bool _isLoding = false;

  @override
  void initState() {
    super.initState();
    getTermsAndCondition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWidget(
          title: "About Us",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoding
            ? SingleChildScrollView(
                child: SizedBox(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        heading.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subHeading.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          content.toString(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              )
            : const LoadingWidget());
  }

  void getTermsAndCondition() {
    setLoading(false);
    userServices.fetchTermsAndCondition('AU').then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseType'].toString() == "S") {
          heading = decodeData['responseValue']['list'][0]['heading'];
          subHeading = decodeData['responseValue']['list'][0]['subHeading'];
          content = decodeData['responseValue']['list'][0]['contentBody']
              .toString()
              .replaceAll(r'\n', '\n');
        } else {}
      }
      setLoading(true);
    });
  }

  setLoading(bool tf) {
    setState(() {
      _isLoding = tf;
    });
  }
}
