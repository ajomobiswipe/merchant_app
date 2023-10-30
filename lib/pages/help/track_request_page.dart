import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';

import '../../widgets/app_widget/app_bar_widget.dart';

class TrackRequestPage extends StatefulWidget {
  const TrackRequestPage({Key? key, this.list}) : super(key: key);
  final dynamic list;

  @override
  State<TrackRequestPage> createState() => _TrackRequestPageState();
}

double kTileHeight = 90.0;

class _TrackRequestPageState extends State<TrackRequestPage> {
  bool transaction = false;
  bool withdraw = false;
  bool others = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: "Track request",
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: old(),
    );
  }

  Widget new1() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Date: ",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            DateFormat('dd-MM-yyyy hh:mm:ss a')
                                .format(
                                    DateTime.parse(widget.list['createdon']))
                                .toString(),
                            // DateFormat("dd-MM-yyyy")
                            //     .parse(widget.list['createdon'])
                            //     .toString(),
                            // widget.list['createdon'].toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Complaint ID: ",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.list['id'].toString(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        ]),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget old() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.all(4.0),
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    'Complaint Date',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('dd-MM-yyyy hh:mm:ss a')
                        .format(DateTime.parse(widget.list['createdon']))
                        .toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Complaint Number',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    widget.list['id'].toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Complaint Message',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    widget.list['complaintMessage'].toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                _Timeline1(widget.list),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline1 extends StatelessWidget {
  const _Timeline1(this.list);
  final dynamic list;

  @override
  Widget build(BuildContext context) {
    const data = _TimelineStatus.values;

    return Flexible(
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0,
          connectorTheme: const ConnectorThemeData(
            thickness: 2.0,
            color: Color(0xffd3d3d3),
          ),
          indicatorTheme: const IndicatorThemeData(
            size: 19.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        builder: TimelineTileBuilder.connected(
          contentsBuilder: (_, index) => _EmptyContents(index, list),
          connectorBuilder: (_, index, __) {
            switch (index) {
              case 0:
                return DashedLineConnector(
                  color: list['seenBy'] ? Colors.green : Colors.grey,
                );
              case 1:
                return DashedLineConnector(
                  color: list['executivePhoned'] ? Colors.green : Colors.grey,
                );
              case 2:
                return DashedLineConnector(
                  color:
                      list['forwardToHeadOffice'] ? Colors.green : Colors.grey,
                );
              case 3:
                return DashedLineConnector(
                  color: list['requestResolved'] ? Colors.green : Colors.grey,
                );
            }
            return null;
          },
          indicatorBuilder: (_, index) {
            switch (data[index]) {
              case _TimelineStatus.done:
                return Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: DotIndicator(
                      color: list['seenBy'] ? Colors.green : Colors.indigo,
                      child: list['seenBy']
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10.0,
                            )
                          : Container()),
                );
              case _TimelineStatus.sync:
                return Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: DotIndicator(
                      color:
                          list['executivePhoned'] ? Colors.green : Colors.grey,
                      child: list['executivePhoned']
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10.0,
                            )
                          : Container()),
                );
              case _TimelineStatus.inProgress:
                return Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: DotIndicator(
                      color: list['forwardToHeadOffice']
                          ? Colors.green
                          : Colors.grey,
                      child: list['forwardToHeadOffice']
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10.0,
                            )
                          : Container()),
                );
              case _TimelineStatus.todo:
                return Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: DotIndicator(
                      color:
                          list['requestResolved'] ? Colors.green : Colors.grey,
                      child: list['requestResolved']
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10.0,
                            )
                          : Container()),
                );
              case _TimelineStatus.completed:
                return Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: DotIndicator(
                      color:
                          list['requestcompleted'] ? Colors.green : Colors.grey,
                      child: list['requestcompleted']
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10.0,
                            )
                          : Container()),
                );
              default:
                return const Padding(
                  padding: EdgeInsets.only(left: 12.0, right: 12.0),
                  child: DotIndicator(
                    color: Colors.grey,
                    /*child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10.0,
                    ),*/
                  ),
                );
            }
          },
          itemExtentBuilder: (_, __) => kTileHeight,
          itemCount: data.length,
        ),
      ),
    );
  }
}

class _EmptyContents extends StatelessWidget {
  const _EmptyContents(this.indexs, this.list);
  final int indexs;
  final dynamic list;

  @override
  Widget build(BuildContext context) {
    String text1 = "Complaint has been registered successfully";
    String text2 = "Complaint Number : ${list['id']}";
    if (indexs == 1) {
      text1 = "SIFR team will call you";
      text2 = "SIFR team will call your registered mobile number in 24 hours";
    }
    if (indexs == 2) {
      text1 = "Your complaint forwarded to head office";
      text2 = "your complaint has been registered and forwarded to head office";
    }
    if (indexs == 3) {
      text1 = "Complaint has been resolved";
      text2 = "your complaint has been resolved";
    }
    if (indexs == 4) {
      text1 = "Complaint has been completed";
      text2 = "your complaint has been completed";
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              text1.toString(),
              style: const TextStyle(fontSize: 14.0),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              text2.toString(),
              style: const TextStyle(fontSize: 12.0),
            ),
          ),
        ),
      ],
    );
  }
}

enum _TimelineStatus {
  done,
  sync,
  inProgress,
  todo,
  completed,
}
