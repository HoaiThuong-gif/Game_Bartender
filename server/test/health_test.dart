import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../bin/server.dart';

void main() {
  group('GET /health', () {
    test('returns status 200 with ok status and timeMs', () async {
      final handler = createHandler(roomsCountProvider: () => 2);
      final request = Request('GET', Uri.parse('http://localhost:8080/health'));
      final response = await handler(request);

      expect(response.statusCode, 200);
      expect(response.headers['content-type'], 'application/json');

      final body =
          jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['status'], 'ok');
      expect(body['rooms'], 2);
      expect(body['timeMs'], isA<int>());
      expect(body['timeMs'], greaterThan(0));
    });

    test('default rooms count is 0', () async {
      final handler = createHandler();
      final request = Request('GET', Uri.parse('http://localhost:8080/health'));
      final response = await handler(request);

      final body =
          jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['status'], 'ok');
      expect(body['rooms'], 0);
    });
  });
}
