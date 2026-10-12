import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nhom_bar/games/gacha/screens/gacha_screen.dart';
import 'package:nhom_bar/games/gacha/services/gacha_collection.dart';
import 'package:nhom_bar/games/gacha/services/gacha_collection_storage.dart';
import 'package:nhom_bar/games/gacha/services/gacha_wallet.dart';
import 'package:nhom_bar/games/gacha/widgets/gacha_cinematic_viewer.dart';
import 'package:nhom_bar/games/gacha/widgets/reward_model_viewer.dart';
import 'package:nhom_bar/games/gacha/widgets/tear_ticket.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _rounds = int.fromEnvironment('GACHA_TEST_ROUNDS', defaultValue: 20);

class _NonLaRandom implements Random {
  @override
  int nextInt(int max) => 1;
  @override
  bool nextBool() => false;
  @override
  double nextDouble() => .1;
}

class _MemoryCollection implements GachaCollectionStorage {
  Set<int> owned = {};
  @override
  Future<Set<int>> readOwnedNumbers() async => owned;
  @override
  Future<void> writeOwnedNumbers(Set<int> value) async {
    owned = {...value};
  }
}

class _Host extends StatefulWidget {
  const _Host();
  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool active = true;
  final collection = GachaCollection(storage: _MemoryCollection());
  final wallet = GachaWallet(initialBalance: _rounds * 100, persist: false);
  @override
  void dispose() {
    collection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: IndexedStack(
        index: active ? 0 : 1,
        children: [
          GachaScreen(
            isActive: active,
            collection: collection,
            wallet: wallet,
            random: _NonLaRandom(),
          ),
          const Center(child: Text('Lobby thử nghiệm')),
        ],
      ),
      bottomNavigationBar: Row(
        children: [
          TextButton(
            key: const ValueKey('device-lobby'),
            onPressed: () => setState(() => active = false),
            child: const Text('Lobby'),
          ),
          TextButton(
            key: const ValueKey('device-gacha'),
            onPressed: () => setState(() => active = true),
            child: const Text('Gacha'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _waitModel(WidgetTester tester) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (find.text('Nón lá · Kéo ngang để xoay').evaluate().isNotEmpty &&
        find.text('Đang tải model 3D…').evaluate().isEmpty) {
      expect(find.byKey(const ValueKey('gacha-model-fallback')), findsNothing);
      expect(find.byKey(const ValueKey('gacha-three-webview')), findsOneWidget);
      for (var j = 0; j < 20; j++) {
        await tester.pump(const Duration(milliseconds: 100));
        if ((await _snapshot(tester))['running'] == false) return;
      }
      fail('Three cinematic did not settle');
    }
  }
  fail('Non la did not load in 50 seconds');
}

Future<Map<String, dynamic>> _snapshot(WidgetTester tester) async {
  final controller = tester
      .widget<WebViewWidget>(find.byKey(const ValueKey('gacha-three-webview')))
      .platform
      .params
      .controller;
  dynamic value = await controller.runJavaScriptReturningResult(
    'JSON.stringify(window.gachaSnapshot?.() ?? {})',
  );
  if (value is String) value = jsonDecode(value);
  if (value is String) value = jsonDecode(value);
  return Map<String, dynamic>.from(value as Map);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    '$_rounds native GLB turns, close/reopen/next and Lobby lifecycle',
    (tester) async {
      await tester.pumpWidget(const _Host());
      final draw = find.byKey(const ValueKey('gacha-draw-button'));
      await tester.tap(draw);
      for (var turn = 0; turn < _rounds; turn++) {
        await tester.pumpAndSettle();
        final ticket = find.byKey(const ValueKey('gacha-ticket-drag'));
        final width = tester.getSize(ticket).width;
        final direction = turn.isEven ? 1.0 : -1.0;
        // Stop halfway, release, reverse, then finish slowly/quickly.
        await tester.timedDrag(
          ticket,
          Offset(direction * width * .25, 0),
          const Duration(milliseconds: 600),
        );
        await tester.pump();
        final partial = tester
            .widget<TearTicket>(find.byType(TearTicket))
            .progress;
        expect(partial, greaterThan(0));
        expect(find.byKey(const ValueKey('gacha-result')), findsNothing);
        if (turn == 0) {
          debugPrint('[GachaDeviceTest] partial-ready');
          await tester.pump(const Duration(seconds: 4));
        }
        await tester.timedDrag(
          ticket,
          Offset(-direction * width * .2, 0),
          const Duration(milliseconds: 250),
        );
        await tester.pump();
        expect(
          tester.widget<TearTicket>(find.byType(TearTicket)).progress,
          partial,
        );
        await tester.timedDrag(
          ticket,
          Offset(direction * width * .85, 0),
          Duration(milliseconds: turn.isEven ? 900 : 150),
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 300));
        await _waitModel(tester);
        final settled = await _snapshot(tester);
        expect(settled['raf'], 0);
        await tester.pump(const Duration(milliseconds: 300));
        expect((await _snapshot(tester))['rendered'], settled['rendered']);
        await tester.timedDrag(
          find.byKey(const ValueKey('gacha-three-webview')),
          const Offset(60, 0),
          const Duration(milliseconds: 500),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect((await _snapshot(tester))['orbitReported'], isTrue);
        await tester.tap(find.byKey(const ValueKey('gacha-result-close')));
        await tester.pumpAndSettle();
        expect(find.byType(GachaCinematicViewer), findsNothing);
        await tester.tap(find.byKey(const ValueKey('gacha-show-result')));
        await _waitModel(tester);
        await tester.tap(find.byKey(const ValueKey('device-lobby')));
        await tester.pumpAndSettle();
        expect(
          find.byType(GachaCinematicViewer, skipOffstage: false),
          findsNothing,
        );
        await tester.tap(find.byKey(const ValueKey('device-gacha')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('gacha-show-result')));
        await _waitModel(tester);
        debugPrint('[GachaDeviceTest] completed turn ${turn + 1}/$_rounds');
        if (turn < _rounds - 1) {
          await tester.tap(find.byKey(const ValueKey('gacha-result-next')));
        } else {
          await tester.tap(find.byKey(const ValueKey('gacha-result-close')));
        }
        await tester.pumpAndSettle();
        expect(find.byType(GachaCinematicViewer), findsNothing);
        expect(tester.takeException(), isNull);
      }
      expect(find.text('0 cá'), findsOneWidget);
      await tester.tap(draw);
      await tester.pumpAndSettle();
      expect(find.textContaining('Không đủ 100 cá'), findsOneWidget);
      // Simulate a WebGL context loss: release Three before legacy GLB mounts.
      await tester.tap(find.byKey(const ValueKey('gacha-show-result')));
      await _waitModel(tester);
      final controller = tester
          .widget<WebViewWidget>(
            find.byKey(const ValueKey('gacha-three-webview')),
          )
          .platform
          .params
          .controller;
      await controller.runJavaScript(
        "document.querySelector('canvas').dispatchEvent(new Event('webglcontextlost', {cancelable:true}));",
      );
      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byType(RewardModelViewer).evaluate().isNotEmpty &&
            find.text('Đang tải model 3D…').evaluate().isEmpty) {
          break;
        }
      }
      expect(find.byKey(const ValueKey('gacha-three-webview')), findsNothing);
      expect(find.byType(RewardModelViewer), findsOneWidget);
      expect(find.byKey(const ValueKey('gacha-model-fallback')), findsNothing);
      expect(find.text('Đang tải model 3D…'), findsNothing);
      debugPrint('[GachaDeviceTest] simulated context loss fallback passed');
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}
