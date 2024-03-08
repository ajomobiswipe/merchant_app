import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sifr_latest/services/services.dart';
import 'package:sifr_latest/utilities/screen_size.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';
import 'package:sifr_latest/widgets/widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../config/app_color.dart';
import '../../widgets/qr_code_widget.dart';
import 'models/statusmodal.dart';

class MyApplications extends StatefulWidget {
  const MyApplications({super.key});

  @override
  State<MyApplications> createState() => _MyApplicationsState();
}

class _MyApplicationsState extends State<MyApplications> {
  TextEditingController _merchantNameController = TextEditingController();
  UserServices userServices = UserServices();
  List applicationStatus = [];
  List allOnboardingApplications = [];
  int selectesStage = 0;
  dynamic selectedValue;

  bool onboardedBool = false;

  bool loader = true;
  List<ApplicationStatus> ststusdata = [
    // ApplicationStatus(
    //   kycApproved: true,
    //   amountToPay: 2000,
    //   eNach: true,
    //   payment: true,
    //   midtidGenerated: true,
    //   allDevicesOnboarded: true,
    //   errorMessage: '5456455',
    //   live: true,
    //   statusCode: 200,
    //   map: "null",
    //   map: "null",
    //   devices: [
    //     Device(
    //       deploymentStatus: true,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //     Device(
    //       deploymentStatus: true,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "AndroidPos",
    //     ),
    //   ],
    // ),
    // ApplicationStatus(
    //   kycApproved: true,
    //   amountToPay: 2000,
    //   eNach: true,
    //   payment: true,
    //   midtidGenerated: false,
    //   allDevicesOnboarded: false,
    //   errorMessage: 'success',
    //   live: false,
    //   statusCode: 200,
    //   map: "null",
    //   devices: [
    //     Device(
    //       deploymentStatus: false,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //     Device(
    //       deploymentStatus: false,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //     Device(
    //       deploymentStatus: false,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //     Device(
    //       deploymentStatus: false,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //   ],
    // ),
    // ApplicationStatus(
    //   kycApproved: true,
    //   amountToPay: 2000,
    //   eNach: true,
    //   payment: true,
    //   midtidGenerated: false,
    //   allDevicesOnboarded: false,
    //   errorMessage: 'success',
    //   live: false,
    //   statusCode: 200,
    //   map: "null",
    //   devices: [
    //     Device(
    //       deploymentStatus: false,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //     Device(
    //       deploymentStatus: false,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //     Device(
    //       deploymentStatus: false,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //     Device(
    //       deploymentStatus: false,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //   ],
    // ),
    // ApplicationStatus(
    //   kycApproved: true,
    //   amountToPay: 2000,
    //   eNach: true,
    //   payment: true,
    //   midtidGenerated: true,
    //   allDevicesOnboarded: false,
    //   errorMessage: 'success',
    //   live: true,
    //   statusCode: 200,
    //   map: "null",
    //   devices: [
    //     Device(
    //       deploymentStatus: true,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //     Device(
    //       deploymentStatus: true,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //     Device(
    //       deploymentStatus: true,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //     Device(
    //       deploymentStatus: false,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //   ],
    // ),
    // ApplicationStatus(
    //   kycApproved: true,
    //   amountToPay: 2000,
    //   eNach: false,
    //   payment: false,
    //   midtidGenerated: false,
    //   allDevicesOnboarded: false,
    //   errorMessage: 'success',
    //   live: false,
    //   statusCode: 200,
    //   map: "null",
    //   devices: [
    //     Device(
    //       deploymentStatus: false,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //     Device(
    //       deploymentStatus: false,
    //       package: "tactiacl",
    //       packageId: 1,
    //       price: 3000,
    //       productId: 2,
    //       productName: "Softpos",
    //     ),
    //   ],
    // ),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDefaultMerchantValues();
      getAllMerchantApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    print(screenWidth);
    bool isSmallScreen = screenWidth < 360;
    print(isSmallScreen);
    double kycPendingCount = 30;
    double paymentPendingCount = 40;
    double deploymentPendingCount = 10;
    double liveCount = 20;

    if (getChartCount != null) {
      kycPendingCount = getChartCount!['kycPendingCount'].toDouble();
      paymentPendingCount = getChartCount!['paymentPendingCount'].toDouble();
      deploymentPendingCount =
          getChartCount!['deploymentPendingCount'].toDouble();
      liveCount = getChartCount!['liveCount'].toDouble();
    }

    return AppScafofld(
        closePressed: () {
          Navigator.pushNamedAndRemoveUntil(
              context, 'MerchantNumVerify', (route) => false);
        },
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
              context, 'MerchantNumVerify', (route) => false);
        },
        child: ListView(
          children: [
            const CustomTextWidget(
                text: 'MY APPLICATIONS', fontWeight: FontWeight.bold, size: 16),

            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.of(context)
            //           .pushNamed('merchantQrCode', arguments: {'params': "200"});
            //     },
            //     child: Text("qrdata")),
            // QRCode(
            //   qrSize: 250,
            //   qrBackgroundColor: Colors.white,
            //   qrPadding: 13,
            //   qrBorderRadius: 10,
            //   qrForegroundColor: Theme.of(context).primaryColor,
            //   qrData:
            //       //"upi://pay?pa=7558877098@apl&pn=Ajo Sebastian&am=500&cu=INR&tn=justForFun",
            //       "000201010212260800043456520499953039785406100.235802IT5907Druidia6005MILAN6233012910000001#QRID00000421##10001#",
            //   gapLess: false,
            //   // embeddedImage: AssetImage("assets/logo.jpg"),
            // ),
            Row(
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: DashboardChart(
                    kycPending: kycPendingCount,
                    paymentPending: paymentPendingCount,
                    deploymentPending: deploymentPendingCount,
                    liveCount: liveCount,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    chartLabels(
                        color: Colors.yellow,
                        label: 'Pending For  Kyc Approval'),
                    chartLabels(
                        color: Colors.cyan, label: 'Pending For payment'),
                    chartLabels(
                        color: Colors.purple, label: 'Pending For Deployment'),
                    chartLabels(color: Colors.green, label: 'Live'),
                  ],
                )
              ],
            ),
//         DropdownButton<int>(
//   value: selectedStatusIndex,
//   onChanged: (int newIndex) {
//     setState(() {
//       selectedStatusIndex = newIndex;
//       printSelectedStatusInfoId();
//     });
//   },
//   items: statusList.map<DropdownMenuItem<int>>((status) {
//     return DropdownMenuItem<int>(
//       value: status["statusInfoId"],
//       child: Text(status["statusName"]),
//     );
//   }).toList(),
// ),
            const SizedBox(
              height: 20,
            ),

