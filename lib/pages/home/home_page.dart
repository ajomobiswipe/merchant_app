/* ===============================================================
| Project : SIFR
| Page    : HOME_PAGE.DART
| Date    : 21-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart' as badge;
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_carousel_slider/flutter_custom_carousel_slider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:majascan/majascan.dart';
import 'package:marquee/marquee.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sifr_latest/config/config.dart';

import '../../services/services.dart';
import '../../storage/secure_storage.dart';
import '../../widgets/loading.dart';
import '../../widgets/widget.dart';

// STATEFUL WIDGET
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

// Home State Class
class _HomePageState extends State<HomePage> {
  TransactionServices notificationServices = TransactionServices();
  AlertService alertService = AlertService();
  CustomAlert customAlert = CustomAlert();
  KycService kycService = KycService();
  UserServices userServices = UserServices();
  WalletService walletService = WalletService();
  BoxStorage boxStorage = BoxStorage();

  // LOCAL VARIABLE DECLARATION
  late List<CarouselItem> carouselItem = [];
  String result = "";
  String role = '';
  String customerId = '';
  String kycExpiryAlertMsg = '';
  late bool _isLoading = false;
  int notificationList = 0;
  late bool verifyKycDetail = false;
  bool onOff = true;
  String? mToken = "";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late AndroidNotificationChannel channel;

  // Init function for page Initialization
  @override
  void initState() {
    // disableCapture();
    getUserDetails(); // GET USER DETAILS using Local Storage.
    getSlider(); // GET SLIDER images from SIFR api
    // GET notification list api call delayed function
    Future.delayed(Duration.zero, () {
      allNotificationList(100);
    });
    // requestPermission(); // request FCM mobile app permissions
    // loadFCM(); // LOAD FCM Notification
    // listenFCM(); // Listen FCM Lists
    // getToken(); // GET FCM - mobile token
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Scaffold(
          floatingActionButton:
              role.toString() != 'MERCHANT' ? floatingScanButton() : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: _isLoading
              ? const LoadingWidget()
              : CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      expandedHeight: height * 0.3,
                      automaticallyImplyLeading: false,
                      elevation: 10,
                      pinned: true,
                      systemOverlayStyle: SystemUiOverlayStyle(
                        statusBarColor: Theme.of(context).primaryColor,
                        statusBarIconBrightness: Theme.of(context).brightness,
                        statusBarBrightness: Theme.of(context).brightness,
                      ),
                      actions: [
                        InkWell(
                          onTap: () async {
                            allNotificationList(100);
                            Navigator.pushNamed(context, 'notificationListing');
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 25),
                            child: myAppBarIcon(),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            logout.bottomSheet(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              LineAwesome.sign_out_alt_solid,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        collapseMode: CollapseMode.parallax,
                        background: Center(
                            child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            Image.asset(
                              'assets/screen/pay_cash.png',
                              fit: BoxFit.contain,
                              height: height * 0.25,
                            ),
                          ],
                        )),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, int index) {
                          return menuList();
                        },
                        childCount: 1,
                      ),
                    ),
                  ],
                ),
        ));
  }

  Future<void> disableCapture() async {
    //disable screenshots and record screen in current screen
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  // BACK BUTTON ACTION
  _onWillPop(BuildContext context) async {
    bool? exitResult = customAlert.displayDialogConfirm(context,
        'Please confirm', 'Do you want to exit the app?', onTapConfirm);
    return exitResult ?? false;
  }

  void onTapConfirm() {
    Navigator.of(context).pop(false);
    SystemNavigator.pop();
  }

  // // --- START FCM Push Notification Functions
  // void requestPermission() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;

  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );

  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     //if(kDebugMode)print('User granted permission');
  //   } else if (settings.authorizationStatus ==
  //       AuthorizationStatus.provisional) {
  //     //if(kDebugMode)print('User granted provisional permission');
  //   } else {
  //     //if(kDebugMode)print('User declined or has not accepted permission');
  //   }
  // }

  // // FCM - save token in FCM & SIFR Backend
  // void saveToken(String token) async {
  //   BoxStorage boxStorage = BoxStorage();
  //   String name = boxStorage.getUsername();
  //   await FirebaseFirestore.instance.collection("UserTokens").doc(name).set({
  //     'token': token,
  //   });
  // }

  // // GET FCM - mobile token
  // getToken() async {
  //   mToken = await FirebaseMessaging.instance.getToken();
  //   //if(kDebugMode)print(mToken);
  //   var localToken = boxStorage.getNotificationToken();
  //   var result = localToken.compareTo(mToken);
  //   if (result != 0) {
  //     saveToken(mToken.toString());
  //     boxStorage.setNotificationToken(mToken.toString());
  //     userServices.updatePushToken(
  //         {'notificationToken': mToken.toString()}).then((response) {
  //       setLoading(false);
  //       var decodeData = json.decode(response.body);
  //       //if(kDebugMode)print(decodeData);
  //     });
  //   }
  // }

  // Listen FCM Lists
  // void listenFCM() async {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     RemoteNotification? notification = message.notification;
  //     AndroidNotification? android = message.notification?.android;
  //     if (notification != null && android != null && !kIsWeb) {
  //       flutterLocalNotificationsPlugin.show(
  //         notification.hashCode,
  //         notification.title,
  //         notification.body,
  //         NotificationDetails(
  //             android: AndroidNotificationDetails(
  //               channel.id,
  //               channel.name,
  //               icon: 'launch_background',
  //             ),
  //             iOS: const DarwinNotificationDetails(
  //               presentAlert: true,
  //               presentBadge: true,
  //             )),
  //       );
  //     }
  //   });
  // }

  // // LOAD FCM Notification
  // void loadFCM() async {
  //   if (!kIsWeb) {
  //     channel = const AndroidNotificationChannel(
  //       'high_importance_channel',
  //       'High Importance Notifications',
  //       importance: Importance.high,
  //       enableVibration: true,
  //     );
  //     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //     await flutterLocalNotificationsPlugin
  //         .resolvePlatformSpecificImplementation<
  //             AndroidFlutterLocalNotificationsPlugin>()
  //         ?.createNotificationChannel(channel);
  //     await FirebaseMessaging.instance
  //         .setForegroundNotificationPresentationOptions(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //     );
  //   }
  // }
  // --- END OF FCM Push Notification Functions ---

  // GET USER DETAILS IN LOCAL STORAGE
  getUserDetails() async {
    role = boxStorage.getRole();
    customerId = boxStorage.getCustomerId();
    if (role == "MERCHANT") {
      kycExpiryAlertMsg = boxStorage.getKycAlert();
      onOff = boxStorage.get('merchantStatus') == 'INACTIVE' ? false : true;
    }
  }

  // GET ALL NOTIFICATION LIST
  allNotificationList(size) async {
    setLoading(true);
    notificationServices.loadAllNotification(size, customerId).then((response) {
      setLoading(false);
      var decodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List filterList =
            decodeData['content'].where((i) => !i['messageRed']).toList();
        setState(() {
          notificationList = filterList.length;
        });
      } else {
        setState(() {
          notificationList = 0;
        });
        setLoading(false);
      }
    });
  }

  // DYNAMIC LOADING STATE
  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  // CHECK USER's MPIN AVAILABLE OR NOT.
  checkMpin(String type) async {
    setLoading(true);
    var requestModel = {
      "instId": Constants.instId,
      "requestType": "checkmpin",
      "custId": customerId
    };
    walletService.mPin(requestModel).then((result) {
      var response = jsonDecode(result.body);
      if (result.statusCode == 200 || result.statusCode == 201) {
        if (response['responseCode'] == "00") {
          if (response['responseMessage'] ==
              "Mpin is not available for this customer") {
            setLoading(false);
            customAlert.displayDialog(context);
          } else {
            type == 'wallet'
                ? Navigator.pushNamed(context, "wallet")
                : _scanQR();
            setLoading(false);
          }
        } else {
          setLoading(false);
        }
      } else {
        setLoading(false);
      }
    });
  }

  // SCAN QR CODE FUNCTION
  Future _scanQR() async {
    try {
      String? qrResult = await MajaScan.startScan(
          title: "Scan QR Code",
          titleColor: Colors.white,
          barColor: Theme.of(context).primaryColor,
          qRCornerColor: Theme.of(context).primaryColor,
          qRScannerColor: Theme.of(context).primaryColor);
      setState(() {
        result = qrResult ?? 'null string ';
      });
    } on PlatformException catch (ex) {
      //if(kDebugMode)print("----------");
      //if(kDebugMode)print(ex);
      if (ex.code == MajaScan.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error: $ex";
      });
    }
    if (!mounted) return;
    if (result.isEmpty) {
      alertService.failure(context, 'Failure', 'Invalid QR code');
    }
    //if(kDebugMode)print(result);
    if (result.isNotEmpty) {
      Navigator.pushNamed(context, "withdrawConfirmation",
          arguments: {'scanData': result});
    }
  }

  // GET SLIDER FUNCTIONS
  getSlider() {
    setLoading(true);
    List<CarouselItem> temp = [];
    for (int i = 1; i < 6; i++) {
      temp.add(
        CarouselItem(
          image: CachedNetworkImageProvider(
            '${EndPoints.baseApi8988}${EndPoints.slideUrl}/IMG_$i.PNG',
          ),
        ),
      );
    }
    setState(() {
      carouselItem = temp;
    });
    setLoading(false);
  }

  // DYNAMIC WIDGET FOR HEADER NOTIFICATION ICON ACTIONS
  Widget myAppBarIcon() {
    return badge.Badge(
      badgeContent: Text(
        notificationList.toString(),
        style: const TextStyle(color: Colors.white),
      ),
      position: badge.BadgePosition.topEnd(top: 0, end: -7),
      child: const Icon(
        Icons.notifications,
        color: Colors.white,
        // size: 30,
      ),
    );
  }

  // FLOATING SCAN QR BUTTON FUNCTION
  Widget floatingScanButton() {
    return FloatingActionButton.extended(
      elevation: 12,
      splashColor: Colors.grey,
      onPressed: () {
        checkMpin('');
      },
      tooltip: "Scan QR",
      icon: const Icon(
        Bootstrap.qr_code_scan,
        color: Colors.white,
      ),
      label: const Text(
        'Scan QR',
      ),
    );
  }

  // WIDGET FOR MENU LIST BOTH CUSTOMERS & MERCHANTS
  Widget menuList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        role == "MERCHANT" && kycExpiryAlertMsg != ''
            ? marquee()
            : const SizedBox(
                height: 10.0,
              ),
        firstRowMenu(),
        const SizedBox(
          height: 10.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomCarouselSlider(
            items: carouselItem,
            height: MediaQuery.of(context).size.height * 0.20,
            subHeight: 50,
            width: double.infinity,
            autoplay: true,
            showSubBackground: false,
            indicatorPosition: IndicatorPosition.none,
            showText: false,
          ),
        ),
        const SizedBox(height: 10.0),
        secondRow(),
        const SizedBox(height: 20.0),
      ],
    );
  }

  // WIDGET FOR MARQUEE TEXT for Merchant Documents Expired.
  Widget marquee() {
    return SizedBox(
      height: 30,
      child: Marquee(
        text: kycExpiryAlertMsg,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold, decoration: TextDecoration.none),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        blankSpace: 20.0,
        velocity: 100.0,
        pauseAfterRound: const Duration(seconds: 1),
        startPadding: 10.0,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }

  // WIDGET for FIRST ROW IN HOME PAGE
  Widget firstRowMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        role.toString() != 'MERCHANT'
            ? InkWell(
                onTap: () {
                  checkMpin('');
                },
                child: Card(
                  elevation: 5,
                  shadowColor: const Color(0xffceec7f),
                  color: const Color(0xffceec7f),
                  shape: RoundedRectangleBorder(
                    // side: BorderSide(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Bootstrap.qr_code_scan,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Scan QR",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : InkWell(
                onTap: () {
                  Navigator.pushNamed(context, 'merchantPay');
                },
                child: Card(
                  elevation: 5,
                  shadowColor: const Color(0xffceec7f),
                  color: const Color(0xffceec7f),
                  shape: RoundedRectangleBorder(
                    // side: BorderSide(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Bootstrap.cash_coin,
                            size: 30,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Pay",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, 'myAccount');
          },
          child: Card(
            elevation: 5,
            shadowColor: const Color(0xffffcb66),
            color: const Color(0xffffcb66),
            shape: RoundedRectangleBorder(
              // side: BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            // margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
            child: SizedBox(
              height: 100.0,
              width: 100.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: const Icon(
                      LineAwesome.user,
                      size: 30,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Account",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            // Navigator.pushNamed(context, 'transactionListing');
            Navigator.pushNamed(context, 'QRTransactionListing');
          },
          child: Card(
            elevation: 5,
            shadowColor: const Color(0xfff6bce8),
            color: const Color(0xfff6bce8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              height: 100.0,
              width: 100.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: const Icon(
                      Icons.history_outlined,
                      size: 30,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Transactions",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // WIDGET for SECOND ROW IN HOME PAGE
  Widget secondRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            checkMpin('wallet');
          },
          child: Card(
            elevation: 5,
            shadowColor: const Color(0xff9cc5bb),
            color: const Color(0xff9cc5bb),
            shape: RoundedRectangleBorder(
              // side: BorderSide(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            // margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
            child: SizedBox(
              height: 100.0,
              width: 100.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 30,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "My Wallet",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
        role != 'MERCHANT'
            ? InkWell(
                onTap: () {
                  checkAndRequestLocationPermissions();
                  // getToken();
                  Validators.encrypt("565069534");
                },
                child: Card(
                  elevation: 5,
                  shadowColor: const Color(0xfffca27b),
                  color: const Color(0xfffca27b),
                  shape: RoundedRectangleBorder(
                    // side: BorderSide(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: const Icon(
                            LineAwesome.compass,
                            size: 30,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Nearby",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : InkWell(
                onTap: () {
                  if (onOff) {
                    customAlert.displayDialogConfirm(context, 'Please confirm',
                        'Do you want Activate your account!', onTapConfirm1);
                  } else {
                    customAlert.displayDialogConfirm(context, 'Please confirm',
                        'Do you want Deactivate your account!', onTapConfirm1);
                  }
                },
                child: Card(
                  elevation: 5,
                  shadowColor: onOff
                      ? Colors.red.withOpacity(0.7)
                      : Colors.green.withOpacity(0.7),
                  color: onOff ? Colors.red[200] : Colors.green[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    height: 100.0,
                    width: 100.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: const Icon(
                            FontAwesome.power_off_solid,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          onOff ? "Deactivate" : "Activate",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
              ),
        InkWell(
          onTap: () async {
            Navigator.pushNamed(context, 'help');
            // getToken();
          },
          child: Card(
            elevation: 5,
            shadowColor: const Color(0xff85afe8),
            color: const Color(0xff85afe8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              height: 100.0,
              width: 100.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: const Icon(
                      Bootstrap.question_circle,
                      size: 30,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Help",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // MERCHANT - ACTIVATION & DEACTIVATION FUNCTIONS
  void onTapConfirm1() {
    setLoading(true);
    setState(() {
      if (onOff) {
        setState(() {
          onOff = false;
        });
      } else {
        onOff = true;
      }
    });
    var params = {"merchantId": boxStorage.getMerchantId(), "status": onOff};
    userServices.updateMerchantStatus(params).then((result) {
      var response = jsonDecode(result.body);
      if (result.statusCode == 200 || result.statusCode == 201) {
        setLoading(false);
        boxStorage.save('merchantStatus', onOff ? 'ACTIVE' : 'INACTIVE');
      } else {
        setLoading(false);
      }
    });
    Navigator.of(context).pop();
  }

  // CHECKING THE LOCATION PERMISSION
  checkAndRequestLocationPermissions() async {
    var status = await Permission.location.status;
    //if(kDebugMode)print(status);
    Navigator.pushNamed(context, 'nearByLocation');

    // if (!status.isGranted) {
    //   openAppSettings();
    // } else {
    //   Navigator.pushNamed(context, 'nearByLocation');
    // }
  }
}
