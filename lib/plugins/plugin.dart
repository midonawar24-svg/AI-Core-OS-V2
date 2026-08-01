/// واجهة الـ Plugin - نظام إضافات للمهارات
abstract class Plugin {
  String get id;
  String get name;
  String get version;
  bool get isEnabled;

  Future<void> onInit();
  Future<void> onDispose();
  Future<bool> canHandle(String input);
  Future<Map<String, dynamic>> handle(String input, Map<String, dynamic> context);
}
