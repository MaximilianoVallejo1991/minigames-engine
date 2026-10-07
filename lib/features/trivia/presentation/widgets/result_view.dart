import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/arcade_button.dart';
import '../../../../core/widgets/arcade_card.dart';
import '../../../../core/widgets/game_body.dart';
import '../../domain/game_rules.dart';
import '../../domain/models/models.dart';
import '../difficulty_style.dart';

class ResultView extends StatelessWidget {
  const ResultView({
    super.key,
    required this.summary,
    required this.onExit,
    required this.onPlayAgain,
    this.message,
  });

  final GameSummary summary;
  final VoidCallback onExit;
  final VoidCallback onPlayAgain;
  final String? message;

  /// Mensaje según qué tan bien salió la partida.
  String get _cheer {
    if (summary.roundsPlayed == 0) return 'Todavía no jugaste ninguna pregunta.';
    final p = summary.accuracyPercent;
    if (p >= 80) {
      return '¡Increíble desempeño! Demostraste un conocimiento ejemplar sobre el cuidado del planeta.';
    }
    if (p >= 50) {
      return '¡Muy bien! Vas por buen camino; una partida más y llegás a la cima.';
    }
    return 'Cada pregunta es una semilla. ¡Probá de nuevo y seguí aprendiendo!';
  }

  @override
  Widget build(BuildContext context) {
    return GameBody(
      children: [
        _ScoreHero(summary: summary, cheer: message ?? _cheer),
        const _SectionLabel('Resumen de partida'),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryFixedDim,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.onPrimaryFixed),
                ),
                value: '${summary.correctCount} / ${summary.roundsPlayed}',
                label: 'Aciertos totales',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                leading: SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    value: summary.accuracyPercent / 100,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.tertiaryFixed,
                    color: AppColors.tertiaryContainer,
                  ),
                ),
                value: '${summary.accuracyPercent}%',
                label: 'Efectividad',
              ),
            ),
          ],
        ),
        ArcadeCard(
          color: AppColors.surfaceContainerLow,
          radius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionLabel('Desglose de preguntas'),
              const SizedBox(height: 6),
              for (final difficulty in Difficulty.values) _BreakdownRow(
                dotColor: difficulty.color,
                label: '${difficulty.label} (+${GameRules.pointsFor(difficulty)} pts)',
                value: () {
                  final stats = summary.statsFor(difficulty);
                  return '${stats.correct} / ${stats.total}';
                }(),
              ),
              if (summary.timedOutCount > 0)
                _BreakdownRow(
                  dotColor: AppColors.slate,
                  label: 'Sin responder (tiempo agotado)',
                  value: '${summary.timedOutCount}',
                ),
            ],
          ),
        ),
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ArcadeButton(
            label: '¡Jugar otra partida!',
            icon: Icons.replay_rounded,
            variant: ArcadeButtonVariant.dark,
            onPressed: onPlayAgain,
          ),
          const SizedBox(height: 6),
          ArcadeButton(
            label: 'Volver al inicio',
            icon: Icons.home_outlined,
            variant: ArcadeButtonVariant.secondary,
            onPressed: onExit,
          ),
        ],
      ),
    );
  }
}

class _ScoreHero extends StatelessWidget {
  const _ScoreHero({required this.summary, required this.cheer});

  final GameSummary summary;
  final String cheer;

  @override
  Widget build(BuildContext context) {
    return ArcadeCard(
      decorated: true,
      color: AppColors.surfaceContainer,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.onSecondaryContainer, offset: Offset(0, 5)),
                      ],
                    ),
                    child: const Icon(Icons.emoji_events_rounded, size: 52, color: Colors.white),
                  ),
                ),
                const Positioned(
                  top: -2,
                  right: -2,
                  child: _MiniBadge(icon: Icons.star_rounded, color: AppColors.secondary),
                ),
                const Positioned(
                  bottom: 6,
                  left: -4,
                  child: _MiniBadge(icon: Icons.eco_rounded, color: AppColors.primaryStrong),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: summary.score),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$value',
                    style: AppTextStyles.counter.copyWith(
                      fontSize: 44,
                      height: 1.1,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  TextSpan(
                    text: ' / ${summary.maxScore}',
                    style: AppTextStyles.counter.copyWith(
                      fontSize: 24,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              semanticsLabel: '${summary.score} de ${summary.maxScore} puntos',
            ),
          ),
          Text('PUNTOS OBTENIDOS', style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurface)),
          const SizedBox(height: 12),
          Text(
            cheer,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x1A0F172A), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelCaps.copyWith(color: AppColors.onSurface),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.leading, required this.value, required this.label});

  final Widget leading;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ArcadeCard(
      color: AppColors.surfaceContainerLow,
      radius: 20,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: AppTextStyles.counter.copyWith(fontSize: 20)),
                ),
                Text(label, style: AppTextStyles.bodySm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.dotColor,
    required this.label,
    required this.value,
  });

  final Color dotColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: AppTextStyles.bodyMd.copyWith(fontSize: 15)),
          ),
          Text(
            value,
            style: AppTextStyles.counter.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
