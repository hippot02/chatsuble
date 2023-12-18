import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatefulDialogButton extends StatefulWidget {
  const StatefulDialogButton({super.key});

  @override
  State<StatefulDialogButton> createState() => _StatefulDialogButtonState();
}

class _StatefulDialogButtonState extends State<StatefulDialogButton> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  final _themeController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _themeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void addMessage() async {
    try {
      await messagesCollection.add({
        'theme': _themeController.text,
        'text': _messageController.text,
        'timestamp': DateTime.now(),
      });
      print('Message ajouté avec succès à Firestore!');
    } catch (e) {
      print('Erreur lors de l\'ajout du message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await showDialog<void>(
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
                            Navigator.of(context).pop();
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
                            TextFormField(
                              controller: _themeController,
                              decoration: const InputDecoration(
                                  icon: Icon(
                                    Icons.theater_comedy,
                                  ),
                                  hintText: "Thème",
                                  labelText: "Thème"),
                            ),
                            TextFormField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                  icon: Icon(
                                    Icons.message,
                                  ),
                                  hintText: "Message",
                                  labelText: "Message"),
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
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ));
      },
      child: const Icon(Icons.add),
    );
  }
}