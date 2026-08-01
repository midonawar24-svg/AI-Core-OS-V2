import 'plugin.dart';
import '../core/skills/skill.dart';

/// مدير الإضافات - Plugin Manager
/// يسمح بإضافة مهارات جديدة بدون تعديل الكود الأساسي
class PluginManager {
  final List<Plugin> _plugins = [];
  final List<Skill> _skills = [];

  void registerPlugin(Plugin plugin) {
    _plugins.add(plugin);
    plugin.onInit();
  }

  void registerSkill(Skill skill) {
    _skills.add(skill);
  }

  List<Skill> get skills => _skills;
  List<Plugin> get plugins => _plugins;

  /// البحث عن مهارة مناسبة - بدل if/else
  Future<Skill?> findSkillForInput(String input, List<String> tokens) async {
    Skill? bestSkill;
    double bestConfidence = 0;

    for (var skill in _skills) {
      if (await skill.canHandle(input, tokens)) {
        if (skill.confidence > bestConfidence) {
          bestConfidence = skill.confidence;
          bestSkill = skill;
        }
      }
    }

    return bestSkill;
  }

  Future<Map<String, dynamic>?> executeSkill(String input, Map<String, dynamic> context, List<String> tokens) async {
    final skill = await findSkillForInput(input, tokens);
    if (skill != null) {
      return await skill.execute(input, context);
    }
    return null;
  }

  void clear() {
    for (var plugin in _plugins) {
      plugin.onDispose();
    }
    _plugins.clear();
    _skills.clear();
  }

  int get count => _skills.length + _plugins.length;
}
