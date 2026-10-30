import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/bartender/models/processing_rules.dart';
import 'package:nhom_bar/games/bartender/models/recipe_pool.dart';
import 'package:nhom_bar/games/bartender/models/station.dart';

void main() {
  group('Quy tắc chế biến (D19)', () {
    const seeds = ['orange', 'lemon', 'strawberry', 'ice'];

    test('mọi công thức làm ra đúng productId qua các bước của nó', () {
      for (final r in RecipePool.allRecipes) {
        final ok = seeds.any((seed) {
          String? current = seed;
          for (final step in r.steps) {
            current =
                current == null ? null : processItem(current, step.station);
          }
          return current == r.productId;
        });
        expect(ok, isTrue, reason: '${r.id} không làm ra được ${r.productId}');
      }
    });

    test('vật phẩm lạ thì trạm không xử lý (null)', () {
      expect(processItem('ice', StationType.shaker), isNull);
      expect(processItem('strawberry', StationType.blender), isNull);
      expect(processItem('milk', StationType.blender), isNull);
    });

    test('mỗi StationType có ít nhất một công thức dùng nó', () {
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
