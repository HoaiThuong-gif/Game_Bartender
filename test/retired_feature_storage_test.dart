import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/shared/services/fish_wallet.dart';
import 'package:nhom_bar/shared/services/retired_feature_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test(
    'cleanup removes only inventory and equipment and is safe to repeat',
    () async {
      final preferences = SharedPreferencesAsync();
      await preferences.setStringList('gacha.owned_reward_numbers.v1', ['2']);
      await preferences.setString('gacha.cat_head_wearable.v1', 'non_la');
      await preferences.setString('other.feature.setting', 'keep');
      await preferences.setInt(FishWallet.storageKey, 725);

      await removeRetiredFeatureStorage();
      await removeRetiredFeatureStorage();

      expect(
        await preferences.getStringList('gacha.owned_reward_numbers.v1'),
        isNull,
      );
      expect(await preferences.getString('gacha.cat_head_wearable.v1'), isNull);
      expect(await preferences.getString('other.feature.setting'), 'keep');
      final wallet = FishWallet();
      await wallet.load();
      expect(wallet.balance, 725);
    },
  );

  test(
    'existing account keeps balance and Rubik receipt deduplication',
    () async {
      final account = jsonEncode({
        'balance': 875,
        'credits': ['rubik:user:match:1'],
      });
      final preferences = SharedPreferencesAsync();
      await preferences.setString(FishWallet.accountKey, account);

      await removeRetiredFeatureStorage();

      expect(await preferences.getString(FishWallet.accountKey), account);
      final wallet = FishWallet();
      await wallet.load();
      expect(wallet.balance, 875);
      expect(
        await wallet.creditChallengeReceipt('rubik:user:match:1', 50),
        isFalse,
      );
      expect(wallet.balance, 875);
      expect(
        await wallet.creditChallengeReceipt('rubik:user:match:2', 25),
        isTrue,
      );
      final restarted = FishWallet();
      await restarted.load();
      expect(restarted.balance, 900);
      expect(
        await restarted.creditChallengeReceipt('rubik:user:match:2', 25),
        isFalse,
      );
    },
  );
}
