/// Unit tests cho hàm asMap() trong rtdb_utils.dart.
///
/// Đảm bảo chuẩn hoá dữ liệu RTDB (Map/List/null) hoạt động đúng.
import 'package:flutter_test/flutter_test.dart';

import 'package:nhom_bar/games/bartender/services/rtdb_utils.dart';

void main() {
  group('asMap Tests', () {
    test('handles null', () {
      expect(asMap(null), isEmpty);
    });

    test('handles Map', () {
      final input = {'a': 1, 'b': null, 2: 'c'};
      final res = asMap(input);
      expect(res.length, 2);
      expect(res['a'], 1);
      expect(res['2'], 'c');
      expect(res.containsKey('b'), isFalse);
    });

    test('handles List', () {
      final input = ['a', null, 'c'];
      final res = asMap(input);
      expect(res.length, 2);
      expect(res['0'], 'a');
      expect(res['2'], 'c');
      expect(res.containsKey('1'), isFalse);
    });

    test('handles empty Map', () {
      expect(asMap(<String, dynamic>{}), isEmpty);
    });

    test('handles empty List', () {
      expect(asMap(<dynamic>[]), isEmpty);
    });

    test('handles non-Map non-List non-null', () {
      // Bất kỳ kiểu nào khác → trả về Map rỗng
      expect(asMap(42), isEmpty);
      expect(asMap('hello'), isEmpty);
    });
  });
}
