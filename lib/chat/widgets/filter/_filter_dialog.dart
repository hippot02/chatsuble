// _filter_dialog.dart
import 'package:chatsuble/chat/widgets/filter/_filter_theme.dart';
import 'package:flutter/material.dart';

class FilterDialog {
  static void show(BuildContext context, String selectedTheme,
      Function(String) onThemeChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filtrer par thème'),
          content: FilterThemeDialog(
            selectedTheme: selectedTheme,
            onThemeChanged: (value) {
              onThemeChanged(value);
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
