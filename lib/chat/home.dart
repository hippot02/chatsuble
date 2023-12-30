import 'package:chatsuble/chat/widgets/_list_tile.dart';
import 'package:chatsuble/chat/widgets/_stateful_dialog_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatsuble/profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
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
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CollectionReference messagesCollection =
        FirebaseFirestore.instance.collection('messages');

    return Scaffold(
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: messagesCollection
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Erreur: ${snapshot.error}');
            } else {
              final List<DocumentSnapshot> documents = snapshot.data!.docs;
              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> data =
                      documents[index].data() as Map<String, dynamic>;
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
      floatingActionButton: const StatefulDialogButton(),
    );
  }
}
