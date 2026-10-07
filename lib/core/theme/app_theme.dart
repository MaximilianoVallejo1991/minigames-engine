import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Tema visual "Arcade Neo-Pop". Para cambiar de temática (no solo
/// medioambiente) se ajustan [AppColors], las fuentes y los assets.
abstract final class AppTheme {
  /// Ancho máximo del área de juego en pantallas grandes.
  static const double maxContentWidth = 560;

  /// Margen lateral de las pantallas.
  static const double margin = 16;

  // Radios del diseño.
  static const double radiusSm = 8;
  static const double radius = 16;
  static const double radiusMd = 24;
  static const double radiusLg = 32;

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryFixed,
      onPrimaryContainer: AppColors.onPrimaryFixed,
      secondary: AppColors.secondaryContainer,
      onSecondary: AppColors.onSecondaryContainer,
      secondaryContainer: AppColors.secondaryFixed,
      onSecondaryContainer: AppColors.onSecondaryFixed,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiaryFixed,
      onTertiaryContainer: Color(0xFF001F28),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: Color(0xFF93000A),
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      outline: AppColors.borderEdge,
      outlineVariant: AppColors.border,
      inverseSurface: Color(0xFF283044),
      onInverseSurface: Color(0xFFEEF0FF),
      inversePrimary: AppColors.primaryFixedDim,
      shadow: Color(0xFF0F172A),
      scrim: Color(0xFF0F172A),
    );

    const textTheme = TextTheme(
      displaySmall: AppTextStyles.displayHero,
      headlineMedium: AppTextStyles.headlineLg,
      headlineSmall: AppTextStyles.headlineMd,
      titleLarge: AppTextStyles.headlineMd,
      titleMedium: AppTextStyles.headlineSm,
      titleSmall: AppTextStyles.button,
      bodyLarge: AppTextStyles.bodyLg,
      bodyMedium: AppTextStyles.bodyMd,
      bodySmall: AppTextStyles.bodySm,
      labelLarge: AppTextStyles.button,
      labelMedium: AppTextStyles.labelCaps,
      labelSmall: AppTextStyles.labelCaps,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: AppTextStyles.body,
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceContainerHigh,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF283044),
        contentTextStyle: AppTextStyles.bodySm.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  /// Convierte '#RRGGBB' en [Color].
  static Color fromHex(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }
}
