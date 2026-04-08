import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF1F7AE0),
    brightness: brightness,
  );

  final serifFamily = kIsWeb ? 'Noto Serif SC' : 'NotoSerifSC';
  const serifFallback = <String>[
    'SourceSerif4',
    'Georgia',
  ];

  final serifDisplay = TextStyle(
    fontFamily: serifFamily,
    fontFamilyFallback: serifFallback,
    fontWeight: FontWeight.w700,
    height: 1.08,
    letterSpacing: -0.6,
  );

  final serifTitle = TextStyle(
    fontFamily: serifFamily,
    fontFamilyFallback: serifFallback,
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
      fontFamily: serifFamily,
      fontFamilyFallback: serifFallback,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: serifFallback,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: serifFallback,
      height: 1.55,
    ),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: serifFallback,
      height: 1.55,
    ),
    bodySmall: baseTextTheme.bodySmall?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: serifFallback,
      height: 1.5,
    ),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: serifFallback,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
    labelMedium: baseTextTheme.labelMedium?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: serifFallback,
      fontWeight: FontWeight.w700,
    ),
  );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: baseScheme,
    scaffoldBackgroundColor:
        brightness == Brightness.light ? const Color(0xFFF5F7FB) : const Color(0xFF11141A),
    fontFamily: serifFamily,
    textTheme: textTheme,
    cardTheme: CardThemeData(
      elevation: 0,
      color: baseScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        shape: buttonShape,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        shape: buttonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
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
        fontFamily: serifFamily,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: baseScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
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
