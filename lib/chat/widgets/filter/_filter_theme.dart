// _filter_theme.dart
import 'package:flutter/material.dart';

class FilterThemeDialog extends StatefulWidget {
  final String selectedTheme;
  final Function(String) onThemeChanged;

  const FilterThemeDialog({
    Key? key,
    required this.selectedTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _FilterThemeDialogState createState() => _FilterThemeDialogState();
}

class _FilterThemeDialogState extends State<FilterThemeDialog> {
  @override
  Widget build(BuildContext context) {
    final List<String> themes = [
      'Tous les thèmes',
      'Étude',
      'Food',
      'Jeux Vidéo',
      'Cinéma',
      'Sport',
      'Autre'
    ];

    return DropdownButton<String>(
      value: widget.selectedTheme,
      onChanged: (value) {
        widget.onThemeChanged(value!);
      },
      items: themes.map((theme) {
        return DropdownMenuItem<String>(
          value: theme,
          child: Text(theme),
        );
      }).toList(),
    );
  }
}
