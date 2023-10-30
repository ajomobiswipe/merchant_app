/* ===============================================================
| Project : SIFR
| Page    : SECURITY_QUESTIONS_VERIFICATION_PAGE.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sifr_latest/config/constants.dart';
import 'package:sifr_latest/widgets/app_widget/app_button.dart';

import '../../models/getSecurity_questions_model.dart';
import '../../services/user_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/loading.dart';

// STATEFUL WIDGET
class Security extends StatefulWidget {
  const Security({super.key, required this.userName, this.type});
  final String userName;
  final String? type;

  @override
  State<Security> createState() => _SecurityState();
}

// Security State Class
class _SecurityState extends State<Security> {
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _answer1 = TextEditingController();
  final TextEditingController _answer3 = TextEditingController();
  final TextEditingController _answer2 = TextEditingController();
  UserServices userServices = UserServices();
  AlertService alertWidget = AlertService();
  SecurityQuestionResponse securityQuestionResponse =
      SecurityQuestionResponse();
  SecurityQuestionVerification securityQuestionVerification =
      SecurityQuestionVerification();

  // Init function for page Initialization
  @override
  void initState() {
    securityApi(); // Get security questions from SIFR api
    super.initState();
  }

  //Form submit to verify security questions and answers
  void submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      securityQuestionVerification.instId = Constants.instId;
      securityQuestionVerification.userName = widget.userName;
      userServices
          .securityVerification(securityQuestionVerification)
          .then((response) {
        setLoading(false);
        var decodeData = jsonDecode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (decodeData['responseCode'].toString() == "00") {
            alertWidget.success(
                context, 'Success', decodeData['responseMessage']);
            Navigator.pop(context);
            Navigator.pushNamed(context, 'OTPVerification',
                arguments: {'type': widget.type, 'userName': widget.userName});
          } else {
            alertWidget.failure(
                context, 'Failure', decodeData['responseMessage']);
          }
        } else {
          alertWidget.failure(context, 'Failure', decodeData['message']);
        }
      });
      setLoading(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWidget(
          title: "Security Question",
          action: false,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: _isLoading
                ? const LoadingWidget()
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    // height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Text(
                            "Verify your security questions",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06,
                          ),
                          question1(),
                          // const SizedBox(height: 20),
                          answer1(),
                          const SizedBox(height: 40),
                          question2(),
                          // const SizedBox(height: 20),
                          answer2(),
                          const SizedBox(height: 40),
                          question3(),
                          // const SizedBox(height: 20),
                          answer3(),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: AppButton(
                              title: 'Verify & Proceed',
                              onPressed: () {
                                submit();
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    )),
          ),
        ));
  }

  // TextFormField for question1
  question1() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: TextFormField(
          initialValue: securityQuestionResponse.questionOne.toString(),
          autofocus: false,
          enabled: securityQuestionResponse.questionOne.toString().isEmpty
              ? true
              : false,
          minLines: 1,
          style: const TextStyle(fontSize: 14),
          maxLines: 5,
          keyboardType: TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: "Security Question 1",
            labelStyle:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 18),
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
            prefixIcon: Icon(Icons.admin_panel_settings_outlined,
                size: 25, color: Theme.of(context).primaryColor),
          ),
          onSaved: (value) {
            securityQuestionVerification.questionOne = value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Question 1!';
            }
            return null;
          }),
    );
  }

  // TextFormField for question2
  question2() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: TextFormField(
          initialValue: securityQuestionResponse.questionTwo.toString(),
          autofocus: false,
          enabled: securityQuestionResponse.questionTwo.toString().isEmpty
              ? true
              : false,
          minLines: 1,
          maxLines: 5,
          style: const TextStyle(fontSize: 14),
          keyboardType: TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: "Security Question 2",
            labelStyle:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 18),
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
            prefixIcon: Icon(Icons.admin_panel_settings_outlined,
                size: 25, color: Theme.of(context).primaryColor),
          ),
          onSaved: (value) {
            securityQuestionVerification.questionTwo = value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Question 2!';
            }
            return null;
          }),
    );
  }

  // TextFormField for question3
  question3() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: TextFormField(
          initialValue: securityQuestionResponse.questionThree.toString(),
          autofocus: false,
          enabled: securityQuestionResponse.questionThree.toString().isEmpty
              ? true
              : false,
          minLines: 1,
          maxLines: 5,
          style: const TextStyle(fontSize: 14),
          keyboardType: TextInputType.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: "Security Question 3",
            labelStyle:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 18),
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
            prefixIcon: Icon(Icons.admin_panel_settings_outlined,
                size: 25, color: Theme.of(context).primaryColor),
          ),
          onSaved: (value) {
            securityQuestionVerification.questionThree = value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Question 3!';
            }
            return null;
          }),
    );
  }

  // TextFormField for answer1
  answer1() {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: TextFormField(
            controller: _answer1,
            keyboardType: TextInputType.text,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Answer 1 *',
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
              prefixIcon: Icon(Icons.key,
                  size: 25, color: Theme.of(context).primaryColor),
            ),
            onSaved: (value) {
              securityQuestionVerification.answerOne = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Answer 1!';
              }
              return null;
            }));
  }

  // TextFormField for answer2
  answer2() {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: TextFormField(
            controller: _answer2,
            style: const TextStyle(fontSize: 14),
            keyboardType: TextInputType.text,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Answer 2 *',
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
              prefixIcon: Icon(Icons.key,
                  size: 25, color: Theme.of(context).primaryColor),
            ),
            onSaved: (value) {
              securityQuestionVerification.answerTwo = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Answer 2!';
              }
              return null;
            }));
  }

  // TextFormField for answer3
  answer3() {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: TextFormField(
            controller: _answer3,
            style: const TextStyle(fontSize: 14),
            keyboardType: TextInputType.text,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Answer 3 *',
              labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 14),
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
              prefixIcon: Icon(Icons.key,
                  size: 25, color: Theme.of(context).primaryColor),
            ),
            onSaved: (value) {
              securityQuestionVerification.answerThree = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Answer 3!';
              }
              return null;
            }));
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _answer1.dispose();
    _answer2.dispose();
    _answer3.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  // Get security questions from SIFR api
  void securityApi() {
    userServices.securityQuestion(widget.userName).then((response) {
      setLoading(false);
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "000") {
          securityQuestionResponse =
              SecurityQuestionResponse.fromJson(decodeData);
          /*  alertWidget.success(
              context, 'Success', decodeData['responseMessage']);*/
        } else {
          alertWidget.failure(
              context, 'Failure', decodeData['responseMessage']);
        }
      } else {
        alertWidget.failure(context, 'Failure', decodeData['message']);
      }
    });
    setLoading(true);
  }

  // DYNAMIC LOADING STATE
  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }
}
