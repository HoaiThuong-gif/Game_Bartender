import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/screens/home/widgets/lobby_object.dart';
import 'package:nhom_bar/screens/home/widgets/lobby_panorama.dart';

void main() {
  test('Hit mask keeps transparency and threshold values using a quarter of RGBA memory', () {
    final rgba = Uint8List.fromList([
      255,
      255,
      255,
      0,
      0,
      0,
      0,
      100,
      1,
      2,
      3,
      101,
      0,
      0,
      0,
      255,
    ]);
    final alpha = imageAlpha(ByteData.sublistView(rgba));
    expect(alpha, [0, 100, 101, 255]);
    expect(alpha.length * 4, rgba.length);
    expect(alpha.where((value) => value > 100).length, 2);
  });
  test('Hit mask honors byte buffer offsets', () {
    final bytes = Uint8List.fromList([9, 9, 10, 20, 30, 200, 9]);
    expect(imageAlpha(ByteData.sublistView(bytes, 2, 6)), [200]);
  });
  testWidgets(
    'Lobby appears while the optional GPU diagnostic is still pending',
    (tester) async {
      const channel = MethodChannel('meomeo/lobby');
      final diagnostic = Completer<Map<String, dynamic>>();
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => diagnostic.future,
      );
      addTearDown(() {
        if (!diagnostic.isCompleted) diagnostic.complete({});
        messenger.setMockMethodCallHandler(channel, null);
      });
      await tester.pumpWidget(
        const MaterialApp(home: LobbyPanorama(children: [Text('Lobby ready')])),
      );
      for (
        var attempt = 0;
        attempt < 100 && find.text('Lobby ready').evaluate().isEmpty;
        attempt++
      ) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump();
      }
      expect(find.text('Lobby ready'), findsOneWidget);
      expect(diagnostic.isCompleted, isFalse);
      await tester.pumpWidget(const SizedBox());
      diagnostic.complete({'maxTextureSize': 2048, 'renderer': 'test'});
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
