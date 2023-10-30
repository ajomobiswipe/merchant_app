import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../../config/config.dart';
import '../../models/register_model.dart';
import '../app_widget/app_bar_widget.dart';
import '../app_widget/app_button.dart';

// STATEFUL WIDGET
class SecurityForm extends StatefulWidget {
  final MerchantRequestModel registerRequestModel;
  var darkmode;
  Function previous;
  Function next;
  final TextEditingController selectedItem1;
  final TextEditingController selectedItem2;
  final TextEditingController selectedItem3;
  final TextEditingController answer1;
  final TextEditingController answer2;
  final TextEditingController answer3;
  List securityQuestionList;
  SecurityForm(
      {Key? key,
      required this.registerRequestModel,
      required this.previous,
      this.darkmode,
      required this.next,
      required this.selectedItem1,
      required this.selectedItem2,
      required this.selectedItem3,
      required this.answer2,
      required this.answer1,
      required this.answer3,
      required this.securityQuestionList})
      : super(key: key);

  @override
  State<SecurityForm> createState() => _SecurityFormState();
}

class _SecurityFormState extends State<SecurityForm> {
  final GlobalKey<FormState> securityFormKey = GlobalKey<FormState>();
  bool enabledSecurity2 = false;
  bool enabledSecurity3 = false;
  bool enabledAnswer1 = false;
  bool enabledAnswer2 = false;
  bool enabledAnswer3 = false;
  List list = [];

