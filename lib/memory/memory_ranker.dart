// lib/memory/memory_ranker.dart
// V6 Part 1 - BM25 + TF-IDF - Ready for V6
import 'dart:math';
import 'memory_engine.dart';

class MemoryRanker {
  static const double k1 = 1.2;
  static const double b = 0.75;

  static double bm25({
    required String query,
    required MemoryEntry entry,
    required Map<String, int> docFreq,
    required int totalDocs,
    required double avgDocLen,
  }) {
    final qTokens = Tokenizer.tokenize(query);
    final eTokens = Tokenizer.tokenize(entry.content);
    if (qTokens.isEmpty || eTokens.isEmpty) return 0;
    final tf = <String,int>{};
    for(final t in eTokens) tf[t] = (tf[t]??0)+1;
    double score = 0;
    for(final q in qTokens){
      final f = tf[q]??0;
      if(f==0) continue;
      final df = docFreq[q]??1;
      final idf = log((totalDocs - df + 0.5)/(df+0.5) + 1);
      final numerator = f * (k1+1);
      final denom = f + k1 * (1 - b + b * eTokens.length / avgDocLen);
      score += idf * (numerator/denom);
    }
    return score;
  }
}
