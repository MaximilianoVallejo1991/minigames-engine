import 'package:flutter/material.dart';

import '../../core/theme/app_brand.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/arcade_button.dart';
import '../../core/widgets/arcade_card.dart';
import '../../core/widgets/game_app_bar.dart';
import '../../core/widgets/game_body.dart';
import '../../core/widgets/pill.dart';
import '../trivia/domain/game_rules.dart';
import '../trivia/domain/models/models.dart';
import '../trivia/domain/trivia_repository.dart';
import '../trivia/presentation/category_style.dart';
import '../trivia/presentation/screens/trivia_game_screen.dart';

/// Inicio / selector de minijuegos. Cada juego nuevo es una carpeta hermana
/// en features/ y suma su tarjeta acá.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.triviaRepository});

  final TriviaRepository triviaRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<TriviaCategory>> _categories =
      widget.triviaRepository.getCategories();

  void _play() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TriviaGameScreen(repository: widget.triviaRepository),
      ),
    );
  }

  void _showRules() {
    showDialog<void>(context: context, builder: (_) => const _RulesDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GameAppBar(
        title: AppBrand.appName,
        titleColor: AppColors.primaryDark,
        showBack: false,
        actions: [
          RoundIconButton(
            icon: Icons.help_outline_rounded,
            tooltip: 'Reglas del juego',
            onPressed: _showRules,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: GameBody(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Pill(
                label: 'MVP · Temporada activa',
                leading: _PulseDot(),
                background: AppColors.surfaceContainerLow,
              ),
            ),
            const _HeroCard(),
            Column(
              children: [
                ArcadeButton(
                  label: '¡Jugar partida!',
                  icon: Icons.rocket_launch_rounded,
                  uppercase: true,
                  height: 64,
                  onPressed: _play,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${GameRules.questionsPerGame} preguntas · '
                      '${GameRules.questionTimeLimit.inSeconds} s cada una',
                      style: AppTextStyles.labelCaps.copyWith(letterSpacing: 0.2),
                    ),
                  ],
                ),
              ],
            ),
            const _MissionCard(),
            FutureBuilder<List<TriviaCategory>>(
              future: _categories,
              builder: (context, snapshot) {
                final categories = snapshot.data ?? const <TriviaCategory>[];
                if (categories.isEmpty) return const SizedBox.shrink();
                return _CategoriesCard(categories: categories);
              },
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_c),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return ArcadeCard(
      decorated: true,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        children: [
          const Pill(
            label: '¡Bienvenido a ${AppBrand.gameName}!',
            icon: Icons.eco_rounded,
            background: AppColors.primaryFixed,
            foreground: AppColors.onPrimaryFixed,
          ),
          const SizedBox(height: 12),
          const Text(
            AppBrand.heroTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayHero,
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: const Text(
              AppBrand.heroSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 140,
            height: 132,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [AppColors.surfaceContainerHigh, AppColors.surface],
                    ),
                    boxShadow: [
                      BoxShadow(color: AppColors.surfaceContainerHighest, offset: Offset(0, 6)),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.tertiaryContainer, AppColors.primary],
                        ),
                      ),
                      child: const Icon(Icons.public_rounded, size: 52, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Pill(
                    label: 'Hasta ${GameRules.maxScore} pts',
                    icon: Icons.bolt_rounded,
                    dense: true,
                    background: AppColors.secondaryContainer,
                    foreground: AppColors.onSecondaryContainer,
                    edgeColor: AppColors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard();

  @override
  Widget build(BuildContext context) {
    return ArcadeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryFixed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${GameRules.questionsPerGame}',
                  style: AppTextStyles.labelCaps.copyWith(
                    color: AppColors.onSecondaryFixed,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Trivia con ruleta', style: AppTextStyles.headlineSm),
              ),
              const Pill(
                label: 'Partida única',
                uppercase: false,
                dense: true,
                background: AppColors.surfaceContainerHigh,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Step(
                  icon: Icons.tune_rounded,
                  color: AppColors.primaryDark,
                  title: '1. Dificultad',
                  subtitle: 'Elegí tu ritmo',
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _Step(
                  icon: Icons.casino_outlined,
                  color: AppColors.tertiary,
                  title: '2. Ruleta',
                  subtitle: 'Categoría al azar',
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _Step(
                  icon: Icons.military_tech_outlined,
                  color: AppColors.secondary,
                  title: '3. Puntaje',
                  subtitle: 'Respondé y sumá',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelCaps.copyWith(
              color: AppColors.onSurface,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySm.copyWith(fontSize: 11, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({required this.categories});

  final List<TriviaCategory> categories;

  @override
  Widget build(BuildContext context) {
    return ArcadeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Temas en juego', style: AppTextStyles.headlineSm),
              ),
              Text('${categories.length} áreas', style: AppTextStyles.labelCaps),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final columns = constraints.maxWidth < 300 ? 2 : 3;
              final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap + 2,
                children: [
                  for (final category in categories)
                    SizedBox(width: width, child: _CategoryChip(category: category)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final TriviaCategory category;

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.darken(category.color, 0.12);
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Color.alphaBlend(category.color.withValues(alpha: 0.16), Colors.white),
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(color: category.color.withValues(alpha: 0.45), offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category.iconData, size: 16, color: fg),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelCaps.copyWith(
                color: fg,
                fontSize: 11,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.75,
      child: Column(
        children: [
          Text(
            '${AppBrand.gameName} MVP  •  Versión 1.0',
            style: AppTextStyles.labelCaps,
          ),
          const SizedBox(height: 2),
          Text(
            AppBrand.footer,
            style: AppTextStyles.bodySm.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RulesDialog extends StatelessWidget {
  const _RulesDialog();

  @override
  Widget build(BuildContext context) {
    final points = Difficulty.values
        .map((d) => '${d.label} +${GameRules.pointsFor(d)}')
        .join(' · ');
    return Dialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.info_rounded, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reglas rápidas',
                    style: AppTextStyles.headlineSm.copyWith(color: AppColors.primaryDark),
                  ),
                ),
                RoundIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Cerrar',
                  size: 36,
                  background: AppColors.surfaceContainerHigh,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RuleLine(
              title: '${GameRules.questionsPerGame} preguntas por partida.',
              text: 'Antes de cada una elegís el nivel y girás la ruleta.',
            ),
            _RuleLine(title: 'Puntos por acierto:', text: points),
            _RuleLine(
              title: '${GameRules.questionTimeLimit.inSeconds} segundos por pregunta.',
              text: 'Si se acaba el tiempo o fallás, sumás 0 y seguís jugando.',
            ),
            _RuleLine(
              title: 'Máximo: ${GameRules.maxScore} puntos.',
              text: 'Todas difíciles y todas correctas.',
            ),
            const SizedBox(height: 12),
            ArcadeButton(
              label: '¡Entendido!',
              height: 48,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: '•  '),
            TextSpan(
              text: '$title ',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            TextSpan(text: text),
          ],
        ),
        style: AppTextStyles.bodySm,
      ),
    );
  }
}