  @override
  void initState() {
    securityDropDown();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Global Background Pattern Widget
    return Scaffold(
      appBar: const AppBarWidget(
        action: false,
        title: 'Security Information',
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: securityFormKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              DropdownSearch(
                selectedItem: widget.selectedItem1.text != ''
                    ? widget.selectedItem1.text
                    : null,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                popupProps: PopupProps.menu(
                    menuProps: MenuProps(
                        elevation: 16,
                        backgroundColor: widget.darkmode
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor)),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    labelText: "Security Question 1 *",
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    prefixIcon: Icon(Icons.question_answer,
                        size: 25, color: Theme.of(context).primaryColor),
                  ),
                ),
                items: list.isEmpty ? widget.securityQuestionList : list,
                onSaved: (value) {
                  widget.registerRequestModel.questionOne = value;
                },
                onChanged: (val) {
                  setState(() {
                    widget.selectedItem1.text = val;
                    val.isEmpty || val == null || val == ''
                        ? enabledAnswer1 = false
                        : enabledAnswer1 = true;
                  });
                  securityDropDown();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Security Question 1 is Mandatory!';
                  }
                  return null;
                },
              ),
              // CustomDropdown(
              //   title: "Security Question 1",
              //   required: true,
              //   itemList: list.isEmpty ? securityQuestionList : list,
              //   prefixIcon: Icons.question_answer,
              //   selectedItem: selectedItem1 != '' ? selectedItem1 : null,
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: widget.answer1,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    label: const Text("Answer 1 *"),
                    enabled: widget.selectedItem1.text.isEmpty ||
                            widget.selectedItem1.text == ''
                        ? enabledAnswer1 = false
                        : enabledAnswer1 = true,
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    prefixIcon: Icon(Icons.key,
                        size: 25, color: Theme.of(context).primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Answer 1 is Mandatory!';
                    }
                    if (!Validators.isAlphaNumeric(value)) {
                      return 'Invalid Answer 1';
                    }
                    if (widget.answer1.text.trim() ==
                            widget.answer2.text.trim() ||
                        widget.answer1.text.trim() ==
                            widget.answer3.text.trim()) {
                      return Constants.answerMesage;
                    }

                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {
                      value.isEmpty
                          ? enabledSecurity2 = false
                          : enabledSecurity2 = enabledAnswer1;
                    });
                  },
                  onSaved: (value) {
                    widget.registerRequestModel.answerOne = value;
                  },
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              DropdownSearch(
                selectedItem: widget.selectedItem2.text != ''
                    ? widget.selectedItem2.text
                    : null,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                enabled: widget.answer1.text.isEmpty
                    ? enabledSecurity2 = false
                    : enabledSecurity2 = enabledAnswer1,
                popupProps: PopupProps.menu(
                    menuProps: MenuProps(
                        elevation: 16,
                        backgroundColor: widget.darkmode
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor)),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    labelText: "Security Question 2 *",
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    prefixIcon: Icon(Icons.question_answer,
                        size: 25, color: Theme.of(context).primaryColor),
                  ),
                ),
                items: list.isEmpty ? widget.securityQuestionList : list,
                onSaved: (value) {
                  widget.registerRequestModel.questionTwo = value;
                },
                onChanged: (val) {
                  widget.answer1.text = widget.answer1.text.trim();
                  setState(() {
                    widget.selectedItem2.text = val;
                    widget.selectedItem2.text.isEmpty
                        ? enabledAnswer2 = false
                        : enabledAnswer2 = enabledSecurity2;
                  });
                  securityDropDown();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Security Question 2 is Mandatory!';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: widget.answer2,
                  keyboardType: TextInputType.text,
                  enabled: widget.selectedItem2.text.isEmpty
                      ? enabledAnswer2 = false
                      : enabledAnswer2 = enabledSecurity2,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    label: const Text("Answer 2 *"),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    prefixIcon: Icon(Icons.key,
                        size: 25, color: Theme.of(context).primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Answer 2 is Mandatory!';
                    }
                    if (!Validators.isAlphaNumeric(value)) {
                      return 'Invalid Answer 2';
                    }
                    if (widget.answer2.text.trim() ==
                            widget.answer1.text.trim() ||
                        widget.answer2.text.trim() ==
                            widget.answer3.text.trim()) {
                      return Constants.answerMesage;
                    }

                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {
                      value.isEmpty
                          ? enabledSecurity3 = false
                          : enabledSecurity3 = enabledAnswer2;
                    });
                  },
                  onSaved: (value) {
                    widget.registerRequestModel.answerTwo = value;
                  },
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              DropdownSearch(
                selectedItem: widget.selectedItem3.text != ''
                    ? widget.selectedItem3.text
                    : null,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                enabled: widget.answer2.text.isEmpty ||
                        widget.answer2.text.trim() ==
                            widget.answer1.text.trim() ||
                        widget.answer2.text.trim() == widget.answer3.text.trim()
                    ? enabledSecurity3 = false
                    : enabledSecurity3 = enabledAnswer2,
                popupProps: PopupProps.menu(
                    menuProps: MenuProps(
                        elevation: 16,
                        backgroundColor: widget.darkmode
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor)),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Security Question 3 *",
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    prefixIcon: Icon(Icons.question_answer,
                        size: 25, color: Theme.of(context).primaryColor),
                  ),
                ),
                items: list.isEmpty ? widget.securityQuestionList : list,
                onSaved: (value) {
                  widget.registerRequestModel.questionThree = value;
                },
                onChanged: (val) {
                  widget.answer2.text = widget.answer2.text.trim();
                  setState(() {
                    widget.selectedItem3.text = val;
                    widget.selectedItem3.text.isEmpty
                        ? enabledAnswer3 = false
                        : enabledAnswer3 = enabledSecurity3;
                  });
                  securityDropDown();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Security Question 3 is Mandatory!';
                  }
                  return null;
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: widget.answer3,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  enabled: widget.selectedItem3.text.isEmpty
                      ? enabledAnswer3 = false
                      : enabledAnswer3 = enabledSecurity3,
                  // focusNode: myFocusNode,
                  decoration: InputDecoration(
                    label: const Text("Answer 3 *"),
                    border: const OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    prefixIcon: Icon(Icons.key,
                        size: 25, color: Theme.of(context).primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Answer 3 is Mandatory!';
                    }
                    if (!Validators.isAlphaNumeric(value)) {
                      return 'Invalid Answer 3';
                    }
                    if (widget.answer3.text.trim() ==
                            widget.answer1.text.trim() ||
                        widget.answer3.text.trim() ==
                            widget.answer2.text.trim()) {
                      return Constants.answerMesage;
                    }

                    return null;
                  },
                  onSaved: (value) {
                    widget.registerRequestModel.answerThree = value;
                  },
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    child: AppButton(
                      title: 'Previous',
                      onPressed: () {
                        widget.previous();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: AppButton(
                      title: "Next",
                      onPressed: () {
                        widget.answer1.text = widget.answer1.text.trim();
                        widget.answer2.text = widget.answer2.text.trim();
                        widget.answer3.text = widget.answer3.text.trim();

                        if (securityFormKey.currentState!.validate()) {
                          securityFormKey.currentState!.save();
                          widget.next();
                        }
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List securityDropDown() {
    list.clear();
    setState(() {
      list = widget.securityQuestionList
          .where((i) =>
              i != widget.selectedItem1.text &&
              i != widget.selectedItem2.text &&
              i != widget.selectedItem3.text)
          .toList();
    });
    return list;
  }
}
