import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../src/app_router.dart';
import '../src/room_service.dart';

void main() {
  group('GET /health', () {
    test('returns status 200 with ok status and timeMs', () async {
      final service = RoomService(enableTimers: false);
      final handler = createAppHandler(service);
      final request = Request('GET', Uri.parse('http://localhost:8080/health'));
      final response = await handler(request);

      expect(response.statusCode, 200);
      expect(response.headers['content-type'], 'application/json');

      final body =
          jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['status'], 'ok');
      expect(body['rooms'], 0);
      expect(body['timeMs'], isA<int>());
      expect(body['timeMs'], greaterThan(0));

      service.dispose();
    });
  });
}
