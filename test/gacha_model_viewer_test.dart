import 'package:nhom_bar/games/gacha/services/gacha_collection.dart';
import 'package:nhom_bar/games/gacha/services/gacha_wallet.dart';

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:nhom_bar/games/gacha/data/gacha_rewards.dart';
import 'package:nhom_bar/games/gacha/models/gacha_reward.dart';
import 'package:nhom_bar/games/gacha/screens/gacha_screen.dart';
import 'package:nhom_bar/games/gacha/widgets/tear_ticket.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_model_viewer.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_board.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_icon.dart';
import 'package:webview_flutter/webview_flutter.dart';

class _Bundle extends CachingAssetBundle {
  _Bundle(this.paths);
  final List<String> paths;
  final requests = <String>[];
  Completer<ByteData>? pending;

  @override
  Future<ByteData> load(String key) async {
    // UI image reads are independent of the model lifecycle under test.
    if (key.startsWith('assets/images/gacha/')) {
      return rootBundle.load(key);
    }
    requests.add(key);
    if (pending != null) return pending!.future;
    if (key != 'AssetManifest.bin') {
      throw FlutterError('Unexpected asset read: $key');
    }
    return const StandardMessageCodec().encodeMessage({
      for (final path in paths)
        path: [
          {'asset': path},
        ],
    })!;
  }
}

class _DrawRandom implements Random {
  int draws = 0;
  @override
  int nextInt(int max) => (draws++ + 1) % max;
  @override
  bool nextBool() => throw UnimplementedError();
  @override
  double nextDouble() => throw UnimplementedError();
}

