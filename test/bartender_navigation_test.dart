import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/main.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_lobby_screen.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_match_screen.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_screen.dart';
import 'package:nhom_bar/screens/home/lobby_screen.dart';
import 'package:nhom_bar/screens/home/widgets/lobby_object.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(360, 640)]) {
    testWidgets(
      'lobby opens Bartender, creates a room, plays and returns at $size',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        addTearDown(() => tester.pumpWidget(const SizedBox()));
        await tester.pumpWidget(const NhomBarApp());
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 400)),
        );
        await tester.pump();

        final bartender = find.byWidgetPredicate(
          (widget) => widget is LobbyObject && widget.label == 'Quầy Bartender',
        );
        await tester.tap(bartender);
        await tester.pumpAndSettle();
        expect(find.byType(BartenderScreen), findsOneWidget);
        expect(find.byType(BartenderLobbyScreen), findsOneWidget);
        expect(find.text('Bartender đang được phát triển.'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.enterText(find.byType(TextField), 'Người chơi');
        await tester.tap(find.text('TẠO PHÒNG'));
        await tester.pumpAndSettle();
        expect(find.text('MÃ PHÒNG'), findsOneWidget);
        expect(find.text('Người chơi'), findsOneWidget);
        expect(find.text('Bot'), findsNWidgets(2));
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('BẮT ĐẦU TRẬN ĐẤU!'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(BartenderMatchScreen), findsOneWidget);
        expect(find.text('ROUND 1'), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Popping the game must dispose its repository, timers and controller.
        final context = tester.element(find.byType(BartenderScreen));
        Navigator.of(context).pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(BartenderScreen), findsNothing);
        expect(find.byType(LobbyScreen), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
