import '../utils/constants.dart';

/// Tokenizer حقيقي - بدل contains()
/// يحول الجملة لتوكنز، يشيل علامات الترقيم، يوحد الحروف، يشيل كلمات التوقف
class Tokenizer {
  static const List<String> _stopWords = [
    'انا', 'انت', 'هو', 'هي', 'احنا', 'هما', 'ده', 'دي', 'دول',
    'في', 'من', 'على', 'الى', 'عن', 'مع', 'هذا', 'هذه', 'اللي', 'التي', 'الذي',
    'و', 'او', 'ثم', 'لكن', 'ان', 'كان', 'يكون', 'كانت', 'يوجد',
    'is', 'are', 'the', 'a', 'an', 'in', 'on', 'at', 'to', 'of',
  ];

  /// تطبيع النص العربي
  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[إأآا]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[ـًٌٍَُِّْ]'), '') // تشكيل
        .replaceAll(RegExp(r'[؟?!.،,;:]'), ' ')
        .trim();
  }

  List<String> tokenize(String text) {
    if (text.isEmpty) return [];
    final normalized = _normalize(text);
    final rawTokens = normalized.split(RegExp(r'\s+')).where((t) => t.length > 1).toList();
    
    // شيل كلمات التوقف + توكنز قصيرة
    final tokens = rawTokens.where((t) => !_stopWords.contains(t) && t.length > 1).toList();
    
    // Stemming بسيط عربي
    return tokens.map(_stem).toList();
  }

  String _stem(String word) {
    // إزالة ال التعريف
    if (word.startsWith('ال') && word.length > 3) word = word.substring(2);
    // إزالة واو العطف
    if (word.startsWith('و') && word.length > 3) word = word.substring(1);
    // إزالة ياء الملكية
    if (word.endsWith('ي') && word.length > 3) word = word.substring(0, word.length - 1);
    return word;
  }

  Map<String, int> getTermFrequency(List<String> tokens) {
    final freq = <String, int>{};
    for (var token in tokens) {
      freq[token] = (freq[token] ?? 0) + 1;
    }
    return freq;
  }

  // تحويل لجملة نظيفة للبحث
  String cleanForSearch(String text) {
    return tokenize(text).join(' ');
  }
}
