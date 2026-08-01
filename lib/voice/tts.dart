import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _tts.setLanguage("ar-EG");
    await _tts.setSpeechRate(0.85);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    _ready = true;
  }

  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text.length > 250 ? text.substring(0, 250) : text);
  }

  Future<void> stop() async => await _tts.stop();
  void dispose() => _tts.stop();
}
