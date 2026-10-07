import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Escala tipográfica del diseño.
///
/// - Plus Jakarta Sans: títulos, botones, chips y contadores.
/// - Inter: preguntas, explicaciones y textos de apoyo.
///
/// Las fuentes están embebidas en `assets/fonts/` (no se descargan en runtime).
abstract final class AppTextStyles {
  static const String display = 'PlusJakartaSans';
  static const String body = 'Inter';

  static const TextStyle displayHero = TextStyle(
    fontFamily: display,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.64,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: display,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.28,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: display,
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: display,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: body,
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: body,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: body,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle button = TextStyle(
    fontFamily: display,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.16,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: display,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.72,
    color: AppColors.onSurfaceVariant,
  );

  /// Contadores (puntaje, tiempo): números tabulares para que no "salten".
  static const TextStyle counter = TextStyle(
    fontFamily: display,
    fontSize: 24,
    height: 28 / 24,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
