import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/settings/app_settings.dart';
import 'package:nhom_bar/settings/app_theme.dart';

void main() {
  test('Appearance persists and remains separate for each account', () async {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    await settings.useAccount('appearance-alice');
    await settings.update(color: 'Xanh ngọc', scale: 1.3, lessMotion: true);
    await settings.useAccount('appearance-bob');
    expect(settings.colorName, 'Cam đất');
    expect(settings.textScale, 1);
    await settings.update(color: 'Tím');

    final restored = AppSettings();
    addTearDown(restored.dispose);
    await restored.useAccount('appearance-alice');
    expect(restored.colorName, 'Xanh ngọc');
    expect(restored.textScale, 1.3);
    expect(restored.reduceMotion, isTrue);
    await restored.useAccount('appearance-bob');
    expect(restored.colorName, 'Tím');
    await restored.reset();
    await restored.useAccount('appearance-alice');
    expect(restored.colorName, 'Xanh ngọc');
  });

  test('Rapid saves and account switches keep the latest choice', () async {
    final settings = AppSettings();
    addTearDown(settings.dispose);
    await settings.useAccount('rapid-alice');
    final first = settings.update(color: 'Tím');
    final second = settings.update(color: 'Xanh chàm', scale: 1.15);
    await settings.useAccount('rapid-bob');
    await Future.wait([first, second]);
    expect(settings.colorName, 'Cam đất');
    await settings.useAccount('rapid-alice');
    expect(settings.colorName, 'Xanh chàm');
    expect(settings.textScale, 1.15);
  });

  test('App scaling respects the system text size', () {
    const scaler = AppTextScaler(TextScaler.linear(1.5), 1.3);
    expect(scaler.scale(20), closeTo(39, .001));
  });

  test('Theme uses the chosen terracotta and keeps arena contrast', () {
    const seed = Color(0xFFA95C3B);
    final light = AppTheme.build(seed);
    expect(light.useMaterial3, isTrue);
    expect(light.colorScheme.primary, seed);
    expect(light.colorScheme.surface, AppTheme.cream);
    final arena = AppTheme.build(seed, game: true);
    expect(arena.brightness, Brightness.dark);
    expect(arena.colorScheme.onSurface, AppTheme.cream);
  });
}
