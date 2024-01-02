import 'package:chatsuble/chat/_message_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class StatefulDialogButton extends StatefulWidget {
  final Function() notifyParent;
  const StatefulDialogButton({super.key, required this.notifyParent});

  @override
  State<StatefulDialogButton> createState() => _StatefulDialogButtonState();
}

class _StatefulDialogButtonState extends State<StatefulDialogButton> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  final _messageController = TextEditingController();

  // Liste des thèmes prédéfinis
  final List<String> themes = [
    'Étude',
    'Food',
    'Jeux Vidéo',
    'Cinéma',
    'Sport',
    'Autre'
  ];
  String selectedTheme = 'Étude'; // Thème par défaut

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
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void addMessage() async {
    try {
      Position userPosition = await getUserLocation();

      await messagesCollection.add({
        'theme': selectedTheme,
        'text': _messageController.text,
        'timestamp': DateTime.now(),
        'latitude': userPosition.latitude,
        'longitude': userPosition.longitude,
      });
      print('Message ajouté avec succès à Firestore!');
      widget.notifyParent();
      Navigator.of(context)
          .pop(true); // Ferme la fenêtre de dialogue avec une valeur true
    } catch (e) {
      print('Erreur lors de l\'ajout du message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        bool? result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  right: -40,
                  top: -40,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop(
                          false); // Ferme la fenêtre de dialogue avec une valeur false
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close),
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        value: selectedTheme,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedTheme = newValue!;
                          });
                        },
                        items: themes
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: getThemeColor(value),
                                  radius: 10,
                                ),
                                const SizedBox(width: 8),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.theater_comedy),
                          labelText: "Thème",
                        ),
                      ),
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.message),
                          hintText: "Message",
                          labelText: "Message",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          child: const Text('Envoyer'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              addMessage();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        if (result != null && result) {
          // Si la fenêtre de dialogue est fermée avec une valeur true, rafraîchissez la liste des messages
          // Mettez ici votre logique de rafraîchissement
        }
      },
      child: const Icon(Icons.add),
    );
  }
}
