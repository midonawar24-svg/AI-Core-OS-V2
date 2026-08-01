# MemoryEngine V5.2.1 Enterprise

## التركيب:
1. انسخ مجلد lib/memory الى مشروعك
2. في main.dart:
```dart
import 'memory/memory_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MemoryEngine.initialize();
  runApp(MyApp());
}
```

## الاستخدام:
```dart
await MemoryEngine.remember(type: MemoryType.episodic, content: "محمد بيحب البيتزا");
final res = await MemoryEngine.recall(MemoryQuery(query: "بيتزا"));
```

## المسار النهائي:
lib/memory/memory_engine.dart
lib/memory/memory_ranker.dart (لـ V6)
