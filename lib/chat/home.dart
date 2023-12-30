import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatsuble/profile/profile_page.dart';
import 'package:chatsuble/chat/widgets/_list_tile.dart';
import 'package:chatsuble/chat/widgets/_stateful_dialog_button.dart';
import 'package:chatsuble/chat/widgets/filter/_filter_dialog.dart';
import 'package:chatsuble/chat/widgets/filter/filter_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedTheme = 'Tous les thèmes'; // Thème par défaut
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Messages'),
        actions: [
          FilterButton(
            onPressed: () {
              FilterDialog.show(context, _selectedTheme, (value) {
                setState(() {
                  _selectedTheme = value;
                });
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  } else {
                    final List<Map<String, dynamic>> messages = snapshot.data!;
                    final filteredMessages = _selectedTheme == 'Tous les thèmes'
                        ? messages
                        : messages
                            .where(
                                (message) => message['theme'] == _selectedTheme)
                            .toList();

                    return ListView.builder(
                      itemCount: filteredMessages.length,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> data =
                            filteredMessages[index];
                        final String messageText = data['text'] ?? '';
                        final String messageTheme = data['theme'] ?? '';
                        final DateTime messageTime =
                            (data['timestamp'] as Timestamp).toDate();

                        return MyListTile(
                          theme: messageTheme,
                          text: messageText,
                          date: messageTime.toString(),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getMessages() async {
    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('messages');

    final QuerySnapshot snapshot = await messagesCollection.get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
