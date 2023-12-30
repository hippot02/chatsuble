import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class StatefulDialogButton extends StatefulWidget {
  const StatefulDialogButton({Key? key}) : super(key: key);

  @override
  State<StatefulDialogButton> createState() => _StatefulDialogButtonState();
}

class _StatefulDialogButtonState extends State<StatefulDialogButton> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  final TextEditingController _messageController = TextEditingController();

  // Liste d'options pour le thème
  final List<String> _themeOptions = [
    'Monstre',
    'Feur',
    'Chipi Chipi Chapa Chapa Dubi Dubi Daba Daba',
    'Cyprien',
    'La grosse de Yvelin'
  ];
  String _selectedTheme = 'Monstre'; // Thème par défaut

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<Position> getUserLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Erreur lors de l'obtention de la position : $e");
      return Position(
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        timestamp: DateTime.now(),
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }

  void addMessage() async {
    try {
      Position userPosition = await getUserLocation();
      await _messagesCollection.add({
        'theme': _selectedTheme,
        'text': _messageController.text,
        'timestamp': DateTime.now(),
        'latitude': userPosition.latitude,
        'longitude': userPosition.longitude,
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
            title: Text('Nouveau Message'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Utilisez DropdownButtonFormField pour le thème
                  DropdownButtonFormField<String>(
                    value: _selectedTheme,
                    items: _themeOptions.map((String theme) {
                      return DropdownMenuItem<String>(
                        value: theme,
                        child: Text(theme),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedTheme = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Thème',
                      icon: Icon(Icons.theater_comedy),
                    ),
                  ),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.message),
                      hintText: 'Message',
                      labelText: 'Message',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un message';
                      }
                      return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: ElevatedButton(
                      child: const Text('Envoyer'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          addMessage();
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
