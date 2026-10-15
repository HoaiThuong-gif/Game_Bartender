import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/bartender/models/round_setup.dart';
import 'package:nhom_bar/games/bartender/models/station.dart';

void main() {
  group('RoundSetup.feasibleFor', () {
    test('assignment chỉ có blender ở round 1 phải trả danh sách rỗng', () {
      final feasible = RoundSetup.feasibleFor(
        assignment: {0: StationType.blender},
        roundNumber: 1,
      );
      expect(feasible, isEmpty);
    });

    test('assignment có juicer ở round 1 phải gồm orange_juice và lemonade', () {
      final feasible = RoundSetup.feasibleFor(
        assignment: {0: StationType.juicer},
        roundNumber: 1,
      );
      final recipeIds = feasible.map((r) => r.id).toList();
      expect(recipeIds, containsAll(['orange_juice', 'lemonade']));
    });

    test('assignment có juicer + shaker ở round 3 phải gồm citrus_cocktail', () {
      final feasible = RoundSetup.feasibleFor(
        assignment: {
          0: StationType.juicer,
          1: StationType.shaker,
        },
        roundNumber: 3,
      );
      final recipeIds = feasible.map((r) => r.id).toList();
      expect(recipeIds, contains('citrus_cocktail'));
    });
  });

  group('RoundSetup.generate', () {
    test(
        '(a) mọi công thức trong feasibleRecipes đều làm được bằng các trạm đang có (dùng feasibleFor làm đối chứng)',
        () {
      for (var playerCount = 2; playerCount <= 4; playerCount++) {
        final playerIds = List.generate(playerCount, (i) => 'p$i');
        for (var round = 1; round <= 4; round++) {
          for (var seed = 0; seed < 200; seed++) {
            final setup = RoundSetup.generate(
              playerIds: playerIds,
              roundNumber: round,
              rng: Random(seed),
            );
            final expected = RoundSetup.feasibleFor(
              assignment: setup.stationAssignment,
              roundNumber: round,
            );
            expect(
              setup.feasibleRecipes.map((r) => r.id).toSet(),
              equals(expected.map((r) => r.id).toSet()),
            );
            final availableStations =
                setup.stationAssignment.values.whereType<StationType>().toSet();
            for (final recipe in setup.feasibleRecipes) {
              for (final step in recipe.steps) {
                expect(availableStations.contains(step.station), isTrue);
              }
            }
          }
        }
      }
    });

    test('(b) round 1 luôn có ít nhất một người giữ máy ép (juicer)', () {
      for (var playerCount = 2; playerCount <= 4; playerCount++) {
        final playerIds = List.generate(playerCount, (i) => 'p$i');
        for (var seed = 0; seed < 200; seed++) {
          final setup = RoundSetup.generate(
            playerIds: playerIds,
            roundNumber: 1,
            rng: Random(seed),
          );
          expect(
            setup.stationAssignment.values.contains(StationType.juicer),
            isTrue,
            reason:
                'playerCount=$playerCount, seed=$seed thiếu juicer ở round 1',
          );
        }
      }
    });

    test(
        '(c) các trạm của công thức "mỏ neo" luôn được giao cho các người KHÁC NHAU',
        () {
      for (var playerCount = 2; playerCount <= 4; playerCount++) {
        final playerIds = List.generate(playerCount, (i) => 'p$i');
        for (var round = 1; round <= 4; round++) {
          for (var seed = 0; seed < 200; seed++) {
            final setup = RoundSetup.generate(
              playerIds: playerIds,
              roundNumber: round,
              rng: Random(seed),
            );
            final anchor = setup.anchor;
            expect(anchor, isNotNull);
            expect(
              setup.feasibleRecipes.any((r) => r.id == anchor!.id),
              isTrue,
            );

            // Tập các trạm khác nhau của mỏ neo
            final anchorStations =
                anchor!.steps.map((s) => s.station).toSet();

            // Tìm những ring được gán các trạm mỏ neo
            // Mỗi trạm mỏ neo phải được gán cho một ring riêng biệt
            final ringsForAnchor = <int>{};
            for (final station in anchorStations) {
              final ringsWithThisStation = setup.stationAssignment.entries
                  .where((e) => e.value == station)
                  .map((e) => e.key)
                  .toSet();
              expect(ringsWithThisStation, isNotEmpty);
              ringsForAnchor.addAll(ringsWithThisStation);
            }
            // Số người được giao các trạm này phải ít nhất bằng số trạm khác nhau
            // (vì mỗi người chỉ giữ 1 trạm, không thể gán 2 trạm của mỏ neo cho cùng 1 người)
            expect(
              ringsForAnchor.length,
              greaterThanOrEqualTo(anchorStations.length),
            );
          }
        }
      }
    });

    test(
        '(d) với 3 người ở round 3, công thức 3 trạm (strawberry_lemonade) có thể xuất hiện',
        () {
      final playerIds = ['p0', 'p1', 'p2'];
      var appearedCount = 0;
      for (var seed = 0; seed < 200; seed++) {
        final setup = RoundSetup.generate(
          playerIds: playerIds,
          roundNumber: 3,
          rng: Random(seed),
        );
        if (setup.feasibleRecipes.any((r) => r.id == 'strawberry_lemonade')) {
          appearedCount++;
        }
      }
      expect(
        appearedCount,
        greaterThan(0),
        reason:
            'strawberry_lemonade phải xuất hiện ít nhất 1 lần trong 200 seed với 3 người ở round 3',
      );
    });
  });
}

