import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const colors = <String, Color>{
    'Cam đất': Color(0xFFA95C3B),
    'Xanh ngọc': Color(0xFF267566),
    'Xanh chàm': Color(0xFF4F5BD5),
    'Tím': Color(0xFF795281),
  };
  static const textSizes = <String, double>{
    'Nhỏ': .9,
    'Mặc định': 1,
    'Lớn': 1.15,
    'Rất lớn': 1.3,
  };
  final SharedPreferencesAsync _preferences;
  String colorName = 'Cam đất';
  double textScale = 1;
  bool reduceMotion = false;
  String? storageError;
  String? _account;
  bool _loaded = false, _disposed = false;
  int _loadVersion = 0;
  Future<void> _saveQueue = Future.value();

  Color get seedColor => colors[colorName]!;
  String _key(String? uid) => 'appearance.v1.${uid ?? 'guest'}';

  Future<void> useAccount(String? uid) async {
    if (_loaded && _account == uid) return;
    _account = uid;
    _loaded = true;
    final version = ++_loadVersion;
    String? stored;
    String? error;
    try {
      await _saveQueue;
      stored = await _preferences.getString(_key(uid));
    } catch (_) {
      error = 'Chưa đọc được giao diện đã lưu. Đang dùng mặc định.';
    }
    if (_disposed || version != _loadVersion) return;
    colorName = 'Cam đất';
    textScale = 1;
    reduceMotion = false;
    if (stored != null) {
      try {
        final data = jsonDecode(stored);
        if (data is Map) {
          if (colors.containsKey(data['color'])) {
            colorName = data['color'] as String;
          }
          if (textSizes.containsValue(data['textScale'])) {
            textScale = (data['textScale'] as num).toDouble();
          }
          reduceMotion = data['reduceMotion'] == true;
        }
      } catch (_) {
        error = 'Giao diện đã lưu chưa hợp lệ. Đang dùng mặc định.';
      }
    }
    storageError = error;
    notifyListeners();
  }

  Future<void> update({String? color, double? scale, bool? lessMotion}) {
    if (color != null && colors.containsKey(color)) colorName = color;
    if (scale != null && textSizes.containsValue(scale)) textScale = scale;
    if (lessMotion != null) reduceMotion = lessMotion;
    storageError = null;
    notifyListeners();
    final key = _key(_account);
    final version = _loadVersion;
    final data = jsonEncode({
      'color': colorName,
      'textScale': textScale,
      'reduceMotion': reduceMotion,
    });
    // Save in order, to the account selected when the change was made.
    _saveQueue = _saveQueue.then((_) async {
      try {
        await _preferences.setString(key, data);
      } catch (_) {
        if (!_disposed && version == _loadVersion) {
          storageError = 'Chưa lưu được lựa chọn. Hãy thử lại.';
          notifyListeners();
        }
      }
    });
    return _saveQueue;
  }

  Future<void> reset() => update(color: 'Cam đất', scale: 1, lessMotion: false);
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);
  static AppSettings? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettingsScope>()?.notifier;
  static AppSettings of(BuildContext context) => maybeOf(context)!;
}

/// Preserve Android's nonlinear accessibility scaling, then apply the user's choice.
class AppTextScaler extends TextScaler {
  const AppTextScaler(this.system, this.factor);
  final TextScaler system;
  final double factor;
  @override
  double scale(double fontSize) => system.scale(fontSize) * factor;
  @override
  double get textScaleFactor => scale(14) / 14;
}
