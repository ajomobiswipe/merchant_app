import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/config.dart';
import '../../widgets/widget.dart';

class MerchantPay extends StatefulWidget {
  const MerchantPay({Key? key}) : super(key: key);

  @override
  State<MerchantPay> createState() => _MerchantPayState();
}

class _MerchantPayState extends State<MerchantPay> {
  var focusNode = FocusNode();
  static const fixedAmount = ['50', '100', '150', '200', '500', 'Others'];
  late bool showAmountField = false;
  late bool _isButtonDisabled = false;
  TextEditingController amountController = TextEditingController();
  String tag = '0';
  CustomAlert customAlert = CustomAlert();

  static defaultHeight() {
    return const SizedBox(height: 20.0);
  }

  @override
  void initState() {
    amountController.addListener(_printLatestValue);
    super.initState();
  }

  _printLatestValue() {
    setState(() {
      _isButtonDisabled =
          (amountController.text.isEmpty || amountController.text == '0')
              ? true
              : false;
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: const AppBarWidget(
          title: "Pay Cash",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: mainContent(context),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    var exitResult = customAlert.displayDialogConfirm(
        context,
        'Please confirm',
        'Do you want cancel this transaction?',
        onTapConfirm1);
    return exitResult!=null?true : false;
  }

  void onTapConfirm1() {
    Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
  }

  Widget centerTitle() {
    return Center(
      child: Text(
        "Dispense Cash @ Virtual ATM's",
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w400, fontSize: 20),
      ),
    );
  }

  Widget mainContent(context) {
    return Column(children: [
      defaultHeight(),
      centerTitle(),
      defaultHeight(),
      Image.asset(Constants.payCashImage, height: 200, fit: BoxFit.fill),
      defaultHeight(),
      !showAmountField
          ? Column(
              children: [
                Center(
                    child: Text(
                  "Choose Amount",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w400, fontSize: 16),
                )),
                const SizedBox(
                  height: 16.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 30,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // primary: true,
                    children: fixedAmount
                        .map((e) => InkWell(
                              onTap: () async {
                                if (e == 'Others') {
                                  amountController.clear();
                                  setState(() {
                                    showAmountField = true;
                                  });
                                } else {
                                  amountController.text = e;
                                  customAlert.displayDialogConfirm(
                                      context,
                                      'Please confirm',
                                      'We hope that you have AED $e Cash with you for dispensing the same to our customer.',
                                      onTapConfirm);
                                }
                              },
                              child: Card(
                                elevation: 5,
                                shadowColor: Theme.of(context).primaryColor,
                                color: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.only(
                                    right: 10.0, bottom: 10.0),
                                child: SizedBox(
                                  height: 50.0,
                                  width: 100.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        e == 'Others' ? e : '+$e',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontSize: 14),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                )
              ],
            )
          : Column(
              children: [
                Center(
                    child: Text(
                  "Enter Your Amount",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w400, fontSize: 16),
                )),
                const SizedBox(
                  height: 16.0,
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 100, left: 100),
                    child: TextFormField(
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        autofocus: true,
                        controller: amountController,
                        focusNode: focusNode,
                        maxLength: 6,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          counterText: "",
                          prefixIcon: const Padding(
                              padding: EdgeInsets.only(
                                  left: 15, top: 15, bottom: 15, right: 5),
                              child: Text(
                                'AED ',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              )),
                          labelStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                        ),
                        onSaved: (value) {
                          amountController.text = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty || value == '0') {
                            return 'Enter valid Amount';
                          }
                          return null;
                        })),
                defaultHeight(),
                SizedBox(
                  height: 50,
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _isButtonDisabled
                        ? null
                        : () async {
                            String e = amountController.text;
                            customAlert.displayDialogConfirm(
                                context,
                                'Please confirm',
                                'We hope that you have AED $e Cash with you for dispensing the same to our customer.',
                                onTapConfirm);
                            /* var result = await showAlertDialog<OkCancelResult>(
                              context: context,
                              title: "Are you sure?",
                              message:
                                  "We hope that you have AED $e Cash with you for dispensing the same to our customer.",
                              barrierDismissible: true,
                              style: AdaptiveDialog.instance.defaultStyle,
                              actions: [
                                const AlertDialogAction(
                                    label: "No",
                                    key: OkCancelResult.cancel,
                                    isDefaultAction: true,
                                    textStyle: TextStyle(color: Colors.red)),
                                const AlertDialogAction(
                                  label: "Yes",
                                  key: OkCancelResult.ok,
                                  isDefaultAction: true,
                                ),
                              ],
                            );*/
                            /* if (result == OkCancelResult.ok) {
                              if (!mounted) return;
                              Navigator.of(context).pushNamed('merchantQrCode',
                                  arguments: {'params': e});
                            }*/
                          },
                    child: const Text("Pay Now"),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        showAmountField = false;
                        amountController.text = '';
                      });
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.red,
                          decoration: TextDecoration.underline),
                    ))
              ],
            ),
      defaultHeight(),
    ]);
  }

  onTapConfirm() {
    Navigator.pop(context);
    if (!mounted) return;
    Navigator.of(context).pushNamed('merchantQrCode',
        arguments: {'params': amountController.text});
    amountController.clear();
  }
}
