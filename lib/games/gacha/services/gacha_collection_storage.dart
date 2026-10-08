import 'package:shared_preferences/shared_preferences.dart';

abstract interface class GachaCollectionStorage {
  Future<Set<int>> readOwnedNumbers();
  Future<void> writeOwnedNumbers(Set<int> numbers);
}

class PreferencesGachaCollectionStorage implements GachaCollectionStorage {
  static const storageKey = 'gacha.owned_reward_numbers.v1';

  late final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<Set<int>> readOwnedNumbers() async {
    final values = await _preferences.getStringList(storageKey) ?? [];
    return values.map(int.tryParse).whereType<int>().toSet();
  }

  @override
  Future<void> writeOwnedNumbers(Set<int> numbers) async {
    final sorted = numbers.toList()..sort();
    await _preferences.setStringList(
      storageKey,
      sorted.map((number) => number.toString()).toList(),
    );
  }
}
