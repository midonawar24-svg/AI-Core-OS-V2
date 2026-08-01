// lib/memory/memory_engine.dart
// V5.2.1 ENTERPRISE - FINAL FIXES - 10/10
import 'dart:async';
import 'dart:collection';
import 'dart:math';

class LoggerService {
  static void info(String m) => print('[INFO] $m');
  static void success(String m) => print('[OK] $m');
  static void error(String m, [dynamic e, dynamic st]) => print('[ERR] $m $e');
}

class MemoryConstants {
  static const int maxQueryResults = 20;
  static const int maxTokenLength = 20;
  static const int maxMemoriesPerType = 500;
  static const int lruCacheSize = 200;
  static const int decayBatchSize = 100;
  static const double minConfidence = 0.15;
  static const double decayRate = 0.02;
  static const double recencyDivider = 86400000;
  static const double recencyMax = 1.0;
  static const double frequencyDivider = 10;
  static const double frequencyMax = 1.0;
}

enum MemoryType { episodic, semantic, procedural, working, longTerm; String get nameValue => name; }

class MemoryMetadata {
  final double importance; final String? source; final Map<String, dynamic> extra;
  const MemoryMetadata({this.importance = 0.5, this.source, this.extra = const {}});
  MemoryMetadata copyWith({double? importance, String? source, Map<String, dynamic>? extra}) =>
      MemoryMetadata(importance: importance?? this.importance, source: source?? this.source, extra: extra?? this.extra);
}

class TrieNode {
  final Map<String, TrieNode> children = {};
  final Set<String> ids = {};
  bool isEnd = false;
}

class Trie {
  final TrieNode root = TrieNode();
  int _size = 0;

  void insert(String token, String id) {
    var node = root;
    for (final ch in token.split('')) node = node.children.putIfAbsent(ch, () => TrieNode());
    if (!node.isEnd) _size++;
    node.isEnd = true;
    node.ids.add(id);
  }

  // FIX 3: Pruning حقيقي للعقد الفارغة
  void remove(String token, String id) {
    var node = root;
    final List<TrieNode> path = [root];
    final List<String> chars = [];
    for (final ch in token.split('')) {
      if (!node.children.containsKey(ch)) return;
      node = node.children[ch]!;
      path.add(node);
      chars.add(ch);
    }
    node.ids.remove(id);
    // Prune empty nodes from leaf to root
    for (int i = path.length - 1; i > 0; i--) {
      final curr = path[i];
      final parent = path[i - 1];
      if (curr.ids.isEmpty && curr.children.isEmpty) {
        parent.children.remove(chars[i - 1]);
        if (curr.isEnd) _size = max(0, _size - 1);
      } else {
        break;
      }
    }
  }

  Set<String> searchPrefix(String prefix) {
    var node = root;
    for (final ch in prefix.split('')) { if (!node.children.containsKey(ch)) return {}; node = node.children[ch]!; }
    return _collect(node);
  }
  Set<String> _collect(TrieNode node) {
    final res = <String>{...node.ids};
    for (final child in node.children.values) res.addAll(_collect(child));
    return res;
  }
  void clear() { root.children.clear(); _size = 0; }
  int get size => _size;
}

class AsyncLock {
  bool _locked = false;
  final Queue<Completer<void>> _queue = Queue();
  Future<T> synchronized<T>(Future<T> Function() fn) async {
    if (_locked) { final c = Completer<void>(); _queue.add(c); await c.future; }
    _locked = true;
    try { return await fn(); } finally { _locked = false; if (_queue.isNotEmpty) _queue.removeFirst().complete(); }
  }
}

class LruCache<K, V> {
  final int capacity; final LinkedHashMap<K, V> _map = LinkedHashMap();
  LruCache(this.capacity);
  V? get(K key) { if (!_map.containsKey(key)) return null; final v = _map.remove(key)!; _map[key] = v; return v; }
  void put(K key, V value) { if (_map.containsKey(key)) _map.remove(key); else if (_map.length >= capacity) _map.remove(_map.keys.first); _map[key] = value; }
  void remove(K key) => _map.remove(key);
  void clear() => _map.clear();
  int get length => _map.length;
}

