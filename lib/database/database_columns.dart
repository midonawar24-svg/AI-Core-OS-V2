/// DatabaseColumns - أسماء الأعمدة كثوابت - نظام واحد فقط
/// يمنع الأخطاء الإملائية 100% - Enterprise Level

class FactColumns {
  FactColumns._();
  static const String id = 'id';
  static const String key = 'key';
  static const String value = 'value';
  static const String type = 'type';
  static const String source = 'source';
  static const String timestamp = 'timestamp';
  
  static const List<String> all = [id, key, value, type, source, timestamp];
}

class ConversationColumns {
  ConversationColumns._();
  static const String id = 'id';
  static const String input = 'input';
  static const String output = 'output';
  static const String intent = 'intent';
  static const String command = 'command';
  static const String confidence = 'confidence';
  static const String success = 'success';
  static const String timestamp = 'timestamp';
  
  static const List<String> all = [id, input, output, intent, command, confidence, success, timestamp];
}

class WordColumns {
  WordColumns._();
  static const String id = 'id';
  static const String word = 'word';
  static const String frequency = 'frequency';
  static const String firstSeen = 'firstSeen';
  static const String lastSeen = 'lastSeen';
  
  static const List<String> all = [id, word, frequency, firstSeen, lastSeen];
}

class DecisionColumns {
  DecisionColumns._();
  static const String id = 'id';
  static const String input = 'input';
  static const String intent = 'intent';
  static const String decision = 'decision';
  static const String reasoning = 'reasoning';
  static const String confidence = 'confidence';
  static const String timestamp = 'timestamp';
  
  static const List<String> all = [id, input, intent, decision, reasoning, confidence, timestamp];
}

class EvolutionColumns {
  EvolutionColumns._();
  static const String id = 'id';
  static const String level = 'level';
  static const String totalConversations = 'totalConversations';
  static const String totalSuccess = 'totalSuccess';
  static const String totalFacts = 'totalFacts';
  static const String totalWords = 'totalWords';
  static const String lastUpdate = 'lastUpdate';
  
  static const List<String> all = [id, level, totalConversations, totalSuccess, totalFacts, totalWords, lastUpdate];
}

class KnowledgeColumns {
  KnowledgeColumns._();
  static const String id = 'id';
  static const String question = 'question';
  static const String answer = 'answer';
  static const String category = 'category';
  static const String timestamp = 'timestamp';
  
  static const List<String> all = [id, question, answer, category, timestamp];
}
