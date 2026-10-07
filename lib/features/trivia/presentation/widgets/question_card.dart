import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/arcade_card.dart';
import '../../../../core/widgets/game_body.dart';
import '../../../../core/widgets/pill.dart';
import '../../../../core/widgets/pill_progress_bar.dart';
import '../../../../core/widgets/pressable_3d.dart';
import '../../domain/game_rules.dart';
import '../../domain/models/models.dart';
import '../category_style.dart';
import '../difficulty_style.dart';

/// Paso 3 de cada ronda: responder antes de que se acabe el tiempo.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.category,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.onAnswer,
  });

  final TriviaCategory category;
  final Question question;
  final int questionNumber;
  final int totalQuestions;
  final int remainingSeconds;
  final int totalSeconds;
  final ValueChanged<AnswerOption> onAnswer;

  static const letters = ['A', 'B', 'C', 'D', 'E'];

  @override
  Widget build(BuildContext context) {
    final fraction = totalSeconds == 0 ? 0.0 : remainingSeconds / totalSeconds;

    return GameBody(
      spacing: 12,
      children: [
        Row(
          children: [
            Expanded(
              child: QuestionCounter(
                questionNumber: questionNumber,
                totalQuestions: totalQuestions,
              ),
            ),
            TimerPill(seconds: remainingSeconds, fraction: fraction),
          ],
        ),
        PillProgressBar(
          value: fraction,
          color: timerColor(fraction),
          height: 12,
          duration: const Duration(milliseconds: 950),
        ),
        const SizedBox(height: 2),
        Center(child: CategoryBadge(category: category)),
        Center(
          child: Pill(
            label:
                'Nivel ${question.difficulty.label} • +${GameRules.pointsFor(question.difficulty)} pts',
            icon: Icons.military_tech_outlined,
            background: question.difficulty.tint,
            foreground: question.difficulty.onTint,
            dense: true,
          ),
        ),
        ArcadeCard(
          decorated: true,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (question.image != null) ...[
                QuestionImage(path: question.image!, category: category),
                const SizedBox(height: 16),
              ],
              Text(question.text, style: AppTextStyles.headlineMd),
            ],
          ),
        ),
        for (var i = 0; i < question.options.length; i++)
          AnswerOptionButton(
            letter: i < letters.length ? letters[i] : '${i + 1}',
            text: question.options[i].text,
            onTap: () => onAnswer(question.options[i]),
          ),
      ],
    );
  }

  /// Verde → ámbar → rosa a medida que se acaba el tiempo.
  static Color timerColor(double fraction) {
    if (fraction > 0.5) {
      return Color.lerp(AppColors.amber, AppColors.primary, (fraction - 0.5) * 2)!;
    }
    return Color.lerp(AppColors.error, AppColors.amber, fraction * 2)!;
  }
}

/// "PREGUNTA 3 /10".
class QuestionCounter extends StatelessWidget {
  const QuestionCounter({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
  });

  final int questionNumber;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'PREGUNTA '),
          TextSpan(
            text: '$questionNumber',
            style: AppTextStyles.counter.copyWith(
              color: AppColors.primaryDark,
              fontSize: 20,
            ),
          ),
          TextSpan(
            text: ' /$totalQuestions',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.slate),
          ),
        ],
      ),
      style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurface),
    );
  }
}

class TimerPill extends StatelessWidget {
  const TimerPill({super.key, required this.seconds, required this.fraction});

  final int seconds;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final runningOut = seconds <= 5;
    final color = runningOut ? AppColors.error : AppColors.onSecondaryContainer;
    return Semantics(
      label: 'Quedan $seconds segundos',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: runningOut ? AppColors.errorContainer : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              '${seconds}s',
              style: AppTextStyles.counter.copyWith(fontSize: 16, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de la categoría con su color de fondo.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category, this.tinted = false});

  final TriviaCategory category;

  /// Versión suave (fondo translúcido y texto del color de la categoría).
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Pill(
      label: category.name,
      icon: category.iconData,
      background: tinted ? category.tint : category.color,
      foreground: tinted ? AppColors.darken(category.color, 0.1) : Colors.white,
      edgeColor: tinted ? null : category.edgeColor,
    );
  }
}

class QuestionImage extends StatelessWidget {
  const QuestionImage({super.key, required this.path, required this.category});

  final String path;
  final TriviaCategory category;

  @override
  Widget build(BuildContext context) {
    final isNetwork = path.startsWith('http');
    final fallback = Container(
      color: category.tint,
      alignment: Alignment.center,
      child: Icon(category.iconData, size: 56, color: category.color),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: isNetwork
            ? Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback)
            : Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback),
      ),
    );
  }
}

/// Opción de respuesta: tarjeta blanca 3D con la letra en un círculo.
class AnswerOptionButton extends StatelessWidget {
  const AnswerOptionButton({
    super.key,
    required this.letter,
    required this.text,
    required this.onTap,
  });

  final String letter;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable3D(
      onTap: onTap,
      semanticLabel: 'Opción $letter: $text',
      color: AppColors.surfaceContainerLowest,
      edgeColor: AppColors.borderEdge,
      border: Border.all(color: AppColors.border, width: 2),
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            LetterBadge(letter: letter),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LetterBadge extends StatelessWidget {
  const LetterBadge({
    super.key,
    required this.letter,
    this.background = AppColors.surfaceContainer,
    this.foreground = AppColors.onSurface,
  });

  final String letter;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppTextStyles.headlineMd.copyWith(color: foreground, fontWeight: FontWeight.w800),
      ),
    );
  }
}