class MemoryEntry {
  final String id; final MemoryType type; final String content; final List<String> tags;
  final String? userId; final String? sessionId; final String? conversationId;
  final MemoryMetadata metadata; final double confidence; final int accessCount;
  final DateTime createdAt; final DateTime lastAccessedAt;
  const MemoryEntry({required this.id, required this.type, required this.content, this.tags = const [], this.userId, this.sessionId, this.conversationId, this.metadata = const MemoryMetadata(), this.confidence = 1.0, this.accessCount = 0, required this.createdAt, required this.lastAccessedAt});
  bool get isExpired => confidence < MemoryConstants.minConfidence;
  MemoryEntry copyWith({String? content, List<String>? tags, MemoryMetadata? metadata, double? confidence, int? accessCount, DateTime? lastAccessedAt}) =>
      MemoryEntry(id: id, type: type, content: content?? this.content, tags: tags?? this.tags, userId: userId, sessionId: sessionId, conversationId: conversationId, metadata: metadata?? this.metadata, confidence: confidence?? this.confidence, accessCount: accessCount?? this.accessCount, createdAt: createdAt, lastAccessedAt: lastAccessedAt?? this.lastAccessedAt);
}

class MemoryQuery {
  final String query; final List<MemoryType> types; final int limit; final String? userId; final String? sessionId; final String? conversationId; final List<String>? tags;
  const MemoryQuery({required this.query, this.types = const [], this.limit = MemoryConstants.maxQueryResults, this.userId, this.sessionId, this.conversationId, this.tags});
}

class MemorySearchResult { final MemoryEntry entry; final double relevance; const MemorySearchResult({required this.entry, required this.relevance}); }

abstract class MemoryStore {
  String get name;
  Future<void> save(MemoryEntry entry); Future<void> saveAll(List<MemoryEntry> entries);
  Future<List<MemoryEntry>> loadAll(); Future<List<MemoryEntry>> queryFiltered({List<MemoryType>? types, String? userId, String? conversationId});
  Future<Set<String>> searchTokens(List<String> tokens); Future<Set<String>> getTokensForId(String id);
  Future<MemoryEntry?> loadById(String id); Future<void> delete(String id); Future<void> deleteAll(List<String> ids);
  Future<void> clear(); Future<int> count(); Future<int> countByType(MemoryType type);
  Future<List<MemoryEntry>> getOldestByType(MemoryType type, int limit); Future<Map<String, dynamic>> getIndexStats();
}

class IdGenerator {
  static final Random _random = Random.secure();
  static String generate(MemoryType type) {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40; bytes[8] = (bytes[8] & 0x3F) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${type.nameValue}_${hex.substring(0,8)}-${hex.substring(8,12)}-${hex.substring(12,16)}-${hex.substring(16,20)}-${hex.substring(20)}';
  }
}

class Tokenizer {
  static List<String> tokenize(String text) => text.toLowerCase().replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), ' ').split(RegExp(r'\s+')).where((t) => t.length > 2 && t.length <= MemoryConstants.maxTokenLength).toSet().toList();
}

