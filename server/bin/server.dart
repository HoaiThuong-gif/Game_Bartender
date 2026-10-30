// ignore_for_file: avoid_relative_lib_imports, avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// Reusing models directly from lib/games/bartender/models/ without moving them
import '../../lib/games/bartender/models/room.dart';

Handler createHandler({int Function()? roomsCountProvider}) {
  final app = Router();

  app.get('/health', (Request request) {
    // Model reference
    const _ = RoomStatus.lobby;

    final roomsCount = roomsCountProvider != null ? roomsCountProvider() : 0;
    final payload = {
      'status': 'ok',
      'rooms': roomsCount,
      'timeMs': DateTime.now().millisecondsSinceEpoch,
    };

    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  return const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(app.call);
}

void main(List<String> args) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final handler = createHandler();
  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Bartender server listening on port ${server.port}');
}
