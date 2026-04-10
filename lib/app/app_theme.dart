import 'package:flutter/material.dart';

import 'widgets/emoji_text.dart';

ThemeData buildAppTheme(Brightness brightness) {
  const seedColor = Color(0xFFB45A3C);
  final baseScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
  );

  const serifFamily = 'NotoSerifSC';
  const serifFallback = <String>['SourceSerif4', 'Georgia'];
  final fontFallback = <String>[...serifFallback, ...kEmojiFontFallback];

  final serifDisplay = TextStyle(
    fontFamily: serifFamily,
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w700,
    height: 1.04,
    letterSpacing: -0.82,
  );

  final serifTitle = TextStyle(
    fontFamily: serifFamily,
    fontFamilyFallback: fontFallback,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.4,
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
      letterSpacing: -0.18,
    ),
    titleMedium: baseTextTheme.titleMedium?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: fontFallback,
      fontWeight: FontWeight.w700,
      height: 1.22,
    ),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: fontFallback,
      height: 1.6,
    ),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: fontFallback,
      height: 1.6,
    ),
    bodySmall: baseTextTheme.bodySmall?.copyWith(
      fontFamily: serifFamily,
      fontFamilyFallback: fontFallback,
      height: 1.5,
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

  final scheme = brightness == Brightness.dark
      ? baseScheme.copyWith(
          primary: const Color(0xFFFFB69A),
          onPrimary: const Color(0xFF5A210B),
          primaryContainer: const Color(0xFF7A3620),
          onPrimaryContainer: const Color(0xFFFFDBCF),
          secondary: const Color(0xFFE7C28B),
          onSecondary: const Color(0xFF3E2A05),
          secondaryContainer: const Color(0xFF5A4115),
          onSecondaryContainer: const Color(0xFFFFDEAB),
          tertiary: const Color(0xFFB4D7B9),
          onTertiary: const Color(0xFF143723),
          tertiaryContainer: const Color(0xFF2C4E37),
          onTertiaryContainer: const Color(0xFFD0F3D4),
          error: const Color(0xFFFFB4AB),
          onError: const Color(0xFF690005),
          errorContainer: const Color(0xFF93000A),
          onErrorContainer: const Color(0xFFFFDAD6),
          surface: const Color(0xFF181210),
          onSurface: const Color(0xFFEDE0DB),
          surfaceContainerLowest: const Color(0xFF100B09),
          surfaceContainerLow: const Color(0xFF211A18),
          surfaceContainer: const Color(0xFF261F1C),
          surfaceContainerHigh: const Color(0xFF302826),
          surfaceContainerHighest: const Color(0xFF3B3330),
          onSurfaceVariant: const Color(0xFFD5C3BC),
          outline: const Color(0xFF9E8D87),
          outlineVariant: const Color(0xFF53433E),
          shadow: Colors.black,
          scrim: Colors.black,
        )
      : baseScheme.copyWith(
          primary: const Color(0xFF934C31),
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFFFDBC9),
          onPrimaryContainer: const Color(0xFF3A1403),
          secondary: const Color(0xFF76592A),
          onSecondary: Colors.white,
          secondaryContainer: const Color(0xFFFFDEAC),
          onSecondaryContainer: const Color(0xFF271900),
          tertiary: const Color(0xFF516350),
          onTertiary: Colors.white,
          tertiaryContainer: const Color(0xFFD4E8D0),
          onTertiaryContainer: const Color(0xFF10200F),
          error: const Color(0xFFBA1A1A),
          onError: Colors.white,
          errorContainer: const Color(0xFFFFDAD6),
          onErrorContainer: const Color(0xFF410002),
          surface: const Color(0xFFFFF8F6),
          onSurface: const Color(0xFF231917),
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: const Color(0xFFFFF1EC),
          surfaceContainer: const Color(0xFFFCEAE3),
          surfaceContainerHigh: const Color(0xFFF6E3DB),
          surfaceContainerHighest: const Color(0xFFF0DDD6),
          onSurfaceVariant: const Color(0xFF56433D),
          outline: const Color(0xFF88736C),
          outlineVariant: const Color(0xFFDBC7BF),
          shadow: Colors.black,
          scrim: Colors.black,
        );

  final scaffoldBackgroundColor = brightness == Brightness.dark
      ? const Color(0xFF130F0D)
      : const Color(0xFFF7F1EC);
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(22),
  );
  final buttonTextStyle = textTheme.titleMedium?.copyWith(
    fontSize: 18.5,
    height: 1.08,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    fontFamily: serifFamily,
    textTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 60),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: buttonShape,
        textStyle: buttonTextStyle,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(0, 60),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: buttonShape,
        textStyle: buttonTextStyle,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 60),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
        shape: buttonShape,
        side: BorderSide(color: scheme.outlineVariant),
        textStyle: buttonTextStyle,
        backgroundColor: brightness == Brightness.dark
            ? scheme.surfaceContainerHigh.withValues(alpha: 0.96)
            : scheme.surfaceContainerLowest.withValues(alpha: 0.96),
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontFamily: serifFamily,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(34),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: brightness == Brightness.dark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side:
              BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.88)),
        ),
      ),
    ),
    chipTheme: ThemeData(brightness: brightness).chipTheme.copyWith(
          backgroundColor: scheme.surfaceContainerLow,
          selectedColor: scheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          side: BorderSide(color: scheme.outlineVariant),
          labelStyle: textTheme.labelLarge,
        ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
    ),
  );
}
