import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gacha_collection.dart';

/// One shared head item for the lobby cats; ownership stays in the collection.
class CatEquipment extends ChangeNotifier {
  CatEquipment({required this.collection});
  static final instance = CatEquipment(collection: GachaCollection.instance);
  static const storageKey = 'gacha.cat_head_wearable.v1';
  static const nonLa = 'non_la';
  static const rewardNumber = 2;
  final GachaCollection collection;
  final _preferences = SharedPreferencesAsync();
  Future<void> _queue = Future.value();
  String? _head;
  bool _disposed = false;
  bool isLoaded = false;
  Object? error;
  String? get head => _head;

  Future<bool> load() => _enqueue(() async {
    if (!await collection.load()) throw StateError('Cannot load ownership');
    if (!isLoaded) {
      final saved = await _preferences.getString(storageKey);
      _head = saved == nonLa && collection.owns(rewardNumber) ? nonLa : null;
      isLoaded = true;
    }
  });

  Future<bool> equip() => _enqueue(() async {
    if (!await collection.load() || !collection.owns(rewardNumber)) {
      throw StateError('Nón lá is not owned');
    }
    await _preferences.setString(storageKey, nonLa);
    _head = nonLa;
    isLoaded = true;
  });

  Future<bool> unequip() => _enqueue(() async {
    await _preferences.remove(storageKey);
    _head = null;
    isLoaded = true;
  });

  Future<bool> _enqueue(Future<void> Function() action) {
    final operation = _queue.then((_) async {
      try {
        await action();
        error = null;
        if (!_disposed) notifyListeners();
        return true;
      } catch (failure) {
        error = failure;
        if (!_disposed) notifyListeners();
        return false;
      }
    });
    _queue = operation.then<void>((_) {});
    return operation;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
