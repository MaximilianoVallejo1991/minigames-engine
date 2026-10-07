import 'package:flutter/material.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../domain/game_rules.dart';
import '../../domain/models/models.dart';

class ResultView extends StatelessWidget {
  const ResultView({
    super.key,
    required this.summary,
    required this.onExit,
    this.message,
  });

  final GameSummary summary;
  final VoidCallback onExit;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      children: [
        const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
        const SizedBox(height: 8),
        Text(
          '${summary.score} / ${summary.maxScore}',
          style: textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        Text('Puntos obtenidos', textAlign: TextAlign.center, style: textTheme.labelLarge),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!, textAlign: TextAlign.center),
        ],
        const SizedBox(height: 24),
        Text('Resumen de partida', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${summary.correctCount} / ${summary.roundsPlayed}',
                label: 'Aciertos',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(value: '${summary.accuracyPercent} %', label: 'Efectividad'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Desglose por nivel', style: textTheme.titleMedium),
        for (final difficulty in Difficulty.values)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('${difficulty.label} (+${GameRules.pointsFor(difficulty)} pts)'),
            trailing: Text(() {
              final stats = summary.statsFor(difficulty);
              return '${stats.correct} / ${stats.total}';
            }()),
          ),
        if (summary.timedOutCount > 0)
          Text('Sin responder (tiempo agotado): ${summary.timedOutCount}'),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Volver al inicio', onPressed: onExit),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label),
          ],
        ),
      ),
    );
  }
}
