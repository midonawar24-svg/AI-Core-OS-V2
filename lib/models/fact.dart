class Fact {
  final int? id;
  final String key;
  final String value;
  final String type;
  final String source;
  final DateTime timestamp;

  Fact({this.id, required this.key, required this.value, required this.type, required this.source, required this.timestamp});

  factory Fact.fromMap(Map<String, dynamic> map) => Fact(
    id: map['id'],
    key: map['key'],
    value: map['value'],
    type: map['type'],
    source: map['source'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'key': key,
    'value': value,
    'type': type,
    'source': source,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };
}