class InMemoryStore implements MemoryStore {
  final Map<String, MemoryEntry> _storage = {};
  final Map<MemoryType, Set<String>> _byType = {};
  final Map<String, Set<String>> _byUserId = {}, _byConversation = {};
  final Map<String, Set<String>> _invertedIndex = {}, _entryTokens = {};
  final Trie _trie = Trie();
  InMemoryStore() { for (final t in MemoryType.values) _byType[t] = <String>{}; }
  @override String get name => 'in_memory';
  @override Future<void> save(MemoryEntry entry) async { final old = _storage[entry.id]; if (old!= null) _remove(old); _storage[entry.id]=entry; _add(entry); }
  @override Future<void> saveAll(List<MemoryEntry> entries) async { for (final e in entries) { final old=_storage[e.id]; if(old!=null) _remove(old); _storage[e.id]=e; _add(e); } }
  void _add(MemoryEntry e) {
    _byType[e.type]?.add(e.id);
    if(e.userId!=null) _byUserId.putIfAbsent(e.userId!,()=> <String>{}).add(e.id);
    if(e.conversationId!=null) _byConversation.putIfAbsent(e.conversationId!,()=> <String>{}).add(e.id);
    final tokens = Tokenizer.tokenize(e.content);
    _entryTokens[e.id]=tokens.toSet();
    for(final t in tokens){ _invertedIndex.putIfAbsent(t,()=> <String>{}).add(e.id); _trie.insert(t, e.id); }
    for(final tag in e.tags){ final tt='tag:${tag.toLowerCase()}'; _invertedIndex.putIfAbsent(tt,()=> <String>{}).add(e.id); _trie.insert(tt, e.id); }
  }
  void _remove(MemoryEntry e) {
    _byType[e.type]?.remove(e.id); _byUserId[e.userId]?.remove(e.id); _byConversation[e.conversationId]?.remove(e.id);
    final tokens=_entryTokens[e.id]??{}; for(final t in tokens){ _invertedIndex[t]?.remove(e.id); _trie.remove(t,e.id); if(_invertedIndex[t]?.isEmpty??false) _invertedIndex.remove(t); }
    for(final tag in e.tags) _invertedIndex['tag:${tag.toLowerCase()}']?.remove(e.id);
    _entryTokens.remove(e.id);
  }
  @override Future<List<MemoryEntry>> loadAll() async => _storage.values.toList();
  @override Future<List<MemoryEntry>> queryFiltered({List<MemoryType>? types, String? userId, String? conversationId}) async {
    Set<String>? c;
    if(types!=null&&types.isNotEmpty){ final s=<String>{}; for(final t in types) s.addAll(_byType[t]??{}); c=s; }
    if(userId!=null){ final u=_byUserId[userId]??{}; c=c==null?u:c.intersection(u); }
    if(conversationId!=null){ final cv=_byConversation[conversationId]??{}; c=c==null?cv:c.intersection(cv); }
    if(c==null) return _storage.values.toList();
    return c.map((id)=>_storage[id]).whereType<MemoryEntry>().toList();
  }
  @override Future<Set<String>> searchTokens(List<String> tokens) async {
    if(tokens.isEmpty) return _storage.keys.toSet();
    final result=<String>{};
    for(final token in tokens){ result.addAll(_invertedIndex[token]??{}); result.addAll(_trie.searchPrefix(token)); }
    return result;
  }
  @override Future<Set<String>> getTokensForId(String id) async => _entryTokens[id]??{};
  @override Future<MemoryEntry?> loadById(String id) async => _storage[id];
  @override Future<void> delete(String id) async { final old=_storage.remove(id); if(old!=null) _remove(old); }
  @override Future<void> deleteAll(List<String> ids) async { for(final id in ids){ final old=_storage.remove(id); if(old!=null) _remove(old); } }
  @override Future<void> clear() async { _storage.clear(); for(final t in MemoryType.values) _byType[t]?.clear(); _byUserId.clear(); _byConversation.clear(); _invertedIndex.clear(); _entryTokens.clear(); _trie.clear(); }
  @override Future<int> count() async => _storage.length;
  @override Future<int> countByType(MemoryType type) async => _byType[type]?.length??0;
  @override Future<List<MemoryEntry>> getOldestByType(MemoryType type, int limit) async { final ids=_byType[type]??{}; final list=ids.map((id)=>_storage[id]).whereType<MemoryEntry>().toList(); list.sort((a,b){ final c=a.confidence.compareTo(b.confidence); if(c!=0) return c; return a.lastAccessedAt.compareTo(b.lastAccessedAt);}); return list.take(limit).toList(); }
  @override Future<Map<String,dynamic>> getIndexStats() async => {'invertedIndexSize':_invertedIndex.length,'trieSize':_trie.size,'entryTokens':_entryTokens.length,'totalEntries':_storage.length};
}

