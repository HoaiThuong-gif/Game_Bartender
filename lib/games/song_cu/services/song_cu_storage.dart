import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SongCuStorage {
  static const _key = 'song_cu.progress.v2';
  static const _legacyKey = 'song_cu.progress.v1';
  final _preferences = SharedPreferencesAsync();
  Future<void> _queue = Future.value();

  Future<Map<String, dynamic>> load() async {
    try {
      final raw =
          await _preferences.getString(_key) ??
          await _preferences.getString(_legacyKey);
      return raw == null
          ? {}
          : Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> save(Map<String, Object> data) {
    final encoded = jsonEncode(data);
    final operation = _queue.then((_) => _preferences.setString(_key, encoded));
    _queue = operation.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return operation;
  }
}
