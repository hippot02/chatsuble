import 'package:chatsuble/chat/widgets/_list_tile.dart';
import 'package:chatsuble/chat/widgets/_stateful_dialog_button.dart';
import 'package:flutter/material.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
