import 'package:flutter/material.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? onPressed;
  const AppAppbar({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onPressed,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