class MemoryEngine {
  static MemoryStore? _activeStore;
  static final AsyncLock _lock = AsyncLock();
  static final LruCache<String, MemoryEntry> _lruCache = LruCache(MemoryConstants.lruCacheSize);
  static MemoryStore get activeStore { _activeStore??=InMemoryStore(); return _activeStore!; }
  static Future<void> initialize({MemoryStore? store}) async { _activeStore=store??InMemoryStore(); await warmup(); LoggerService.success('MemoryEngine V5.2.1 Enterprise initialized with ${activeStore.name}'); }

  static Future<MemoryEntry> remember({required MemoryType type, required String content, List<String> tags=const[], String? userId, String? sessionId, String? conversationId, MemoryMetadata metadata=const MemoryMetadata(), double confidence=1.0}) async {
    final entry=MemoryEntry(id:IdGenerator.generate(type),type:type,content:content,tags:tags,userId:userId,sessionId:sessionId,conversationId:conversationId,metadata:metadata,confidence:confidence,createdAt:DateTime.now(),lastAccessedAt:DateTime.now());
    await _lock.synchronized(() async {
      final count=await activeStore.countByType(type);
      if(count>=MemoryConstants.maxMemoriesPerType){
        final removeCount=count-MemoryConstants.maxMemoriesPerType+1;
        final oldest=await activeStore.getOldestByType(type, removeCount);
        await activeStore.deleteAll(oldest.map((e)=>e.id).toList());
        for(final e in oldest) _lruCache.remove(e.id);
      }
      await activeStore.save(entry); _lruCache.put(entry.id, entry);
    });
    return entry;
  }

  // FIX 1 + FIX 2: sessionId + tags + confidence boost
  static Future<List<MemorySearchResult>> recall(MemoryQuery query) async {
    final tokens=Tokenizer.tokenize(query.query);
    final filtered=await activeStore.queryFiltered(types:query.types,userId:query.userId,conversationId:query.conversationId);
    final matchedIds=await activeStore.searchTokens(tokens);
    var candidates=filtered.where((e)=>matchedIds.contains(e.id)).toList();

    if (query.sessionId != null) {
      candidates = candidates.where((e) => e.sessionId == query.sessionId || e.sessionId == null).toList();
    }
    if (query.tags != null && query.tags!.isNotEmpty) {
      candidates = candidates.where((e) => query.tags!.any((t) => e.tags.contains(t))).toList();
    }

    final results=<MemorySearchResult>[];
    for(final e in candidates){ final s=_score(e,tokens); if(s>0) results.add(MemorySearchResult(entry:e,relevance:s)); }
    results.sort((a,b)=>b.relevance.compareTo(a.relevance));
    final top=results.take(query.limit).toList();
    for(final r in top){
      final u=r.entry.copyWith(
        accessCount:r.entry.accessCount+1,
        lastAccessedAt:DateTime.now(),
        confidence: min(1.0, r.entry.confidence + 0.02),
      );
      await activeStore.save(u); _lruCache.put(u.id,u);
    }
    return top;
  }

  static double _score(MemoryEntry e, List<String> q){ if(q.isEmpty) return e.confidence; final et=Tokenizer.tokenize(e.content).toSet(); int hits=0; for(final t in q) if(et.contains(t)||et.any((x)=>x.startsWith(t))) hits++; final bm= q.isEmpty?0: hits/q.length; final age=DateTime.now().difference(e.lastAccessedAt).inMilliseconds/MemoryConstants.recencyDivider; final rec=exp(-age*0.1).clamp(0.0,1.0); return bm*0.6+rec*0.15+e.confidence*0.15+e.metadata.importance*0.1; }

