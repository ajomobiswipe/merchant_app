import 'package:flutter/material.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppAppbar({super.key, this.title = ''});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: CustomTextWidget(text: title),
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
