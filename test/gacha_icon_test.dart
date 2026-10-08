import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/gacha/data/gacha_rewards.dart';
import 'package:nhom_bar/games/gacha/models/gacha_reward.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_board.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_icon.dart';

class _BrokenIconBundle extends CachingAssetBundle {
  _BrokenIconBundle({required this.corrupt});
  final bool corrupt;

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('.png')) {
      if (corrupt) return ByteData.sublistView(Uint8List.fromList([1, 2, 3]));
      throw FlutterError('Missing icon');
    }
    return rootBundle.load(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('six reward icons match item names and are bundled PNG assets', () async {
    const expected = {
      'Áo bà ba': 'ao_ba_ba.png',
      'Nón lá': 'non_la.png',
      'Khăn rằn': 'khan_ran.png',
      'Dép tổ ong': 'dep_to_ong.png',
      'Mũ tai bèo': 'non_tai_beo.png',
      'Túi vải': 'tui_vai.png',
    };
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    expect(gachaRewards.length, expected.length);
    for (final reward in gachaRewards) {
      expect(
        reward.iconAssetPath,
        'assets/images/gacha/icons/${expected[reward.name]}',
      );
      expect(manifest.listAssets(), contains(reward.iconAssetPath));
      final bytes = await rootBundle.load(reward.iconAssetPath);
      expect(bytes.buffer.asUint8List(bytes.offsetInBytes, 8), [
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
      ]);
      expect(
        reward.modelAssetPath,
        'assets/models/gacha/${expected[reward.name]!.replaceAll('.png', '.glb')}',
      );
      if (reward.number == 2) {
        expect(manifest.listAssets(), contains(reward.modelAssetPath));
      }
    }
  });

  testWidgets('board centers previews without visible reward names', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: RewardBoard(rewards: gachaRewards)),
      ),
    );
    for (final reward in gachaRewards) {
      final row = find.byKey(ValueKey('gacha-reward-${reward.number}'));
      final icon = find.descendant(of: row, matching: find.byType(RewardIcon));
      expect(icon, findsOneWidget);
      expect(tester.widget<RewardIcon>(icon).reward, same(reward));
      expect(tester.widget<RewardIcon>(icon).size, greaterThan(0));
      expect(
        tester.widget<RewardIcon>(icon).size,
        lessThan(tester.getSize(row).width),
      );
      expect(
        find.descendant(
          of: row,
          matching: find.text('${reward.displayNumber} · ${reward.name}'),
        ),
        findsNothing,
      );
      expect(
        (tester.getRect(icon).center - tester.getRect(row).center).distance,
        lessThan(.001),
      );
      final image = tester.widget<Image>(
        find.descendant(of: icon, matching: find.byType(Image)),
      );
      expect(image.fit, BoxFit.contain);
      expect(image.color, isNull);
    }
    expect(tester.takeException(), isNull);
  });

  for (final corrupt in [false, true]) {
    testWidgets('missing/corrupt icon falls back without crash: $corrupt', (
      tester,
    ) async {
      final reward = GachaReward(
        number: 1,
        name: 'Áo bà ba',
        iconAssetPath: 'assets/images/gacha/icons/broken_$corrupt.png',
        modelAssetPath: gachaBenchmarkModelPath,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultAssetBundle(
            bundle: _BrokenIconBundle(corrupt: corrupt),
            child: Scaffold(
              body: Column(
                children: [
                  RewardIcon(reward: reward, size: 144),
                  Text(reward.name),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.card_giftcard_outlined), findsOneWidget);
      expect(find.text(reward.name), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
