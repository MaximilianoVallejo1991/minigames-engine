import 'package:flutter/material.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../domain/models/models.dart';

/// Paso 4 de cada ronda: resultado de la respuesta y el "¿Sabías que…?".
class AnswerFeedback extends StatelessWidget {
  const AnswerFeedback({
    super.key,
    required this.round,
    required this.isLastQuestion,
    required this.nextQuestionNumber,
    required this.totalQuestions,
    required this.onNext,
  });

  final RoundResult round;
  final bool isLastQuestion;
  final int nextQuestionNumber;
  final int totalQuestions;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final question = round.question;

    final (String title, IconData icon, Color color) = switch (round.outcome) {
      RoundOutcome.correct => ('¡Excelente respuesta!', Icons.celebration, Colors.green),
      RoundOutcome.incorrect => ('Respuesta incorrecta', Icons.cancel_outlined, Colors.red),
      RoundOutcome.timedOut => ('Se acabó el tiempo', Icons.timer_off_outlined, Colors.orange),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Text(question.text, style: textTheme.titleLarge),
              const SizedBox(height: 16),
              for (final option in question.options) ...[
                _OptionResult(
                  option: option,
                  wasSelected: option.id == round.selectedOption?.id,
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(title, style: textTheme.titleMedium?.copyWith(color: color)),
                ],
              ),
              Text(
                round.isCorrect ? '+${round.points} puntos obtenidos' : '0 puntos',
              ),
              if (question.explanation != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('¿Sabías que…?', style: textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Text(question.explanation!),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: isLastQuestion
              ? 'Ver resultados'
              : 'Siguiente pregunta ($nextQuestionNumber/$totalQuestions)',
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _OptionResult extends StatelessWidget {
  const _OptionResult({required this.option, required this.wasSelected});

  final AnswerOption option;
  final bool wasSelected;

  @override
  Widget build(BuildContext context) {
    final Color? background;
    final String? tag;
    if (option.isCorrect) {
      background = Colors.green.withValues(alpha: 0.2);
      tag = wasSelected ? 'Correcto · Tu selección' : 'Correcto';
    } else if (wasSelected) {
      background = Colors.red.withValues(alpha: 0.2);
      tag = 'Tu selección';
    } else {
      background = null;
      tag = null;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(option.text)),
          if (tag != null) Text(tag, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
