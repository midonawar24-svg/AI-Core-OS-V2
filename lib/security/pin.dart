import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PinService {
  String _hash(String pin) => base64Encode(utf8.encode(pin + '_ai_core_v2_pro'));

  Future<String> getHash() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pin_hash_pro') ?? _hash('1234');
  }

  Future<void> save(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin_hash_pro', _hash(pin));
  }

  Future<bool> verify(String pin) async {
    final saved = await getHash();
    return _hash(pin) == saved;
  }
}
