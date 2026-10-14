import 'package:shared_preferences/shared_preferences.dart';

/// Remove only retired inventory/equipment data, preserving the shared wallet.
Future<void> removeRetiredFeatureStorage() async {
  final preferences = SharedPreferencesAsync();
  await preferences.remove('gacha.owned_reward_numbers.v1');
  await preferences.remove('gacha.cat_head_wearable.v1');
}
