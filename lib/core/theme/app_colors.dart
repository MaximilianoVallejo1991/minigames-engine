import 'package:flutter/painting.dart';

/// Paleta "Arcade Neo-Pop" (diseño hecho en Stitch, ver DESIGN.md).
///
/// Para cambiar de temática se tocan estos valores y los colores de las
/// categorías en `assets/data/`; las pantallas solo usan estos nombres.
abstract final class AppColors {
  // Superficies
  static const Color surface = Color(0xFFFAF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FD);
  static const Color surfaceDim = Color(0xFFD2D9F4);

  // Texto
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF3C4A42);
  static const Color slate = Color(0xFF64748B);

  // Bordes
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderEdge = Color(0xFFCBD5E1);
  static const Color outlineVariant = Color(0xFFBBCABF);

  // Primario (verde esmeralda)
  static const Color primary = Color(0xFF10B981);
  static const Color primaryEdge = Color(0xFF005236);
  static const Color primaryDark = Color(0xFF006C49);
  static const Color primaryStrong = Color(0xFF059669);
  static const Color primaryFixed = Color(0xFF6FFBBE);
  static const Color primaryFixedDim = Color(0xFF4EDEA3);
  static const Color onPrimaryFixed = Color(0xFF002113);
  static const Color mint = Color(0xFFECFDF5);

  // Secundario (ámbar: premios, puntaje, ruleta)
  static const Color secondary = Color(0xFF855300);
  static const Color secondaryContainer = Color(0xFFFEA619);
  static const Color onSecondaryContainer = Color(0xFF684000);
  static const Color secondaryFixed = Color(0xFFFFDDB8);
  static const Color secondaryFixedDim = Color(0xFFFFB95F);
  static const Color onSecondaryFixed = Color(0xFF2A1700);
  static const Color amber = Color(0xFFF59E0B);

  // Terciario (cian)
  static const Color tertiary = Color(0xFF006780);
  static const Color tertiaryContainer = Color(0xFF41AFD1);
  static const Color tertiaryFixed = Color(0xFFB7EAFF);
  static const Color tertiaryFixedDim = Color(0xFF6CD3F7);

  // Feedback
  static const Color correct = Color(0xFF059669);
  static const Color error = Color(0xFFE11D48);
  static const Color errorEdge = Color(0xFFB91C1C);
  static const Color errorContainer = Color(0xFFFFE4E6);

  /// Sombra suave para tarjetas blancas sobre el fondo.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F0F172A),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  /// Color más oscuro del mismo tono, para el "borde inferior" 3D.
  static Color darken(Color color, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
