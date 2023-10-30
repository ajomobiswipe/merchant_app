import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:sifr_latest/config/constants.dart';
import 'package:sifr_latest/config/global.dart';
import 'package:sifr_latest/storage/secure_storage.dart';

import '../../models/notification_model.dart';
import '../../services/transaction_services.dart';
import '../../widgets/app/alert_service.dart';
import '../../widgets/app_widget/app_bar_widget.dart';
import '../../widgets/loading.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Size size;
  late String customerId;
  late bool _isLoading = false;
  TransactionServices transactionServices = TransactionServices();
  AlertService alertWidget = AlertService();
  List notificationList = [];
  NotificationRequest notificationRequest = NotificationRequest();

  @override
  void initState() {
    getLocalData();
    Future.delayed(Duration.zero, () {
      getNotificationList();
    });
    super.initState();
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  getLocalData() async {
    BoxStorage boxStorage = BoxStorage();
    customerId = boxStorage.getCustomerId();
  }

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pushNamed(context, 'home');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: const AppBarWidget(
          title: "Notification",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoading ? const LoadingWidget() : mainContent(),
      ),
    );
  }

  Widget mainContent() {
    return Center(
      child: notificationList.isEmpty
          ? Global.noDataFound('notification')
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[listContent()],
            ),
    );
  }

  getNotificationList() {
    setLoading(true);
    transactionServices.loadAllNotification(100, customerId).then((response) {
      setLoading(false);
      var decodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        notificationList.clear();
        notificationList = decodeData['content'];
      } else {
        setState(() {
          _isLoading = false;
          notificationList = [];
        });
        alertWidget.failure(
            context, 'Failure', decodeData['message'].toString());
      }
    });
  }

  listContent() {
    return Expanded(
      child: GroupedListView<dynamic, DateTime>(
        elements: notificationList,
        stickyHeaderBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        groupBy: (element) =>
            DateTime.parse(convertDateTimeDisplay(element['createdon'])),
        itemComparator: (item1, item2) =>
            item1['createdon'].compareTo(item2['createdon']),
        groupComparator: (value1, value2) => value1.compareTo(value2),
        order: GroupedListOrder.DESC,
        useStickyGroupSeparators: true,
        groupSeparatorBuilder: (DateTime value) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            convertDateTimeDisplay1(value.toString()),
            textAlign: TextAlign.left,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        itemBuilder: (c, element) {
          return InkWell(
            onTap: () {
              notificationRequest.instId = Constants.instId;
              notificationRequest.custId = customerId;
              notificationRequest.notificationId = element['id'].toString();
              readNotification(notificationRequest);
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: element['messageRed'] == true
                      ? Theme.of(context).primaryColor.withOpacity(0.5)
                      : Theme.of(context).primaryColor,
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 20,
                  )),
              title: Text(
                element['message'],
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.normal, fontSize: 14),
              ),
              subtitle: Text(
                DateFormat('dd-MM-yyyy hh:mm:ss a')
                    .format(DateTime.parse(element['createdon']))
                    .toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.normal, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

  readNotification(NotificationRequest notificationRequest) async {
    transactionServices.notificationRead(notificationRequest).then((response) {
      var decodeData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decodeData['responseCode'].toString() == "00") {
          getNotificationList();
        }
      } else {
        alertWidget.failure(
            context, 'Failure', decodeData['message'].toString());
      }
    });
  }

  String convertDateTimeDisplay(String date) {
    final DateFormat displayFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat serverFormatter = DateFormat('yyyy-MM');
    final DateTime displayDate = displayFormatter.parse(date);
    final String formatted = '${serverFormatter.format(displayDate)}-01';
    return formatted;
  }

  String convertDateTimeDisplay1(String date) {
    final DateFormat displayFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat serverFormatter = DateFormat('MMM yyyy');
    final DateTime displayDate = displayFormatter.parse(date);
    final String formatted = serverFormatter.format(displayDate);
    return formatted;
  }
}
