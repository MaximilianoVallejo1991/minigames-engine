import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/game_rules.dart';
import '../../domain/models/models.dart';

/// Paso 2 de cada ronda: girar la ruleta para obtener la categoría.
/// TODO: reemplazar por una ruleta animada (CustomPainter + AnimationController).
class RouletteView extends StatelessWidget {
  const RouletteView({
    super.key,
    required this.categories,
    required this.difficulty,
    required this.isSpinning,
    required this.onSpin,
    this.message,
  });

  final List<TriviaCategory> categories;
  final Difficulty difficulty;
  final bool isSpinning;
  final VoidCallback onSpin;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Chip(
          avatar: const Icon(Icons.check_circle_outline, size: 18),
          label: Text(
            'Nivel: ${difficulty.label} (+${GameRules.pointsFor(difficulty)} pts)',
          ),
        ),
        Expanded(
          child: Center(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final category in categories)
                  Chip(
                    label: Text(category.name),
                    backgroundColor:
                        AppTheme.fromHex(category.colorHex).withValues(alpha: 0.15),
                  ),
              ],
            ),
          ),
        ),
        if (message != null) ...[
          Text(message!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
        ],
        PrimaryButton(
          label: isSpinning ? 'Girando…' : '¡Girar ruleta!',
          onPressed: isSpinning ? null : onSpin,
        ),
      ],
    );
  }
}
