import 'package:flutter/material.dart';

class ProfileNewScreen extends StatelessWidget {
  const ProfileNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
        ),);
        // body: const Center(child: Text('Profile data will come here')));
  }
}
