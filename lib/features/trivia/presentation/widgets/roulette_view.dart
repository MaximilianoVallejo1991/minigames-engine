import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/arcade_button.dart';
import '../../../../core/widgets/arcade_card.dart';
import '../../../../core/widgets/game_body.dart';
import '../../../../core/widgets/pill.dart';
import '../../domain/game_rules.dart';
import '../../domain/models/models.dart';
import '../category_style.dart';
import 'score_board.dart';

/// Paso 2 de cada ronda: girar la ruleta para obtener la categoría.
class RouletteView extends StatelessWidget {
  const RouletteView({
    super.key,
    required this.categories,
    required this.difficulty,
    required this.isSpinning,
    required this.onSpin,
    required this.score,
    required this.questionNumber,
    required this.totalQuestions,
    this.result,
    this.message,
  });

  /// Duración de la animación del giro. El controlador espera un poco más
  /// antes de mostrar la pregunta (ver `revealDelay`).
  static const Duration spinDuration = Duration(milliseconds: 3200);

  final List<TriviaCategory> categories;
  final Difficulty difficulty;
  final bool isSpinning;
  final VoidCallback onSpin;
  final int score;
  final int questionNumber;
  final int totalQuestions;

  /// Categoría sorteada: la ruleta anima hasta dejarla bajo el puntero.
  final TriviaCategory? result;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final canSpin = !isSpinning;

    return GameBody(
      children: [
        ScoreBoard(
          score: score,
          questionNumber: questionNumber,
          totalQuestions: totalQuestions,
        ),
        Center(
          child: Pill(
            label: 'Nivel: ${difficulty.label} (+${GameRules.pointsFor(difficulty)} pts)',
            icon: Icons.verified_outlined,
            uppercase: false,
            background: AppColors.surfaceContainerLowest,
            foreground: AppColors.onSurface,
            border: AppColors.border,
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: AspectRatio(
              aspectRatio: 1,
              child: SpinningWheel(
                categories: categories,
                result: result,
                onSpin: canSpin ? onSpin : null,
              ),
            ),
          ),
        ),
        Center(
          child: Pill(
            label: result == null
                ? '¡${categories.length} categorías de impacto!'
                : '¡Salió ${result!.name}!',
            leading: Icon(
              result == null ? Icons.casino_outlined : result!.iconData,
              size: 18,
              color: result == null ? AppColors.onSurface : result!.color,
            ),
            uppercase: true,
            background: AppColors.surfaceContainerLowest,
            foreground: AppColors.onSurface,
            border: AppColors.border,
          ),
        ),
        const _InfoCard(),
        _CategoryStrip(categories: categories, highlighted: result),
        if (message != null)
          Text(message!, textAlign: TextAlign.center, style: AppTextStyles.bodySm),
      ],
      footer: ArcadeButton(
        label: isSpinning ? 'Girando…' : '¡Girar ruleta!',
        icon: Icons.sync_rounded,
        uppercase: true,
        height: 60,
        onPressed: canSpin ? onSpin : null,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return ArcadeCard(
      color: AppColors.surfaceContainerLow,
      radius: 28,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primaryFixedDim,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.touch_app_outlined, color: AppColors.onPrimaryFixed),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Giro del Ecosistema', style: AppTextStyles.headlineSm),
                SizedBox(height: 2),
                Text(
                  'Tocá el botón o el centro de la ruleta para descubrir la categoría de tu próxima pregunta.',
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

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.categories, this.highlighted});

  final List<TriviaCategory> categories;
  final TriviaCategory? highlighted;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final category in categories)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: highlighted == null || highlighted!.id == category.id ? 1 : 0.4,
            child: Pill(
              label: category.name,
              uppercase: false,
              leading: Icon(category.iconData, size: 16, color: category.color),
              background: AppColors.surfaceContainerLowest,
              foreground: AppColors.onSurface,
              border: highlighted?.id == category.id ? category.color : AppColors.border,
            ),
          ),
      ],
    );
  }
}

/// Ruleta de categorías con giro animado.
///
/// Cuando recibe un [result] gira varias vueltas y frena con esa categoría
/// bajo el puntero ámbar de arriba.
class SpinningWheel extends StatefulWidget {
  const SpinningWheel({
    super.key,
    required this.categories,
    this.result,
    this.onSpin,
  });

  final List<TriviaCategory> categories;
  final TriviaCategory? result;
  final VoidCallback? onSpin;

  @override
  State<SpinningWheel> createState() => _SpinningWheelState();
}

