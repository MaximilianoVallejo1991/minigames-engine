import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/game_rules.dart';
import '../../domain/models/models.dart';

/// Paso 3 de cada ronda: responder antes de que se acabe el tiempo.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.category,
    required this.question,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.onAnswer,
  });

  final TriviaCategory category;
  final Question question;
  final int remainingSeconds;
  final int totalSeconds;
  final ValueChanged<AnswerOption> onAnswer;

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isRunningOut = remainingSeconds <= 5;

    return ListView(
      children: [
        Row(
          children: [
            Chip(
              label: Text(category.name),
              backgroundColor:
                  AppTheme.fromHex(category.colorHex).withValues(alpha: 0.15),
            ),
            const SizedBox(width: 8),
            Text(
              '${question.difficulty.label} · +${GameRules.pointsFor(question.difficulty)} pts',
            ),
            const Spacer(),
            Icon(Icons.timer_outlined, color: isRunningOut ? colors.error : null),
            const SizedBox(width: 4),
            Text(
              '${remainingSeconds}s',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isRunningOut ? colors.error : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: totalSeconds == 0 ? 0 : remainingSeconds / totalSeconds,
          color: isRunningOut ? colors.error : null,
        ),
        const SizedBox(height: 16),
        if (question.image != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              question.image!,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(question.text, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        for (var i = 0; i < question.options.length; i++) ...[
          OutlinedButton(
            onPressed: () => onAnswer(question.options[i]),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
            ),
            child: Row(
              children: [
                Text(
                  i < _letters.length ? _letters[i] : '${i + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(question.options[i].text, style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