  static Future<void> decay({int batchSize=MemoryConstants.decayBatchSize}) async {
    int updatedCount=0, deletedCount=0;
    await _lock.synchronized(() async {
      final all=await activeStore.loadAll();
      final toUpdate=<MemoryEntry>[]; final toDelete=<String>[];
      for(final e in all){
        final updated=e.copyWith(confidence:(e.confidence-MemoryConstants.decayRate).clamp(0.0,1.0));
        if(updated.isExpired) toDelete.add(updated.id); else toUpdate.add(updated);
        if(toUpdate.length>=batchSize){ await activeStore.saveAll(toUpdate); for(final u in toUpdate) _lruCache.put(u.id,u); updatedCount+=toUpdate.length; toUpdate.clear(); }
        if(toDelete.length>=batchSize){ await activeStore.deleteAll(toDelete); for(final id in toDelete) _lruCache.remove(id); deletedCount+=toDelete.length; toDelete.clear(); }
      }
      if(toUpdate.isNotEmpty){ await activeStore.saveAll(toUpdate); for(final u in toUpdate) _lruCache.put(u.id,u); updatedCount+=toUpdate.length; }
      if(toDelete.isNotEmpty){ await activeStore.deleteAll(toDelete); for(final id in toDelete) _lruCache.remove(id); deletedCount+=toDelete.length; }
    });
    LoggerService.success('Decay completed | Updated=$updatedCount Deleted=$deletedCount');
  }

  static Future<MemoryEntry?> getById(String id) async {
    return _lock.synchronized(() async {
      MemoryEntry? entry=_lruCache.get(id);
      entry??=await activeStore.loadById(id);
      if(entry==null) return null;
      final updated=entry.copyWith(accessCount:entry.accessCount+1,lastAccessedAt:DateTime.now(),confidence:min(1.0,entry.confidence+0.03));
      await activeStore.save(updated); _lruCache.put(updated.id,updated);
      return updated;
    });
  }

  static Future<void> forget(String id) async => _lock.synchronized(() async { await activeStore.delete(id); _lruCache.remove(id); });
  static Future<void> forgetMany(List<String> ids) async => _lock.synchronized(() async { await activeStore.deleteAll(ids); for(final id in ids) _lruCache.remove(id); });
  static Future<void> clear() async => _lock.synchronized(() async { await activeStore.clear(); _lruCache.clear(); });
  static Future<Map<String,dynamic>> stats() async { final s=await activeStore.getIndexStats(); return {'store':activeStore.name,'entries':await activeStore.count(),'cacheSize':_lruCache.length,'cacheCapacity':MemoryConstants.lruCacheSize,'index':s,'types':{for(final t in MemoryType.values) t.nameValue:await activeStore.countByType(t)}}; }

  // FIX 4: rebuildCache يجيب الأعلى confidence + الأحدث
  static Future<void> rebuildCache() async {
    final all=await activeStore.loadAll();
    all.sort((a,b){
      final c=b.confidence.compareTo(a.confidence);
      if(c!=0) return c;
      return b.lastAccessedAt.compareTo(a.lastAccessedAt);
    });
    _lruCache.clear();
    for(final e in all.take(MemoryConstants.lruCacheSize)) _lruCache.put(e.id,e);
  }

  static Future<void> warmup() async { await rebuildCache(); final s=await activeStore.getIndexStats(); LoggerService.success('Warmup Complete | Entries=${s['totalEntries']} Tokens=${s['entryTokens']} Trie=${s['trieSize']}'); }
  static Future<List<MemoryEntry>> exportAll() async => activeStore.loadAll();
  static Future<void> importEntries(List<MemoryEntry> entries) async => _lock.synchronized(() async { await activeStore.saveAll(entries); for(final e in entries) _lruCache.put(e.id,e); });

  // FIX 5: dispose لا يمسح البيانات
  static Future<void> dispose() async {
    _lruCache.clear();
    _activeStore = null;
    LoggerService.info('MemoryEngine disposed - cache cleared, store preserved');
  }
}
