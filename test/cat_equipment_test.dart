import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/gacha/services/cat_equipment.dart';
import 'package:nhom_bar/games/gacha/services/gacha_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  test(
    'rejects unowned hat; owned equip and removal persist across restart',
    () async {
      final collection = GachaCollection();
      final equipment = CatEquipment(collection: collection);
      expect(await equipment.equip(), isFalse);
      expect(equipment.head, isNull);
      expect(await collection.unlock(2), isTrue);
      expect(await equipment.equip(), isTrue);
      expect(
        await SharedPreferencesAsync().getString(CatEquipment.storageKey),
        'non_la',
      );
      final restarted = CatEquipment(collection: GachaCollection());
      expect(await restarted.load(), isTrue);
      expect(restarted.head, 'non_la');
      expect(await restarted.unequip(), isTrue);
      final afterRemoval = CatEquipment(collection: GachaCollection());
      expect(await afterRemoval.load(), isTrue);
      expect(afterRemoval.head, isNull);
    },
  );
  test('ignores unknown or unowned saved wearable', () async {
    for (final saved in ['non_la', 'other']) {
      await SharedPreferencesAsync().setString(CatEquipment.storageKey, saved);
      final equipment = CatEquipment(collection: GachaCollection());
      expect(await equipment.load(), isTrue);
      expect(equipment.head, isNull);
    }
  });
}
