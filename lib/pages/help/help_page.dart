import 'package:flutter/material.dart';

import '../../widgets/app_widget/app_bar_widget.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  late Size size;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, 'home');
        return true;
      },
      child: Scaffold(
        appBar: const AppBarWidget(
          title: "Help",
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Text("Help Menu",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ))
              ],
            ),
          ),
          Expanded(child: helpMenuList())
        ]),
      ),
    );
  }

  Widget helpMenuList() {
    return ListView(
        physics: const RangeMaintainingScrollPhysics(),
        children: ListTile.divideTiles(context: context, tiles: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, 'complaint');
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.edit_note_sharp,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              title: Text('Complaint & Status',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
              subtitle: Text(
                'Raise a complaint, Track request',
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
              Navigator.pushNamed(context, "faq");
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(
                  Icons.dynamic_feed,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              title: Text('FAQ',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
              subtitle: Text(
                'Most customers asked questions & answers',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontSize: 12),
              ),
              trailing: const Icon(Icons.keyboard_arrow_right),
            ),
          ),
        ]).toList());
  }

  Widget items(int position, BuildContext context1) {
    var color = Theme.of(context).primaryColor;
    var iconData = Icons.add;
    String text = 'Raise a complaint';

    switch (position) {
      case 0:
        iconData = Icons.edit_note_sharp;
        text = 'Raise a complaint';
        break;
      case 1:
        iconData = Icons.near_me;
        text = 'Track request';
        break;
      case 2:
        iconData = Icons.dynamic_feed;
        text = 'FAQ';
        break;
    }

    return Builder(builder: (context) {
      return Padding(
        padding:
            const EdgeInsets.only(left: 10.0, right: 10, bottom: 5, top: 5),
        child: Container(
          decoration: const BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20.0)]),
          child: Card(
            elevation: 10,
            color: color,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              side: BorderSide(color: Colors.white),
            ),
            child: InkWell(
              onTap: () {
                if (position == 2) {
                  Navigator.pushNamed(context1, "faq");
                }
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      iconData,
                      size: 40,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        text.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
