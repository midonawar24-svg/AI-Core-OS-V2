import 'package:flutter/material.dart';
import '../models/conversation.dart';

class ChatScreen extends StatelessWidget {
  final List<Conversation> conversations;
  const ChatScreen({super.key, required this.conversations});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (ctx, i) {
        final c = conversations[i];
        return Column(children: [
          Align(alignment: Alignment.centerRight, child: Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.deepPurpleAccent.withOpacity(0.25), borderRadius: BorderRadius.circular(12)), child: Text(c.input, style: const TextStyle(fontSize: 12)))),
          Align(alignment: Alignment.centerLeft, child: Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)), child: Text(c.output, style: const TextStyle(fontSize: 12, color: Colors.white70)))),
        ]);
      },
    );
  }
}
