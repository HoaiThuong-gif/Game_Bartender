import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/rubik/screens/manual_input_screen.dart';
import 'package:nhom_bar/games/rubik/models/cube_state.dart';

Widget preview(BuildContext context, CubeState state) => SizedBox.expand(
  key: ValueKey('preview-${state.toFaceletDefinition(allowIncomplete: true)}'),
);

void main() {
  for (final size in [const Size(360, 740), const Size(390, 844)]) {
    testWidgets('input fits phone $size with safe areas', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(padding: const EdgeInsets.only(top: 24, bottom: 24)),
            child: child!,
          ),
          home: const ManualInputScreen(previewBuilder: preview),
        ),
      );
      final scroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(SingleChildScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(scroll.position.maxScrollExtent, 0);
      expect(
        find.byKey(const ValueKey('palette-B')).hitTestable(),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('erase-sticker')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'phone: fill all six faces and solve; incomplete check reports missing cells',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: ManualInputScreen(previewBuilder: preview)),
      );
      for (var face = 0; face < 5; face++) {
        await tester.tap(find.byKey(const ValueKey('next-face')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Kiểm tra & Giải'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Còn 48 ô chưa nhập.'), findsWidgets);
      expect(find.text('HƯỚNG DẪN GIẢI'), findsNothing);
      await tester.tap(find.byTooltip('Reset trạng thái'));
      await tester.pumpAndSettle();
      // Dismiss the previous validation message before painting.
      final context = tester.element(find.byType(ManualInputScreen));
      ScaffoldMessenger.of(context).clearSnackBars();
      await tester.pumpAndSettle();
      for (final face in ['U', 'R', 'F', 'D', 'L', 'B']) {
        for (final i in [0, 1, 2, 3, 5, 6, 7, 8]) {
          final cell = find.byKey(ValueKey('sticker-$face-$i'));
          await tester.ensureVisible(cell);
          await tester.tap(cell);
          await tester.pump();
        }
        if (face == 'B') {
          await tester.runAsync(() async {
            await tester.tap(find.byKey(const ValueKey('next-face')));
            await Future<void>.delayed(const Duration(milliseconds: 300));
          });
        } else {
          await tester.tap(find.byKey(const ValueKey('next-face')));
        }
        await tester.pumpAndSettle();
      }
      await tester.pumpAndSettle();
      expect(find.text('Rubik đã được giải!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('paint, fixed center, face switching, erase and reset', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ManualInputScreen(previewBuilder: preview)),
    );
    final center = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('sticker-U-4')),
    );
    expect(center.onPressed, isNull);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    await tester.ensureVisible(find.byKey(const ValueKey('sticker-U-0')));
    await tester.tap(find.byKey(const ValueKey('sticker-U-0')));
    await tester.pump();
    expect(find.text('Đã nhập 7/54 ô'), findsOneWidget);
    expect(
      find.byKey(
        ValueKey(
          'preview-${CubeState.empty().withSticker(CubeState.definitionOrder.first, 0, CubeState.definitionOrder.first.centerColor).toFaceletDefinition(allowIncomplete: true)}',
        ),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Mặt tiếp theo'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sticker-R-0')), findsOneWidget);
    await tester.tap(find.text('Mặt trước'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sticker-U-0')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('erase-sticker')));
    await tester.tap(find.byKey(const ValueKey('erase-sticker')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('sticker-U-0')));
    await tester.tap(find.byKey(const ValueKey('sticker-U-0')));
    await tester.pump();
    expect(find.text('Đã nhập 6/54 ô'), findsOneWidget);
    await tester.tap(find.byTooltip('Reset trạng thái'));
    await tester.pump();
    expect(find.text('1/9'), findsNWidgets(6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('small landscape screen scrolls without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: ManualInputScreen(previewBuilder: preview)),
    );
    await tester.ensureVisible(find.byType(FilledButton));
    expect(tester.takeException(), isNull);
  });
}
