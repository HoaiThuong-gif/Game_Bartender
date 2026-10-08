import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/gacha/data/gacha_rewards.dart';
import 'package:nhom_bar/games/gacha/services/gacha_collection.dart';
import 'package:nhom_bar/games/gacha/services/gacha_collection_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _Storage implements GachaCollectionStorage {
  Set<int> saved = {};
  int writes = 0;
  bool failWrite = false;
  Completer<void>? readBarrier;

  @override
  Future<Set<int>> readOwnedNumbers() async {
    await readBarrier?.future;
    return Set.of(saved);
  }

  @override
  Future<void> writeOwnedNumbers(Set<int> numbers) async {
    if (failWrite) throw StateError('Cannot save');
    writes++;
    saved = Set.of(numbers);
  }
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test(
    'empty collection, ownership API, count and duplicate deduplication',
    () async {
      final storage = _Storage();
      final collection = GachaCollection(storage: storage);
      await collection.load();
      expect(collection.ownedNumbers, isEmpty);
      expect(collection.unlockedCount, 0);
      expect(collection.owns(1), isFalse);
      await collection.unlock(1);
      await collection.unlock(1);
      expect(collection.ownedNumbers, {1});
      expect(collection.owns(1), isTrue);
      expect(collection.unlockedCount, 1);
      expect(storage.writes, 1);
      await collection.unlock(2);
      expect(collection.unlockedCount, 2);
      expect(() => collection.ownedNumbers.add(3), throwsUnsupportedError);
      expect(() => collection.unlock(999), throwsArgumentError);
      collection.dispose();
    },
  );

  test(
    'new repository and preferences adapter reload persisted IDs only',
    () async {
      final first = GachaCollection();
      await first.unlock(gachaRewards[2].number);
      await first.unlock(gachaRewards.last.number);
      first.dispose();
      final saved = await SharedPreferencesAsync().getStringList(
        PreferencesGachaCollectionStorage.storageKey,
      );
      expect(saved, ['3', '6']);
      final restarted = GachaCollection();
      await restarted.load();
      expect(restarted.ownedNumbers, {3, 6});
      expect(restarted.unlockedCount, 2);
      expect(restarted.owns(3), isTrue);
      expect(restarted.owns(1), isFalse);
      restarted.dispose();
    },
  );

  test(
    'loading saved items and simultaneous unlocks do not overwrite ownership',
    () async {
      final storage = _Storage()
        ..saved = {6}
        ..readBarrier = Completer<void>();
      final collection = GachaCollection(storage: storage);
      final loading = collection.load();
      final first = collection.unlock(1);
      final second = collection.unlock(2);
      final duplicate = collection.unlock(1);
      storage.readBarrier!.complete();
      await Future.wait([loading, first, second, duplicate]);
      expect(collection.ownedNumbers, {1, 2, 6});
      expect(storage.saved, {1, 2, 6});
      expect(collection.unlockedCount, 3);
      collection.dispose();
    },
  );

  test('failed write stays pending and load retries it', () async {
    final storage = _Storage()..failWrite = true;
    final collection = GachaCollection(storage: storage);
    expect(await collection.unlock(1), isFalse);
    expect(collection.error, isNotNull);
    expect(collection.owns(1), isFalse);
    storage.failWrite = false;
    expect(await collection.load(), isTrue);
    expect(collection.error, isNull);
    expect(collection.owns(1), isTrue);
    expect(storage.saved, {1});
    collection.dispose();
  });

  test(
    'malformed, duplicate and unknown saved IDs do not inflate count',
    () async {
      await SharedPreferencesAsync().setStringList(
        PreferencesGachaCollectionStorage.storageKey,
        ['1', '1', '6', '999', 'invalid'],
      );
      final collection = GachaCollection();
      await collection.load();
      expect(collection.ownedNumbers, {1, 6});
      expect(collection.unlockedCount, 2);
      collection.dispose();
    },
  );
}
