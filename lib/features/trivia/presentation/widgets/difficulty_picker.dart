import 'package:flutter/material.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../domain/game_rules.dart';
import '../../domain/models/models.dart';

/// Paso 1 de cada ronda: elegir la dificultad de la próxima pregunta.
class DifficultyPicker extends StatefulWidget {
  const DifficultyPicker({
    super.key,
    required this.onConfirm,
    this.exhausted = const {},
    this.message,
  });

  final ValueChanged<Difficulty> onConfirm;

  /// Dificultades que ya no tienen preguntas disponibles.
  final Set<Difficulty> exhausted;
  final String? message;

  @override
  State<DifficultyPicker> createState() => _DifficultyPickerState();
}

class _DifficultyPickerState extends State<DifficultyPicker> {
  Difficulty? _selected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Si la opción elegida se quedó sin preguntas, se descarta la selección.
    final selected = widget.exhausted.contains(_selected) ? null : _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Elegí el nivel', style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        const Text('Seleccioná la dificultad para esta pregunta y define tus puntos en juego.'),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              for (final difficulty in Difficulty.values)
                _DifficultyCard(
                  difficulty: difficulty,
                  selected: selected == difficulty,
                  enabled: !widget.exhausted.contains(difficulty),
                  onTap: () => setState(() => _selected = difficulty),
                ),
            ],
          ),
        ),
        if (widget.message != null) ...[
          Text(widget.message!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
        ],
        PrimaryButton(
          label: 'Girar ruleta',
          onPressed: selected == null ? null : () => widget.onConfirm(selected),
        ),
      ],
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.difficulty,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final Difficulty difficulty;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? colors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        enabled: enabled,
        onTap: enabled ? onTap : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(difficulty.label),
        subtitle: Text(
          enabled
              ? '+${GameRules.pointsFor(difficulty)} pts por acierto'
              : 'Sin preguntas disponibles',
        ),
        trailing: Icon(
          selected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: selected ? colors.primary : null,
        ),
      ),
    );
  }
}
