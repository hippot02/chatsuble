import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyListTile extends StatelessWidget {
  final String theme;
  final String text;
  final String date;
  final String messageId;

  const MyListTile({
    Key? key,
    required this.theme,
    required this.text,
    required this.date,
    required this.messageId,
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
                      fontSize: 15,
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
        trailing: IconButton(
          icon: Icon(Icons.comment),
          onPressed: () {
            _showCommentsDialog(context, messageId);
          },
        ),
      ),
    );
  }

  void _showCommentsDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return CommentsDialog(messageId: messageId);
      },
    );
  }
}

class CommentsDialog extends StatefulWidget {
  final String messageId;

  CommentsDialog({required this.messageId});

  @override
  _CommentsDialogState createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsDialog> {
  TextEditingController _commentController = TextEditingController();
  List<String> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_comments[index]),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
                height:
                    16), // Ajouter un espace entre la liste de commentaires et le champ de texte
            TextField(
              controller: _commentController,
              decoration: InputDecoration(labelText: 'Ajouter un commentaire'),
            ),
            SizedBox(
                height:
                    16), // Ajouter un espace entre le champ de texte et les boutons
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _addComment(widget.messageId, _commentController.text);
                    _commentController
                        .clear(); // Effacer le champ de commentaire après l'ajout
                    _loadComments(); // Rafraîchir les commentaires après ajout
                  },
                  child: Text('Ajouter'),
                ),
                SizedBox(width: 16), // Ajouter un espace entre les boutons
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Fermer la fenêtre des commentaires
                  },
                  child: Text('Fermer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _loadComments() async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.messageId)
          .get();

      final List<dynamic> comments = snapshot['comments'] ?? [];
      setState(() {
        _comments = comments.cast<String>().toList();
      });
    } catch (e) {
      print('Erreur lors du chargement des commentaires: $e');
      setState(() {
        _comments = [];
      });
    }
  }

  void _addComment(String messageId, String comment) async {
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(messageId)
          .update({
        'comments': FieldValue.arrayUnion([comment]),
      });
    } catch (e) {
      print('Erreur lors de l\'ajout du commentaire: $e');
    }
  }
}
