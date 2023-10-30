/* ===============================================================
| Project : SIFR
| Page    : APP_BAR_WIDGET.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import '../logout.dart';

Logout logout = Logout();

// App Bar Widget Class
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  // LOCAL VARIABLE DECLARATION
  final String title;
  final bool? automaticallyImplyLeading;
  final bool? action;
  final double? elevation;

  const AppBarWidget(
      {Key? key,
      required this.title,
      this.automaticallyImplyLeading,
      this.action,
      this.elevation})
      : super(key: key);

  // Get Preferred Size For App Bar Widget
  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).primaryColor,
        statusBarIconBrightness: Theme.of(context).brightness,
        statusBarBrightness: Theme.of(context).brightness,
      ),
      centerTitle: true,
      // backgroundColor: Colors.red,
      shadowColor: Theme.of(context).primaryColor,
      elevation: elevation ?? 5,
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Colors.white),
      ),
      actions: [
        action == false
            ? Container()
            : InkWell(
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
    );
  }
}
