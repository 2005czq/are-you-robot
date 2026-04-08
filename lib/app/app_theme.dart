import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'widgets/emoji_text.dart';

ThemeData buildAppTheme(Brightness brightness) {
  const seedColor = Color(0xFFC26441);
  final baseScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );

  const serifFamily = kIsWeb ? 'Noto Serif SC' : 'NotoSerifSC';
  const serifFallback = <String>[
    'SourceSerif4',
    'Georgia',
  ];
  final fontFallback = <String>[
    ...serifFallback,
    ...kEmojiFontFallback,
  ];

  final serifDisplay = TextStyle(
    fontFamily: serifFamily,
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w700,
    height: 1.04,
    letterSpacing: -0.8,
  );

  final serifTitle = TextStyle(
    fontFamily: serifFamily,
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w700,
    height: 1.14,
    letterSpacing: -0.42,
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
      fontFamilyFallback: fontFallback,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: fontFallback,
      fontWeight: FontWeight.w700,
      height: 1.2,
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: fontFallback,
      height: 1.58,
    ),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: fontFallback,
      height: 1.58,
    ),
    bodySmall: baseTextTheme.bodySmall?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: fontFallback,
      height: 1.48,
    ),
    labelLarge: baseTextTheme.labelLarge?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: fontFallback,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
    labelMedium: baseTextTheme.labelMedium?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: fontFallback,
      fontWeight: FontWeight.w700,
    ),
  );

  final scaffoldBackgroundColor = brightness == Brightness.dark
      ? const Color(0xFF17120F)
      : const Color(0xFFF8F1E7);
  final surfaceColor = brightness == Brightness.dark
      ? const Color(0xFF241D18)
      : const Color(0xFFFFFBF6);
  final outlineColor = brightness == Brightness.dark
      ? const Color(0xFF6A584F)
      : const Color(0xFFE0CABB);
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: baseScheme.copyWith(
      surface: surfaceColor,
      outline: outlineColor,
      primary: brightness == Brightness.dark
          ? const Color(0xFFFFB590)
          : const Color(0xFF9F4B2B),
      secondary: brightness == Brightness.dark
          ? const Color(0xFFF1C98B)
          : const Color(0xFF8C5B12),
      tertiary: brightness == Brightness.dark
          ? const Color(0xFFA9D3B7)
          : const Color(0xFF426B4C),
      error: brightness == Brightness.dark
          ? const Color(0xFFFFB4A8)
          : const Color(0xFFB3261E),
    ),
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    fontFamily: serifFamily,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceColor.withValues(alpha: 0.92),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: outlineColor.withValues(alpha: 0.52)),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
        shape: buttonShape,
        textStyle: textTheme.titleMedium,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
        shape: buttonShape,
        textStyle: textTheme.titleMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
        shape: buttonShape,
        side: BorderSide(color: outlineColor),
        textStyle: textTheme.titleMedium,
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
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(34),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(18),
        backgroundColor: surfaceColor.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: outlineColor.withValues(alpha: 0.52)),
        ),
      ),
    ),
    chipTheme: ThemeData(brightness: brightness).chipTheme.copyWith(
          backgroundColor: surfaceColor.withValues(alpha: 0.94),
          selectedColor: baseScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          side: BorderSide(color: outlineColor.withValues(alpha: 0.72)),
          labelStyle: textTheme.labelLarge,
        ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: brightness == Brightness.dark
          ? const Color(0xFF2D221C)
          : const Color(0xFF53362A),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: DividerThemeData(
      color: outlineColor.withValues(alpha: 0.5),
      thickness: 1,
    ),
  );
}
