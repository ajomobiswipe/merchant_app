import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../config/constants.dart';
import '../../services/wallet_services.dart';
import '../../storage/secure_storage.dart';
import '../../widgets/loading.dart';
import '../../widgets/widget.dart';

class SecuritySettings extends StatefulWidget {
  const SecuritySettings({super.key, this.list});
  final dynamic list;

  @override
  State<SecuritySettings> createState() => SecuritySetting();
}

class SecuritySetting extends State<SecuritySettings> {
  late bool _isLoading = false;
  BoxStorage boxStorage = BoxStorage();
  WalletService walletService = WalletService();
  CustomAlert customAlert = CustomAlert();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: "Security Settings",
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        Text("Security Settings",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ))
                      ],
                    ),
                  ),
                  Expanded(child: menuList(context))
                ],
              ),
            ),
    );
  }

  Widget menuList(context) {
    return ListView(
      physics: const RangeMaintainingScrollPhysics(),
      children: ListTile.divideTiles(context: context, tiles: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, 'changePassword',
                arguments: 'Password');
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                FontAwesome.lock_solid,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            title: Text('Update Password',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
            subtitle: Text(
              'Manage Login Password',
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
            Navigator.pushNamed(context, 'changePassword', arguments: 'PIN');
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.pin,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            title: Text('Update PIN',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
            subtitle: Text(
              'Manage PIN',
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
            checkMpin();
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                FontAwesome.key_solid,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            title: Text('Update MPIN',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
            subtitle: Text(
              'Manage MPIN',
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
            Navigator.pushNamed(context, 'emailOrMobileChange', arguments: {
              'type': 'Email ID',
              'list': widget.list
            } /*arguments: 'Email Id'*/);
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.alternate_email,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            title: Text('Update Email ID',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
            subtitle: Text(
              'Manage Email ID',
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
            Navigator.pushNamed(context, 'emailOrMobileChange',
                arguments: {'type': 'Mobile Number', 'list': widget.list});
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(
                Icons.phone,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            title: Text('Update Mobile Number',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
            subtitle: Text(
              'Manage Mobile Number',
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

  checkMpin() async {
    setLoading(true);
    var requestModel = {
      "instId": Constants.instId,
      "requestType": "checkmpin",
      "custId": boxStorage.getCustomerId(),
    };
    walletService.mPin(requestModel).then((result) {
      var response = jsonDecode(result.body);
      if (result.statusCode == 200 || result.statusCode == 201) {
        setLoading(false);
        if (response['responseCode'] == "00") {
          if (response['responseMessage'] ==
              "Mpin is not available for this customer") {
            customAlert.displayDialog(context);
          } else {
            Navigator.pushNamed(context, 'changePassword', arguments: 'MPIN');
          }
        } else {
          setLoading(false);
        }
      } else {
        setLoading(false);
      }
    });
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }
}
