import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/arcade_button.dart';
import '../../../../core/widgets/arcade_card.dart';
import '../../../../core/widgets/game_body.dart';
import '../../../../core/widgets/pill_progress_bar.dart';
import '../../domain/models/models.dart';
import 'question_card.dart';

/// Paso 4 de cada ronda: resultado de la respuesta y el "¿Sabías que…?".
class AnswerFeedback extends StatelessWidget {
  const AnswerFeedback({
    super.key,
    required this.round,
    required this.questionNumber,
    required this.isLastQuestion,
    required this.totalQuestions,
    required this.onNext,
  });

  final RoundResult round;
  final int questionNumber;
  final bool isLastQuestion;
  final int totalQuestions;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final question = round.question;

    return GameBody(
      spacing: 12,
      children: [
        Row(
          children: [
            Flexible(child: CategoryBadge(category: round.category, tinted: true)),
            const Spacer(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: questionNumber.toString().padLeft(2, '0'),
                    style: AppTextStyles.counter.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 20,
                    ),
                  ),
                  TextSpan(
                    text: ' / $totalQuestions',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.slate),
                  ),
                ],
              ),
            ),
          ],
        ),
        PillProgressBar(
          value: totalQuestions == 0 ? 0 : questionNumber / totalQuestions,
          height: 10,
        ),
        if (question.image != null)
          QuestionImage(path: question.image!, category: round.category),
        Text(question.text, style: AppTextStyles.headlineMd),
        for (var i = 0; i < question.options.length; i++)
          _OptionResult(
            letter: i < QuestionCard.letters.length ? QuestionCard.letters[i] : '${i + 1}',
            option: question.options[i],
            wasSelected: question.options[i].id == round.selectedOption?.id,
          ),
        const SizedBox(height: 4),
        _OutcomeCard(round: round),
      ],
      footer: ArcadeButton(
        label: isLastQuestion
            ? 'Ver resultados'
            : 'Siguiente pregunta (${questionNumber + 1}/$totalQuestions)',
        trailingIcon: isLastQuestion ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
        onPressed: onNext,
      ),
    );
  }
}

class _OptionResult extends StatelessWidget {
  const _OptionResult({
    required this.letter,
    required this.option,
    required this.wasSelected,
  });

  final String letter;
  final AnswerOption option;
  final bool wasSelected;

  @override
  Widget build(BuildContext context) {
    final isCorrect = option.isCorrect;
    final isWrongPick = wasSelected && !isCorrect;
    final highlighted = isCorrect || isWrongPick;
    final accent = isCorrect ? AppColors.correct : AppColors.error;

    final Color background = isCorrect
        ? AppColors.mint
        : isWrongPick
            ? AppColors.errorContainer
            : AppColors.surfaceContainerLow;

    return Opacity(
      opacity: highlighted ? 1 : 0.7,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: highlighted ? accent.withValues(alpha: 0.5) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            LetterBadge(
              letter: letter,
              background: highlighted ? accent : AppColors.surfaceContainer,
              foreground: highlighted ? Colors.white : AppColors.slate,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.text,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: highlighted ? FontWeight.w700 : FontWeight.w400,
                      color: highlighted ? AppColors.onSurface : AppColors.slate,
                    ),
                  ),
                  if (wasSelected)
                    Text(
                      'TU SELECCIÓN',
                      style: AppTextStyles.labelCaps.copyWith(
                        fontSize: 11,
                        color: AppColors.darken(accent, 0.08),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (highlighted)
              _ResultTag(correct: isCorrect)
            else
              const Icon(
                Icons.radio_button_unchecked_rounded,
                color: AppColors.outlineVariant,
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultTag extends StatelessWidget {
  const _ResultTag({required this.correct});

  final bool correct;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppColors.primaryDark : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            correct ? 'Correcto' : 'Incorrecta',
            style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  const _OutcomeCard({required this.round});

  final RoundResult round;

  @override
  Widget build(BuildContext context) {
    final (String title, IconData icon, Color color, Color tint) = switch (round.outcome) {
      RoundOutcome.correct => (
          '¡Excelente respuesta!',
          Icons.celebration_rounded,
          AppColors.primary,
          AppColors.primaryFixed,
        ),
      RoundOutcome.incorrect => (
          'Respuesta incorrecta',
          Icons.sentiment_dissatisfied_rounded,
          AppColors.error,
          AppColors.errorContainer,
        ),
      RoundOutcome.timedOut => (
          'Se acabó el tiempo',
          Icons.timer_off_rounded,
          AppColors.amber,
          AppColors.secondaryFixed,
        ),
    };
    final explanation = round.question.explanation;

    return ArcadeCard(
      topEdgeColor: color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.darken(color, 0.1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.headlineMd),
                    Text(
                      round.isCorrect ? '+${round.points} puntos obtenidos' : '0 puntos',
                      style: AppTextStyles.labelCaps.copyWith(
                        color: round.isCorrect ? AppColors.secondary : AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (explanation != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.tertiaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      size: 18,
                      color: AppColors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿SABÍAS QUE…?',
                          style: AppTextStyles.labelCaps.copyWith(color: AppColors.tertiary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          explanation,
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
