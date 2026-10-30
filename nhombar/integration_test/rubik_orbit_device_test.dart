import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nhom_bar/games/rubik/screens/rubik_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'rubik_interactive_device_test.dart' as rubik;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native one/two finger view gestures keep cube state', (
    tester,
  ) async {
    const key = 'rubik.practice.session.v1';
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(key);
    await tester.pumpWidget(const MaterialApp(home: RubikScreen()));
    try {
      await rubik.ready(tester);
      for (
        var i = 0;
        i < 50 && (await rubik.state(tester))['oneFingerOrbit'] != true;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final before = await rubik.state(tester);
      expect(before['oneFingerOrbit'], true);
      final rect = tester.getRect(find.byType(WebViewWidget));
      Future<void> drag(int fingers) async {
        final contacts = <TestGesture>[];
        for (var i = 0; i < fingers; i++) {
          contacts.add(
            await tester.startGesture(
              rect.center + Offset(i * 70.0 - 35, 0),
              pointer: i + 1,
            ),
          );
        }
        for (var step = 0; step < 15; step++) {
          for (final contact in contacts) {
            await contact.moveBy(const Offset(5, 3));
          }
          await tester.pump(const Duration(milliseconds: 25));
        }
        for (final contact in contacts.reversed) {
          await contact.up();
        }
        await tester.pump(const Duration(milliseconds: 300));
      }

      await drag(1);
      final one = await rubik.state(tester);
      expect(one['camera'], isNot(before['camera']));
      expect(one['cube'], before['cube']);
      expect(one['moves'], before['moves']);
      await drag(2);
      final two = await rubik.state(tester);
      expect(two['camera'], isNot(one['camera']));
      expect(two['cube'], before['cube']);
      expect(two['moves'], before['moves']);
      await tester.tap(find.byKey(const ValueKey('rubik-gesture-mode')));
      await tester.pump(const Duration(milliseconds: 300));
      expect((await rubik.state(tester))['oneFingerOrbit'], false);
      expect(find.text('Xoay tầng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      // Restore the practice session; do not replace the user's saved puzzle.
      if (rubik.view.evaluate().isNotEmpty) {
        await rubik.js(
          tester,
          'window.restoreRubikToy(${saved == null ? 'null' : jsonEncode(jsonDecode(saved))})',
        );
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
      if (saved == null) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, saved);
      }
    }
  });
}
