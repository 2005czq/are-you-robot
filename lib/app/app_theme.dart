import 'package:flutter/material.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1F7AE0),
    brightness: brightness,
  );

  final textTheme = Typography.material2021().black.apply(
        bodyColor: baseScheme.onSurface,
        displayColor: baseScheme.onSurface,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: baseScheme,
    scaffoldBackgroundColor: brightness == Brightness.light
        ? const Color(0xFFF5F7FB)
        : const Color(0xFF11141A),
    textTheme: textTheme,
    cardTheme: CardThemeData(
      elevation: 0,
      color: baseScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: baseScheme.outlineVariant,
        ),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    ),
    chipTheme: ThemeData(brightness: brightness).chipTheme.copyWith(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
  );
}
