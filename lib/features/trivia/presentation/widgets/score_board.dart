import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Píldoras superiores: número de pregunta y puntaje acumulado.
class ScoreBoard extends StatelessWidget {
  const ScoreBoard({
    super.key,
    required this.score,
    required this.questionNumber,
    required this.totalQuestions,
  });

  final int score;
  final int questionNumber;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: _StatPill(
            leading: _RoundBadge(number: questionNumber, total: totalQuestions),
            child: Text(
              'Pregunta $questionNumber de $totalQuestions',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _StatPill(
          leading: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, size: 16, color: Colors.white),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'PUNTAJE: '),
                TextSpan(
                  text: '$score',
                  style: const TextStyle(color: AppColors.secondaryContainer),
                ),
              ],
            ),
            style: AppTextStyles.labelCaps.copyWith(
              fontSize: 13,
              color: AppColors.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.leading, required this.child});

  final Widget leading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: 8),
            // Flexible solo si el ancho está acotado (ver Pill).
            if (constraints.hasBoundedWidth) Flexible(child: child) else child,
          ],
        ),
      ),
    );
  }
}

class _RoundBadge extends StatelessWidget {
  const _RoundBadge({required this.number, required this.total});

  final int number;
  final int total;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: total == 0 ? 0 : number / total,
            strokeWidth: 3,
            backgroundColor: AppColors.surfaceContainerHighest,
            color: AppColors.primary,
          ),
          Text(
            '$number',
            style: AppTextStyles.labelCaps.copyWith(
              fontSize: 10,
              letterSpacing: 0,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra superior de pasos: "Pregunta N de 10" + etiqueta del paso.
class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.stepLabel,
  });

  final int questionNumber;
  final int totalQuestions;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: const [
          BoxShadow(color: AppColors.surfaceContainerHighest, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_outlined, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Pregunta $questionNumber',
                    style: AppTextStyles.headlineSm,
                  ),
                  TextSpan(
                    text: ' de $totalQuestions',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(
              stepLabel.toUpperCase(),
              style: AppTextStyles.labelCaps.copyWith(
                fontSize: 11,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
