/// واجهة المهارة - Skill Interface
/// كل مهارة جديدة هتطبق الواجهة دي - سهل إضافة مهارات
abstract class Skill {
  String get name;
  String get description;
  List<String> get keywords;
  double get confidence;

  /// هل المهارة دي تقدر تتعامل مع المدخل؟
  Future<bool> canHandle(String input, List<String> tokens);

  /// تنفيذ المهارة
  Future<Map<String, dynamic>> execute(String input, Map<String, dynamic> context);
}
