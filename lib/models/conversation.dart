class Conversation {
  final int? id;
  final String input;
  final String output;
  final String intent;
  final String command;
  final double confidence;
  final bool success;
  final DateTime timestamp;

  Conversation({
    this.id,
    required this.input,
    required this.output,
    required this.intent,
    required this.command,
    required this.confidence,
    required this.success,
    required this.timestamp,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) => Conversation(
    id: map['id'],
    input: map['input'],
    output: map['output'],
    intent: map['intent'],
    command: map['command'],
    confidence: (map['confidence'] as num).toDouble(),
    success: map['success'] == 1,
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'input': input,
    'output': output,
    'intent': intent,
    'command': command,
    'confidence': confidence,
    'success': success ? 1 : 0,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };
}
