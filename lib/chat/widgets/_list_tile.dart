import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String theme;
  final String text;
  final String date;

  const MyListTile(
      {super.key, required this.theme, required this.text, required this.date});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        children: [
          Text(theme),
          Text(text),
        ],
      ),
      subtitle: Text('Envoyé le $date'),
    );
  }
}
