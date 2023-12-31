import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String theme;
  final String text;
  final String date;

  const MyListTile({
    Key? key,
    required this.theme,
    required this.text,
    required this.date,
  }) : super(key: key);

  Color getThemeColor(String theme) {
    switch (theme) {
      case 'Étude':
        return Colors.blue;
      case 'Food':
        return Colors.green;
      case 'Jeux Vidéo':
        return Colors.orange;
      case 'Cinéma':
        return Colors.deepPurple;
      case 'Sport':
        return Colors.yellow;
      case 'Autre':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = getThemeColor(theme);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: themeColor,
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                      fontSize:
                          15, // Ajustez la taille du titre selon vos préférences
                    ),
                children: [
                  TextSpan(
                    text: theme,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text('Message: $text', style: const TextStyle(color: Colors.white)),
          ],
        ),
        subtitle: Text('Envoyé le $date',
            style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
