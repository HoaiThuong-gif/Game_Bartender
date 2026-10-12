import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nhom_bar/games/gacha/services/gacha_wallet.dart';
import 'package:nhom_bar/games/rubik/challenge/models/rubik_room.dart';
import 'package:nhom_bar/games/rubik/challenge/services/mock_rubik_challenge_service.dart';
import 'package:nhom_bar/games/rubik/challenge/services/rubik_reward_service.dart';
import 'package:nhom_bar/games/rubik/challenge/screens/rubik_challenge_room_screen.dart';

class _ClockDemo extends MockRubikChallengeRepository {
  int now = 100000;
  @override
  int get serverNow => now;
}

void main() {
  testWidgets(
    'single-device flow: ready, countdown, solved gate, result and rematch',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _ClockDemo();
      final code = await repository.create('Tester');
      await tester.pumpWidget(
        MaterialApp(
          home: RubikChallengeRoomScreen(
            repository: repository,
            code: code,
            cubeBuilder: (_, controller) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: controller.cubePrepared,
                  child: const Text('Load test cube'),
                ),
                TextButton(
                  onPressed: () => controller.cubeSolved(true),
                  child: const Text('Solve test cube'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.widgetWithText(FilledButton, 'Sẵn sàng'));
      await tester.pump();
      await tester.tap(find.text('Load test cube'));
      await tester.pump();
      repository.now += 6000;
      await tester.pump(const Duration(seconds: 6));
      final finish = find.widgetWithText(FilledButton, 'Hoàn thành');
      expect(tester.widget<FilledButton>(finish).onPressed, isNull);
      await tester.tap(find.text('Solve test cube'));
      await tester.pump();
      expect(tester.widget<FilledButton>(finish).onPressed, isNotNull);
      await tester.tap(finish);
      await tester.pump();
      repository.now += 20000;
      await tester.pump(const Duration(seconds: 20));
      await tester.pump();
      expect(find.text('CHIẾN THẮNG'), findsOneWidget);
      expect(find.text('+50 cá (mô phỏng)'), findsOneWidget);
      await tester.tap(find.text('Chơi lại'));
      await tester.pump();
      await tester.pump();
    expect(find.widgetWithText(FilledButton, 'Sẵn sàng'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await repository.dispose();
    },
  );
  test(
    'receipt credits atomically persist and cannot repeat after restart',
    () async {
      final wallet = GachaWallet(initialBalance: 100);
      final results = await Future.wait([
        wallet.creditChallengeReceipt('match:1', 50),
        wallet.creditChallengeReceipt('match:1', 50),
      ]);
      expect(results, [true, false]);
      expect(wallet.balance, 150);
      expect(await wallet.spend(), true);
      final restored = GachaWallet();
      await restored.load();
      expect(restored.balance, 50);
      expect(await restored.creditChallengeReceipt('match:1', 50), false);
      expect(restored.balance, 50);
    },
  );
  test('demo never credits the real wallet', () async {
    final repository = MockRubikChallengeRepository();
    final wallet = GachaWallet(initialBalance: 0, persist: false);
    await RubikRewardService(repository, wallet: wallet).sync();
    expect(wallet.balance, 0);
    await repository.dispose();
  });
  test('timer keeps milliseconds and clamps negative values', () {
    expect(challengeTime(41582), '00:41.582');
    expect(challengeTime(-1), '00:00.000');
  });
}
