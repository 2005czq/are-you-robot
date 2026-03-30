import 'package:flutter/material.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1F7AE0),
    brightness: brightness,
  );

  const serifDisplay = TextStyle(
    fontFamily: 'Georgia',
    fontWeight: FontWeight.w700,
    height: 1.08,
    letterSpacing: -0.6,
  );

  const serifTitle = TextStyle(
    fontFamily: 'Georgia',
    fontWeight: FontWeight.w700,
    height: 1.18,
    letterSpacing: -0.35,
  );

  final baseTextTheme = (brightness == Brightness.dark
          ? Typography.material2021().white
          : Typography.material2021().black)
      .apply(
    bodyColor: baseScheme.onSurface,
    displayColor: baseScheme.onSurface,
  );

  final textTheme = baseTextTheme.copyWith(
    displayLarge: baseTextTheme.displayLarge?.merge(serifDisplay),
    displayMedium: baseTextTheme.displayMedium?.merge(serifDisplay),
    displaySmall: baseTextTheme.displaySmall?.merge(serifDisplay),
    headlineLarge: baseTextTheme.headlineLarge?.merge(serifTitle),
    headlineMedium: baseTextTheme.headlineMedium?.merge(serifTitle),
    headlineSmall: baseTextTheme.headlineSmall?.merge(serifTitle),
    titleLarge: baseTextTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.55),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.55),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(999),
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
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(
          color: baseScheme.outlineVariant,
        ),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: buttonShape,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: buttonShape,
        side: BorderSide(color: baseScheme.outline),
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: baseScheme.onSurface,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: baseScheme.onSurface,
        fontFamily: 'Georgia',
      ),
    ),
    chipTheme: ThemeData(brightness: brightness).chipTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      side: BorderSide(color: baseScheme.outlineVariant),
    ),
  );
}
