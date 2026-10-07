import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/arcade_button.dart';
import '../../../../core/widgets/arcade_card.dart';
import '../../../../core/widgets/game_body.dart';
import '../../../../core/widgets/pressable_3d.dart';
import '../../domain/game_rules.dart';
import '../../domain/models/models.dart';
import '../difficulty_style.dart';
import 'score_board.dart';

/// Paso 1 de cada ronda: elegir la dificultad de la próxima pregunta.
class DifficultyPicker extends StatefulWidget {
  const DifficultyPicker({
    super.key,
    required this.onConfirm,
    required this.questionNumber,
    required this.totalQuestions,
    this.exhausted = const {},
    this.message,
  });

  final ValueChanged<Difficulty> onConfirm;
  final int questionNumber;
  final int totalQuestions;

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
    // Si la opción elegida se quedó sin preguntas, se descarta la selección.
    final selected = widget.exhausted.contains(_selected) ? null : _selected;

    return GameBody(
      children: [
        StepHeader(
          questionNumber: widget.questionNumber,
          totalQuestions: widget.totalQuestions,
          stepLabel: 'Paso 1: Dificultad',
        ),
        const _IntroCard(),
        for (final difficulty in Difficulty.values)
          _DifficultyCard(
            difficulty: difficulty,
            selected: selected == difficulty,
            enabled: !widget.exhausted.contains(difficulty),
            onTap: () => setState(() => _selected = difficulty),
          ),
        if (widget.message != null) _Notice(text: widget.message!),
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ArcadeButton(
            label: 'Girar ruleta',
            icon: Icons.casino_rounded,
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: selected == null ? null : () => widget.onConfirm(selected),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco_outlined, size: 14, color: AppColors.slate),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  selected == null
                      ? 'Elegí un nivel para continuar'
                      : 'La ruleta sortea la categoría de la pregunta',
                  style: AppTextStyles.bodySm.copyWith(
                    fontSize: 12,
                    color: AppColors.slate,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return ArcadeCard(
      bottomEdgeColor: AppColors.surfaceContainerHighest,
      decorated: true,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.tertiaryFixed, AppColors.primaryFixed],
              ),
            ),
            child: const Icon(Icons.tune_rounded, size: 34, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RONDA ACTUAL',
                  style: AppTextStyles.labelCaps.copyWith(color: AppColors.primaryDark),
                ),
                const SizedBox(height: 2),
                const Text('Elegí el nivel', style: AppTextStyles.headlineLg),
                const SizedBox(height: 2),
                const Text(
                  'Seleccioná la dificultad para esta pregunta y definí tus puntos en juego.',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
        ],
      ),
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
    final points = GameRules.pointsFor(difficulty);

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Pressable3D(
        onTap: enabled ? onTap : null,
        selected: selected,
        semanticLabel: '${difficulty.label}, más $points puntos por acierto',
        color: AppColors.surfaceContainerLowest,
        edgeColor: selected ? difficulty.edgeColor : AppColors.surfaceContainerHighest,
        depth: 5,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected ? difficulty.color : AppColors.surfaceContainerLowest,
          width: 2,
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: difficulty.tint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(difficulty.icon, color: difficulty.color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 8,
                        children: [
                          Text(difficulty.label, style: AppTextStyles.headlineMd),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              difficulty.nickname,
                              style: AppTextStyles.bodySm.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        enabled ? difficulty.description : 'Sin preguntas disponibles',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _CheckCircle(selected: selected),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: difficulty.tint,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars_rounded, size: 16, color: difficulty.onTint),
                  const SizedBox(width: 6),
                  Text(
                    '+$points pts por acierto',
                    style: AppTextStyles.labelCaps.copyWith(
                      color: difficulty.onTint,
                      letterSpacing: 0,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primary : AppColors.surfaceContainer,
      ),
      child: Icon(
        Icons.check_rounded,
        size: 18,
        color: selected ? Colors.white : AppColors.surfaceDim,
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryFixed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.onSecondaryFixed),
            ),
          ),
        ],
      ),
    );
  }
}
