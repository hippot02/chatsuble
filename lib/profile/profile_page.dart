import 'package:flutter/material.dart';
import 'package:chatsuble/navbar/navbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}
