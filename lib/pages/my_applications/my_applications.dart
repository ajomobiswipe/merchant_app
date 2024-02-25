import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sifr_latest/services/services.dart';
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
                  // print(value);
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
                // _lastNameController.text = value.trim();
              },
              suffixIcon: Icon(Icons.search),
              suffixIconTrue: true,
              suffixIconOnPressed: () {
                setState(() {
                  print("sufix pressed");
                  print(_merchantNameController.text);
                  print(selectesStage);
                  // getAllMerchantApplications();
                  allOnboardingApplications.clear();
                  getAllMerchantApplications();
                });
              },
            ),
            // if (selectedValue != null)
            //   Text(selectedValue["statusInfoId"].toString()),

            allOnboardingApplications.isNotEmpty
                ? ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(allOnboardingApplications.length,
                        (index) {
                      return ListTile(
                        leading: Text((index + 1).toString()),
                        title: Row(
                          children: [
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

                                  if (response['data'][0]
                                              ['merchantProductDetailsResponse']
                                          ['merchantProductDetails'] !=
                                      null) {
                                    for (var item in response['data'][0]
                                            ['merchantProductDetailsResponse']
                                        ['merchantProductDetails']) {
                                      print(item);

                                      _devices.add(Device(
                                        productId: item['productId'],
                                        productName: item['productName'],
                                        deploymentStatus:
                                            item['deploymentStatus'],
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
                                    live: response['data'][0]['liveStatus'] ??
                                        true,
                                    devices: _devices,
                                    map: response['map'],
                                    merchantProductDetailsResponse:
                                        response['data'][0]
                                            ['merchantProductDetailsResponse'],
                                  );

                                  _showMyDialog(
                                      data: dataResponse,
                                      phoneNumber:
                                          allOnboardingApplications[index]
                                              ["mobileNo"],
                                      name: allOnboardingApplications[index]
                                          ["merchantName"],
                                      merchantId:
                                          allOnboardingApplications[index]
                                              ['merchantId']);
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
    print("----default value called----");
    await userServices.GetMerchantOnboardingValues().then((response) async {
      final Map<String, dynamic> data = json.decode(response.body);
      // List<dynamic> acquirerDetails =
      //     data['data'][0]['acquirerAcquirerDetails'];
      // List<dynamic> mccGroups = data['data'][0]['tmsMasterMccGroup'];
      // List<dynamic> mccTypes = data['data'][0]['tmsMasterMccTypes'];
      // List<dynamic> tmsMasterCountries = data['data'][0]['tmsMasterCountries'];
      // List<dynamic> tmsMasterCities = data['data'][0]['tmsMasterCities'];
      // List<dynamic> tmsMasterCurrencies =
      //     data['data'][0]['tmsMasterCurrencies'];
      List<dynamic> applicationStatusFromJson =
          data['data'][0]['merchantOnboardStatus'];

      //       var countries = List<String>.from(data['data'][0]['tmsMasterCountries']
      //     .map((item) => item['countryName']));
      // cities = List<String>.from(
      //     data['data'][0]['tmsMasterCities'].map((item) => item['cityName']));
      // currencies = List<String>.from(data['data'][0]['tmsMasterCurrencies']
      //     .map((item) => item['currencyDesc']));

      setState(() {
        applicationStatus = applicationStatusFromJson;
        // mmcGroupList = mccGroups;
        // mmcTypeList = mccTypes;
        // tmsMasterCountriesList = tmsMasterCountries;
        // tmsMasterCitiesList = tmsMasterCities;
        // tmsMasterCurrenciesList = tmsMasterCurrencies;
        // tmsProductMasterlist = tmsProductMaster;

        // countryList = decodeData['responseValue']['list'];
        // if (countryList.isNotEmpty) {
        //   selectedCountries = countryList[0]['ctyName'].toString();
        //   requestModel.country = selectedCountries;
        //   requestModel.currencyId =
        //       countryList[0]['currencyCode'].toString();
        //   getState(countryList[0]['id'].toString());
        // }
        //userServices.getAcqApplicationid('1');
      });

      for (var applications in applicationStatus) {
        String applicationStatusis = applications['statusInfoId'].toString();
        print('Application Status id: $applicationStatusis');
        print('Application Name: ${applications['statusDesc']}');
      }

      print("Total Items${applicationStatus.length}");

      // for (var mccGroup in mccGroups) {
      //   String mccGroupId = mccGroup['mccGroupId'].toString();
      //   print('mccGroupId : $mccGroupId');
      // }

      // for (var mccType in mccTypes) {
      //   String acquirerName = mccType['mccTypeDesc'];
      //   print('mccTypeDesc: $acquirerName');
      // }

      // for (var products in tmsProductMaster) {
      //   String acquirerName = products['productName'];
      //   print('productName: $acquirerName');
      // }
      // print("length" + "${tmsProductMaster.length}");
    });
  }

  Map<String, dynamic>? getChartCount;

  getAllMerchantApplications() async {
    print("----AllMerchantApplications called----");
    await userServices
        .getMerchantApplication(
            stage: selectesStage, merchantname: _merchantNameController.text)
        .then((response) async {
      final Map<String, dynamic> data = json.decode(response.body);

      getChartCount = data['merchantDashboard'];

      List<dynamic> applicationsFromJson = data['data'];

      setState(() {
        allOnboardingApplications = applicationsFromJson;
      });

      for (var applications in applicationsFromJson) {
        String applicationStatusis = applications['merchantName'].toString();
        print('merchant Name: $applicationStatusis');
        print('Merchant Mobile number : ${applications['mobileNo']}');
      }

      print("Total Irems" "${allOnboardingApplications.length}");

      // for (var mccGroup in mccGroups) {
      //   String mccGroupId = mccGroup['mccGroupId'].toString();
      //   print('mccGroupId : $mccGroupId');
      // }

      // for (var mccType in mccTypes) {
      //   String acquirerName = mccType['mccTypeDesc'];
      //   print('mccTypeDesc: $acquirerName');
      // }

      // for (var products in tmsProductMaster) {
      //   String acquirerName = products['productName'];
      //   print('productName: $acquirerName');
      // }
      // print("length" + "${tmsProductMaster.length}");
    });
  }

  _getApplicationStatus(merchantId) async {
    print("----AllMerchantApplications called$merchantId");
    var response = await userServices.getMerchantApplicationStatus(merchantId);
    final Map<String, dynamic> data = json.decode(response.body);
    List<dynamic> applicationsFromJson = data['data'] ?? [];
    if (applicationsFromJson.isEmpty) return null;
    print('response before  return$applicationsFromJson');
    return data;
  }

  postMerchantOnBoarding(merchantId) async {
    var response = await userServices.postMerchantOnBoarding(merchantId);
    final Map<String, dynamic> data = json.decode(response.body);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Onboarded Successfully'),
        duration: Duration(seconds: 3),
      ),
    );

    return data;
  }

  Future<void> _showMyDialog({
    required ApplicationStatus data,
    required String name,
    required String phoneNumber,
    required String merchantId,
  }) async {
    //if(data.devices!.isNotEmpty)
    return showDialog<void>(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phoneNumber,
                      style: const TextStyle(fontSize: 16,fontFamily: 'Mont'),
                    ),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 20,fontFamily: 'Mont'),
                    ),
                  ],
                ),
              ),
              // const Expanded(child: SizedBox()),
              IconButton(
                icon:
                    const Icon(Icons.cancel_outlined, color: Color(0xFF97098D)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
          content: SizedBox(
            height: 600,
            width: MediaQuery.of(context).size.width * .8,
            child: ListView(
              shrinkWrap: true,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TimelineTile(
                  afterLineStyle: LineStyle(
                      color:
                          data.kycApproved == true ? Colors.blue : Colors.grey),
                  alignment: TimelineAlign.manual,
                  lineXY: 0.1,
                  isFirst: true,
                  isLast: false,
                  hasIndicator: true,
                  indicatorStyle: IndicatorStyle(
                    width: 20,
                    color: Colors.white,
                    iconStyle: IconStyle(
                      color:
                          data.kycApproved == true ? Colors.blue : Colors.grey,
                      fontSize: 26,
                      iconData: Icons.radio_button_checked,
                    ),
                  ),
                  endChild: Row(
                    children: [
                      const Text(
                        " Application",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                            fontFamily: 'Mont'
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Expanded(
                        child: statusTextWidget(
                            title: "Kyc", status: data.kycApproved ?? false),
                      ),
                    ],
                  ),
                ),
                TimelineTile(
                  beforeLineStyle: LineStyle(
                      color:
                          data.kycApproved == true ? Colors.blue : Colors.grey),
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
                          fontWeight: FontWeight.bold, fontFamily: 'Mont'
                        ),
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
                                    Navigator.pushNamed(context, "PaymentPage",
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
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    minimumSize: Size(60.0, 30.0),
                                  ),
                                  child: const Text(
                                    "Collect",
                                    style: TextStyle(color: Colors.white),
                                  )),
                          statusTextWidget(title: "eNACH", status: data.eNach!),
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
                      color: data.midtidGenerated! ? Colors.blue : Colors.grey,
                      fontSize: 26,
                      iconData: Icons.radio_button_checked,
                    ),
                  ),
                  endChild: Row(
                    children: [
                      Text(
                        " Onboarding",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                            fontFamily: 'Mont'
                        ),
                      ),
                      Expanded(child: SizedBox()),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!data.midtidGenerated!)
                            ElevatedButton(
                                onPressed: () {
                                  postMerchantOnBoarding(merchantId);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  minimumSize: const Size(60.0, 30.0),
                                ),
                                child: const Text(
                                  'Onbaord',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                )),
                          statusTextWidget(
                              title: "MID/TID", status: data.midtidGenerated!),
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
                      color:
                          data.allDevicesOnboarded! ? Colors.blue : Colors.grey,
                      fontSize: 26,
                      iconData: Icons.radio_button_checked,
                    ),
                  ),
                  endChild: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        " Deployment",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                            fontFamily: 'Mont'
                        ),
                      ),

                      // if (data.midtidGenerated!)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            data.devices!.length,
                            (index) => SizedBox(
                              child: data.devices![index].deploymentStatus!
                                  ? statusTextWidget(
                                      title: data.devices![index].productName!,
                                      status: data
                                          .devices![index].deploymentStatus!)
                                  : ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, "DeviceDeploymentScreen",
                                            arguments: {
                                              "productId": data
                                                  .devices![index].productId,
                                              "packageId": data
                                                  .devices![index].packageId,
                                              "merchantId": data
                                                  .devices![index].merchantId,
                                              "guid": data.devices![index].guid,
                                              "productName": data
                                                  .devices![index].productName,
                                              "deploymentStatus": data
                                                  .devices![index]
                                                  .deploymentStatus,
                                              "MerchantName": name,
                                              "phoneNumber": phoneNumber,
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
                                      child: Text(
                                        data.devices![index].productName!,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13),
                                      )),
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //   height: 100,
                      //   width: 250,
                      //   child: Column(
                      //     children: [
                      //       ListView.builder(
                      //         shrinkWrap: true,
                      //         itemCount: data.devices!.length,
                      //         itemBuilder: (context, index) {
                      //           // Build a ListTile for each user
                      //           return Text(data.devices![index].productName!);
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // )
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.end,
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Expanded(
                      //       child: ListView.builder(
                      //         shrinkWrap: true,
                      //         itemCount: data.devices!.length,
                      //         itemBuilder: (context, index) {
                      //           // Build a ListTile for each user
                      //           return Text(data.devices![index].productName!);
                      //         },
                      //       ),
                      //     ),
                      //     statusTextWidget(title: "Sound Box"),
                      //     statusTextWidget(title: "Android Pos"),
                      //   ],
                      // ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Status",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF000000), fontFamily: 'Mont'),
                    ),
                    Text(
                      "Live",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF97098D), fontFamily: 'Mont'),
                    )
                  ],
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
          dataLabelSettings: DataLabelSettings(isVisible: true),
          innerRadius: '50%',
          pointColorMapper: (ChartData data, _) => data.color,
          radius: '100%',
        ),
      ],
    );
  }
}
