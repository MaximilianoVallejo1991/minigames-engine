import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_brand.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/pill.dart';
import '../../core/widgets/pill_progress_bar.dart';

/// Carga inicial: logo animado + barra de progreso. Al terminar reemplaza
/// la pantalla por la que devuelve [next].
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.next,
    this.duration = const Duration(milliseconds: 2200),
  });

  final WidgetBuilder next;
  final Duration duration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _progress;
  late final AnimationController _orbit;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _progress = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder<void>(
              transitionDuration: const Duration(milliseconds: 400),
              pageBuilder: (context, _, __) => widget.next(context),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          );
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Pill(
                    label: 'Modo arcade • Aprender jugando',
                    leading: _Dot(),
                    background: AppColors.surfaceContainer,
                    foreground: AppColors.onSurface,
                  ),
                  const Spacer(),
                  _OrbitLogo(animation: _orbit),
                  const SizedBox(height: 28),
                  Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(text: AppBrand.gameNameLead),
                        TextSpan(
                          text: AppBrand.gameNameAccent,
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                    style: AppTextStyles.displayHero.copyWith(fontSize: 40, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppBrand.tagline,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) {
                      final value = Curves.easeInOut.transform(_progress.value);
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  value < 1 ? 'Preparando la experiencia…' : '¡Experiencia preparada!',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${(value * 100).round()}%',
                                style: AppTextStyles.counter.copyWith(
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          PillProgressBar(
                            value: value,
                            height: 14,
                            duration: Duration.zero,
                          ),
                        ],
                      );
                    },
                  ),
                  const Spacer(flex: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pan_tool_alt_outlined, size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Consejo: diseñado para jugar con una sola mano en tu celular',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySm.copyWith(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
    );
  }
}

/// Globo central con un anillo que gira y dos satélites (hoja y rayo).
class _OrbitLogo extends StatelessWidget {
  const _OrbitLogo({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    const size = 168.0;
    return SizedBox(
      width: size + 40,
      height: size + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo.
          Container(
            width: size + 40,
            height: size + 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryFixed.withValues(alpha: 0.45),
                  AppColors.primaryFixed.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x140F172A), blurRadius: 24, offset: Offset(0, 8))],
            ),
          ),
          RotationTransition(
            turns: animation,
            child: SizedBox.square(
              dimension: size - 16,
              child: CustomPaint(painter: _RingPainter()),
            ),
          ),
          Container(
            width: size - 52,
            height: size - 52,
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.public_rounded, size: 52, color: Colors.white),
          ),
          const Positioned(
            top: 18,
            right: 16,
            child: _Satellite(icon: Icons.eco_rounded, bg: AppColors.secondaryFixed, fg: AppColors.secondary),
          ),
          const Positioned(
            bottom: 34,
            left: 14,
            child: _Satellite(icon: Icons.bolt_rounded, bg: AppColors.tertiaryFixed, fg: AppColors.tertiary),
          ),
        ],
      ),
    );
  }
}

class _Satellite extends StatelessWidget {
  const _Satellite({required this.icon, required this.bg, required this.fg});

  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: fg),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const stroke = 9.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final arcRect = rect.deflate(stroke / 2);
    const segments = [
      (AppColors.primary, 0.0, 0.32),
      (AppColors.secondaryContainer, 0.36, 0.2),
      (AppColors.tertiaryContainer, 0.6, 0.22),
      (AppColors.surfaceContainerHighest, 0.86, 0.1),
    ];
    for (final (color, start, sweep) in segments) {
      canvas.drawArc(
        arcRect,
        -math.pi / 2 + start * 2 * math.pi,
        sweep * 2 * math.pi,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => false;
}
