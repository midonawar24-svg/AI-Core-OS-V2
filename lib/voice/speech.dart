import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _ready = false;
  bool _listening = false;

  bool get isListening => _listening;

  Future<bool> init() async {
    if (_ready) return true;
    final status = await Permission.microphone.request();
    if (!status.isGranted) return false;
    _ready = await _speech.initialize();
    return _ready;
  }

  Future<void> start({required Function(String) onResult}) async {
    if (!await init()) return;
    _listening = true;
    await _speech.listen(localeId: "ar_EG", listenFor: const Duration(seconds: 30), onResult: (v) => onResult(v.recognizedWords));
  }

  Future<void> stop() async {
    _listening = false;
    await _speech.stop();
  }

  void dispose() => _speech.stop();
}
