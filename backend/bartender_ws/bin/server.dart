// ignore_for_file: avoid_relative_lib_imports, avoid_print
import 'dart:io';

import 'package:shelf/shelf_io.dart' as io;

import '../src/app_router.dart';
import '../src/room_service.dart';

void main(List<String> args) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final service = RoomService();
  final handler = createAppHandler(service);

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Bartender server listening on port ${server.port}');

  ProcessSignal.sigint.watch().listen((_) {
    print('Shutting down server...');
    service.dispose();
    server.close(force: true);
    exit(0);
  });
}
