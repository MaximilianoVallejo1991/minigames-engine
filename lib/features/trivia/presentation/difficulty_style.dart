import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/models/models.dart';

/// Personalidad visual de cada nivel (colores, ícono y apodo del diseño).
extension DifficultyStyle on Difficulty {
  /// Apodo temático que acompaña al nivel.
  String get nickname => switch (this) {
        Difficulty.easy => 'Brote Verde',
        Difficulty.medium => 'Eco Rayo',
        Difficulty.hard => 'Guardián Experto',
      };

  String get description => switch (this) {
        Difficulty.easy => 'Preguntas básicas y directas',
        Difficulty.medium => 'Desafíos intermedios con curiosidades',
        Difficulty.hard => 'Preguntas complejas y datos específicos',
      };

  IconData get icon => switch (this) {
        Difficulty.easy => Icons.spa_rounded,
        Difficulty.medium => Icons.bolt_rounded,
        Difficulty.hard => Icons.local_fire_department_rounded,
      };

  /// Color fuerte (texto, ícono, borde de selección).
  Color get color => switch (this) {
        Difficulty.easy => AppColors.primaryStrong,
        Difficulty.medium => const Color(0xFFD97706),
        Difficulty.hard => AppColors.error,
      };

  /// Fondo suave (círculo del ícono y chip de puntos).
  Color get tint => switch (this) {
        Difficulty.easy => const Color(0xFFD1FAE5),
        Difficulty.medium => const Color(0xFFFFEDD5),
        Difficulty.hard => const Color(0xFFFFE4E6),
      };

  /// Texto del chip de puntos.
  Color get onTint => switch (this) {
        Difficulty.easy => const Color(0xFF065F46),
        Difficulty.medium => const Color(0xFF7C4A03),
        Difficulty.hard => const Color(0xFF9F1239),
      };

  /// Borde inferior cuando la tarjeta está seleccionada.
  Color get edgeColor => switch (this) {
        Difficulty.easy => AppColors.primaryEdge,
        Difficulty.medium => const Color(0xFFB45309),
        Difficulty.hard => AppColors.errorEdge,
      };
}