            DropdownButtonFormField(
              // hint: const Text('Select Stage'),
              value: selectedValue ?? 0,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.kPrimaryColor),
              items: [
                const DropdownMenuItem(
                  value: 0,
                  child: Text('All'),
                ),
                ...applicationStatus.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value["statusName"].toString()),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                  selectesStage =
                      value == 0 ? 0 : selectedValue["statusInfoId"];

                  getAllMerchantApplications();

                  // packagelist = selectedValue["tmsPackage"];
                  //if(kDebugMode)print(value);
                });
              },
              decoration: InputDecoration(
                label: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    "Select Stage",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                ),
                // hintText:"Select Stage",
                // counterText: counterText ?? '',
                // errorMaxLines: errorMaxLines,
                // helperText: "helperText",
                // errorText: errorText,
                // helperStyle: helperStyle,
                fillColor: AppColors.kTileColor,
                filled: true,

                hintStyle: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.transparent)),
                disabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(color: Colors.transparent)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                prefixIcon:
                    Icon(Icons.storage, color: Theme.of(context).primaryColor),
              ),
            ),

            const SizedBox(
              height: 20,
            ),
            CustomTextFormField(
              title: 'Search with Merchant Name',
              controller: _merchantNameController,
              required: true,
              textCapitalization: TextCapitalization.words,
              // enabled: _firstNameController.text.isEmpty ||
              //         _firstNameController.text.length < 3
              //     ? enabledLast = false
              //     : enabledLast = true,
              // prefixIcon: LineAwesome.user_circle,
              // validator: (value) {
              //   if (value.trim() == null || value.trim().isEmpty) {
              //     return 'Last Name is Mandatory!';
              //   }
              //   if (value.trim().length < 3) {
              //     return 'Minimum 3 characters';
              //   }
              //   return null;
              // },
              onChanged: (String value) {
                value = value.trim();
              },
              onSaved: (value) {
                // registerRequestModel.lastName = value.trim();
              },
              onFieldSubmitted: (value) {
                allOnboardingApplications.clear();
                getAllMerchantApplications();
              },
              suffixIcon: const Icon(Icons.search),
              suffixIconTrue: true,
              suffixIconOnPressed: () {
                setState(() {
                  if (kDebugMode) print("sufix pressed");
                  if (kDebugMode) print(_merchantNameController.text);
                  if (kDebugMode) print(selectesStage.toString());
                  // getAllMerchantApplications();
                  allOnboardingApplications.clear();
                  getAllMerchantApplications();
                });
              },
            ),
            // if (selectedValue != null)
            //   Text(selectedValue["statusInfoId"].toString()),

            loader
                ? Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .1),
                    color: AppColors.white,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                  )
                : allOnboardingApplications.isNotEmpty
                    ? ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                            allOnboardingApplications.length, (index) {
                          return ListTile(
                            leading: Text((index + 1).toString()),
                            title: Row(
                              children: [
                                if (!isSmallScreen)
                                  const CustomTextWidget(
                                      size: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                      text: "Name : "),
                                Expanded(
                                  child: CustomTextWidget(
                                      size: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.kLightGreen,
                                      text: allOnboardingApplications[index]
                                          ["merchantName"]),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (!isSmallScreen)
                                      const CustomTextWidget(
                                          size: 12, text: "Number : "),
                                    CustomTextWidget(
                                        size: 12,
                                        text: allOnboardingApplications[index]
                                                ["mobileNo"] ??
                                            ''),
                                  ],
                                ),
                                // CustomTextWidget(
                                //     size: 12,
                                //     text: allOnboardingApplications[index]
                                //             ["insertDatetime"]
                                //         .toString())
                              ],
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    allOnboardingApplications[index]
                                                ["statusInfoId"] ==
                                            null
                                        ? "Unknown"
                                        : "${allOnboardingApplications[index]["statusInfoId"]["statusName"]}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  InkWell(
                                    child: const CustomTextWidget(
                                        text: "Check Status",
                                        color: AppColors.kPrimaryColor,
                                        size: 12),
                                    onTap: () async {
                                      var response;

                                      response = await _getApplicationStatus(
                                          allOnboardingApplications[index]
                                              ['merchantId']);

                                      if (response == null) return;
                                      if (response['data'].length == 0) return;

                                      // response ??= await _getApplicationStatus(
                                      //     "ADIBM0000000375");

                                      List<Device> _devices = [];

                                      if (response['data'][0][
                                                  'merchantProductDetailsResponse']
                                              ['merchantProductDetails'] !=
                                          null) {
                                        for (var item in response['data'][0][
                                                'merchantProductDetailsResponse']
                                            ['merchantProductDetails']) {
                                          if (kDebugMode) print(item);

                                          _devices.add(Device(
                                            productId: item['productId'],
                                            productName: item['productName'],
                                            pendingQty: item['pendingQty'],
                                            // deploymentStatus:
                                            //     item['deploymentStatus'],

                                            deploymentStatus:
                                                item['pendingQty'] == 0,
                                            package: item['packageId'],
                                            packageId: item['packageId'],
                                            quantity: item['qty'],
                                            price: item['unitPrice'],
                                            merchantId: item['merchantId'],
                                            guid: item['guid'],
                                          ));
                                        }
                                      }

                                      ApplicationStatus dataResponse =
                                          ApplicationStatus(
                                        errorMessage: response['errorMessage'],
                                        statusCode: response['statusCode'],
                                        amountToPay: 200,
                                        kycApproved: response['data'][0]
                                                ['appStatus'] ??
                                            false,

                                        // payment: response['data'][0]
                                        //     ['paymentStatus'],
                                        payment: false,
                                        eNach: response['data'][0]
                                                ['paymentStatus'] ??
                                            false,
                                        midtidGenerated: response['data'][0]
                                                ['onboardingStatus'] ??
                                            false,
                                        allDevicesOnboarded: true,
                                        live: response['data'][0]
                                                ['liveStatus'] ??
                                            true,
                                        devices: _devices,
                                        map: response['map'],
                                        merchantProductDetailsResponse: response[
                                                'data'][0]
                                            ['merchantProductDetailsResponse'],
                                      );

                                      onboardedBool = false;

                                      _showMyDialog(
                                        data: dataResponse,
                                        phoneNumber:
                                            allOnboardingApplications[index]
                                                ["mobileNo"],
                                        name: allOnboardingApplications[index]
                                            ["merchantName"],
                                        merchantId:
                                            allOnboardingApplications[index]
                                                ['merchantId'],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      )
                    : Center(
                        child: Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * .1),
                            child: const SizedBox(
                                child: Text("No Application Found")))),
          ],
        ));
  }

  Row chartLabels({
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
              color: color, border: Border.all(width: 1, color: Colors.black)),
        ),
        const SizedBox(
          width: 10,
        ),
        CustomTextWidget(
          text: label,
          size: 11,
        )
      ],
    );
  }

  getDefaultMerchantValues() async {
    if (kDebugMode) print("----default value called----");
    await userServices.GetMerchantOnboardingValues().then((response) async {
      final Map<String, dynamic> data = json.decode(response.body);

      List<dynamic> applicationStatusFromJson =
          data['data'][0]['merchantOnboardStatus'];

      setState(() {
        applicationStatus = applicationStatusFromJson;
      });

      for (var applications in applicationStatus) {
        String applicationStatusis = applications['statusInfoId'].toString();
        if (kDebugMode) print('Application Status id: $applicationStatusis');
        if (kDebugMode) {
          print('Application Name: ${applications['statusDesc']}');
        }
      }

      if (kDebugMode) print("Total Items${applicationStatus.length}");
    });
  }

  Map<String, dynamic>? getChartCount;

  getAllMerchantApplications() async {
    setState(() {
      loader = true;
    });

    if (kDebugMode) print("----AllMerchantApplications called----");
    await userServices
        .getMerchantApplication(
            stage: selectesStage, merchantname: _merchantNameController.text)
        .then((response) async {
      final Map<String, dynamic> data = json.decode(response.body);

      getChartCount = data['merchantDashboard'];

      List<dynamic> applicationsFromJson = data['data'];

      setState(() {
        allOnboardingApplications = applicationsFromJson.reversed.toList();
        loader = false;
      });

      for (var applications in applicationsFromJson) {
        String applicationStatusis = applications['merchantName'].toString();
        if (kDebugMode) print('merchant Name: $applicationStatusis');
        if (kDebugMode) {
          print('Merchant Mobile number : ${applications['mobileNo']}');
        }
      }

      if (kDebugMode) {
        print("Total Irems" "${allOnboardingApplications.length}");
      }

      // for (var mccGroup in mccGroups) {
      //   String mccGroupId = mccGroup['mccGroupId'].toString();
      //  if(kDebugMode)print('mccGroupId : $mccGroupId');
      // }

      // for (var mccType in mccTypes) {
      //   String acquirerName = mccType['mccTypeDesc'];
      //  if(kDebugMode)print('mccTypeDesc: $acquirerName');
      // }

      // for (var products in tmsProductMaster) {
      //   String acquirerName = products['productName'];
      //  if(kDebugMode)print('productName: $acquirerName');
      // }
      //if(kDebugMode)print("length" + "${tmsProductMaster.length}");
    });
  }

  _getApplicationStatus(merchantId) async {
    if (kDebugMode) print("----getApplicationStatus called   $merchantId");
    var response = await userServices.getMerchantApplicationStatus(merchantId);
    final Map<String, dynamic> data = json.decode(response.body);
    List<dynamic> applicationsFromJson = data['data'] ?? [];
    if (applicationsFromJson.isEmpty) return null;
    if (kDebugMode) print('response before  return$applicationsFromJson');
    return data;
  }

  postMerchantOnBoarding(merchantId) async {
    var response = await userServices.postMerchantOnBoarding(merchantId);
    final Map<String, dynamic> data = json.decode(response.body);

    // Navigator.pop(context);

    // if (context.mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Onboarded Successfully'),
    //       duration: Duration(seconds: 3),
    //     ),
    //   );
    // }

    return data;
  }

  Future<void> _showMyDialog({
    required ApplicationStatus data,
    required String name,
    required String phoneNumber,
    required String merchantId,
  }) async {
    setValues() {}

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateForAlert) {

          void setRemainingQuantities(index, pendingQuantity) {
            setStateForAlert((){
              data.devices![index].pendingQty = pendingQuantity;

              if(pendingQuantity==0){
                data.devices![index].deploymentStatus = true;
              }

            });
          }
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 10),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12.0),
              ),
            ),

            backgroundColor: Colors.white,
            shadowColor: Colors.white,
            surfaceTintColor: Colors.white,

            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              width: MediaQuery.of(context).size.width,
              height: 600,
              child: ListView(
                // mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      InkWell(
                        child: const Icon(Icons.cancel_outlined,
                            size: 30, color: AppColors.kPrimaryColor),
                        onTap: () {
                          setValues();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            phoneNumber,
                            style: const TextStyle(
                                fontSize: 16, fontFamily: 'Mont'),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 20, fontFamily: 'Mont'),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                  TimelineTile(
                    afterLineStyle: LineStyle(
                        color: data.kycApproved == true
                            ? Colors.blue
                            : Colors.grey),
                    alignment: TimelineAlign.manual,
                    lineXY: 0.1,
                    isFirst: true,
                    isLast: false,
                    hasIndicator: true,
                    indicatorStyle: IndicatorStyle(
                      width: 20,
                      color: Colors.white,
                      iconStyle: IconStyle(
                        color: data.kycApproved == true
                            ? Colors.blue
                            : Colors.grey,
                        fontSize: 26,
                        iconData: Icons.radio_button_checked,
                      ),
                    ),
                    endChild: Row(
                      children: [
                        const Text(
                          " Application",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontFamily: 'Mont'),
                        ),
                        const Expanded(child: SizedBox()),
                        statusTextWidget(
                            title: "Kyc", status: data.kycApproved ?? false),
                      ],
                    ),
                  ),
                  TimelineTile(
                    beforeLineStyle: LineStyle(
                        color: data.kycApproved == true
                            ? Colors.blue
                            : Colors.grey),
                    afterLineStyle: LineStyle(
                        color: data.payment! ? Colors.blue : Colors.grey),
                    alignment: TimelineAlign.manual,
                    lineXY: 0.1,
                    indicatorStyle: IndicatorStyle(
                      width: 20,
                      color: Colors.white,
                      iconStyle: IconStyle(
                        color: data.payment == true ? Colors.blue : Colors.grey,
                        fontSize: 26,
                        iconData: Icons.radio_button_checked,
                      ),
                    ),
                    endChild: Row(
                      children: [
                        const Text(
                          " payment",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontFamily: 'Mont'),
                        ),
                        const Expanded(child: SizedBox()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            data.payment!
                                ? statusTextWidget(
                                    title: "Received", status: data.payment!)
                                : ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, "PaymentPage",
                                          arguments: {
                                            "merchantId": merchantId,
                                            "merchantProductDetailsResponse": data
                                                .merchantProductDetailsResponse,
                                            "mobile": phoneNumber,
                                            "name": name
                                          });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      minimumSize: const Size(60.0, 30.0),
                                    ),
                                    child: const Text(
                                      "Collect",
                                      style: TextStyle(color: Colors.white),
                                    )),
                            statusTextWidget(
                                title: "eNACH", status: data.eNach!),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TimelineTile(
                    beforeLineStyle: LineStyle(
                      color: data.eNach! ? Colors.blue : Colors.grey,
                    ),
                    afterLineStyle: LineStyle(
                      color: data.midtidGenerated! ? Colors.blue : Colors.grey,
                    ),
                    alignment: TimelineAlign.manual,
                    lineXY: 0.1,
                    indicatorStyle: IndicatorStyle(
                      width: 20,
                      color: Colors.white,
                      iconStyle: IconStyle(
                        color:
                            data.midtidGenerated! ? Colors.blue : Colors.grey,
                        fontSize: 26,
                        iconData: Icons.radio_button_checked,
                      ),
                    ),
                    endChild: Row(
                      children: [
                        const Text(
                          " Onboarding",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontFamily: 'Mont'),
                        ),
                        const Expanded(child: SizedBox()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!data.midtidGenerated!)
                              ElevatedButton(
                                  onPressed: () async {
                                    var response = await postMerchantOnBoarding(
                                        merchantId);

                                    if (response == null) return;

                                    setStateForAlert(() {
                                      onboardedBool = true;
                                      data.midtidGenerated = true;
                                    });

                                    Future.delayed(const Duration(seconds: 3),
                                        () {
                                      if (mounted) {
                                        try {
                                          setStateForAlert(() {
                                            onboardedBool = false;
                                          });
                                        } catch (_) {}
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    minimumSize: const Size(60.0, 30.0),
                                  ),
                                  child: const Text(
                                    'Onboard',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  )),
                            statusTextWidget(
                                title: "MID/TID",
                                status: data.midtidGenerated!),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TimelineTile(
                    beforeLineStyle: LineStyle(
                      color: data.midtidGenerated! ? Colors.blue : Colors.grey,
                    ),
                    alignment: TimelineAlign.manual,
                    lineXY: 0.1,
                    isFirst: false,
                    isLast: true,
                    indicatorStyle: IndicatorStyle(
                      width: 20,
                      color: Colors.white,
                      iconStyle: IconStyle(
                        color: data.allDevicesOnboarded!
                            ? Colors.blue
                            : Colors.grey,
                        fontSize: 26,
                        iconData: Icons.radio_button_checked,
                      ),
                    ),
                    endChild: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          " Deployment",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontFamily: 'Mont'),
                        ),
                        const Expanded(child: SizedBox()),
                        // if (data.midtidGenerated!)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            data.devices!.length,
                            (index) => data.devices![index].deploymentStatus!
                                ? statusTextWidget(
                                    title: data.devices![index].productName!,
                                    status:
                                        data.devices![index].deploymentStatus!)
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                  "DeviceDeploymentScreen",
                                                  arguments: {
                                                    "productId": data
                                                        .devices![index]
                                                        .productId,
                                                    "packageId": data
                                                        .devices![index]
                                                        .packageId,
                                                    "merchantId": data
                                                        .devices![index]
                                                        .merchantId,
                                                    "guid": data
                                                        .devices![index].guid,
                                                    "productName": data
                                                        .devices![index]
                                                        .productName,
                                                    "deploymentStatus": data
                                                        .devices![index]
                                                        .deploymentStatus,
                                                    "MerchantName": name,
                                                    "phoneNumber": phoneNumber,
                                                    "index": index,
                                                    "pendingQty": data
                                                        .devices![index]
                                                        .pendingQty!,
                                                    "quantity": data
                                                        .devices![index]
                                                        .quantity!,
                                                    "changeFunction":setRemainingQuantities
                                                  });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              minimumSize:
                                                  const Size(60.0, 30.0),
                                            ),
                                            child: Text(
                                              data.devices![index].productName!,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13),
                                            )),
                                        CustomTextWidget(
                                          text:
                                              "Deployed ${data.devices![index].quantity! - data.devices![index].pendingQty!}/${data.devices![index].quantity!}",
                                          size: 10,
                                        )
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          "Status",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF000000),
                              fontFamily: 'Mont'),
                        ),
                        Text(
                          "Live",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF97098D),
                              fontFamily: 'Mont'),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (onboardedBool)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * .025,
                          vertical: MediaQuery.of(context).size.height * .01),
                      decoration: BoxDecoration(
                          color: Colors.black54.withOpacity(.7),
                          borderRadius: BorderRadius.circular(5)),
                      width: double.infinity,
                      child: const Text(
                        'Onboarded Successfully',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    )
                ],
              ),
            ),
            // actions: <Widget>[
            //   TextButton(
            //     child: const Text('Approve'),
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //     },
            //   ),
            // ],
          );
        });
      },
    );
  }

  Row statusTextWidget({
    required String title,
    bool status = true,
  }) =>
      Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF97098D),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          status
              ? Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade800,
                )
              : const Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                ),
        ],
      );

  Column deviceListWidget({
    required String title,
    required int quantity,
    required int pendingQty,
    bool status = true,
  }) =>
      Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF97098D),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              status
                  ? Icon(
                      Icons.check_circle_outline,
                      color: Colors.green.shade800,
                    )
                  : const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                    ),
            ],
          ),
          CustomTextWidget(
              text: "Deployment Status${quantity - pendingQty}/$quantity")
        ],
      );
}

class ChartData {
  final String category;
  final double sales;
  final Color color;

  ChartData(
    this.category,
    this.sales,
    this.color,
  );
}

class DashboardChart extends StatelessWidget {
  final double? kycPending;
  final double? paymentPending;
  final double? deploymentPending;
  final double? liveCount;

  const DashboardChart(
      {super.key,
      this.kycPending,
      this.paymentPending,
      this.deploymentPending,
      this.liveCount});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      series: <CircularSeries>[
        DoughnutSeries<ChartData, String>(
          dataSource: <ChartData>[
            ChartData('Pending For  Kyc Approval', kycPending!, Colors.yellow),
            ChartData('Pending For payment', paymentPending!, Colors.cyan),
            ChartData(
                'Pending For Deployment', deploymentPending!, Colors.purple),
            ChartData('Live', liveCount!, Colors.green),
          ],
          xValueMapper: (ChartData data, _) => data.category,
          yValueMapper: (ChartData data, _) => data.sales,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
          innerRadius: '50%',
          pointColorMapper: (ChartData data, _) => data.color,
          radius: '100%',
        ),
      ],
    );
  }
}
