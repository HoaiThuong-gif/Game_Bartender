import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const cream = Color(0xFFFFF8F1);
  static const background = Color(0xFFFAF4ED);
  static const ink = Color(0xFF30241F);
  static const arenaBackground = Color(0xFF211B18);
  static const arenaSurface = Color(0xFF302620);
  static const arenaRaised = Color(0xFF40332B);

  static ThemeData build(Color seed, {bool game = false}) {
    final generated = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: game ? Brightness.dark : Brightness.light,
    );
    final scheme = generated.copyWith(
      primary: game ? generated.primary : seed,
      onPrimary: game ? generated.onPrimary : Colors.white,
      surface: game ? arenaSurface : cream,
      onSurface: game ? cream : ink,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium!.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.textTheme.titleLarge!.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.textTheme.titleMedium!.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge!.copyWith(fontSize: 16, height: 1.45),
      bodyMedium: base.textTheme.bodyMedium!.copyWith(
        fontSize: 14,
        height: 1.4,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: game ? arenaBackground : background,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: game ? arenaBackground : background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: text.titleLarge!.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: shape,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 24),
    );
  }
}
