import 'package:flutter/material.dart';
import 'package:chatsuble/navbar/navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      bottomNavigationBar: MyBottomNavigationBar(),
    );
  }
}
