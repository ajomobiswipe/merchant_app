import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sifr_latest/storage/secure_storage.dart';
import 'package:timelines/timelines.dart';

import '../../config/config.dart';
import '../../services/user_services.dart';
import '../../services/wallet_services.dart';
import '../../widgets/loading.dart';
import '../../widgets/logout.dart';
import '../../widgets/widget.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  late List data = [];
  late String customerId;
  late bool _isLoading = false;
  UserServices userServices = UserServices();
  Logout logout = Logout();
  WalletService walletService = WalletService();
  CustomAlert customAlert = CustomAlert();
  static const kTileHeight = 73.0;
  List processes = [];

  getCustomerData() async {
    setState(() {
      _isLoading = true;
    });
    BoxStorage boxStorage = BoxStorage();
    customerId = boxStorage.getCustomerId();
    userServices.getUserDetails(customerId).then((result) {
      var response = jsonDecode(result.body);
      setState(() {
        _isLoading = false;
      });
      if (result.statusCode == 200 || result.statusCode == 201) {
        setState(() {
          data = [response['customer']];
        });
      } else if (result.statusCode == 401) {
        setState(() {
          data = [response['customer']];
        });
        AlertService alertService = AlertService();
        alertService.failure(context, "Failed", response['error']);
      } else {
        setState(() {
          data = [];
        });
      }
    });
  }

  getProcessFlowDetails() async {
    setState(() {
      _isLoading = true;
    });
    BoxStorage boxStorage = BoxStorage();
    customerId = boxStorage.getCustomerId();
    userServices.getProcessFlowDetails(customerId).then((result) {
      var response = jsonDecode(result.body);
      setState(() {
        _isLoading = false;
      });
      if (result.statusCode == 200 || result.statusCode == 201) {
        setState(() {
          List data1 = [response['appProcessFlow']];
          generateData(data1);
        });
      }
    });
  }

  @override
  void initState() {
    getCustomerData();
    getProcessFlowDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, 'home');
        return true;
      },
      child: Scaffold(
        appBar: const AppBarWidget(
          title: "My Account",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoading
            ? const LoadingWidget()
            : SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: getCardItem()),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: timeline(),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          Text("Account Settings",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ))
                        ],
                      ),
                    ),
                    Expanded(child: settingList())
                  ],
                ),
              ),
      ),
    );
  }

  Widget getCardItem() {
    return data.isNotEmpty
        ? Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: data[0]['profilePicture'] == null
                      ? Icon(
                          Icons.account_circle,
                          size: 50,
                          color: Theme.of(context).primaryColor,
                        )
                      : CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(
                              Validators.urlDecrypt(data[0]['profilePicture'])),
                        ),
                  textColor: Theme.of(context).primaryColor,
                  title: Text(
                    "${data[0]['firstName']} ${data[0]['lastName']}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data[0]['emailId'].toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  Widget settingList() {
    return ListView(
      physics: const RangeMaintainingScrollPhysics(),
      children: ListTile.divideTiles(context: context, tiles: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, 'profile');
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.supervised_user_circle,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            title: Text('Profile Settings',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
            subtitle: Text(
              'Update your Personal Information',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontSize: 12),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
        ),
        GestureDetector(
          onTap: () {
            checkMpin('account');
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                LineAwesome.building,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            title: Text('Account Settings',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
            subtitle: Text(
              'Add/Manage Accounts',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontSize: 12),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
        ),
        GestureDetector(
          onTap: () {
            checkMpin('Card');
            // Navigator.pushNamed(context, 'card',
            //     arguments: {'type': Constants.card});
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                LineAwesome.credit_card,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            title: Text('Card Settings',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
            subtitle: Text(
              'Add/Manage Cards',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontSize: 12),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, 'securitySettings',
                arguments: data[0]);
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                LineAwesome.user_lock_solid,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            title: Text('Security Settings',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
            subtitle: Text(
              'Manage Password, PIN & MPIN',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontSize: 12),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, 'settings');
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                FontAwesome.gear_solid,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            title: Text('App Settings',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
            subtitle: Text(
              'Manage App Settings',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontSize: 12),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
        ),
      ]).toList(),
    );
  }

  checkMpin(String type) async {
    setState(() {
      _isLoading = true;
    });
    // print(type);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var customerId = prefs.getString('custId').toString();
    var requestModel = {
      "instId": Constants.instId,
      "requestType": "checkmpin",
      "custId": customerId
    };
    walletService.mPin(requestModel).then((result) {
      var response = jsonDecode(result.body);
      if (result.statusCode == 200 || result.statusCode == 201) {
        setState(() {
          _isLoading = false;
        });
        if (response['responseCode'] == "00") {
          if (response['responseMessage'] ==
              "Mpin is not available for this customer") {
            customAlert.displayDialog(context);
          } else {
            if (type == 'account') {
              Navigator.pushNamed(context, 'accounts',
                  arguments: {'type': Constants.account});
            } else {
              Navigator.pushNamed(context, 'cards');
            }
          }
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Widget timeline() {
    final key0 = GlobalKey<State<Tooltip>>();
    final key1 = GlobalKey<State<Tooltip>>();
    final key2 = GlobalKey<State<Tooltip>>();
    final key3 = GlobalKey<State<Tooltip>>();
    final key4 = GlobalKey<State<Tooltip>>();
    final key5 = GlobalKey<State<Tooltip>>();
    final key6 = GlobalKey<State<Tooltip>>();
    final key7 = GlobalKey<State<Tooltip>>();
    final key8 = GlobalKey<State<Tooltip>>();
    final key9 = GlobalKey<State<Tooltip>>();

    List key = [key0, key1, key2, key3, key4];
    List key11 = [key5, key6, key7, key8, key9];
    return SizedBox(
      height: 80,
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          direction: Axis.horizontal,
          connectorTheme: const ConnectorThemeData(
            space: 30.0,
            thickness: 5.0,
          ),
        ),
        builder: TimelineTileBuilder.connected(
          connectionDirection: ConnectionDirection.before,
          itemExtentBuilder: (_, __) => kTileHeight,
          contentsBuilder: (context, index) {
            return Tooltip(
              triggerMode: TooltipTriggerMode.manual,
              showDuration: const Duration(seconds: 1),
              key: key[index],
              message: processes[index]['status'].toString(),
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final dynamic tooltip = key[index].currentState;
                    tooltip?.ensureTooltipVisible();
                  },
                  child: Text(
                    processes[index]['title'].toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            );
          },
          indicatorBuilder: (_, index) {
            MaterialColor color;
            Padding child;
            color =
                processes[index]['checked'] == true ? Colors.green : Colors.red;
            child = const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 15.0,
              ),
            );
            return Tooltip(
              triggerMode: TooltipTriggerMode.manual,
              showDuration: const Duration(seconds: 1),
              key: key11[index],
              message: processes[index]['status'].toString(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  final dynamic tooltip = key11[index].currentState;
                  tooltip?.ensureTooltipVisible();
                },
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(30.0, 30.0),
                      painter: _BezierPainter(
                        color: color,
                        drawStart: index > 0,
                        drawEnd: index < 5,
                      ),
                    ),
                    DotIndicator(
                      size: 30.0,
                      color: color,
                      child: child,
                    ),
                  ],
                ),
              ),
            );
          },
          connectorBuilder: (_, index, type) {
            if (index > 0) {
              if (index == 4) {
                final prevColor = getColor(index - 1, context);
                final color = getColor(index, context);
                List<Color> gradientColors;
                if (type == ConnectorType.start) {
                  gradientColors = [Color.lerp(prevColor, color, 0.5)!, color];
                } else {
                  gradientColors = [
                    prevColor,
                    Color.lerp(prevColor, color, 0.5)!
                  ];
                }
                return DecoratedLineConnector(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                  ),
                );
              } else {
                return SolidLineConnector(
                  color: getColor(index, context),
                );
              }
            } else {
              return null;
            }
          },
          itemCount: processes.length,
        ),
      ),
    );
  }

  Color getColor(int index, BuildContext context) {
    if (index == 5) {
      return const Color(0xff5ec792);
    } else if (index < 5) {
      return Theme.of(context).primaryColor;
    } else {
      return const Color(0xffd1d2d7);
    }
  }

  generateData(List data1) {
    processes = [
      {
        'title': "Registration",
        "checked": data1[0]['registred'],
        'status': data1[0]['registred'] == true
            ? 'Registration Completed'
            : 'Registration Pending'
      },
      {
        'title': "Wallet",
        "checked": data1[0]['iswalletAccGenrated'],
        'status': data1[0]['iswalletAccGenrated'] == true
            ? 'Wallet Account Created'
            : 'Wallet Account Not Created'
      },
      {
        'title': "MPIN",
        "checked": data1[0]['mpinGenerated'],
        'status': data1[0]['mpinGenerated'] == true
            ? 'MPIN Added'
            : 'MPIN Not created'
      },
      {
        'title': "Account/Card",
        "checked": data1[0]['accountcardAdded'],
        'status': data1[0]['accountcardAdded'] == true
            ? 'Account/Card Added'
            : 'Account/Card Not Added'
      },
      {
        'title': "Add Amount",
        "checked": data1[0]['balLoadedToWallet'],
        'status': data1[0]['balLoadedToWallet'] == true
            ? 'Amount Added To Wallet'
            : 'Amount Not Added To Wallet'
      },
    ];
  }
}

class _BezierPainter extends CustomPainter {
  const _BezierPainter({
    required this.color,
    this.drawStart = true,
    this.drawEnd = true,
  });

  final Color color;
  final bool drawStart;
  final bool drawEnd;

  Offset _offset(double radius, double angle) {
    return Offset(
      radius * cos(angle) + radius,
      radius * sin(angle) + radius,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final radius = size.width / 2;

    double angle;
    Offset offset1;
    Offset offset2;

    Path path;

    if (drawStart) {
      angle = 3 * pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);
      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(0.0, size.height / 2, -radius, radius)
        ..quadraticBezierTo(0.0, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
    if (drawEnd) {
      angle = -pi / 4;
      offset1 = _offset(radius, angle);
      offset2 = _offset(radius, -angle);

      path = Path()
        ..moveTo(offset1.dx, offset1.dy)
        ..quadraticBezierTo(
            size.width, size.height / 2, size.width + radius, radius)
        ..quadraticBezierTo(size.width, size.height / 2, offset2.dx, offset2.dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.drawStart != drawStart ||
        oldDelegate.drawEnd != drawEnd;
  }
}
