import 'package:chatsuble/chat/widgets/_list_tile.dart';
import 'package:chatsuble/chat/widgets/_stateful_dialog_button.dart';
import 'package:chatsuble/chat/widgets/filter/_filter_dialog.dart';
import 'package:chatsuble/chat/widgets/filter/filter_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatsuble/profile/profile_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _selectedTheme = 'Tous les thèmes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0
          ? HomePageContent(
              selectedTheme: _selectedTheme, onThemeChanged: _onThemeChanged)
          : const ProfilePage(),
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

  void _onThemeChanged(String value) {
    setState(() {
      _selectedTheme = value;
    });
  }
}

class HomePageContent extends StatelessWidget {
  final String selectedTheme;
  final Function(String) onThemeChanged;

  const HomePageContent({
    Key? key,
    required this.selectedTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Messages'),
        actions: [
          FilterButton(
            onPressed: () {
              FilterDialog.show(context, selectedTheme, onThemeChanged);
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
                    final filteredMessages = selectedTheme == 'Tous les thèmes'
                        ? messages
                        : messages
                            .where(
                                (message) => message['theme'] == selectedTheme)
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

                        final formattedDate =
                            DateFormat('dd/MM/yyyy HH:mm').format(messageTime);

                        return MyListTile(
                          theme: messageTheme,
                          text: messageText,
                          date: formattedDate,
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
      floatingActionButton: const StatefulDialogButton(),
    );
  }

  Future<List<Map<String, dynamic>>> _getMessages() async {
    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('messages');

    final QuerySnapshot snapshot = await messagesCollection.get();
    List<Map<String, dynamic>> messages =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    messages.sort((a, b) {
      final DateTime dateTimeA = (a['timestamp'] as Timestamp).toDate();
      final DateTime dateTimeB = (b['timestamp'] as Timestamp).toDate();

      return dateTimeB.compareTo(dateTimeA);
    });

    return messages;
  }
}
