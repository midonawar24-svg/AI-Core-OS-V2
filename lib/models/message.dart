import 'conversation.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String intent;
  final double confidence;

  Message({required this.text, required this.isUser, required this.timestamp, this.intent = 'chat', this.confidence = 0.8});

  factory Message.fromConversation(Conversation conv, bool isUser) => Message(
    text: isUser ? conv.input : conv.output,
    isUser: isUser,
    timestamp: conv.timestamp,
    intent: conv.intent,
    confidence: conv.confidence,
  );
}
