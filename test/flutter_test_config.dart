import 'dart:async';

import 'package:nhom_bar/games/bartender/bartender_config.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Widget/Unit tests exercise local persistence without invoking native plugins.
  BartenderConfig.useFakeRepository = true;
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  await testMain();
}
