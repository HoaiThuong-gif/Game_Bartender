import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

import 'exceptions.dart';
import 'room_service.dart';

/// Helper to parse Bearer token from Authorization header.
String _extractBearerToken(Request request) {
  final authHeader = request.headers['authorization'];
  if (authHeader == null) {
    throw ApiException.unauthorized('Missing Authorization header.');
  }

  final parts = authHeader.trim().split(' ');
  if (parts.length != 2 || parts[0].toLowerCase() != 'bearer') {
    throw ApiException.unauthorized(
        'Invalid Authorization header format. Expected Bearer <token>.');
  }

  return parts[1];
}

/// Helper to decode JSON request body into a Map.
Future<Map<String, dynamic>> _parseJsonBody(Request request) async {
  try {
    final text = await request.readAsString();
    if (text.trim().isEmpty) return const {};
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException.invalidRequest('Request body must be a JSON object.');
    }
    return decoded;
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException.invalidRequest('Malformed JSON body: $e');
  }
}

/// Builds the Shelf Router and request pipeline for the Bartender server.
Handler createAppHandler(RoomService service) {
  final router = Router();

  // GET /health
  router.get('/health', (Request request) {
    final payload = {
      'status': 'ok',
      'rooms': service.roomsCount,
      'timeMs': DateTime.now().millisecondsSinceEpoch,
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /rooms
  router.post('/rooms', (Request request) async {
    final body = await _parseJsonBody(request);
    final playerName = body['playerName'] as String? ?? '';
    final result = service.createRoom(playerName: playerName);

    return Response(
      201,
      body: jsonEncode(result.toJson()),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /rooms/<code>/join
  router.post('/rooms/<code>/join', (Request request, String code) async {
    final body = await _parseJsonBody(request);
    final playerName = body['playerName'] as String? ?? '';
    final result = service.joinRoom(code: code, playerName: playerName);

    return Response.ok(
      jsonEncode(result.toJson()),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /rooms/<code>/leave
  router.post('/rooms/<code>/leave', (Request request, String code) {
    final token = _extractBearerToken(request);
    service.leaveRoom(code: code, token: token);
    return Response(204);
  });

  // POST /rooms/<code>/start
  router.post('/rooms/<code>/start', (Request request, String code) async {
    final token = _extractBearerToken(request);
    final body = await _parseJsonBody(request);
    service.startMatch(
        code: code, token: token, waitForScene: body['waitForScene'] == true);
    return Response(204);
  });

  router.post('/rooms/<code>/scene-ready',
      (Request request, String code) async {
    final token = _extractBearerToken(request);
    final body = await _parseJsonBody(request);
    final preparationId = body['preparationId'];
    if (preparationId is! int)
      throw ApiException.invalidRequest('Missing preparationId.');
    service.markSceneReady(
        code: code, token: token, preparationId: preparationId);
    return Response(204);
  });

  // GET /rooms/<code>
  router.get('/rooms/<code>', (Request request, String code) {
    final token = _extractBearerToken(request);
    final room = service.getRoom(code: code, token: token);

    return Response.ok(
      jsonEncode({'room': room.toJson()}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /rooms/<code>/items/send
  router.post('/rooms/<code>/items/send', (Request request, String code) async {
    final token = _extractBearerToken(request);
    final body = await _parseJsonBody(request);
    final itemId = body['itemId'] as String? ?? '';
    final toRingIndex = (body['toRingIndex'] as num?)?.toInt() ?? -1;

    if (itemId.isEmpty || toRingIndex < 0) {
      throw ApiException.invalidRequest('Missing itemId or valid toRingIndex.');
    }

    service.sendItem(
      code: code,
      token: token,
      itemId: itemId,
      toRingIndex: toRingIndex,
    );

    return Response(204);
  });

  // POST /rooms/<code>/items/trash
  router.post('/rooms/<code>/items/trash',
      (Request request, String code) async {
    final token = _extractBearerToken(request);
    final body = await _parseJsonBody(request);
    final itemId = body['itemId'] as String? ?? '';

    if (itemId.isEmpty) {
      throw ApiException.invalidRequest('Missing itemId.');
    }

    service.trashItem(code: code, token: token, itemId: itemId);
    return Response(204);
  });

  // POST /rooms/<code>/items/process
  router.post('/rooms/<code>/items/process',
      (Request request, String code) async {
    final token = _extractBearerToken(request);
    final body = await _parseJsonBody(request);
    final itemId = body['itemId'] as String? ?? '';
    final station = body['station'] as String? ?? '';

    if (itemId.isEmpty || station.isEmpty) {
      throw ApiException.invalidRequest('Missing itemId or station.');
    }

    final item = service.processItemAtStation(
      code: code,
      token: token,
      itemId: itemId,
      station: station,
    );

    return Response.ok(
      jsonEncode({'item': item.toJson()}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /rooms/<code>/orders/submit
  router.post('/rooms/<code>/orders/submit',
      (Request request, String code) async {
    final token = _extractBearerToken(request);
    final body = await _parseJsonBody(request);
    final orderId = body['orderId'] as String? ?? '';
    final itemId = body['itemId'] as String? ?? '';

    if (orderId.isEmpty || itemId.isEmpty) {
      throw ApiException.invalidRequest('Missing orderId or itemId.');
    }

    service.submitOrder(
      code: code,
      token: token,
      orderId: orderId,
      itemId: itemId,
    );

    return Response(204);
  });

  // GET /rooms/<code>/ws?token=...
  router.get('/rooms/<code>/ws', (Request request, String code) {
    final token = request.url.queryParameters['token'] ?? '';
    if (token.isEmpty) {
      return Response(401, body: 'Missing token in query parameters.');
    }

    final wsHandler = webSocketHandler((channel, ping) {
      service.handleWebSocketConnection(
        code: code,
        token: token,
        incoming: channel.stream,
        send: (msg) => channel.sink.add(msg),
        close: ([int? closeCode, String? reason]) {
          channel.sink.close(closeCode, reason);
        },
      );
    });

    return wsHandler(request);
  });

  // Error handling middleware
  final errorMiddleware = createMiddleware(
    errorHandler: (error, stackTrace) {
      if (error is ApiException) {
        return Response(
          error.statusCode,
          body: jsonEncode(error.toJson()),
          headers: {'content-type': 'application/json'},
        );
      }
      return Response(
        500,
        body: jsonEncode({
          'error': {
            'code': 'INTERNAL_ERROR',
            'message': error.toString(),
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    },
  );

  return const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(errorMiddleware)
      .addHandler(router.call);
}
