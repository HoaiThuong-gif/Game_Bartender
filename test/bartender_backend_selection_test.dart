import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/bartender/bartender_config.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_lobby_screen.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_screen.dart';

void main() {
  group('BartenderBackend Selection Logic', () {
    test('parseBackend parses valid backend names case-insensitively and with trimming', () {
      expect(BartenderConfig.parseBackend('fake'), BartenderBackend.fake);
      expect(BartenderConfig.parseBackend('Fake'), BartenderBackend.fake);
      expect(BartenderConfig.parseBackend('  FAKE  '), BartenderBackend.fake);

      expect(BartenderConfig.parseBackend('firebase'), BartenderBackend.firebase);
      expect(BartenderConfig.parseBackend('FIREBASE'), BartenderBackend.firebase);
      expect(BartenderConfig.parseBackend('  Firebase  '), BartenderBackend.firebase);

      expect(BartenderConfig.parseBackend('api'), BartenderBackend.api);
      expect(BartenderConfig.parseBackend('API'), BartenderBackend.api);
      expect(BartenderConfig.parseBackend('  api  '), BartenderBackend.api);
    });

    test('parseBackend falls back to fake for unknown or empty values', () {
      expect(BartenderConfig.parseBackend(''), BartenderBackend.fake);
      expect(BartenderConfig.parseBackend('unknown'), BartenderBackend.fake);
      expect(BartenderConfig.parseBackend('render'), BartenderBackend.fake);
      expect(BartenderConfig.parseBackend('123'), BartenderBackend.fake);
    });

    test('default backend is fake and useFakeRepository is true without defines', () {
      expect(BartenderConfig.backend, BartenderBackend.fake);
      expect(BartenderConfig.useFakeRepository, isTrue);
    });
  });

  group('BartenderScreen Firebase initialization bypass', () {
    late BartenderBackend originalBackend;

    setUp(() {
      originalBackend = BartenderConfig.backend;
    });

    tearDown(() {
      BartenderConfig.backend = originalBackend;
    });

    testWidgets('BartenderScreen does not call Firebase and renders immediately in api mode', (tester) async {
      BartenderConfig.backend = BartenderBackend.api;

      await tester.pumpWidget(
        const MaterialApp(
          home: BartenderScreen(),
        ),
      );
      await tester.pump();

      // Trong chế độ api, màn hình mở thẳng lobby mà không khởi tạo Firebase
      expect(tester.takeException(), isNull);
      expect(find.byType(BartenderLobbyScreen), findsOneWidget);
    });

    testWidgets('BartenderScreen renders immediately in fake mode', (tester) async {
      BartenderConfig.backend = BartenderBackend.fake;

      await tester.pumpWidget(
        const MaterialApp(
          home: BartenderScreen(),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(BartenderLobbyScreen), findsOneWidget);
    });
  });
}

