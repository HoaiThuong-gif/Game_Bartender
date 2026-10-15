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
}
