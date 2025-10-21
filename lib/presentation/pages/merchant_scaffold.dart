import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/form_field/custom_dropdown.dart';
import 'package:anet_merchant_app/presentation/widgets/logout.dart';
import 'package:anet_merchant_app/tools/inapp_update_test.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';

class MerchantScaffold extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onNotificationPressed;
  final FloatingActionButton? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Function()? onTapSupport;
  final Function()? onTapHome;

  final bool canPop;
  final bool showStoreName;

  const MerchantScaffold({
    super.key,
    required this.child,
    this.padding,
    this.onMenuPressed,
    this.onProfilePressed,
    this.onNotificationPressed,
    this.canPop = true,
    this.floatingActionButton,
    this.onTapSupport,
    this.onTapHome,
    this.showStoreName = false,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButtonLocation: floatingActionButtonLocation,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        // leading: Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     IconButton(
        //       icon: const Icon(Icons.menu),
        //       onPressed: onMenuPressed,
        //     ),
        //     // IconButton(
        //     //   icon: const Icon(Icons.person),
        //     //   onPressed: onProfilePressed,
        //     // ),
        //   ],
        // ),
        centerTitle: true,
        title: Image.asset(
          "assets/screen/anet_launcher_icon.png",
          height: 40,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
            onLongPress: () {
              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const InAppUpdateScreen(),
                ),
              );
            },
            // onPressed: onNotificationPressed,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Logout().logoutWarningDialog(
                context: context,
                title: "Logout",
              );
            },
          ),
        ],
        automaticallyImplyLeading: true,
        // leading: Builder(
        //   builder: (context) {
        //     return IconButton(
        //       icon: const Icon(Icons.menu),
        //       onPressed: () => Scaffold.of(context).openDrawer(),
        //     );
        //   },
        // ),
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       UserAccountsDrawerHeader(
      //         accountEmail: null,
      //         accountName: null,
      //         currentAccountPicture: CircleAvatar(
      //             // backgroundImage: NetworkImage(
      //             //   Provider.of<AuthProvider>(context).merchantProfileUrl,
      //             // ),
      //             ),
      //         decoration: BoxDecoration(
      //           color: Colors.blue,
      //         ),
      //       ),
      //       ListTile(
      //         title: const Text("Dashboard"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           onTapHome?.call();
      //         },
      //       ),
      //       ListTile(
      //         title: const Text("Support"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           onTapSupport?.call();
      //         },
      //       ),
      //       ListTile(
      //         title: const Text("Logout"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Logout().logoutWarningDialog(
      //             context: context,
      //             title: "Logout",
      //           );
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: Padding(
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.01,
            ),
        child: Column(
          children: [
            if (showStoreName)
              Consumer<AuthProvider>(
                builder: (context, provider, child) {
                  if ((provider.merchantIds != null &&
                          provider.merchantIds!.isNotEmpty) ||
                      (provider.merchantIds is List &&
                          provider.merchantIds!.isNotEmpty)) {
                    print('provider.merchantIds is ${provider.merchantIds}');
                    return DropdownButtonFormField<dynamic>(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      isDense: true,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.kPrimaryColor,
                      ),
                      decoration: commonInputDecoration(
                        hintText: "select one",
                        Icons.maps_home_work_outlined,
                      ),
                      // value: provider.selectedQuickAction,
                      items: provider.merchantIds!.map((entry) {
                        return DropdownMenuItem<dynamic>(
                          value: entry,
                          child: CustomTextWidget(text: entry['shopName']),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        // setState(() {
                        Provider.of<AuthProvider>(context, listen: false)
                            .setMerchantDbaName(newValue!['shopName']);
                        // Update the provider with the selected value
                        // });
                      },
                    );
                  }
                  return Row(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.6,
                        child: CustomTextWidget(
                          size: 14,
                          text: Provider.of<AuthProvider>(context)
                              .merchantDbaName,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  );
                },
              ),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        padding: EdgeInsets.all(0),
        shape: CircularNotchedRectangle(),
        notchMargin: 0,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: onTapHome,
              child: Column(
                children: [
                  Icon(Icons.home),
                  CustomTextWidget(text: "Home", size: 12),
                ],
              ),
            ),
            SizedBox(width: 48), // Space between the icons
            InkWell(
              onTap: onTapSupport,
              child: Column(
                children: [
                  Icon(Icons.support_agent),
                  CustomTextWidget(text: "Support", size: 12),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
