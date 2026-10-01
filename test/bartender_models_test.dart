import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/bartender/models/ingredient.dart';
import 'package:nhom_bar/games/bartender/models/match_result.dart';
import 'package:nhom_bar/games/bartender/models/match_timer.dart';
import 'package:nhom_bar/games/bartender/models/order.dart';
import 'package:nhom_bar/games/bartender/models/player.dart';
import 'package:nhom_bar/games/bartender/models/recipe.dart';
import 'package:nhom_bar/games/bartender/models/recipe_pool.dart';
import 'package:nhom_bar/games/bartender/models/ring.dart';
import 'package:nhom_bar/games/bartender/models/room.dart';
import 'package:nhom_bar/games/bartender/models/round.dart';
import 'package:nhom_bar/games/bartender/models/station.dart';
import 'package:nhom_bar/games/bartender/models/station_assigner.dart';
import 'package:nhom_bar/games/bartender/models/game_item.dart';

void main() {
  // ─── Ring math ───────────────────────────────────────────────
  group('Ring', () {
    test('2 players: left/right are each other', () {
      expect(Ring.leftNeighbor(0, 2), 1);
      expect(Ring.rightNeighbor(0, 2), 1);
      expect(Ring.leftNeighbor(1, 2), 0);
      expect(Ring.rightNeighbor(1, 2), 0);
    });

    test('3 players: wrap-around works', () {
      // Ring: 0 → 1 → 2 → 0
      expect(Ring.rightNeighbor(0, 3), 1);
      expect(Ring.rightNeighbor(1, 3), 2);
      expect(Ring.rightNeighbor(2, 3), 0); // wrap-around
      expect(Ring.leftNeighbor(0, 3), 2); // wrap-around
      expect(Ring.leftNeighbor(1, 3), 0);
      expect(Ring.leftNeighbor(2, 3), 1);
    });

    test('4 players: neighbors are correct', () {
      expect(Ring.leftNeighbor(0, 4), 3);
      expect(Ring.rightNeighbor(0, 4), 1);
      expect(Ring.leftNeighbor(3, 4), 2);
      expect(Ring.rightNeighbor(3, 4), 0);
    });

    test('works for larger N (generic)', () {
      // Chỉ verify tổng quát, không tối ưu cho > 4.
      expect(Ring.rightNeighbor(9, 10), 0);
      expect(Ring.leftNeighbor(0, 10), 9);
    });
  });

  // ─── Recipe pool ─────────────────────────────────────────────
  group('RecipePool', () {
    test('has 5 recipes total', () {
      expect(RecipePool.allRecipes.length, 5);
    });

    test('recipes are sorted by difficulty', () {
      for (var i = 1; i < RecipePool.allRecipes.length; i++) {
        expect(
          RecipePool.allRecipes[i].difficulty,
          greaterThanOrEqualTo(RecipePool.allRecipes[i - 1].difficulty),
        );
      }
    });

    test('round 1 returns only difficulty 1 recipes', () {
      final recipes = RecipePool.recipesForRound(1);
      expect(recipes, isNotEmpty);
      for (final r in recipes) {
        expect(r.difficulty, 1);
      }
    });

    test('round 2 returns difficulty 1-2', () {
      final recipes = RecipePool.recipesForRound(2);
      expect(recipes.length, greaterThan(RecipePool.recipesForRound(1).length));
      for (final r in recipes) {
        expect(r.difficulty, lessThanOrEqualTo(2));
      }
    });

    test('round 3+ returns all recipes', () {
      final recipes = RecipePool.recipesForRound(3);
      expect(recipes.length, RecipePool.allRecipes.length);
    });

    test('round 99 still returns all (clamp at 3)', () {
      expect(
        RecipePool.recipesForRound(99).length,
        RecipePool.allRecipes.length,
      );
    });

    test('each recipe has non-empty ingredients and steps', () {
      for (final r in RecipePool.allRecipes) {
        expect(r.ingredients, isNotEmpty, reason: '${r.id} has no ingredients');
        expect(r.steps, isNotEmpty, reason: '${r.id} has no steps');
        expect(r.id, isNotEmpty);
        expect(r.name, isNotEmpty);
      }
    });
  });

  // ─── Station assignment ──────────────────────────────────────
  group('StationAssigner', () {
    test('assigns stations for 2 players', () {
      final result = StationAssigner.assign(
        playerCount: 2,
        random: Random(42), // seed cố định để test deterministic
      );
      expect(result.length, 2);
      expect(result.containsKey(0), isTrue);
      expect(result.containsKey(1), isTrue);
    });

    test('assigns stations for 4 players', () {
      final result = StationAssigner.assign(
        playerCount: 4,
        random: Random(42),
      );
      expect(result.length, 4);
    });

    test('can produce null (no station) assignments', () {
      // Với nhiều lần thử, nên có ít nhất 1 lần null xuất hiện.
      var hasNull = false;
      for (var seed = 0; seed < 100; seed++) {
        final result = StationAssigner.assign(
          playerCount: 4,
          random: Random(seed),
        );
        if (result.values.contains(null)) {
          hasNull = true;
          break;
        }
      }
      expect(hasNull, isTrue, reason: 'Expected at least one null assignment');
    });

    test('can produce duplicate station assignments', () {
      var hasDuplicate = false;
      for (var seed = 0; seed < 100; seed++) {
        final result = StationAssigner.assign(
          playerCount: 4,
          random: Random(seed),
        );
        final nonNull = result.values.whereType<StationType>().toList();
        if (nonNull.length != nonNull.toSet().length) {
          hasDuplicate = true;
          break;
        }
      }
      expect(
        hasDuplicate,
        isTrue,
        reason: 'Expected at least one duplicate',
      );
    });
  });

  // ─── Round completion ────────────────────────────────────────
  group('Round', () {
    late Round round;

    setUp(() {
      round = Round(
        number: 1,
        ordersPerPlayer: 3,
        stationAssignment: {0: StationType.juicer, 1: StationType.blender},
        playerOrders: {
          'p1': [
            const Order(id: 'o1', recipeId: 'orange_juice'),
            const Order(id: 'o2', recipeId: 'lemonade'),
            const Order(id: 'o3', recipeId: 'orange_juice'),
          ],
          'p2': [
            const Order(id: 'o4', recipeId: 'orange_juice'),
            const Order(id: 'o5', recipeId: 'lemonade'),
            const Order(id: 'o6', recipeId: 'orange_juice'),
          ],
        },
      );
    });

    test('round is not complete when no orders are submitted', () {
      expect(round.isComplete, isFalse);
    });

    test('isPlayerDone returns false when orders are pending', () {
      expect(round.isPlayerDone('p1'), isFalse);
    });

    test('completedCount is 0 initially', () {
      expect(round.completedCount('p1'), 0);
    });

    test('round is not complete when only one player is done', () {
      // Tạo round mới với p1 đã xong hết, p2 chưa.
      final partialRound = Round(
        number: 1,
        ordersPerPlayer: 3,
        stationAssignment: round.stationAssignment,
        playerOrders: {
          'p1': [
            const Order(
              id: 'o1',
              recipeId: 'r1',
              status: OrderStatus.submitted,
            ),
            const Order(
              id: 'o2',
              recipeId: 'r2',
              status: OrderStatus.submitted,
            ),
            const Order(
              id: 'o3',
              recipeId: 'r3',
              status: OrderStatus.submitted,
            ),
          ],
          'p2': [
            const Order(id: 'o4', recipeId: 'r1'),
            const Order(id: 'o5', recipeId: 'r2'),
            const Order(id: 'o6', recipeId: 'r3'),
          ],
        },
      );
      expect(partialRound.isPlayerDone('p1'), isTrue);
      expect(partialRound.isPlayerDone('p2'), isFalse);
      expect(partialRound.isComplete, isFalse);
    });

    test('round is complete when all players are done', () {
      final doneRound = Round(
        number: 1,
        ordersPerPlayer: 3,
        stationAssignment: round.stationAssignment,
        playerOrders: {
          'p1': [
            const Order(
              id: 'o1',
              recipeId: 'r1',
              status: OrderStatus.submitted,
            ),
            const Order(
              id: 'o2',
              recipeId: 'r2',
              status: OrderStatus.submitted,
            ),
            const Order(
              id: 'o3',
              recipeId: 'r3',
              status: OrderStatus.submitted,
            ),
          ],
          'p2': [
            const Order(
              id: 'o4',
              recipeId: 'r1',
              status: OrderStatus.submitted,
            ),
            const Order(
              id: 'o5',
              recipeId: 'r2',
              status: OrderStatus.submitted,
            ),
            const Order(
              id: 'o6',
              recipeId: 'r3',
              status: OrderStatus.submitted,
            ),
          ],
        },
      );
      expect(doneRound.isComplete, isTrue);
      expect(doneRound.completedCount('p1'), 3);
      expect(doneRound.completedCount('p2'), 3);
    });
  });

  // ─── Match timer ─────────────────────────────────────────────
  group('MatchTimer', () {
    test('starts with 60 seconds', () {
      final timer = MatchTimer.start(nowMs: 1000);
      expect(timer.startedAt, 1000);
      expect(timer.endTime, 1000 + 60000);
    });

    test('remaining time decreases over time', () {
      final timer = MatchTimer.start(nowMs: 0);
      expect(timer.remainingMs(nowMs: 0), 60000);
      expect(timer.remainingMs(nowMs: 30000), 30000);
      expect(timer.remainingMs(nowMs: 60000), 0);
    });

    test('remaining time never goes negative', () {
      final timer = MatchTimer.start(nowMs: 0);
      expect(timer.remainingMs(nowMs: 999999), 0);
    });

    test('isExpired after time runs out', () {
      final timer = MatchTimer.start(nowMs: 0);
      expect(timer.isExpired(nowMs: 59999), isFalse);
      expect(timer.isExpired(nowMs: 60000), isTrue);
      expect(timer.isExpired(nowMs: 60001), isTrue);
    });

    test('withBonus adds 5 seconds', () {
      final timer = MatchTimer.start(nowMs: 0);
      final bonused = timer.withBonus();
      expect(bonused.endTime, timer.endTime + 5000);
      expect(bonused.startedAt, timer.startedAt);
    });

    test('multiple bonuses stack', () {
      var timer = MatchTimer.start(nowMs: 0);
      timer = timer.withBonus().withBonus().withBonus();
      expect(timer.endTime, 60000 + 15000);
    });

    test('server offset correction', () {
      final timer = MatchTimer.start(nowMs: 0);
      // Client clock is 2s behind server → offset = +2000ms.
      // Real server time = nowMs + offset = 58000 + 2000 = 60000 → expired.
      expect(timer.isExpired(nowMs: 58000, serverOffsetMs: 2000), isTrue);
      // Without offset, 58s client time → 2s remaining.
      expect(timer.isExpired(nowMs: 58000), isFalse);
    });

    test('totalSurvivalSeconds', () {
      final timer = MatchTimer.start(nowMs: 0);
      expect(timer.totalSurvivalSeconds(nowMs: 65000), 65);
    });
  });

  // ─── Order ──────────────────────────────────────────────────
  group('Order', () {
    test('defaults to pending', () {
      const order = Order(id: 'o1', recipeId: 'r1');
      expect(order.status, OrderStatus.pending);
      expect(order.isCompleted, isFalse);
    });

    test('copyWith updates status', () {
      const order = Order(id: 'o1', recipeId: 'r1');
      final submitted = order.copyWith(status: OrderStatus.submitted);
      expect(submitted.isCompleted, isTrue);
      expect(submitted.id, 'o1');
      expect(submitted.recipeId, 'r1');
    });
  });

  // ─── Player ─────────────────────────────────────────────────
  group('Player', () {
    test('copyWith preserves unchanged fields', () {
      const player = Player(id: 'p1', name: 'Alice', ringIndex: 0);
      final disconnected = player.copyWith(connected: false);
      expect(disconnected.id, 'p1');
      expect(disconnected.name, 'Alice');
      expect(disconnected.ringIndex, 0);
      expect(disconnected.connected, isFalse);
    });

    test('equality works', () {
      const a = Player(id: 'p1', name: 'A', ringIndex: 0);
      const b = Player(id: 'p1', name: 'A', ringIndex: 0);
      expect(a, equals(b));
    });
  });

  // ─── Room ───────────────────────────────────────────────────
  group('Room', () {
    test('canStart requires lobby + 2 connected players', () {
      final room = Room(
        code: '1234',
        status: RoomStatus.lobby,
        players: {
          'p1': const Player(id: 'p1', name: 'A', ringIndex: 0),
          'p2': const Player(id: 'p2', name: 'B', ringIndex: 1),
        },
      );
      expect(room.canStart, isTrue);
    });

    test('canStart is false with 1 player', () {
      final room = Room(
        code: '1234',
        status: RoomStatus.lobby,
        players: {
          'p1': const Player(id: 'p1', name: 'A', ringIndex: 0),
        },
      );
      expect(room.canStart, isFalse);
    });

    test('canStart is false when playing', () {
      final room = Room(
        code: '1234',
        status: RoomStatus.playing,
        players: {
          'p1': const Player(id: 'p1', name: 'A', ringIndex: 0),
          'p2': const Player(id: 'p2', name: 'B', ringIndex: 1),
        },
      );
      expect(room.canStart, isFalse);
    });

    test('playerAtRing returns correct player', () {
      final room = Room(
        code: '1234',
        status: RoomStatus.lobby,
        players: {
          'p1': const Player(id: 'p1', name: 'A', ringIndex: 0),
          'p2': const Player(id: 'p2', name: 'B', ringIndex: 1),
        },
      );
      expect(room.playerAtRing(0)?.name, 'A');
      expect(room.playerAtRing(1)?.name, 'B');
      expect(room.playerAtRing(2), isNull);
    });

    test('connectedPlayerCount excludes disconnected', () {
      final room = Room(
        code: '1234',
        status: RoomStatus.playing,
        players: {
          'p1': const Player(id: 'p1', name: 'A', ringIndex: 0),
          'p2': const Player(
            id: 'p2',
            name: 'B',
            ringIndex: 1,
            connected: false,
          ),
          'p3': const Player(id: 'p3', name: 'C', ringIndex: 2),
        },
      );
      expect(room.connectedPlayerCount, 2);
      expect(room.totalPlayerCount, 3);
    });
  });

  // ─── Match result ────────────────────────────────────────────
  group('MatchResult', () {
    test('ranks players by completedOrders descending', () {
      final result = MatchResult.fromPlayers(
        players: [
          const Player(
            id: 'p1',
            name: 'A',
            ringIndex: 0,
            completedOrders: 3,
          ),
          const Player(
            id: 'p2',
            name: 'B',
            ringIndex: 1,
            completedOrders: 7,
          ),
          const Player(
            id: 'p3',
            name: 'C',
            ringIndex: 2,
            completedOrders: 5,
          ),
        ],
        survivalSeconds: 120,
      );

      expect(result.ranking[0].name, 'B'); // 7 orders — first
      expect(result.ranking[1].name, 'C'); // 5 orders
      expect(result.ranking[2].name, 'A'); // 3 orders — last
      expect(result.totalTeamOrders, 15);
      expect(result.totalSurvivalSeconds, 120);
    });
  });

  // ─── GameItem ────────────────────────────────────────────────
  group('GameItem', () {
    test('equality works', () {
      const a = GameItem(
        id: 'i1',
        type: GameItemType.ingredient,
        itemId: 'orange',
        fromRingIndex: 0,
      );
      const b = GameItem(
        id: 'i1',
        type: GameItemType.ingredient,
        itemId: 'orange',
        fromRingIndex: 0,
      );
      expect(a, equals(b));
    });
  });

  // ─── Recipe model ────────────────────────────────────────────
  group('Recipe', () {
    test('recipe step has station and description', () {
      const step = RecipeStep(
        station: StationType.juicer,
        description: 'Ép cam',
      );
      expect(step.station, StationType.juicer);
      expect(step.description, isNotEmpty);
    });

    test('all ingredients are used in at least one recipe', () {
      final usedIngredients = <Ingredient>{};
      for (final r in RecipePool.allRecipes) {
        usedIngredients.addAll(r.ingredients);
      }
      for (final ing in Ingredient.values) {
        expect(
          usedIngredients.contains(ing),
          isTrue,
          reason: '$ing is not used in any recipe',
        );
      }
    });

    test('all stations are used in at least one recipe', () {
      final usedStations = <StationType>{};
      for (final r in RecipePool.allRecipes) {
        for (final s in r.steps) {
          usedStations.add(s.station);
        }
      }
      for (final st in StationType.values) {
        expect(
          usedStations.contains(st),
          isTrue,
          reason: '$st is not used in any recipe',
        );
      }
    });
  });
}
