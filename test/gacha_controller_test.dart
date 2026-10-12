import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/gacha/controllers/gacha_controller.dart';
import 'package:nhom_bar/games/gacha/models/gacha_ticket_state.dart';
import 'package:nhom_bar/games/gacha/services/gacha_collection.dart';
import 'package:nhom_bar/games/gacha/services/gacha_collection_storage.dart';
import 'package:nhom_bar/games/gacha/services/gacha_wallet.dart';

class _Storage implements GachaCollectionStorage {
  Set<int> saved = {};
  int writes = 0;
  bool fail = false;
  @override
  Future<Set<int>> readOwnedNumbers() async => saved;
  @override
  Future<void> writeOwnedNumbers(Set<int> numbers) async {
    if (fail) throw StateError('disk unavailable');
    writes++;
    saved = {...numbers};
  }
}

class _Random implements Random {
  int calls = 0;
  @override
  int nextInt(int max) {
    calls++;
    return 1;
  }

  @override
  bool nextBool() => false;
  @override
  double nextDouble() => .1;
}

void main() {
  testWidgets(
    'one charge/random, guarded states, duplicate and clean next turn',
    (tester) async {
      final storage = _Storage();
      final collection = GachaCollection(storage: storage);
      final random = _Random();
      final wallet = GachaWallet(initialBalance: 200, persist: false);
      final c = GachaController(
        collection: collection,
        wallet: wallet,
        random: random,
      );
      final draw = c.draw();
      expect(c.state, GachaTicketState.selecting);
      expect(await c.draw(), false);
      expect(await draw, true);
      expect(wallet.balance, 100);
      expect(random.calls, 1);
      expect(c.state, GachaTicketState.paperFocus);
      c.tear(.9);
      expect(c.progress, 0);
      await tester.pump(const Duration(milliseconds: 280));
      c.tear(.3);
      c.endTear();
      expect(c.progress, .3);
      c.tear(-.2);
      expect(c.progress, .3);
      c.tear(.8);
      expect(c.state, GachaTicketState.numberReveal);
      expect(await c.draw(), false);
      await tester.pump(const Duration(milliseconds: 500));
      expect(c.state, GachaTicketState.prizeLookup);
      await tester.pump(const Duration(milliseconds: 600));
      expect(c.state, GachaTicketState.itemReveal);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(c.state, GachaTicketState.result);
      expect(storage.writes, 1);
      await Future.wait([c.collect(), c.collect()]);
      expect(storage.writes, 1);
      c.closeResult();
      c.reopenResult();
      expect(c.resultVisible, true);
      expect(wallet.balance, 100);
      expect(random.calls, 1);
      expect(await c.draw(), true);
      expect(c.duplicate, true);
      expect(c.result, null);
      expect(c.progress, 0);
      expect(c.resultVisible, false);
      await tester.pump(const Duration(milliseconds: 280));
      c.tear(.8);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(storage.writes, 1);
      expect(await c.draw(), false);
      expect(c.message, contains('Không đủ 100 cá'));
      expect(wallet.balance, 0);
      expect(random.calls, 2);
      expect(c.result, isNotNull);
      c.dispose();
      collection.dispose();
    },
  );
  testWidgets(
    'leaving tab during reveal collects safely without mounting result',
    (tester) async {
      final collection = GachaCollection(storage: _Storage());
      final c = GachaController(
        collection: collection,
        wallet: GachaWallet(persist: false),
      );
      await c.draw();
      await tester.pump(const Duration(milliseconds: 280));
      c.tear(.8);
      c.setActive(false);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(c.resultVisible, false);
      expect(collection.unlockedCount, 1);
      c.setActive(true);
      c.reopenResult();
      expect(c.resultVisible, true);
      c.dispose();
      collection.dispose();
    },
  );
  testWidgets('failed award remains retryable and repeated claim writes once', (
    tester,
  ) async {
    final storage = _Storage()..fail = true;
    final collection = GachaCollection(storage: storage);
    final c = GachaController(
      collection: collection,
      wallet: GachaWallet(persist: false),
    );
    await c.draw();
    await tester.pump(const Duration(milliseconds: 280));
    c.tear(.8);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(collection.unlockedCount, 0);
    storage.fail = false;
    await Future.wait([c.collect(), c.collect()]);
    expect(storage.writes, 1);
    expect(collection.unlockedCount, 1);
    c.dispose();
    collection.dispose();
  });
  test(
    'wallet serializes competing charges and persists across recreation',
    () async {
      final wallet = GachaWallet(initialBalance: 100);
      expect(await Future.wait([wallet.spend(), wallet.spend()]), [
        true,
        false,
      ]);
      final restored = GachaWallet();
      await restored.load();
      expect(restored.balance, 0);
    },
  );
}
