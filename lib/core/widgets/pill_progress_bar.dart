import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Barra de progreso tipo cápsula, con transición suave entre valores.
class PillProgressBar extends StatelessWidget {
  const PillProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.trackColor = AppColors.surfaceContainerHigh,
    this.height = 10,
    this.duration = const Duration(milliseconds: 400),
  });

  /// Entre 0 y 1.
  final double value;
  final Color color;
  final Color trackColor;
  final double height;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(height),
      ),
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: clamped),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => FractionallySizedBox(
          widthFactor: v,
          child: AnimatedContainer(
            duration: duration,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        ),
      ),
    );
  }
}