class _SpinningWheelState extends State<SpinningWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;
  late Animation<double> _rotation;
  final _random = math.Random();
  double _angle = 0;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this, duration: RouletteView.spinDuration);
    _rotation = AlwaysStoppedAnimation(_angle);
    if (widget.result != null) _spinTo(widget.result!);
  }

  @override
  void didUpdateWidget(covariant SpinningWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final result = widget.result;
    if (result != null && result.id != oldWidget.result?.id) _spinTo(result);
  }

  void _spinTo(TriviaCategory category) {
    final count = widget.categories.length;
    final index = widget.categories.indexWhere((c) => c.id == category.id);
    if (count == 0 || index < 0) return;

    final sweep = 2 * math.pi / count;
    // El segmento i se dibuja empezando arriba; su centro queda bajo el
    // puntero cuando la rueda giró -(i + 0.5) * sweep.
    final jitter = (_random.nextDouble() - 0.5) * sweep * 0.6;
    final target = _normalize(-(index + 0.5) * sweep + jitter);
    final current = _normalize(_angle);
    var delta = target - current;
    if (delta < 0) delta += 2 * math.pi;
    final end = _angle + 5 * 2 * math.pi + delta;

    _rotation = Tween<double>(begin: _angle, end: end).animate(
      CurvedAnimation(parent: _animation, curve: Curves.easeOutQuart),
    );
    _angle = end;
    _animation.forward(from: 0);
  }

  static double _normalize(double a) {
    final r = a % (2 * math.pi);
    return r < 0 ? r + 2 * math.pi : r;
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ruleta de categorías',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide;
          final hub = size * 0.27;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Aro exterior.
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(size * 0.035),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) => Transform.rotate(
                    angle: _rotation.value,
                    child: CustomPaint(
                      size: Size.square(size),
                      painter: _WheelPainter(widget.categories),
                    ),
                  ),
                ),
              ),
              // Centro "GIRAR".
              _Hub(size: hub, onTap: widget.onSpin),
              // Puntero.
              Positioned(
                top: -size * 0.03,
                child: _Pointer(size: size * 0.11),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.categories);

  final List<TriviaCategory> categories;

  @override
  void paint(Canvas canvas, Size size) {
    if (categories.isEmpty) return;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * math.pi / categories.length;
    const start = -math.pi / 2;

    for (var i = 0; i < categories.length; i++) {
      final category = categories[i];
      final a0 = start + i * sweep;
      canvas.drawArc(rect, a0, sweep, true, Paint()..color = category.color);

      // Ícono en el medio del segmento.
      final mid = a0 + sweep / 2;
      final iconCenter = center + Offset(math.cos(mid), math.sin(mid)) * radius * 0.66;
      final icon = category.iconData;
      final painter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            fontSize: radius * 0.2,
            color: Colors.white,
            shadows: const [Shadow(color: Color(0x40000000), offset: Offset(0, 2), blurRadius: 3)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(iconCenter.dx, iconCenter.dy);
      canvas.rotate(mid + math.pi / 2);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
      painter.dispose();
    }

    // Divisores blancos.
    final divider = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 3;
    for (var i = 0; i < categories.length; i++) {
      final a = start + i * sweep;
      canvas.drawLine(center, center + Offset(math.cos(a), math.sin(a)) * radius, divider);
    }

    // Brillo interior sutil.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.categories != categories;
}

class _Hub extends StatelessWidget {
  const _Hub({required this.size, this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Girar ruleta',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: AppColors.surfaceDim, offset: Offset(0, 5)),
                BoxShadow(color: Color(0x220F172A), blurRadius: 12),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.eco_rounded, color: AppColors.primaryDark, size: size * 0.3),
                Text(
                  'GIRAR',
                  style: AppTextStyles.labelCaps.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: size * 0.14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pointer extends StatelessWidget {
  const _Pointer({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.3,
      child: CustomPaint(painter: _PointerPainter()),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final r = w / 2;
    final path = Path()
      ..addOval(Rect.fromCircle(center: Offset(r, r), radius: r))
      ..moveTo(w * 0.12, r * 1.3)
      ..lineTo(r, size.height)
      ..lineTo(w * 0.88, r * 1.3)
      ..close();

    canvas.drawShadow(path, const Color(0xFF684000), 3, false);
    canvas.drawPath(path, Paint()..color = AppColors.secondaryContainer);
    canvas.drawCircle(Offset(r, r), r * 0.42, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(r, r), r * 0.22, Paint()..color = AppColors.secondaryContainer);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) => false;
}
