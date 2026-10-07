import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/models/models.dart';

/// Traduce los datos de una categoría (color e ícono como texto) a la UI.
///
/// Los íconos se nombran en `assets/data/` con el nombre de Material Icons.
/// Para agregar una temática nueva, sumar acá los íconos que use.
extension CategoryStyle on TriviaCategory {
  Color get color => AppTheme.fromHex(colorHex);

  /// Fondo suave (10 %) para chips y badges.
  Color get tint => color.withValues(alpha: 0.12);

  /// Borde inferior 3D del color de la categoría.
  Color get edgeColor => AppColors.darken(color, 0.15);

  IconData get iconData => _icons[icon] ?? Icons.category_rounded;
}

const Map<String, IconData> _icons = {
  'recycling': Icons.recycling_rounded,
  'bolt': Icons.bolt_rounded,
  'sunny': Icons.wb_sunny_rounded,
  'water_drop': Icons.water_drop_rounded,
  'waves': Icons.waves_rounded,
  'water': Icons.water_rounded,
  'forest': Icons.forest_rounded,
  'eco': Icons.eco_rounded,
  'park': Icons.park_rounded,
  'air': Icons.air_rounded,
  'cloud': Icons.cloud_rounded,
  'thermostat': Icons.thermostat_rounded,
  'shopping_bag': Icons.shopping_bag_rounded,
  'shopping_cart': Icons.shopping_cart_rounded,
  'science': Icons.science_rounded,
  'public': Icons.public_rounded,
  'history_edu': Icons.history_edu_rounded,
  'calculate': Icons.calculate_rounded,
  'sports_soccer': Icons.sports_soccer_rounded,
  'music_note': Icons.music_note_rounded,
  'palette': Icons.palette_rounded,
  'pets': Icons.pets_rounded,
};
