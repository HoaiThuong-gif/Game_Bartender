import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _asMap(Object? data) {
  if (data == null) return <String, dynamic>{};
  if (data is Map) {
    final res = <String, dynamic>{};
    for (final e in data.entries) {
      if (e.value != null) {
        res[e.key.toString()] = e.value;
      }
    }
    return res;
  }
  if (data is List) {
    final res = <String, dynamic>{};
    for (var i = 0; i < data.length; i++) {
      if (data[i] != null) {
        res[i.toString()] = data[i];
      }
    }
    return res;
  }
  return <String, dynamic>{};
}

void main() {
  group('_asMap Tests', () {
    test('handles null', () {
      expect(_asMap(null), isEmpty);
    });

    test('handles Map', () {
      final input = {'a': 1, 'b': null, 2: 'c'};
      final res = _asMap(input);
      expect(res.length, 2);
      expect(res['a'], 1);
      expect(res['2'], 'c');
      expect(res.containsKey('b'), isFalse);
    });

    test('handles List', () {
      final input = ['a', null, 'c'];
      final res = _asMap(input);
      expect(res.length, 2);
      expect(res['0'], 'a');
      expect(res['2'], 'c');
      expect(res.containsKey('1'), isFalse);
    });
  });
}
