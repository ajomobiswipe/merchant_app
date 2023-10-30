import 'dart:convert';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';

import '../../models/faq_model.dart';
import '../../services/user_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/loading.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  bool _isLoding = false;
  List<Data> responses = [];
  UserServices userServices = UserServices();
  AlertService alertWidget = AlertService();

  final _headerStyle = const TextStyle(
      color: Color(0xffffffff), fontSize: 15, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    getFaq();
  }

  @override
  build(context) => Scaffold(
      appBar: const AppBarWidget(
        title: "FAQ",
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoding
          ? Accordion(
              contentBackgroundColor: Colors.white,
              maxOpenSections: 1,
              headerBackgroundColor: Theme.of(context).primaryColorDark,
              headerBackgroundColorOpened: Theme.of(context).primaryColorLight,
              scaleWhenAnimating: true,
              openAndCloseAnimation: true,
              headerPadding:
                  const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
              sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
              sectionClosingHapticFeedback: SectionHapticFeedback.light,
              children: responses
                  .map((i) => AccordionSection(
                        isOpen: true,
                        leftIcon: const Icon(Icons.insights_rounded,
                            color: Colors.white),
                        headerBackgroundColor:
                            Theme.of(context).primaryColorDark,
                        headerBackgroundColorOpened:
                            Theme.of(context).primaryColor.withOpacity(0.8),
                        header:
                            Text(i.category.toString(), style: _headerStyle),
                        content: Accordion(
                          maxOpenSections: 1,
                          headerBackgroundColorOpened:
                              Theme.of(context).primaryColor,
                          headerBackgroundColor: Colors.white,
                          rightIcon: const Icon(
                            Icons.arrow_drop_down_outlined,
                            color: Colors.black,
                          ),
                          flipRightIconIfOpen: true,
                          headerPadding: const EdgeInsets.symmetric(
                              vertical: 7, horizontal: 15),
                          children: i.value!
                              .map(
                                (e) => AccordionSection(
                                  scrollIntoViewOfItems:
                                      ScrollIntoViewOfItems.fast,
                                  header: Text(
                                    e.queston.toString(),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  content: Text(
                                    e.answer.toString().trim(),
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  contentHorizontalPadding: 20,
                                  contentBorderColor:
                                      Theme.of(context).primaryColor,
                                  contentBackgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                              )
                              .toList(),
                        ),
                        contentHorizontalPadding: 20,
                        contentBorderColor: Colors.black54,
                      ))
                  .toList(),
            )
          : const LoadingWidget());

  void getFaq() {
    setLoading(false);
    userServices.fetchFaq().then((response) {
      var decodeData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseType'].toString() == "S") {
          var res = Faq.fromJson(
            decodeData,
          );
          setState(() {
            responses = res.responseValue!.list!;
          });
          /*alertWidget.success(
              context, 'Success', decodeData['responseValue']['message']);*/
        }
      } else {
        alertWidget.failure(
            context, 'Failure', decodeData['responseValue']['message']);
      }
    });
    setLoading(true);
  }

  setLoading(bool tf) {
    setState(() {
      _isLoding = tf;
    });
  }
}
