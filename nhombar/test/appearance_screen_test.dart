import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/main.dart';
import 'package:nhom_bar/settings/app_settings.dart';
import 'package:nhom_bar/settings/settings_screen.dart';

void main() {
  testWidgets(
    'Appearance wraps on a small phone and updates without losing route',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final settings = AppSettings();
      addTearDown(settings.dispose);
      await settings.useAccount('appearance-widget');
      await settings.update(scale: 1.3);
      await tester.pumpWidget(
        NhomBarApp(settings: settings, home: const SettingsScreen()),
      );
      await tester.tap(find.text('Giao diện'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xanh ngọc'));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(AppearanceScreen));
      expect(
        Theme.of(context).colorScheme.primary,
        AppSettings.colors['Xanh ngọc'],
      );
      expect(MediaQuery.textScalerOf(context).scale(20), closeTo(26, .001));
      expect(find.byType(AppearanceScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      await settings.useAccount('another-user');
      await settings.useAccount('appearance-widget');
      expect(settings.colorName, 'Xanh ngọc');
    },
  );
}
