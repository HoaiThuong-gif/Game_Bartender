import 'package:flutter/foundation.dart';

import '../data/gacha_rewards.dart';
import 'gacha_collection_storage.dart';

/// App-wide collection. Screens borrow it; closing a dialog does not dispose it.
class GachaCollection extends ChangeNotifier {
  GachaCollection({GachaCollectionStorage? storage})
    : _storage = storage ?? PreferencesGachaCollectionStorage();

  static final instance = GachaCollection();

  final GachaCollectionStorage _storage;
  final Set<int> _ownedNumbers = {};
  final Set<int> _pendingNumbers = {};
  Future<void> _queue = Future.value();
  bool _isLoaded = false;
  Object? _error;

  bool get isLoaded => _isLoaded;
  Object? get error => _error;
  bool owns(int number) => _ownedNumbers.contains(number);
  Set<int> get ownedNumbers => Set.unmodifiable(_ownedNumbers);
  int get unlockedCount => _ownedNumbers.length;

  /// Also retries rewards whose previous write failed, without losing them.
  Future<bool> load() => _enqueueSync();

  Future<bool> unlock(int number) {
    if (!gachaRewards.any((reward) => reward.number == number)) {
      throw ArgumentError.value(number, 'number', 'Unknown Gacha reward');
    }
    _pendingNumbers.add(number);
    return _enqueueSync();
  }

  Future<bool> _enqueueSync() {
    final operation = _queue.then((_) => _sync());
    _queue = operation.then<void>((_) {});
    return operation;
  }

  Future<bool> _sync() async {
    try {
      if (!_isLoaded) {
        final saved = await _storage.readOwnedNumbers();
        final knownNumbers = gachaRewards
            .map((reward) => reward.number)
            .toSet();
        _ownedNumbers.addAll(saved.intersection(knownNumbers));
        _isLoaded = true;
      }
      final pending = Set<int>.of(_pendingNumbers);
      final updated = {..._ownedNumbers, ...pending};
      if (updated.length != _ownedNumbers.length) {
        await _storage.writeOwnedNumbers(updated);
        _ownedNumbers.addAll(updated);
      }
      _pendingNumbers.removeAll(pending);
      _error = null;
      notifyListeners();
      return true;
    } catch (error) {
      _error = error;
      notifyListeners();
      return false;
    }
  }
}