class _Probe extends StatefulWidget {
  const _Probe({super.key, required this.onDispose, this.onMount});
  final VoidCallback onDispose;
  final VoidCallback? onMount;
  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.onMount?.call();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

GachaReward _reward(String path) => GachaReward(
  number: 1,
  name: 'Món thử',
  iconAssetPath: gachaRewards.first.iconAssetPath,
  modelAssetPath: path,
);

Widget _app(
  _Bundle bundle,
  GachaReward? reward,
  Widget Function(ModelViewer)? builder,
) => MaterialApp(
  home: Scaffold(
    body: DefaultAssetBundle(
      bundle: bundle,
      child: RewardModelViewer(reward: reward, viewerBuilder: builder),
    ),
  ),
);

void main() {
  testWidgets(
    'result panel owns viewer through close, reopen, tabs and next draw',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final bundle = _Bundle([gachaRewards[1].modelAssetPath]);
      final random = _DrawRandom();
      var creates = 0;
      var disposed = 0;
      Widget app(bool active) => MaterialApp(
        home: DefaultAssetBundle(
          bundle: bundle,
          child: GachaScreen(
            wallet: GachaWallet(persist: false),
            collection: GachaCollection(),
            random: random,
            isActive: active,
            viewerBuilder: (viewer) {
              expect(viewer.src, gachaRewards[1].modelAssetPath);
              return _Probe(
                onMount: () => creates++,
                onDispose: () => disposed++,
              );
            },
          ),
        ),
      );
      await tester.pumpWidget(app(true));
      await tester.tap(find.byKey(const ValueKey('gacha-draw-button')));
      await tester.pumpAndSettle();
      tester.widget<TearTicket>(find.byType(TearTicket)).onDrag(.8);
      await tester.pump();
      expect(find.byKey(const ValueKey('gacha-result')), findsNothing);
      expect(creates, 0);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('gacha-result')), findsOneWidget);
      expect(creates, 1);
      expect(
        tester
            .widget<RewardIcon>(find.byKey(const ValueKey('gacha-result-icon')))
            .reward,
        same(gachaRewards[1]),
      );
      expect(
        tester.widget<RewardBoard>(find.byType(RewardBoard)).selectedNumber,
        2,
      );
      await tester.tap(find.byKey(const ValueKey('gacha-result-close')));
      await tester.pumpAndSettle();
      expect(disposed, 1);
      expect(find.byType(_Probe), findsNothing);
      expect(random.draws, 1);
      await tester.tap(find.byKey(const ValueKey('gacha-show-result')));
      await tester.pumpAndSettle();
      expect(creates, 2);
      await tester.pumpWidget(app(false));
      expect(disposed, 2);
      await tester.pumpWidget(app(true));
      await tester.pumpAndSettle();
      expect(find.byType(_Probe), findsNothing);
      expect(
        tester.widget<RewardBoard>(find.byType(RewardBoard)).selectedNumber,
        2,
      );
      await tester.tap(find.byKey(const ValueKey('gacha-show-result')));
      await tester.pumpAndSettle();
      expect(creates, 3);
      await tester.tap(find.byKey(const ValueKey('gacha-result-next')));
      await tester.pumpAndSettle();
      expect(disposed, 3);
      expect(random.draws, 2);
      expect(find.byKey(const ValueKey('gacha-result')), findsNothing);
      expect(
        tester.widget<RewardBoard>(find.byType(RewardBoard)).selectedNumber,
        isNull,
      );
      final fresh = tester.widget<TearTicket>(find.byType(TearTicket));
      expect(fresh.reward, same(gachaRewards[2]));
      expect(fresh.progress, 0);
      expect(fresh.revealed, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  test('each reward has its own model path; missing models use PNG', () {
    expect(
      gachaRewards.singleWhere((reward) => reward.number == 2).modelAssetPath,
      'assets/models/gacha/non_la.glb',
    );
    expect(
      gachaRewards
          .where((reward) => reward.number != 2)
          .map((reward) => reward.modelAssetPath),
      everyElement(isNot(gachaBenchmarkModelPath)),
    );
  });

  testWidgets('unrevealed reward performs no asset read or viewer creation', (
    tester,
  ) async {
    final bundle = _Bundle([gachaBenchmarkModelPath]);
    var creates = 0;
    await tester.pumpWidget(
      _app(bundle, null, (_) {
        creates++;
        return const SizedBox();
      }),
    );
    expect(bundle.requests, isEmpty);
    expect(creates, 0);
  });

  testWidgets('missing asset shows fallback without mounting WebView', (
    tester,
  ) async {
    final bundle = _Bundle([]);
    var creates = 0;
    await tester.pumpWidget(
      _app(bundle, _reward(gachaBenchmarkModelPath), (_) {
        creates++;
        return const SizedBox();
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa có model 3D cho vật phẩm này'), findsOneWidget);
    expect(creates, 0);
    expect(bundle.requests, ['AssetManifest.bin']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('URL and invalid paths never load assets or viewer', (
    tester,
  ) async {
    final bundle = _Bundle([]);
    for (final path in [
      'https://example.com/test.glb',
      'assets/models/gacha/../test.glb',
      'assets/models/gacha/test.png',
    ]) {
      await tester.pumpWidget(
        _app(
          bundle,
          _reward(path),
          (_) => throw StateError('Viewer should not be created'),
        ),
      );
      expect(
        find.text('Đường dẫn model GLB local không hợp lệ'),
        findsOneWidget,
      );
    }
    // PNG fallback may request its image manifest; no model bytes are read.
    expect(bundle.requests, everyElement('AssetManifest.bin'));
  });

  testWidgets(
    'viewer config, load event, path change and reset release old viewer',
    (tester) async {
      const other = 'assets/models/gacha/other_test.glb';
      final bundle = _Bundle([gachaBenchmarkModelPath, other]);
      late ModelViewer viewer;
      var disposed = 0;
      Widget buildViewer(ModelViewer value) {
        viewer = value;
        return _Probe(key: value.key, onDispose: () => disposed++);
      }

      await tester.pumpWidget(
        _app(bundle, _reward(gachaBenchmarkModelPath), buildViewer),
      );
      await tester.pumpAndSettle();
      expect(viewer.src, gachaBenchmarkModelPath);
      expect(viewer.ar, isFalse);
      expect(viewer.autoRotate, isFalse);
      expect(viewer.autoPlay, isFalse);
      expect(viewer.shadowIntensity, 0);
      expect(viewer.cameraControls, isTrue);
      expect(find.text('Đang tải model 3D…'), findsOneWidget);
      viewer.javascriptChannels!.single.onMessageReceived(
        const JavaScriptMessage(message: 'loaded'),
      );
      await tester.pump();
      expect(find.text('Đang tải model 3D…'), findsNothing);

      final staleChannel = viewer.javascriptChannels!.single;
      await tester.pumpWidget(_app(bundle, _reward(other), buildViewer));
      await tester.pumpAndSettle();
      expect(disposed, 1);
      expect(viewer.src, other);
      staleChannel.onMessageReceived(const JavaScriptMessage(message: 'error'));
      await tester.pump();
      expect(find.text('Không thể hiển thị model 3D này'), findsNothing);
      await tester.pumpWidget(_app(bundle, null, buildViewer));
      expect(disposed, 2);
      expect(
        bundle.requests.every((path) => path == 'AssetManifest.bin'),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('renderer error shows fallback and removes viewer', (
    tester,
  ) async {
    final bundle = _Bundle([gachaBenchmarkModelPath]);
    late ModelViewer viewer;
    var disposed = 0;
    await tester.pumpWidget(
      _app(bundle, _reward(gachaBenchmarkModelPath), (value) {
        viewer = value;
        return _Probe(onDispose: () => disposed++);
      }),
    );
    await tester.pumpAndSettle();
    viewer.javascriptChannels!.single.onMessageReceived(
      const JavaScriptMessage(message: 'error'),
    );
    await tester.pump();
    expect(find.text('Không thể hiển thị model 3D này'), findsOneWidget);
    expect(disposed, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('late asset check after leaving does not recreate viewer', (
    tester,
  ) async {
    final bundle = _Bundle([])..pending = Completer<ByteData>();
    var creates = 0;
    await tester.pumpWidget(
      _app(bundle, _reward(gachaBenchmarkModelPath), (_) {
        creates++;
        return const SizedBox();
      }),
    );
    await tester.pumpWidget(const SizedBox());
    bundle.pending!.complete(
      const StandardMessageCodec().encodeMessage({
        gachaBenchmarkModelPath: [
          {'asset': gachaBenchmarkModelPath},
        ],
      })!,
    );
    await tester.pump();
    expect(creates, 0);
    expect(tester.takeException(), isNull);
  });
}
