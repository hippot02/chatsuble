import 'package:flutter/material.dart';
import 'package:chatsuble/chat/widgets/_list_tile.dart';
import 'package:chatsuble/chat/widgets/_stateful_dialog_button.dart';
import 'package:chatsuble/chat/widgets/filter/_filter_dialog.dart';
import 'package:chatsuble/chat/widgets/filter/filter_button.dart';
import '_message_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePageContent extends StatefulWidget {
  final String selectedTheme;
  final Function(String) onThemeChanged;

  const HomePageContent({
    Key? key,
    required this.selectedTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Messages'),
        actions: [
          FilterButton(
            onPressed: () {
              FilterDialog.show(
                  context, widget.selectedTheme, widget.onThemeChanged);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: getMessages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Erreur: ${snapshot.error}');
                    } else {
                      final List<Map<String, dynamic>> messages =
                          snapshot.data!;
                      final filteredMessages =
                          widget.selectedTheme == 'Tous les thèmes'
                              ? messages
                              : messages
                                  .where((message) =>
                                      message['theme'] == widget.selectedTheme)
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

                          final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                              .format(messageTime);

                          return MyListTile(
                            theme: messageTheme,
                            text: messageText,
                            date: formattedDate,
                            messageId: data['messageId'],
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
      ),
      floatingActionButton: StatefulDialogButton(
        notifyParent: refresh,
      ),
    );
  }
}
