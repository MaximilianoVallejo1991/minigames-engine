import 'package:flutter/material.dart';

/// Tema visual. Para cambiar de temática (no solo medioambiente),
/// se ajusta la semilla de color y los assets.
abstract final class AppTheme {
  static const Color seed = Color(0xFF2E7D32);

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      useMaterial3: true,
    );
  }

  /// Convierte '#RRGGBB' en [Color].
  static Color fromHex(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }
}
