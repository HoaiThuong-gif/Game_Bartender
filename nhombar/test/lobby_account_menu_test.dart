import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/screens/home/lobby_screen.dart';
import 'package:nhom_bar/screens/home/widgets/lobby_account_menu.dart';
import 'package:nhom_bar/settings/app_settings.dart';
import 'package:nhom_bar/settings/app_theme.dart';
import 'package:nhom_bar/settings/settings_screen.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(740, 360)]) {
    testWidgets(
      'Account panel opens, scrolls, closes and returns actions at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        LobbyAccountAction? selected;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.build(const Color(0xFFA95C3B)),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.8)),
              child: child!,
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) => Align(
                  alignment: Alignment.topLeft,
                  child: LobbyAccountButton(
                    name: 'Người chơi có tên thật dài để kiểm tra bố cục',
                    onPressed: () async {
                      selected = await showLobbyAccountMenu(
                        context,
                        name: 'Người chơi có tên thật dài để kiểm tra bố cục',
                        canLogout: true,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(LobbyAccountButton));
        await tester.pumpAndSettle();
        expect(find.text('Hồ sơ cá nhân'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Đóng menu'));
        await tester.pumpAndSettle();
        expect(selected, isNull);
        for (final entry in {
          'Hồ sơ cá nhân': LobbyAccountAction.profile,
          'Cài đặt': LobbyAccountAction.settings,
          'Giao diện': LobbyAccountAction.appearance,
          'Chỉnh bố cục Lobby': LobbyAccountAction.layout,
          'Đăng xuất': LobbyAccountAction.logout,
        }.entries) {
          await tester.tap(find.byType(LobbyAccountButton));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text(entry.key));
          await tester.tap(find.text(entry.key));
          await tester.pumpAndSettle();
          expect(selected, entry.value);
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets(
    'Lobby account menu stays usable during scene loading and returns from appearance',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final settings = AppSettings();
      addTearDown(settings.dispose);
      await settings.useAccount('lobby-menu');
      await tester.pumpWidget(
        AppSettingsScope(
          settings: settings,
          child: MaterialApp(
            theme: AppTheme.build(settings.seedColor),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const LobbyScreen(playerName: 'An'),
          ),
        ),
      );
      expect(find.byTooltip('Layers'), findsNothing);
      await tester.tap(find.byTooltip('Menu tài khoản'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Giao diện'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(AppearanceScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byTooltip('Menu tài khoản'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Chỉnh bố cục Lobby'), findsOneWidget);
      await tester.ensureVisible(find.text('Chỉnh bố cục Lobby'));
      await tester.tap(find.text('Chỉnh bố cục Lobby'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Bố cục Lobby'), findsOneWidget);
      final toggle = find.byType(SwitchListTile).first;
      await tester.tap(toggle);
      await tester.pump();
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      Navigator.of(tester.element(toggle)).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byTooltip('Menu tài khoản'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.ensureVisible(find.text('Chỉnh bố cục Lobby'));
      await tester.tap(find.text('Chỉnh bố cục Lobby'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile).first).value,
        isFalse,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
